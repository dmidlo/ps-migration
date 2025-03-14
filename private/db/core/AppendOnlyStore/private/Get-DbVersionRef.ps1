function Get-DbVersionRef {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        $DbVersionRef,
        [Parameter(Mandatory)]
        $Database,
        [Parameter(Mandatory)]
        $Collection
    )

    process {
        if ($DbVersionRef.PSObject.Properties.Name -contains '$Ref' -and $DbVersionRef.PSObject.Properties.Name -contains '$VersionId') {
            $null = ($RefCollection = Get-LiteCollection -Database $Database -CollectionName $DbVersionRef.'$Ref')
            $null = ($target = ($DbVersionRef.'$VersionId' | Get-DbDocumentByVersion -Database $Database -Collection $RefCollection))

            if ($target.PSObject.Properties.Name -contains '$VersionArcs') {
                $null = ($arcVersions = [System.Collections.ArrayList]::New())
                $DbVersionRefVersionId = (Get-DataHash -DataObject $DbVersionRef -FieldsToIgnore @('none')).Hash
                foreach ($arc in $target.'$VersionArcs') {
                    $arcVersion = (Get-DataHash -DataObject $arc -FieldsToIgnore @('none')).Hash
                    $null = $arcVersions.Add($arcVersion)
                }
                
                if ($arcVersions -notcontains $DbVersionRefVersionId) {
                    $null = $target.'$VersionArcs'.Add($DbVersionRef)
                }
            }
            else {
                $null = ($target = ($target | Add-Member -MemberType NoteProperty -Name '$VersionArcs' -Value ([System.Collections.ArrayList]::New()) -PassThru))
                $null = $target.'$VersionArcs'.Add($DbVersionRef)
            }
            $null = ($target | Set-LiteData -Collection $RefCollection)
            Write-Output $target
        }
        else {
            throw "Object Not a DbRef"
        }
    }
}