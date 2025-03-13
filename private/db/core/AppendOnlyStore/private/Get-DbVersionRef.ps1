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
            ($RefCollection = Get-LiteCollection -Database $Database -CollectionName $DbVersionRef.'$Ref') | Out-Null
            ($target = ($DbVersionRef.'$VersionId' | Get-DbDocumentByVersion -Database $Database -Collection $RefCollection)) | Out-Null

            if ($target.PSObject.Properties.Name -contains '$VersionArcs') {
                ($arcVersions = [System.Collections.ArrayList]::New()) | Out-Null
                $DbVersionRefVersionId = (Get-DataHash -DataObject $DbVersionRef -FieldsToIgnore @('none')).Hash
                foreach ($arc in $target.'$VersionArcs') {
                    $arcVersion = (Get-DataHash -DataObject $arc -FieldsToIgnore @('none')).Hash
                    $arcVersions.Add($arcVersion) | Out-Null
                }
                
                if ($arcVersions -notcontains $DbVersionRefVersionId) {
                    $target.'$VersionArcs'.Add($DbVersionRef) | Out-Null
                }
            }
            else {
                ($target = ($target | Add-Member -MemberType NoteProperty -Name '$VersionArcs' -Value ([System.Collections.ArrayList]::New()) -PassThru)) | Out-Null
                $target.'$VersionArcs'.Add($DbVersionRef) | Out-Null
            }
            ($target | Set-LiteData -Collection $RefCollection) | Out-Null
            Write-Output $target
        }
        else {
            throw "Object Not a DbRef"
        }
    }
}