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
        if ($DbHashRef.PSObject.Properties.Name -contains '$Ref') {
            $RefCollection = Get-LiteCollection -Database $Database -CollectionName $DbHashRef.'$Ref'
            $target = ($DbHashRef.'$Hash' | Get-DbDocumentByHash -Database $Database -Collection $RefCollection)
            if ($target -and $target.PSObject.Properties.Name -contains 'RefHash') {
                if ($target.RefHash -notcontains $DbHashRef.Hash) {
                    $target.RefHash.Add($DbHashRef.Hash) 
                }
            }
            else {
                $target = ($target | Add-Member -MemberType NoteProperty -Name "RefHash" -Value ([System.Collections.ArrayList]::New()) -PassThru)
                $target.RefHash.Add($DbHashRef.Hash)
            }
            $target | Set-LiteData -Collection $RefCollection
            Write-Output $target
        }
        else {
            throw "Object Not a DbHashRef"
        }
    }
}