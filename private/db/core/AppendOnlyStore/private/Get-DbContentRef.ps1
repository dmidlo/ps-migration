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
            $null = ($RefCollection = Get-LiteCollection -Database $Database -CollectionName $DbContentRef.'$Ref')
            $null = ($target = ($DbContentRef.'$ContentMark' | Get-DbDocumentByContent -Database $Database -Collection $RefCollection))

            if ($target.PSObject.Properties.Name -contains '$ContentArcs') {
                $null = ($arcContentMarks = [System.Collections.ArrayList]::New())
                $DbContentRefContentMark = (Get-DataHash -DataObject $DbContentRef -FieldsToIgnore @('none')).Hash
                foreach ($arc in $target.'$ContentArcs') {
                    $arcContentMark = (Get-DataHash -DataObject $arc -FieldsToIgnore @('none')).Hash
                    $null = $arcContentMarks.Add($arcContentMark)
                }
                
                if ($arcContentMarks -notcontains $DbContentRefContentMark) {
                    $null = $target.'$ContentArcs'.Add($DbContentRef)
                }
            }
            else {
                $null = ($target = ($target | Add-Member -MemberType NoteProperty -Name '$ContentArcs' -Value ([System.Collections.ArrayList]::New()) -PassThru))
                $null = $target.'$ContentArcs'.Add($DbContentRef)
            }
            $null = ($target | Set-LiteData -Collection $RefCollection)
            Write-Output $target
        }
        else {
            throw "Object Not a DbRef"
        }
    }
}