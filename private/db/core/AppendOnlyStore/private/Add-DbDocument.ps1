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
            '_id', 'ContentMark', 'VersionId', 'BundleId', 'UTC_Created', 'UTC_Updated',
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
        if ($Data.BundleId -eq $null) {
            $Data.BundleId = ([Guid]::NewGuid())
            $BundleIdPresent = $false
        }
        else {
            $BundleIdPresent = $true
        }
    }


    # # Compute ContentMark and VersionId
    if ($Data.PSObject.Properties.Name -notcontains '$Ref') {
        $ContentMark = (Get-DataHash -DataObject $Data -FieldsToIgnore $IgnoreFields).Hash
        $VersionId = (Get-DataHash -DataObject @{ContentMark = $ContentMark; BundleId = $Data.BundleId} -FieldsToIgnore @('none')).Hash

        if ($Data.PSObject.Properties.Name -notcontains 'ContentMark') {
            $Data = ($Data | Add-Member -MemberType NoteProperty -Name "ContentMark" -Value $ContentMark -PassThru) 
            $Data = ($Data | Add-Member -MemberType NoteProperty -Name "VersionId" -Value $VersionId -PassThru)
        }
        else {
            $Data.ContentMark = $ContentMark
            $Data.VersionId = $VersionId
        }
    }

    # # Check for existing record by VersionId
    $now = [DateTimeOffset]::UtcNow.ToUnixTimeMilliseconds()
    if ($Data.PSObject.Properties.Name -notcontains '$Ref') {
        $existsInBundle = $Data.VersionId | Get-DbDocumentByVersion -Database $Database -Collection $Collection
        $wasRef = $false
    }
    elseif ($Data.PSObject.Properties.Name -contains '$VersionId') {
        $existsInBundle = $Data.'$VersionId' | Get-DbDocumentByVersion -Database $Database -Collection $Collection
        $wasRef = $true
    }
    
    if ($existsInBundle -and $BundleIdPresent) {
        $latestVersion = $existsInBundle.VersionId | Get-DbDocumentVersion -Database $Database -Collection $Collection -Latest
    
        $existsProps = $existsInBundle.PSCustom.Properties.Name
        $latestProps = $latestVersion.PSObject.Properties.Name
        if ((($existsProps -contains '$Ref') -or ($latestProps -contains '$Ref'))) {
            
            if ($existsProps -notcontains '$Ref' -and $latestProps -contains '$Ref') {
                if ($existsInBundle.VersionId -eq $latestVersion.'$VersionId') {
                    $existsInBundle = $latestVersion
                    Write-Host "Here"
                    $skip = $true
                }
            }
        }
        elseif ($latestVersion.VersionId -eq $existsInBundle.VersionId) {
            Write-Host "There"
            $skip = $true
        }
        else {
            $Data = New-DbVersionRef -DbDocument $existsInBundle -Collection $Collection -RefCollection $Collection
            $skip = $false
        }
    }
    elseif ($wasRef -and $BundleIdPresent) {
        throw "Bad VersionRef: VersionId not present in bundle"
    }
    else {
        $skip = $false
    }
    
    if ($skip) {
        $outDoc = $existsInBundle.VersionId | Get-DbDocumentByVersion -Database $Database -Collection $Collection
    }
    else {
        $Database.BeginTrans()
        try {
            # Instert partially so LiteDB atuo-assigns _id
            $Data.PSObject.Properties.Remove('_id')
            $initialDoc = [PSCustomObject]@{
                ContentMark = $Data.ContentMark
                BundleId = $Data.BundleId
                VersionId = $Data.VersionId
            }
            $initialDoc | Add-LiteData -Collection $Collection

            # Retrieve the newly inserted doc from LiteDB using VersionId
            $found = $initialDoc.VersionId | Get-DbDocumentByVersion -Database $Database -Collection $Collection

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
                if($BundleIdPresent) {
                    
                    # If new version/edit update timestamps
                    if($Data.PSObject.Properties.Name -contains "UTC_Created" -and -not $NoTimestampUpdate) {
                        $Data.UTC_Updated = $now
                    }
                    elseif (-not $NoTimestampUpdate) {
                        $Data = ($Data | Add-Member -MemberType NoteProperty -Name "UTC_Created" -Value $now -PassThru)
                        $Data = ($Data | Add-Member -MemberType NoteProperty -Name "UTC_Updated" -Value $now -PassThru)
                    }
                    else {
                        # `-NoTimestampUpdate` is active. If we're not supposed to update timestamps on a new version where
                        # bundleId is present on the inbound that means we moving to or from Temp or RecycleBin Collections
                        # with `Set-DbObjectCollectionByBundle` and the timestamps need to be preserved.  They are found
                        # on the $ExistsInBundle object. $Data should already have UTC_CREATED and UTC_UPDATED, and they should
                        # be unmodified.
                        $props = $Data.PSObject.Properties.Name
                        if ($props -notcontains 'UTC_Created' -or $props -notcontains 'UTC_Updated') {
                            throw "Cannot use '-NoTimestampUpdate' if UTC_Created or UTC_Updated is missing."
                        }
                    }
                }
                elseif ($Data.PSObject.Properties.Name -contains "UTC_Created") { # User-Defined UTC_Created on new Bundle
                    if (-not $NoTimestampUpdate) {
                        $Data.UTC_Updated = $now
                    }
                }
                else { # New Bundle
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
                $outDoc = $Data.VersionId | Get-DbDocumentByVersion -Database $Database -Collection $Collection
                $Database.Commit()
            }
        }
        catch {
            $Database.Rollback();
            throw $_
        }
    }
    
    return $outDoc
}

