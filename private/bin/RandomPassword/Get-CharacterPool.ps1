function Get-CharacterPool {
    <#
    .SYNOPSIS
        Constructs a character pool based on specified character type inclusions.

    .DESCRIPTION
        The Get-CharacterPool function generates a string containing a combination of uppercase letters, lowercase letters, numbers, and/or special characters
        based on user-defined boolean flags.

    .PARAMETER IncludeUpper
        A boolean flag indicating whether to include uppercase letters (A-Z) in the character pool.

    .PARAMETER IncludeLower
        A boolean flag indicating whether to include lowercase letters (a-z) in the character pool.

    .PARAMETER IncludeNumeric
        A boolean flag indicating whether to include numeric digits (0-9) in the character pool.

    .PARAMETER IncludeSpecial
        A boolean flag indicating whether to include special characters (!@#$%^&*()-_=+[]{}|;:,.<>?/) in the character pool.

    .OUTPUTS
        [string]
        Returns a string containing the selected character types.

    .EXAMPLE
        PS C:\> Get-CharacterPool -IncludeUpper $true -IncludeLower $true -IncludeNumeric $false -IncludeSpecial $false
        Returns "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz".

    .EXAMPLE
        PS C:\> Get-CharacterPool -IncludeUpper $false -IncludeLower $false -IncludeNumeric $true -IncludeSpecial $true
        Returns "0123456789!@#$%^&*()-_=+[]{}|;:,.<>?/".

    .NOTES
        At least one character type must be included; otherwise, the function will throw an exception.
    #>

    param (
        [bool]$IncludeUpper,
        [bool]$IncludeLower,
        [bool]$IncludeNumeric,
        [bool]$IncludeSpecial
    )

    $pool = ""

    if ($IncludeUpper) {
        $pool += "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    }

    if ($IncludeLower) {
        $pool += "abcdefghijklmnopqrstuvwxyz"
    }

    if ($IncludeNumeric) {
        $pool += "0123456789"
    }

    if ($IncludeSpecial) {
        $pool += "!@#$%^&*()-_=+[]{}|;:,.<>?/"
    }

    if (-not $pool) {
        throw "At least one character type must be included."
    }

    return $pool
}