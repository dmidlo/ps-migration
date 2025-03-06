function New-RandomPassword {
    <#
    .SYNOPSIS
        Generates a random password based on specified options.

    .DESCRIPTION
        The New-RandomPassword function creates a random password of a specified length using user-defined character type inclusions.
        The function takes a PSCustomObject as input, which contains:
        - A "length" property specifying the length of the password.
        - An "Options" property specifying the character types to include (comma-separated string: 'upper', 'lower', 'numeric', 'special').

    .PARAMETER PasswordOptions
        A PSCustomObject containing:
        - length: The desired length of the password (integer).
        - Options: A comma-separated string specifying character types ('upper', 'lower', 'numeric', 'special').

    .OUTPUTS
        [string]
        Returns a randomly generated password based on the provided character inclusion rules.

    .EXAMPLE
        PS C:\> $options = [pscustomobject]@{ length = 12; Options = "upper,lower,numeric" }
        PS C:\> New-RandomPassword -PasswordOptions $options
        Returns a random 12-character password containing uppercase letters, lowercase letters, and numbers.

    .EXAMPLE
        PS C:\> $options = [pscustomobject]@{ length = 16; Options = "upper,lower,numeric,special" }
        PS C:\> New-RandomPassword -PasswordOptions $options
        Returns a random 16-character password containing uppercase, lowercase, numeric, and special characters.

    .NOTES
        - Ensure that the PasswordOptions object contains both a valid length and at least one character type.
        - The function will throw an error if an invalid or empty option set is provided.
        - The password generation is purely random and does not guarantee inclusion of each character type in every password.
    #>

    param (
        [pscustomobject]$PasswordOptions
    )

    $length = $PasswordOptions.length
    $options = $PasswordOptions.Options -split ","

    $includeUpper = $options -contains 'upper'
    $includeLower = $options -contains 'lower'
    $includeNumeric = $options -contains 'numeric'
    $includeSpecial = $options -contains 'special'

    $characterPool = Get-CharacterPool -IncludeUpper $includeUpper -IncludeLower $includeLower -IncludeNumeric $includeNumeric -IncludeSpecial $includeSpecial

    $password = ""
    for ($i = 0; $i -lt $length; $i++) {
        $password += Get-RandomCharacter -CharacterSet $characterPool
    }

    return $password
}
