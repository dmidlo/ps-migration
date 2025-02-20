function Set-dbComponent {
<#
.SYNOPSIS
    Creates, reads, updates, or deletes a "dbComponent" record in LiteDB.

.DESCRIPTION
    This cmdlet serves as the **base class** for all “component-like” objects
    in the new object model (for example, `dbChassis` and `dbModule`). It 
    supports four operations (CRUD):
    
    - **Create**: Inserts a new document (generates `Guid` if not supplied).
    - **Read**:   Retrieves an existing document by `_id`, `Hash`, or `Guid`.
    - **Update**: Updates an existing document's fields.
    - **Delete**: Removes an existing document from the database.
    - **Upsert**: Convenience operation that either creates or updates 
                  automatically, leveraging the `Add-DbDocument` logic.

    The cmdlet also introduces flags like:
    - **IsTemp**: If `$true`, the component is placed in a "temp" collection.
    - **IsDeleted**: If `$true`, the component can be moved to a "deleted" 
        collection, or flagged as removed, depending on your data lifecycle.

.PARAMETER Connection
    Mandatory. The active [LiteDB.LiteDatabase] connection.

.PARAMETER Operation
    Specifies which CRUD operation to perform. Defaults to `Upsert`.

.PARAMETER _id
    (Optional) The LiteDB `_id` if known (for Update/Read/Delete). 
    Ignored on Create unless you explicitly want to control `_id`.

.PARAMETER Guid
    (Optional) A stable unique identifier at the application level.

.PARAMETER Hash
    (Optional) The deduplicating hash value.

.PARAMETER ComponentType
    Specifies whether this object is a generic `Component`, a `Chassis`, or a `Module`.
    Defaults to `Component` if not provided.

.PARAMETER IsTemp
    If `$true`, the document is stored in a temporary collection (by default "Temp" 
    or you can override with `-TempDestCollection`).

.PARAMETER TempDestCollection
    If `IsTemp` is `$true`, specifies which "temp-like" collection to use. 
    Defaults to `"Temp"` if not specified.

.PARAMETER IsDeleted
    If `$true`, signals that the document should be removed or placed into a 
    "deleted" collection. The handling depends on your lifecycle policy.

.PARAMETER DeletedSrcCollection
    When `IsDeleted` is `$true`, you may want to track which “source” collection 
    it came from. This is used if you want to physically relocate it (not shown here).

.PARAMETER META_UTCCreated, META_UTCUpdated
    Optional timestamps. If not supplied, `META_UTCCreated` is set to the current 
    UTC time (in ms) on creation, and `META_UTCUpdated` is always set to the 
    current UTC time for any operation.

.PARAMETER SerialNumber, FriendlyName, RelativeIndex
    Example fields you might track on a component. 

.PARAMETER Properties
    A hashtable that may be piped in or passed to supply additional fields. 
    If a key in `Properties` collides with a direct parameter (e.g. `FriendlyName`),
    the direct parameter takes precedence.

.EXAMPLE
# CREATE
Set-dbComponent -Connection $db -Operation Create -FriendlyName "TestComponent"

.EXAMPLE
# READ (by Guid)
Set-dbComponent -Connection $db -Operation Read -Guid "A-GUID-HERE"

.EXAMPLE
# UPDATE (by _id)
Set-dbComponent -Connection $db -Operation Update -_id "60f8f07d1c547627e487df01" -FriendlyName "Updated"

.EXAMPLE
# DELETE
Set-dbComponent -Connection $db -Operation Delete -Guid "A-GUID-HERE"

.EXAMPLE
# UPSERT
Set-dbComponent -Connection $db -FriendlyName "UpsertExample"

#>
    [CmdletBinding()]
    param(
        # Which LiteDB connection to use
        [Parameter(Mandatory)]
        [LiteDB.LiteDatabase]
        $Connection,

        # Which operation we want to perform (CRUD or Upsert).
        [ValidateSet("Create","Read","Update","Delete","Upsert")]
        [string]
        $Operation = "Upsert",

        # LiteDB primary key (optional, usually assigned automatically).
        [string]$_id,

        # The application-level stable identifier
        [string]$Guid,

        # The deduplication hash
        [string]$Hash,

        # Timestamps (raw Unix time in milliseconds).
        [int]$META_UTCCreated,
        [int]$META_UTCUpdated,

        # The "type" of component
        [dbComponentType]$ComponentType = [dbComponentType]::Component,

        # If true, this record goes into a temporary staging collection
        [bool]$IsTemp,

        # Which collection to use if IsTemp is true
        [string]$TempDestCollection = "Temp",

        # If true, signals that the record should be deleted or "soft-deleted"
        [bool]$IsDeleted,

        # Original or “source” collection if we do any relocation logic
        [string]$DeletedSrcCollection = "dbComponents",

        # Example domain fields
        [string]$SerialNumber,
        [string]$FriendlyName,
        [int]$RelativeIndex,

        # Additional or pipeline-supplied properties
        [Parameter(ValueFromPipeline)]
        [hashtable]$Properties
    )

    begin {
        # A small helper for current UTC ms
        $now = [DateTimeOffset]::UtcNow.ToUnixTimeMilliseconds()

        function Get-TargetCollection {
            if ($IsTemp) { return "Temp" }
            elseif ($IsDeleted) { return 'RecycleBin' }
            else { return 'Components' }
        }

        # Simple “merge” logic: if a key in $Properties collides with an explicit param,
        # we prefer the explicit parameter’s value.
        function Build-FinalObject {
            param(
                [hashtable]$Existing,
                [hashtable]$IncomingProps
            )
            $final = [ordered]@{}

            # Start with existing (if any)
            if ($Existing) {
                foreach ($k in $Existing.Keys) {
                    $final[$k] = $Existing[$k]
                }
            }

            # Merge IncomingProps next
            if ($IncomingProps) {
                foreach ($k in $IncomingProps.Keys) {
                    $final[$k] = $IncomingProps[$k]
                }
            }

            return $final
        }
    }

    process {
        $collectionName = Get-TargetCollection

        switch ($Operation) {

            #region CREATE
            "Create" {
                # We'll build a fresh hashtable. We ignore _id and Hash if provided explicitly 
                # because Add-DbDocument will generate `_id` and compute Hash automatically.

                if (-not $Guid) { $Guid = [Guid]::NewGuid().ToString() }

                # Start from scratch
                $component = [ordered]@{
                    Guid          = $Guid
                    ComponentType = $ComponentType
                    SerialNumber  = $SerialNumber
                    FriendlyName  = $FriendlyName
                    RelativeIndex = $RelativeIndex
                    IsTemp        = $IsTemp
                    IsDeleted     = $IsDeleted
                }

                # Timestamps
                if ($META_UTCCreated) {
                    $component["META_UTCCreated"] = $META_UTCCreated
                    $component["META_UTCUpdated"] = $now
                }
                else {
                    # brand new doc
                    $component["META_UTCCreated"] = $now
                    $component["META_UTCUpdated"] = $now
                }

                # Merge in $Properties
                if ($Properties) {
                    foreach ($key in $Properties.Keys) {
                        $component[$key] = $Properties[$key]
                    }
                }

                # Insert (Add-DbDocument does an upsert-style but returns the new doc)
                $result = Add-DbDocument -Connection $Connection -CollectionName $collectionName -Data $component
                Write-Output $result
            }
            #endregion

            #region READ
            "Read" {
                # We must have at least one unique identifier to do the read
                if (-not $_id -and -not $Hash -and -not $Guid) {
                    throw "READ operation requires either `_id`, `Hash`, or `Guid`."
                }

                # Build the where clause
                if ($Hash) {
                    $where = "Hash = '$Hash'"
                }
                elseif ($Guid) {
                    $where = "Guid = '$Guid'"
                }
                else {
                    # _id must be a string for LiteDB, but typically it's stored as an ObjectId.
                    # If we store _id as a string, you can do `_id = 'some-string'`.
                    $where = "_id = $_id"
                }

                $found = Find-LiteDBDocument -Collection $collectionName -Connection $Connection -Select "*" -Where $where -As PSObject
                if ($found) {
                    Write-Output $found
                }
                else {
                    Write-Warning "No document found in collection '$collectionName' matching: $where"
                }
            }
            #endregion

            #region UPDATE
            "Update" {
                # For an update, we also require some identifying field
                if (-not $_id -and -not $Hash -and -not $Guid) {
                    throw "UPDATE operation requires `_id`, `Hash`, or `Guid` to locate the document."
                }

                # 1) Read existing doc
                if ($Hash) {
                    $where = "Hash = '$Hash'"
                }
                elseif ($Guid) {
                    $where = "Guid = '$Guid'"
                }
                else {
                    $where = "_id = $_id"
                }
                $existing = Find-LiteDBDocument -Collection $collectionName -Connection $Connection -Select "*" -Where $where -As PSObject

                if (-not $existing) {
                    throw "No existing document found in '$collectionName' with $where. Cannot update."
                }

                # 2) Convert the existing doc to a hashtable for merging
                $existingHash = @{}
                foreach ($prop in $existing.PSObject.Properties) {
                    $existingHash[$prop.Name] = $prop.Value
                }

                # 3) Build a new hashtable from existing + pipeline properties
                $component = Build-FinalObject -Existing $existingHash -IncomingProps $Properties

                # 4) Overwrite with direct parameters if provided
                if ($Guid)         { $component["Guid"]         = $Guid }
                if ($SerialNumber) { $component["SerialNumber"] = $SerialNumber }
                if ($FriendlyName) { $component["FriendlyName"] = $FriendlyName }
                if ($RelativeIndex) { $component["RelativeIndex"] = $RelativeIndex }
                
                $component["IsTemp"]    = $IsTemp
                $component["IsDeleted"] = $IsDeleted

                # Timestamps
                $component["META_UTCUpdated"] = $now
                # Keep the existing creation timestamp if not explicitly provided
                if ($META_UTCCreated) {
                    $component["META_UTCCreated"] = $META_UTCCreated
                }

                if ($ComponentType) {
                    $component["ComponentType"] = $ComponentType
                }

                # 5) Upsert updated doc
                $result = Add-DbDocument -Connection $Connection -CollectionName $collectionName -Data $component
                Write-Output $result
            }
            #endregion

            #region DELETE
            "Delete" {
                # For a delete, we must also have some identifier
                if (-not $_id -and -not $Hash -and -not $Guid) {
                    throw "DELETE operation requires `_id`, `Hash`, or `Guid` to locate the document."
                }

                # Find the existing doc
                if ($Hash) {
                    $where = "Hash = '$Hash'"
                }
                elseif ($Guid) {
                    $where = "Guid = '$Guid'"
                }
                else {
                    $where = "_id = $_id"
                }
                $existing = Find-LiteDBDocument -Collection $collectionName -Connection $Connection -Select "*" -Where $where -As PSObject

                if (-not $existing) {
                    Write-Warning "No document found for deletion in '$collectionName' with $where"
                }
                else {
                    # If you want a "soft delete," you could simply set IsDeleted=true
                    # and re-upsert, or physically move the record. The example below
                    # does a *hard delete* from the current collection.

                    Remove-LiteDBDocument -Collection $collectionName -Connection $Connection -ID $existing._id
                    Write-Verbose "Document with _id = $($existing._id) removed from '$collectionName'."
                }
            }
            #endregion

            #region UPSERT
            "Upsert" {
                # This is effectively a "create if not exists, otherwise update."
                # `Add-DbDocument` already implements a dedup check by Hash, 
                # so if the doc's Hash is identical, it returns the existing doc.
                # If there's no match, it inserts a new one.

                # Build a new doc from scratch + $Properties
                # (Similar to CREATE, but we do allow user-supplied `_id`, `Hash`, etc.)
                $component = [ordered]@{
                    _id            = $_id
                    Guid           = $Guid
                    Hash           = $Hash
                    ComponentType  = $ComponentType
                    SerialNumber   = $SerialNumber
                    FriendlyName   = $FriendlyName
                    RelativeIndex  = $RelativeIndex
                    IsTemp         = $IsTemp
                    IsDeleted      = $IsDeleted
                }

                # Timestamps
                if ($META_UTCCreated) {
                    $component["META_UTCCreated"] = $META_UTCCreated
                    $component["META_UTCUpdated"] = $now
                }
                else {
                    $component["META_UTCCreated"] = $now
                    $component["META_UTCUpdated"] = $now
                }

                # Merge in $Properties
                if ($Properties) {
                    foreach ($key in $Properties.Keys) {
                        $component[$key] = $Properties[$key]
                    }
                }

                # Call Add-DbDocument for upsert
                $result = Add-DbDocument -Connection $Connection -CollectionName $collectionName -Data $component
                Write-Output $result
            }
            #endregion
        }
    }
    end { }
}

