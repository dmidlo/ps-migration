function Merge-PSCustomObjects {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [PSCustomObject[]]$Objects
    )

    process {
        $MergedHash = @{}

        foreach ($obj in $Objects) {
            $obj.PSObject.Properties | ForEach-Object {
                $MergedHash[$_.Name] = $_.Value
            }
        }

        [PSCustomObject]$MergedHash
    }
}