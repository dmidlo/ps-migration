function Get-DataHash {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [PSCustomObject] $DataObject,

        [string[]] $FieldsToIgnore = @('_id', 'Guid', 'Id', 'Hash', 'META_UTCCreated', 'META_UTCUpdated', 'Count', 'Length')
    )

    # Convert object to JSON and back to remove ignored fields and sort properties
    $processed = $DataObject | ConvertTo-Json -Depth 15 | ConvertFrom-Json

    # Remove ignored fields dynamically
    foreach ($field in $FieldsToIgnore) {
        $processed.PSObject.Properties.Remove($field)
    }

    # Convert the cleaned object back to a stable JSON format
    $json = $processed | ConvertTo-Json -Depth 15 -Compress

    # Compute SHA256 hash
    $sha256  = [System.Security.Cryptography.SHA256]::Create()
    $bytes   = [System.Text.Encoding]::UTF8.GetBytes($json)
    $hash    = $sha256.ComputeHash($bytes)
    $hashHex = [BitConverter]::ToString($hash) -replace '-',''

    return $hashHex
}
