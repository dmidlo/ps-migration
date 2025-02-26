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
            if ($target -and $target.PSObject.Properties.Name -contains '$arcs') {
                if ($target.'$arcs' -notcontains $DbHashRef) {
                    $target.'$arcs'.Add($DbHashRef) 
                }
            }
            else {
                $target = ($target | Add-Member -MemberType NoteProperty -Name '$arcs' -Value ([System.Collections.ArrayList]::New()) -PassThru)
                $target.'$arcs'.Add($DbHashRef)
            }
            $target | Set-LiteData -Collection $RefCollection
            Write-Output $target
        }
        else {
            throw "Object Not a DbRef"
        }
    }
}