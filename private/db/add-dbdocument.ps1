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
    - Defaults to ignoring internal metadata fields: `_id`, `Guid`, `Hash`, `META_UTCCreated`, `META_UTCUpdated`.  
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
        [LiteDB.LiteDatabase] $Connection,

        [Parameter(Mandatory)]
        [string] $CollectionName,

        [Parameter(Mandatory, ValueFromPipeline)]
        [hashtable] $Data,

        [string[]] $IgnoreFields = @('_id', 'Guid', 'Hash', 'META_UTCCreated', 'META_UTCUpdated', 'Count', 'Length', 'Collection', 'RefHash')
    )

    # Generate Guid if missing
    if (-not $Data.ContainsKey('Guid')) {
        $Data.Guid = [Guid]::NewGuid()
    }

    # Compute hash
    if ($Data.Keys -notcontains '$Ref') {
        $Data['Hash'] = (Get-DataHash -DataObject $Data -FieldsToIgnore $IgnoreFields).Hash
    }

    # Check for existing record by hash
    $now = [DateTimeOffset]::UtcNow.ToUnixTimeMilliseconds()
    $exists = Get-DbDocumentByHash -Connection $Connection -CollectionName $CollectionName -Hash $Data.Hash
    
    if ($exists) {
        $latestVersion = $exists.Hash | Get-DbDocumentVersion -Connection $Connection -CollectionName $CollectionName -Latest
        Write-Host "==================== Preamble"
        write-host $exists
        Write-host $exists.GetType()
        Write-Host $exists.Keys
        Write-host $latestVersion
        Write-Host $latestVersion.GetType()
        Write-Host $latestVersion.Keys

        if ((($exists.Keys -contains '$Ref') -or ($latestVersion.Keys -contains '$Ref'))) {
            Write-Host "++++++++++++++++++ REF"
            if ($exists.Hash -eq $latestVersion.'$Hash') {
                $exists = $latestVersion
            }
            $skip = $true
        }
        elseif ($latestVersion.Hash -eq $exists.Hash) {
            Write-Host "++++++++++++++++++ Lastest"
                Write-Host $latestVersion.Hash
                Write-Host $exists.Hash
                $skip = $true
        }
        else {
            Write-Host "++++++++++++++++++ New DbHashRef"
                Write-Host $exists.Hash
                Write-Host $exists
                Write-Host $latestVersion.Hash
                Write-Host $latestVersion
                $Data = $exists | New-DbHashRef
                $skip = $false
        }
    }
    
    if ($skip){        
        $outDoc = Normalize-Data -InputObject $exists -IgnoreFields @("none")
    }
    else {
        # Insert partially so LiteDB auto-assigns _id
        $PartialDoc = [ordered]@{
            Hash = $Data['Hash']
            Guid = $Data['Guid']
        }
        $initialDoc = [PSCustomObject]$PartialDoc
        $initialBson = $initialDoc | ConvertTo-LiteDbBSON
        Add-LiteDBDocument -Collection $CollectionName -Document $initialBson -Connection $Connection | Out-Null

        # Retrieve the newly inserted doc from LiteDB using Hash
        $found = Get-DbDocumentByHash -Connection $Connection -CollectionName $CollectionName -Hash $Data.Hash

        if (-not $found) {
            throw "Could not retrieve newly inserted document in collection '$CollectionName'. Expected Hash: $($Data.Hash). 
            This may indicate an insertion failure or a query issue."
        }
        
        
        # Ensure `_id` was assigned
        if ($found._id -is [System.Collections.ObjectModel.Collection[PSObject]] ) {
            Write-host "`n ++ Found"
            Write-Host $found._id
            Write-Host ($found._id).GetType().Name
            Write-Host $found._id.ToString()
            Write-Host "`n"
            throw "Unhandled Type found in _id property."

        }
        elseif ((-not $found._id)) {
            throw "LiteDB returned a document but without an _id. Possible database inconsistency."
        }
        else {
            # Now that we have the LiteDB-generated _id, insert it into the Data object.
            $Data['_id'] = $found._id
        }

        # Update Timestamps
        if ($Data['META_UTCCreated']) {
            $Data['META_UTCUpdated'] = $now
        }
        else {
            $Data['META_UTCCreated'] = $now
            $Data['META_UTCUpdated'] = $now
        }

        # Upsert with the new CompositeId + Hash
        $finalBson = ([PSCustomObject]$Data) | ConvertTo-LiteDbBSON
        Update-LiteDBDocument -Collection $CollectionName -ID $Data['_id'] -Document $finalBson -Connection $Connection | Out-Null

        $outDoc = Normalize-Data -InputObject $Data -IgnoreFields @("none")
    }
    
    return $outDoc
}

