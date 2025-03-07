function Test-OUI {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$MacAddress,
        
        [Parameter(Mandatory = $true)]
        [hashtable]$OUIHashTable
    )
    
    process {
        try {
            if ($MacAddress -notmatch '^[0-9A-Fa-f]{12}$') {
                Write-Error "Invalid MAC Address format. Must be 12 hexadecimal characters."
                return $false
            }
            
            $OUI = $MacAddress.Substring(0, 6).ToUpper()
            if ($OUIHashTable.ContainsKey($OUI)) {
                Write-Verbose "Valid OUI: $OUI belongs to $($OUIHashTable[$OUI])"
                return $true
            } else {
                Write-Warning "Unregistered OUI: $OUI is not found in the official IEEE list."
                return $false
            }
        } catch {
            Write-Error "Validation failed: $_"
            return $false
        }
    }
}