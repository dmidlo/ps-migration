function Get-DbContentRef {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        $DbContentRef,
        [Parameter(Mandatory)]
        $Database,
        [Parameter(Mandatory)]
        $Collection
    )

    process {
        if ($DbContentRef.PSObject.Properties.Name -contains '$Ref' -and $DbContentRef.PSObject.Properties.Name -contains '$ContentId') {
            ($RefCollection = Get-LiteCollection -Database $Database -CollectionName $DbContentRef.'$Ref') | Out-Null
            ($target = ($DbContentRef.'$ContentId' | Get-DbDocumentByContent -Database $Database -Collection $RefCollection)) | Out-Null

            if ($target.PSObject.Properties.Name -contains '$ContentArcs') {
                ($arcContentIds = [System.Collections.ArrayList]::New()) | Out-Null
                $DbContentRefContentId = (Get-DataHash -DataObject $DbContentRef -FieldsToIgnore @('none')).Hash
                foreach ($arc in $target.'$ContentArcs') {
                    $arcContentId = (Get-DataHash -DataObject $arc -FieldsToIgnore @('none')).Hash
                    $arcContentIds.Add($arcContentId) | Out-Null
                }
                
                if ($arcContentIds -notcontains $DbContentRefContentId) {
                    $target.'$ContentArcs'.Add($DbContentRef) | Out-Null
                }
            }
            else {
                ($target = ($target | Add-Member -MemberType NoteProperty -Name '$ContentArcs' -Value ([System.Collections.ArrayList]::New()) -PassThru)) | Out-Null
                $target.'$ContentArcs'.Add($DbContentRef) | Out-Null
            }
            ($target | Set-LiteData -Collection $RefCollection) | Out-Null
            Write-Output $target
        }
        else {
            throw "Object Not a DbRef"
        }
    }
}