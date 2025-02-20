function New-DbIdRef {
    [CmdLetBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        $DbDocument
    )

    process {
        Write-Output @{
            "`$id"  = $DbDocument._id
            "`$ref" = $DbDocument.Collection
        }
    }
}
