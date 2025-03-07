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
    $VersionId = (Get-DataHash -DataObject $DbDocument -FieldsToIgnore @('_id', 'Thumbprint', 'VersionId', 'BundleId', 'UTC_Created', 'Count', 'Length')).Hash
    $out = ($out | Add-Member -MemberType NoteProperty -Name "VersionId" -Value $VersionId -Force -PassThru)

    return $out
}
