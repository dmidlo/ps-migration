function Add-DbDocument {
    <#
    .SYNOPSIS
    Inserts a record in two steps:
    1) Allow LiteDB to generate `_id`
    2) Update the record with `_id`

    .DESCRIPTION
    This function enforces a structured three-identifier system to support **database abstraction, 
    record versioning, and optimized lookups** within the pseudo-ORM layer.

    ### **Three-Identifier System**
    - **Guid**: Represents the *application-layer object identifier*. It is **not a record** but 
        uniquely identifies an **object** within the application. A `Guid` can be associated with 
        multiple **record versions** (`Hash` values), but it must always be linked to at least one 
        `Hash`. This ensures that the object remains identifiable across different database systems.
        
    - **Hash**: Represents the *unique record identifier*. Each `Hash` corresponds **one-to-one** 
        with a `Guid`, meaning that every specific **version of an object** has exactly one `Hash`. 
        This allows for **deduplication and version tracking**, ensuring that different states of 
        an object are distinguishable.

    - **_id**: A LiteDB-generated primary key, used **only as an optimization tool**. The `_id`
        exists purely to facilitate **efficient lookups** within LiteDB and is **not relied upon** 
        for application-level identity or relationships.

    ### **Double-Lookup Requirement**
    To ensure consistency and correctness, this function **performs two explicit lookups**:
    1) **Pre-insertion duplicate check**: Searches for an existing record using `Hash` to 
        prevent redundant inserts.
    2) **Post-insertion retrieval**: Finds the newly inserted record using `hash` to acquire `_id`, 
        which is required for subsequent updates.

    This ensures that:
    - **Each application object (`Guid`) can have multiple versions (`Hash`)**, but each version 
        remains unique.
    - **Records remain database-agnostic** by abstracting identity management away from `_id`.
    - **LiteDB's `_id` is leveraged purely for internal efficiency**, without affecting 
        business logic.

    ### **PARAMETERS**
    - **`-Connection`** `[LiteDB.LiteDatabase]` *(Mandatory)*  
    The active LiteDB connection object.

    - **`-CollectionName`** `[string]` *(Mandatory)*  
    The name of the collection where the document will be stored.

    - **`-Data`** `[hashtable]` *(Mandatory)*  
    The document to insert. If `Guid` is not present in the input data, the function will generate 
    one automatically.

    - **`-IgnoreFields`** `[string[]]` *(Optional)*  
    Specifies fields to be **excluded** from the hash computation.  
    - Defaults to ignoring internal metadata fields: `_id`, `Guid`, `Hash`, `UTC_Created`, `UTC_Updated`.  
    - Allows the caller to **customize deduplication behavior** by controlling which fields contribute to `Hash`.  
    - Usage example:  
        ```powershell
        Add-DbDocument -Connection $db -CollectionName 'Domains' -Data $record -IgnoreFields @('Timestamp', 'Comments')
        ```

    .EXAMPLE
    $record = @{
        FriendlyId = 'DOM-ALPHA'
        FQDN       = 'mydomain.local'
    }
    Add-DbDocument -Connection $db -CollectionName 'Domains' -Data $record
    #>

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [LiteDB.LiteDatabase] $Database,

        [Parameter(Mandatory)]
        $Collection,

        [Parameter(Mandatory, ValueFromPipeline)]
        [PSCustomObject]$Data,

        [string[]] $IgnoreFields = @('_id', 'Guid', 'Hash', 'UTC_Created', 'UTC_Updated', 'Count', 'Length', 'Collection', 'RefHash')
    )

    # Validate that inbound object has a Guid
    if($Data.PSObject.Properties.Name -notcontains "Guid") {
        $Data = ($Data | Add-Member -MemberType NoteProperty -Name "Guid" -Value ([Guid]::NewGuid()) -PassThru)
    }

    # # Compute hash
    if ($Data.PSObject.Properties.Name -notcontains '$Ref') {
        $Hash = (Get-DataHash -DataObject $Data -FieldsToIgnore $IgnoreFields).Hash
        if ($Data.PSObject.Properties.Name -notcontains 'Hash') {
           $Data = ($Data | Add-Member -MemberType NoteProperty -Name "Hash" -Value $Hash -PassThru) 
        }
        else {
            $Data.Hash = $Hash
        }
    }

    # # Check for existing record by hash
    $now = [DateTimeOffset]::UtcNow.ToUnixTimeMilliseconds()
    $exists = $Data.Hash | Get-DbDocumentByHash -Database $Database -Collection $Collection
    
    if ($exists) {
        $latestVersion = $exists.Hash | Get-DbDocumentVersion -Database $Database -Collection $Collection -Latest
    
        if ((($exists.PSObject.Properties.Name -contains '$Ref') -or ($latestVersion.PSObject.Properties.Name -contains '$Ref'))) {
            if ($exists.Hash -eq $latestVersion.'$Hash') {
                $exists = $latestVersion
            }
            $skip = $true
        }
        elseif ($latestVersion.Hash -eq $exists.Hash) {
            $skip = $true
        }
        else {
            $Data = New-DbHashRef -DbDocument $exists -Collection $Collection
            $skip = $false
        }
    }
    
    if ($skip) {
        $outDoc = $exists.Hash | Get-DbDocumentByHash -Database $Database -Collection $Collection
    }
    else {
        # Instert partially so LiteDB atuo-assigns _id
        $initialDoc = [PSCustomObject]@{
            Hash = $Data.Hash
            Guid = $Data.Guid
        }
        $initialDoc | Add-LiteData -Collection $Collection

        # Retrieve the newly inserted doc from LiteDB using Hash
        $found = $initialDoc.Hash | Get-DbDocumentByHash -Database $Database -Collection $Collection

        if (-not $found) {
            throw "Could not retrieve newly inserted document in collection '$($Collection.Name)'`n  - Expected Hash: $($initialDoc.Hash).`n  - This may indicate an insertion faulure or query issue."
        }

        if ($found._id -is [System.Collections.ObjectModel.Collection[PSObject]]) {
            throw "Unhandled Type found in _id property."
        }
        elseif (-not $found._id) {
            throw "LiteDB returned a document but one without an _id. Possible database inconsistency."
        }
        else {
            # Now that we have the LiteDB-Generated _id, instert it into the Data object
            $Data = ($Data | Add-Member -MemberType NoteProperty -Name "_id" -Value $found._id -Force -PassThru)

            # Update Timestamps
            if($Data.PSObject.Properties.Name -contains "UTC_Created") {
                $Data.UTC_Updated = $now
            }
            else {
                $Data = ($Data | Add-Member -MemberType NoteProperty -Name "UTC_Created" -Value $now -PassThru)
                $Data = ($Data | Add-Member -MemberType NoteProperty -Name "UTC_Updated" -Value $now -PassThru)
            }

            # Update stub litedb document with the Data object
            $Data | Set-LiteData -Collection $Collection
            $outDoc = $Data.Hash | Get-DbDocumentByHash -Database $Database -Collection $Collection
        }
    }
    
    return $outDoc
}

