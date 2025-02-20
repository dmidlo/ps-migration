function Get-DbHashRef {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        $DbHashRef,
        [Parameter(Mandatory)]
        $Connection
    )

    process {
        Write-Host $DbHashRef.Keys
        if ($DbHashRef.Keys -contains '$Ref') {
            $target = ($DbHashRef.'$Hash' | Get-DbDocumentByHash -Connection $Connection -CollectionName $DbHashRef.'$Ref')
            Write-Host "================= target"
            Write-Host $target
            Write-Host $target.GetType()
            if ($target -and $target.Keys -contains 'RefHash') {
                [System.Collections.ArrayList]$target["RefHash"].Add($DbHashRef.Hash) 
            }
            else {
                $target["RefHash"] = [System.Collections.ArrayList]::New()
                $target["RefHash"].Add($DbHashRef.Hash)
            }
            Update-LiteDBDocument -Connection $Connection -Collection $DbHashRef.'$Ref' -ID $target['_id'] -Document (([PSCustomObject]$target) | ConvertTo-LiteDbBSON)
            Write-Output $target
        }
        else {
            throw "Object Not a DbHashRef"
        }
    }
}