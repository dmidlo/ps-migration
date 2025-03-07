function Get-DbThumbprintRef {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        $DbThumbprintRef,
        [Parameter(Mandatory)]
        $Database,
        [Parameter(Mandatory)]
        $Collection
    )

    process {
        if ($DbThumbprintRef.PSObject.Properties.Name -contains '$Ref' -and $DbThumbprintRef.PSObject.Properties.Name -contains '$Thumbprint') {
            ($RefCollection = Get-LiteCollection -Database $Database -CollectionName $DbThumbprintRef.'$Ref') | Out-Null
            ($target = ($DbThumbprintRef.'$Thumbprint' | Get-DbDocumentByThumbprint -Database $Database -Collection $RefCollection)) | Out-Null

            if ($target.PSObject.Properties.Name -contains '$ThumbprintArcs') {
                ($arcThumbprints = [System.Collections.ArrayList]::New()) | Out-Null
                $DbThumbprintRefThumbprint = (Get-DataHash -DataObject $DbThumbprintRef -FieldsToIgnore @('none')).Hash
                foreach ($arc in $target.'$ThumbprintArcs') {
                    $arcThumbprint = (Get-DataHash -DataObject $arc -FieldsToIgnore @('none')).Hash
                    $arcThumbprints.Add($arcThumbprint) | Out-Null
                }
                
                if ($arcThumbprints -notcontains $DbThumbprintRefThumbprint) {
                    $target.'$ThumbprintArcs'.Add($DbThumbprintRef) | Out-Null
                }
            }
            else {
                ($target = ($target | Add-Member -MemberType NoteProperty -Name '$ThumbprintArcs' -Value ([System.Collections.ArrayList]::New()) -PassThru)) | Out-Null
                $target.'$ThumbprintArcs'.Add($DbThumbprintRef) | Out-Null
            }
            ($target | Set-LiteData -Collection $RefCollection) | Out-Null
            Write-Output $target
        }
        else {
            throw "Object Not a DbRef"
        }
    }
}