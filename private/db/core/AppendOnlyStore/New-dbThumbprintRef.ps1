function New-DbVersionRef {
    param(
        [Parameter(Mandatory)]
        $DbDocument,

        [Parameter(Mandatory)]
        $Collection,

        [Parameter(Mandatory)]
        $RefCollection
    )

    $out = [PSCustomObject]@{
        RefBundleId = [Guid]::NewGuid()
        RefCol = $Collection.Name
        BundleId = $DbDocument.BundleId
        "`$Thumbprint"  = $DbDocument.Thumbprint
        "`$Ref" = $RefCollection.Name
    }
    $Thumbprint = (Get-DataHash -DataObject $out -FieldsToIgnore @('_id', 'Thumbprint', 'Count', 'Length')).Hash
    $out = ($out | Add-Member -MemberType NoteProperty -Name "Thumbprint" -Value $Thumbprint -Force -PassThru)
    
    return $out
}
