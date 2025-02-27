function New-DbGuidRef {
    param(
        [Parameter(Mandatory)]
        $DbDocument,

        [Parameter(Mandatory)]
        $Collection,

        [Parameter(Mandatory)]
        $RefCollection
    )

    $out = [PSCustomObject]@{
        RefGuid = [Guid]::NewGuid()
        RefCol = $Collection.Name
        Guid = $DbDocument.Guid
        "`$Guid"  = $DbDocument.Guid
        "`$Ref" = $RefCollection.Name
    }
    $Hash = (Get-DataHash -DataObject $DbDocument -FieldsToIgnore @('_id', 'Guid', 'Hash', 'UTC_Created', 'Count', 'Length', 'Collection')).Hash
    $out = ($out | Add-Member -MemberType NoteProperty -Name "Hash" -Value $Hash -Force -PassThru)

    return $out
}
