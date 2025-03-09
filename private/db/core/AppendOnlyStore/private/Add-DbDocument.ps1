function Add-DbDocument {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [LiteDB.LiteDatabase] $Database,

        [Parameter(Mandatory)]
        $Collection,

        [Parameter(Mandatory, ValueFromPipeline)]
        [PSCustomObject]$Data,

        [string[]] $IgnoreFields = @(
            '_id', 'ContentId', 'VersionId', 'BundleId', 'UTC_Created', 'UTC_Updated',
            'Count', 'Length', '$ObjVer',
            '$ContentArcs', 'VersionArcs', '$BundleArcs', '$RecycledTime', '$BaseCol'),

        [switch] $NoVersionUpdate,

        [switch] $NoTimestampUpdate
    )

    # Validate that inbound object has a BundleId
    if($Data.PSObject.Properties.Name -notcontains "BundleId") {
        $Data = ($Data | Add-Member -MemberType NoteProperty -Name "BundleId" -Value ([Guid]::NewGuid()) -PassThru)
        $BundleIdPresent = $false
    }
    else {
        $BundleIdPresent = $true
    }


    # # Compute ContentId and VersionId
    if ($Data.PSObject.Properties.Name -notcontains '$Ref') {
        $ContentId = (Get-DataHash -DataObject $Data -FieldsToIgnore $IgnoreFields).Hash
        $VersionId = (Get-DataHash -DataObject @{ContentId = $ContentId; BundleId = $Data.BundleId} -FieldsToIgnore @('none')).Hash

        if ($Data.PSObject.Properties.Name -notcontains 'ContentId') {
            $Data = ($Data | Add-Member -MemberType NoteProperty -Name "ContentId" -Value $ContentId -PassThru) 
            $Data = ($Data | Add-Member -MemberType NoteProperty -Name "VersionId" -Value $VersionId -PassThru)
        }
        else {
            $Data.ContentId = $ContentId
            $Data.VersionId = $VersionId
        }
    }

    # # Check for existing record by VersionId
    $now = [DateTimeOffset]::UtcNow.ToUnixTimeMilliseconds()
    $existsInBundle = $Data.VersionId | Get-DbDocumentByVersionId -Database $Database -Collection $Collection
    
    if ($existsInBundle -and $BundleIdPresent) {
        $latestVersion = $existsInBundle.VersionId | Get-DbDocumentVersion -Database $Database -Collection $Collection -Latest
    
        if ((($existsInBundle.PSObject.Properties.Name -contains '$Ref') -or ($latestVersion.PSObject.Properties.Name -contains '$Ref'))) {
            if ($existsInBundle.VersionId -eq $latestVersion.'$ContentId') {
                $existsInBundle = $latestVersion
            }
            $skip = $true
        }
        elseif ($latestVersion.VersionId -eq $existsInBundle.VersionId) {
            $skip = $true
        }
        else {
            $Data = New-DbVersionIdRef -DbDocument $existsInBundle -Collection $Collection -RefCollection $Collection
            $skip = $false
        }
    }
    else {
        $skip = $false
    }
    
    if ($skip) {
        $outDoc = $existsInBundle.VersionId | Get-DbDocumentByVersionId -Database $Database -Collection $Collection
    }
    else {
        # Instert partially so LiteDB atuo-assigns _id
        $initialDoc = [PSCustomObject]@{
            ContentId = $Data.ContentId
            BundleId = $Data.BundleId
            VersionId = $Data.VersionId
        }
        $initialDoc | Add-LiteData -Collection $Collection

        # Retrieve the newly inserted doc from LiteDB using VersionId
        $found = $initialDoc.VersionId | Get-DbDocumentByVersionId -Database $Database -Collection $Collection

        if (-not $found) {
            throw "Could not retrieve newly inserted document in collection '$($Collection.Name)'`n  - Expected VersionId: $($initialDoc.VersionId).`n  - This may indicate an insertion faulure or query issue."
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
                if (-not $NoTimestampUpdate) {
                    $Data.UTC_Updated = $now
                }
            }
            else {
                $Data = ($Data | Add-Member -MemberType NoteProperty -Name "UTC_Created" -Value $now -PassThru)
                $Data = ($Data | Add-Member -MemberType NoteProperty -Name "UTC_Updated" -Value $now -PassThru)
            }


            # Validate that inbound has a Version integer
            if(-not $NoVersionUpdate) {
                # Update $ObjVer
                $ObjVer = ($Data.BundleId | Get-DbDocumentVersionsByBundle -Database $Database -Collection $Collection).Count

                if($Data.PSObject.Properties.Name -notcontains '$ObjVer') {
                    $Data = ($Data | Add-Member -MemberType NoteProperty -Name '$ObjVer' -Value $ObjVer -PassThru)
                }
                else {
                    $Data.'$ObjVer' = $ObjVer
                }
            }

            # Update stub litedb document with the Data object
            $Data | Set-LiteData -Collection $Collection
            $outDoc = $Data.VersionId | Get-DbDocumentByVersionId -Database $Database -Collection $Collection
        }
    }
    
    return $outDoc
}

