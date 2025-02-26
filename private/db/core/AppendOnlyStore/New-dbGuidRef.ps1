function New-DbGuidRef {
    param(
        [Parameter(Mandatory)]
        $DbDocument,

        [Parameter(Mandatory)]
        $Collection
    )

    $out = [PSCustomObject]@{
        RefGuid = [Guid]::NewGuid()
        Guid = $DbDocument.Guid
        "`$Guid"  = $DbDocument.Guid
        "`$Ref" = $Collection.Name
    }
    $Hash = (Get-DataHash -DataObject $DbDocument -FieldsToIgnore @('_id', 'Guid', 'Hash', 'UTC_Created', 'Count', 'Length', 'Collection')).Hash
    $out = ($out | Add-Member -MemberType NoteProperty -Name "Hash" -Value $Hash -Force -PassThru)

    return $out
}
