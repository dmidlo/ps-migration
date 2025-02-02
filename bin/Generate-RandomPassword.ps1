function Get-RandomCharacter {
    param (
        [string]$CharacterSet
    )

    if (-not $CharacterSet) {
        throw "CharacterSet cannot be null or empty."
    }

    $randomIndex = Get-Random -Minimum 0 -Maximum $CharacterSet.Length
    return $CharacterSet[$randomIndex]
}

function Get-CharacterPool {
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

function Generate-RandomPassword {
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

# Example usage:
# $PasswordOptions = [pscustomobject]@{
#     length = 16
#     secret = "asdgasg" # Not used in this implementation but retained for structure
#     Options = "upper,lower,numeric,special"
# }

# $password = Generate-RandomPassword -PasswordOptions $PasswordOptions
# Write-Output $password
