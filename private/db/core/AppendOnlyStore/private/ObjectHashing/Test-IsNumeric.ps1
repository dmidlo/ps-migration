function Test-IsNumeric {
    param (
        [string]$Value
    )
    
    if (-not $Value) { return $false }  # Handle $null and empty strings
    
    $Value = $Value.Trim()  # Remove leading/trailing spaces

    if ($Value -match '^-?\d+(\.\d+)?([eE][-+]?\d+)?$') {
        return $true
    }

    return $false
}
