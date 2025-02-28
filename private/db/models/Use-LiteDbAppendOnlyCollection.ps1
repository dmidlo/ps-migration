# TODO [ ] - This badboy will end up being the workhorse cmdlet where proper parameter
#            sets will be built out to support the underlying class. Presently it is
#               a literal duplicate of its New- counterpart as a placeholder. It should
#               support Pipeline input. Parameterset validation for method parameter types.
#               When a pscustomobject is inbound, it should validate by prop and when it does
#               it should emit an object of the same kind. it should then likely require 
#               preconstructed connectionstring and/or database objects and (maybe?) collections.
#               It should also accept an -Store param (in all parametersets) which provides an 
#               existing store generated again, by its New- counterpart, access to pipeline features.
function Use-LiteDbAppendOnlyCollection {
    <#
    .SYNOPSIS
    Creates a new append-only LiteDB store object for journaling/versioned documents.

    .DESCRIPTION
    This function constructs a [LiteDbAppendOnlyCollection] class instance, which provides
    a forward-only (append-only) interface to LiteDB collections. Each instance
    references a single collection within a specific [LiteDB.LiteDatabase].

    The returned object exposes several methods (similar to a CRD interface):
    
      1. Create($Data, $IgnoreFields)
         - Inserts a new document using Add-DbDocument under the hood.
         - Parameters:
             * $Data         : A [PSCustomObject] representing the document to insert.
             * $IgnoreFields : A string array of fields to exclude from the deduplication hash.
         - Returns: The newly inserted (or deduplicated) document as a PSCustomObject.

      2. ReadAll([switch] $ResolveRefs)
         - Fetches all documents in the store’s collection using Get-DbDocumentAll.
         - If $ResolveRefs is used, it attempts to resolve any $Ref references into their linked documents.

      3. ReadByHash($Hash, [switch] $ResolveRefs)
         - Fetches a document by its Hash (the application-level unique version ID).
         - If multiple matches are found (unexpected), returns the first with a warning.
         - If $ResolveRefs is used, it attempts to resolve any $Ref references.

      4. ReadById($Id, [switch] $ResolveRefs)
         - Looks up a document by its LiteDB _id field.
         - If multiple matches are found (unexpected), returns the first with a warning.
         - If $ResolveRefs is used, it attempts to resolve any $Ref references.

      5. ReadVersion($Hash, [switch] $Next, $Previous, $Latest, $Original, [switch] $ResolveRefs)
         - Returns the next, previous, latest, or original version for a given Hash.
         - Uses Get-DbDocumentVersion internally to navigate the version chain.
         - Example:
             * $store.ReadVersion($hash, $Next=$true)     # Next version
             * $store.ReadVersion($hash, $Previous=$true) # Previous version
             * $store.ReadVersion($hash, $Latest=$true)   # Latest version
             * $store.ReadVersion($hash, $Original=$true) # Oldest/original version

      6. Delete($Hash)
         - Throws an error because this is an append-only (forward-only) system with no delete.

    .PARAMETER Database
    The active [LiteDB.LiteDatabase] instance which represents your LiteDB data file or in-memory database.

    .PARAMETER Collection
    The name of the LiteDB collection this store will manage.

    .EXAMPLE
    # EXAMPLE 1: Create a new store for the 'Domains' collection
    $db = New-Object LiteDB.LiteDatabase("Filename=MyDatabase.db;")
    $store = New-LiteDbAppendOnlyCollection -Database $db -Collection 'Domains'
    $store.ReadAll()

    .EXAMPLE
    # EXAMPLE 2: Insert a new document using the Create() method
    $db = New-Object LiteDB.LiteDatabase("Filename=MyDatabase.db;")
    $store = New-LiteDbAppendOnlyCollection -Database $db -Collection 'Domains'

    # Prepare data
    $record = [PSCustomObject]@{
        FriendlyId = 'DOM-ALPHA'
        FQDN       = 'mydomain.local'
    }

    # Insert/append new version
    $newDoc = $store.Create($record, @('_id','Guid','Hash','UTC_Created','UTC_Updated'))
    Write-Host "Inserted doc Hash: $($newDoc.Hash)"

    .EXAMPLE
    # EXAMPLE 3: Retrieve all documents in the collection
    $db = New-Object LiteDB.LiteDatabase("Filename=MyDatabase.db;")
    $store = New-LiteDbAppendOnlyCollection -Database $db -Collection 'Domains'

    $allDocs = $store.ReadAll()
    Write-Host "Found $($allDocs.Count) documents."

    .EXAMPLE
    # EXAMPLE 4: Retrieve a document by its Hash
    $db = New-Object LiteDB.LiteDatabase("Filename=MyDatabase.db;")
    $store = New-LiteDbAppendOnlyCollection -Database $db -Collection 'Domains'

    $doc = $store.ReadByHash('ABC123HASH')
    if ($doc) {
        Write-Host "Found doc with Hash ABC123HASH, GUID: $($doc.Guid)"
    } else {
        Write-Host "No document found with Hash 'ABC123HASH'."
    }

    .EXAMPLE
    # EXAMPLE 5: Retrieve a document by its LiteDB _id
    $db = New-Object LiteDB.LiteDatabase("Filename=MyDatabase.db;")
    $store = New-LiteDbAppendOnlyCollection -Database $db -Collection 'Domains'

    $someDoc = $store.ReadById(42) # or a string, or [LiteDB.ObjectId] depending on your _id type

    .EXAMPLE
    # EXAMPLE 6: Retrieve version history
    $db = New-Object LiteDB.LiteDatabase("Filename=MyDatabase.db;")
    $store = New-LiteDbAppendOnlyCollection -Database $db -Collection 'Domains'

    # Suppose you know a doc's Hash
    $hash = 'ABC123HASH'
    # Get the next version
    $nextVer = $store.ReadVersion($hash, $Next = $true)
    # Get the previous version
    $prevVer = $store.ReadVersion($hash, $Previous = $true)
    # Get the latest version
    $latestVer = $store.ReadVersion($hash, $Latest = $true)
    # Get the oldest version
    $origVer = $store.ReadVersion($hash, $Original = $true)

    .EXAMPLE
    # EXAMPLE 7: Attempt to delete a document (throws error)
    $db = New-Object LiteDB.LiteDatabase("Filename=MyDatabase.db;")
    $store = New-LiteDbAppendOnlyCollection -Database $db -Collection 'Domains'

    $store.Delete('ABC123HASH') # => Will throw "Delete not implemented..."

    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [LiteDB.LiteDatabase] $Database,

        [Parameter(Mandatory)]
        $Collection
    )

    process {
        return [LiteDbAppendOnlyCollection]::new($Database, $Collection)
    }
}
