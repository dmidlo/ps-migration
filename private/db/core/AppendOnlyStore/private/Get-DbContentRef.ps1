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
        if ($DbContentRef.PSObject.Properties.Name -contains '$Ref' -and $DbContentRef.PSObject.Properties.Name -contains '$ContentMark') {
            ($RefCollection = Get-LiteCollection -Database $Database -CollectionName $DbContentRef.'$Ref') | Out-Null
            ($target = ($DbContentRef.'$ContentMark' | Get-DbDocumentByContent -Database $Database -Collection $RefCollection)) | Out-Null

            if ($target.PSObject.Properties.Name -contains '$ContentArcs') {
                ($arcContentMarks = [System.Collections.ArrayList]::New()) | Out-Null
                $DbContentRefContentMark = (Get-DataHash -DataObject $DbContentRef -FieldsToIgnore @('none')).Hash
                foreach ($arc in $target.'$ContentArcs') {
                    $arcContentMark = (Get-DataHash -DataObject $arc -FieldsToIgnore @('none')).Hash
                    $arcContentMarks.Add($arcContentMark) | Out-Null
                }
                
                if ($arcContentMarks -notcontains $DbContentRefContentMark) {
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