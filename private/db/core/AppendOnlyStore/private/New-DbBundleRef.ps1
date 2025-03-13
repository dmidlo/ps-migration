function New-DbBundleRef {
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
        "`$BundleId"  = $DbDocument.BundleId
        "`$Ref" = $RefCollection.Name
    }
    $ContentMark = (Get-DataHash -DataObject $DbDocument -FieldsToIgnore @('_id', 'ContentMark', 'VersionId', 'BundleId', 'UTC_Created', 'Count', 'Length')).Hash
    $VersionId = (Get-DataHash -DataObject @{ContentMark = $ContentMark; BundleId = $out.BundleId} -FieldsToIgnore @('none')).Hash
    $out = ($out | Add-Member -MemberType NoteProperty -Name "ContentMark" -Value $ContentMark -Force -PassThru)
    $out = ($out | Add-Member -MemberType NoteProperty -Name "VersionId" -Value $VersionId -Force -PassThru)

    return $out
}
