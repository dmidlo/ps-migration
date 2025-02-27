function Get-DbGuidRef {
    # Returns the Lastest
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        $DbGuidRef,
        [Parameter(Mandatory)]
        $Database,
        [Parameter(Mandatory)]
        $Collection
    )

    begin {
        function Get-ValidTarget {
            param (
                $Targets,
                $RefCollection
            )

            $i = 0
            ($latest = $Targets[$i].Hash | Get-DbDocumentVersion -Database $Database -Collection $RefCollection -Latest) | Out-Null

            if ($latest.PSObject.Properties.Name -contains '$Ref') {
                $Versions = $latest.Guid | Get-DbDocumentVersionsByGuid -Database $Database -Collection $RefCollection
                do {
                    if (-not ($Versions[$i].PSObject.Properties.Name -contains '$Ref')) {
                        return $Versions[$i]
                    }
                    $i++
                }
                until ($i -eq $Targets.Count + 1)
            }
            else {
                return $latest
            }
        }
    }

    process {
        if ($DbGuidRef.PSObject.Properties.Name -contains '$Ref' -and $DbGuidRef.PSObject.Properties.Name -contains '$Guid') {
            $RefCollection = Get-LiteCollection -Database $Database -CollectionName $DbGuidRef.'$Ref'
            $targets = ($DbGuidRef.'$Guid' | Get-DbDocumentVersionsByGuid -Database $Database -Collection $RefCollection)
            $target = Get-ValidTarget -Targets $targets -RefCollection $RefCollection
            
            $DbGuidRefHash = (Get-DataHash -DataObject $DbGuidRef -FieldsToIgnore @('none')).Hash
            foreach ($_t in $targets) {
                if ($_t.PSObject.Properties.Name -notcontains '$Ref') {
                    $_tHash = (Get-DataHash -DataObject $_t -FieldsToIgnore @('none')).Hash

                    if ($_tHash -ne $DbGuidRefHash) {
                        if ($_t.PSObject.Properties.Name -contains '$guidArcs') {
                            $arcHashes = [System.Collections.ArrayList]::New()
                            foreach ($arc in $_t.'$guidArcs') {
                                $archHash = (Get-DataHash -DataObject $arc -FieldsToIgnore @('none')).Hash
                                $arcHashes.Add($archHash) | Out-Null
                            }

                            if ($arcHashes -notcontains $DbGuidRefHash) {
                                $_t.'$guidArcs'.Add($DbGuidRef) | Out-Null
                            }
                        }
                        else {
                            $_t = ($_t | Add-Member -MemberType NoteProperty -Name '$guidArcs' -Value ([System.Collections.ArrayList]::New()) -PassThru)
                            $_t.'$guidArcs'.Add($DbGuidRef) | Out-Null
                        }
                        $_t | Set-LiteData -Collection $RefCollection
                    }
                }
            }

            if ($target.PSObject.Properties.name -contains '$Ref' -and $target.PSObject.Properties.Name -contains '$Hash') {
                Write-Output ($target | Get-DbHashRef -Database $Database -Collection $RefCollection)
            } else {
                Write-Output $target
            }
        }
        else {
            throw "Object Not a DbGuidRef"
        }
    }
}