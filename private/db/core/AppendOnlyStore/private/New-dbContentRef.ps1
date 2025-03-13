function New-DbContentRef {
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
        "`$ContentMark"  = $DbDocument.ContentMark
        "`$Ref" = $RefCollection.Name
    }
    $ContentMark = (Get-DataHash -DataObject $out -FieldsToIgnore @('_id', 'ContentMark', 'Count', 'Length')).Hash
    $VersionId = (Get-DataHash -DataObject @{ContentMark = $ContentMark; $BundleId = $out.BundleId} -FieldsToIgnore @('none')).Hash
    $out = ($out | Add-Member -MemberType NoteProperty -Name "ContentMark" -Value $ContentMark -Force -PassThru)
    $out = ($out | Add-Member -MemberType NoteProperty -Name "VersionId" -Value $VersionId -Force -PassThru)
    
    return $out
}
