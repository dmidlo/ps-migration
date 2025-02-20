function New-DbGuidRef {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        $DbDocument
    )

    process {
        Write-Output @{
            Hash = Get-DataHash -DataObject $DbDocument -FieldsToIgnore @('_id', 'Guid', 'Hash', 'META_UTCCreated', 'Count', 'Length', 'Collection')
            Guid = [Guid]::NewGuid()
            "`$Guid"  = $DbDocument.Guid
            "`$ref" = $DbDocument.Collection
        }
    }
}
