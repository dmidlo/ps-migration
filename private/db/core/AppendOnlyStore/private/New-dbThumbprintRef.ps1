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
        "`$ContentId"  = $DbDocument.ContentId
        "`$Ref" = $RefCollection.Name
    }
    $ContentId = (Get-DataHash -DataObject $out -FieldsToIgnore @('_id', 'ContentId', 'Count', 'Length')).Hash
    $out = ($out | Add-Member -MemberType NoteProperty -Name "ContentId" -Value $ContentId -Force -PassThru)
    
    return $out
}
