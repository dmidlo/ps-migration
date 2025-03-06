function Get-RandomCharacter {
    <#
    .SYNOPSIS
        Selects a random character from a given character set.

    .DESCRIPTION
        The Get-RandomCharacter function takes a string containing a set of characters and returns a randomly selected character from that set.
        If an empty or null character set is provided, an exception is thrown.

    .PARAMETER CharacterSet
        The string containing characters from which a random selection is made.
        This parameter must be non-empty.

    .OUTPUTS
        [char]
        Returns a single randomly selected character from the provided CharacterSet.

    .EXAMPLE
        PS C:\> Get-RandomCharacter -CharacterSet "abcdef"
        Returns a randomly selected character from "abcdef", such as "c".

    .EXAMPLE
        PS C:\> Get-RandomCharacter -CharacterSet "1234567890"
        Returns a random digit from the provided numeric set, such as "7".

    .NOTES
        Ensure that the CharacterSet parameter is not empty, as the function will throw an exception otherwise.

    #>

    param (
        [string]$CharacterSet
    )

    if (-not $CharacterSet) {
        throw "CharacterSet cannot be null or empty."
    }

    $randomIndex = Get-Random -Minimum 0 -Maximum $CharacterSet.Length
    return $CharacterSet[$randomIndex]
}