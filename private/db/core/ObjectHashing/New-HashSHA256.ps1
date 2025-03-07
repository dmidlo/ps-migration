<#
.SYNOPSIS
    Computes a SHA-256 hash of a given input string.

.DESCRIPTION
    - Uses the SHA-256 cryptographic algorithm to hash the provided input.
    - Encodes the string as UTF-8 before computing the hash.
    - Returns the hash as an uppercase hexadecimal string.

.PARAMETER InputString
    The input string to be hashed.

.OUTPUTS
    A SHA-256 hash string in uppercase hexadecimal format.
#>

function New-HashSHA256 {
    param (
        [Parameter(Mandatory = $true)]
        [string]$InputString
    )

    $sha256 = [System.Security.Cryptography.SHA256]::Create()
    try {
        return -join ($sha256.ComputeHash([System.Text.Encoding]::UTF8.GetBytes($InputString)) | ForEach-Object ToString X2)
    }
    finally {
        $sha256.Dispose()
    }
}
