function New-MacAddressAnalyzer {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline = $true, Mandatory = $true)]
        [string]$MacAddress
    )

    Process {
        return ([MacAddressAnalyzer]::new($MacAddress))
    }
}
