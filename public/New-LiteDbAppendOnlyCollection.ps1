function New-LiteDbAppendOnlyCollection {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [LiteDB.LiteDatabase] $Database,

        [Parameter(Mandatory)]
        $Collection
    )

    process {
        return [LiteDbAppendOnlyCollection]::new($Database, $Collection)
    }
}
