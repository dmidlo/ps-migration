function Add-DbDocument {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [LiteDB.LiteDatabase] $Connection,

        [Parameter(Mandatory)]
        [string] $CollectionName,

        [Parameter(Mandatory)]
        [hashtable] $Data
    )
    <#
    .SYNOPSIS
    Inserts a record in two steps: 
      1) Let LiteDB generate _id 
      2) Update record with CompositeId (combining _id and Guid).

    .DESCRIPTION
    This function demonstrates a “hybrid” approach: 
      - If $Data does NOT contain Guid, it generates one.
      - Calls Add-LiteDBDocument so LiteDB assigns an _id. 
      - Then retrieves that inserted record, sets CompositeId, and re-saves via Upsert-LiteDBDocument.
      - Updates a Hash

    .EXAMPLE
    $record = @{
        FriendlyId = 'DOM-ALPHA'
        FQDN       = 'mydomain.local'
    }
    Add-DbDocument -Connection $db -CollectionName 'Domains' -Data $record
    #>

    # Generate Guid if missing
    if (-not $Data.ContainsKey('Guid')) {
        $Data.Guid = [Guid]::NewGuid()
    }

    # # compute hash
    # #     The existing function expects a PSCustomObject, so let's create one:
    $Data['Hash'] = Get-DataHash -DataObject $Data -FieldsToIgnore @(
        '_id', 'Guid', 'Id', 'Hash', 'META_UTCCreated', 'META_UTCUpdated', "Count", "Length"
    )

    $exists = Find-LiteDBDocument -Collection $CollectionName `
         -Where "Hash = '$($Data['Hash'])'" `
         -Connection $Connection -Select "*"

    if ($exists) {
        $finalDoc = $exists
    }
    else {

        # NOTE: We do NOT assign `_id` ourselves, so LiteDB can generate it.

        # Insert partially so LiteDB auto-assigns _id
        $initialDoc = [PSCustomObject]$Data
        $initialBson = $initialDoc | ConvertTo-LiteDbBSON
        Add-LiteDBDocument -Collection $CollectionName -Document $initialBson -Connection $Connection

        # Retrieve the newly inserted doc from LiteDB 
        #     We'll look it up by Guid; something guaranteed unique.
        $GuidSafe = $Data.Guid.ToString().Replace("'", "''")        # escape single quotes for LiteDB expression
        
        $found = Find-LiteDBDocument -Collection $CollectionName `
            -Where "Guid = '$GuidSafe'" `
            -Connection $Connection -As PSObject -Select "*"

        if (-not $found) {
            throw "Could not retrieve newly inserted doc in $CollectionName (Guid = $($Data.Guid))"
        }

        # Now that we have the LiteDB-generated _id, build the CompositeId
        $Data['_id'] = $found._id
        $Data['Id'] =  "$($Data['_id'])-$($Data.Guid)"
        $Data['VerInt'] = 0

        # # # Upsert with the new CompositeId + Hash
        $finalDoc = [PSCustomObject]$Data
        $finalBson = $finalDoc | ConvertTo-LiteDbBSON
        Update-LiteDBDocument -Collection $CollectionName -ID $finalDoc._id -Document $finalBson -Connection $Connection
    }

    return $finalDoc
}
