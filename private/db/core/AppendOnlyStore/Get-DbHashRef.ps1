function Get-DbHashRef {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        $DbHashRef,
        [Parameter(Mandatory)]
        $Database,
        [Parameter(Mandatory)]
        $Collection
    )

    process {
        if ($DbHashRef.PSObject.Properties.Name -contains '$Ref' -and $DbHashRef.PSObject.Properties.Name -contains '$Hash') {
            ($RefCollection = Get-LiteCollection -Database $Database -CollectionName $DbHashRef.'$Ref') | Out-Null
            ($target = ($DbHashRef.'$Hash' | Get-DbDocumentByHash -Database $Database -Collection $RefCollection)) | Out-Null

            if ($target.PSObject.Properties.Name -contains '$hashArcs') {
                ($arcHashes = [System.Collections.ArrayList]::New()) | Out-Null
                $DbHashRefHash = (Get-DataHash -DataObject $DbHashRef -FieldsToIgnore @('none')).Hash
                foreach ($arc in $target.'$hashArcs') {
                    $arcHash = (Get-DataHash -DataObject $arc -FieldsToIgnore @('none')).Hash
                    $arcHashes.Add($arcHash) | Out-Null
                }
                
                if ($arcHashes -notcontains $DbHashRefHash) {
                    $target.'$hashArcs'.Add($DbHashRef) | Out-Null
                }
            }
            else {
                ($target = ($target | Add-Member -MemberType NoteProperty -Name '$hashArcs' -Value ([System.Collections.ArrayList]::New()) -PassThru)) | Out-Null
                $target.'$hashArcs'.Add($DbHashRef) | Out-Null
            }
            ($target | Set-LiteData -Collection $RefCollection) | Out-Null
            Write-Output $target
        }
        else {
            throw "Object Not a DbRef"
        }
    }
}