function Get-MacAddressAnalysis {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline = $true, Mandatory = $true)]
        [string]$MacAddress,
        [MacAddressType]$ExpectedType,
        [MacAddressOriginType]$ExpectedOrigin,
        [switch]$SkipOUI
    )

    Process {
        if ($SkipOUI) {
            if ($ExpectedType -and $ExpectedOrigin) {
                Write-Output ([MacAddressAnalyzer]::ParseMacAddress($MacAddress, $ExpectedType, $ExpectedOrigin, $SkipOUI))
            }
            elseif ($ExpectedType) {
                Write-Output ([MacAddressAnalyzer]::ParseMacAddress($MacAddress, $ExpectedType, $SkipOUI))
            }
            elseif ($ExpectedOrigin) {
                Write-Output ([MacAddressAnalyzer]::ParseMacAddress($MacAddress, $ExpectedOrigin, $SkipOUI))
            }
            else {
                Write-Output ([MacAddressAnalyzer]::ParseMacAddress($MacAddress, $SkipOUI))
            }
        }
        else {
            if ($ExpectedType -and $ExpectedOrigin) {
                Write-Output ([MacAddressAnalyzer]::ParseMacAddress($MacAddress, $ExpectedType, $ExpectedOrigin))
            }
            elseif ($ExpectedType) {
                Write-Output ([MacAddressAnalyzer]::ParseMacAddress($MacAddress, $ExpectedType))
            }
            elseif ($ExpectedOrigin) {
                Write-Output ([MacAddressAnalyzer]::ParseMacAddress($MacAddress, $ExpectedOrigin))
            }
            else {
                Write-Output ([MacAddressAnalyzer]::ParseMacAddress($MacAddress))
            }
        }
    }
}
