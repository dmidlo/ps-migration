function New-DbHashRef {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        $DbDocument
    )

    process {
        $Out = @{
            RefGuid = [Guid]::NewGuid()
            Guid = $DbDocument.Guid
            "`$Hash"  = $DbDocument.Hash
            "`$Ref" = $DbDocument.Collection
        }
        $Out['Hash'] = (Get-DataHash -DataObject $Out -FieldsToIgnore @('_id', 'Hash', 'Count', 'Length', 'Collection')).Hash
        Write-Output $Out
    }
}
