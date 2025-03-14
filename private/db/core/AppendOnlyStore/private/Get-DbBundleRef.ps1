function Get-DbBundleRef {
    # Returns the Lastest
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        $DbBundleRef,
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
            $null = ($latest = $Targets[$i].VersionId | Get-DbDocumentVersion -Database $Database -Collection $RefCollection -Latest)

            if ($latest.PSObject.Properties.Name -contains '$Ref') {
                $Versions = $latest.BundleId | Get-DbDocumentVersionsByBundle -Database $Database -Collection $RefCollection
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
        if ($DbBundleRef.PSObject.Properties.Name -contains '$Ref' -and $DbBundleRef.PSObject.Properties.Name -contains '$BundleId') {
            $RefCollection = Get-LiteCollection -Database $Database -CollectionName $DbBundleRef.'$Ref'
            $targets = ($DbBundleRef.'$BundleId' | Get-DbDocumentVersionsByBundle -Database $Database -Collection $RefCollection) | Where-Object {$_.PSObject.Properties.Name -notcontains '$Ref'}
            $target = Get-ValidTarget -Targets $targets -RefCollection $RefCollection
            
            $DbBundleRefVersionId = (Get-DataHash -DataObject $DbBundleRef -FieldsToIgnore @('none')).Hash
            foreach ($_t in $targets) {
                $_tVersionId = (Get-DataHash -DataObject $_t -FieldsToIgnore @('none')).Hash

                if ($_tVersionId -ne $DbBundleRefVersionId) {
                    if ($_t.PSObject.Properties.Name -contains '$BundleArcs') {
                        $arcVersions = [System.Collections.ArrayList]::New()
                        foreach ($arc in $_t.'$BundleArcs') {
                            $arcVersion = (Get-DataHash -DataObject $arc -FieldsToIgnore @('none')).Hash
                            $null = $arcVersions.Add($arcVersion)
                        }

                        if ($arcVersions -notcontains $DbBundleRefVersionId) {
                            $null = $_t.'$BundleArcs'.Add($DbBundleRef)
                        }
                    }
                    else {
                        $_t = ($_t | Add-Member -MemberType NoteProperty -Name '$BundleArcs' -Value ([System.Collections.ArrayList]::New()) -PassThru)
                        $null = $_t.'$BundleArcs'.Add($DbBundleRef)
                    }
                    $_t | Set-LiteData -Collection $RefCollection
                }
            }

            if ($target.PSObject.Properties.name -contains '$Ref' -and $target.PSObject.Properties.Name -contains '$VersionId') {
                Write-Output ($target | Get-DbVersionRef -Database $Database -Collection $RefCollection)
            } else {
                Write-Output $target
            }
        }
        else {
            throw "Object Not a DbBundleRef"
        }
    }
}