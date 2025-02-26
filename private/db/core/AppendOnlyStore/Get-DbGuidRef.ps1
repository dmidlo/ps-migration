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

    process {
        if ($DbGuidRef.PSObject.Properties.Name -contains '$Ref') {
            $RefCollection = Get-LiteCollection -Database $Database -CollectionName $DbGuidRef.'$Ref'
            $targets = ($DbGuidRef.'$Guid' | Get-DbDocumentVersionsByGuid -Database $Database -Collection $RefCollection)
            $target = $targets[0].'$Hash' | Get-DbDocumentVersion -Database $Database -Collection $RefCollection -Latest
            
            $targets = $targets | ForEach-Object {
                $_t = $_
                if ($_t -and $_t.PSObject.Properties.Name -contains '$arcs') {
                    if ($_t.'$arcs' -notcontains $DbGuidRef) {
                        $_t.'$arcs'.Add($DbGuidRef)
                    }
                }
                else {
                    $_t = ($_t | Add-Member -MemberType NoteProperty -Name '$arcs' -Value ([System.Collections.ArrayList]::New()) -PassThru)
                    $_t.'$arcs'.Add($DbGuidRef)
                }
                $_t | Set-LiteData -Collection $RefCollection
            }

            if ($target.PSObject.Properties.name -contains '$Ref') {
                Write-Output ($target | Get-DbHashRef -Database $Database -Collection $RefCollection)
            } else {
                Write-Output $target
            }
        }
        else {
            throw "Object Not a DbRef"
        }
    }
}