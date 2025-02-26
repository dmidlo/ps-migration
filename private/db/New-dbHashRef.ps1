function New-DbHashRef {
    param(
        [Parameter(Mandatory)]
        $DbDocument,

        [Parameter(Mandatory)]
        $Collection
    )

    $out = [PSCustomObject]@{
        RefGuid = [Guid]::NewGuid()
        Guid = $DbDocument.Guid
        "`$Hash"  = $DbDocument.Hash
        "`$Ref" = $Collection.Name
    }
    $Hash = (Get-DataHash -DataObject $out -FieldsToIgnore @('_id', 'Hash', 'Count', 'Length', 'Collection')).Hash
    $out = ($out | Add-Member -MemberType NoteProperty -Name "Hash" -Value $Hash -Force -PassThru)
    
    return $out
}
