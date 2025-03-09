function New-PhysicalAddress {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [LiteDB.LiteDatabase] $Database,

        [PSCustomObject]$PSCustomObject
    )

    process {
        if ($PSCustomObject) {
            return [PhysicalAddress]::new($Database, $PSCustomObject)
        } else {
            return [PhysicalAddress]::new($Database)
        }
    }
}
