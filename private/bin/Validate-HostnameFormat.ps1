function Validate-HostnameFormat {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string]$Hostname
    )

    process {
        $logs = @()
        function LogMessage($message, $type = "Info") {
            $logs += "[$type] $message"
            switch ($type) {
                "Info"    { Write-Host $message -ForegroundColor Green }
                "Verbose" { Write-Verbose $message }
                "Warning" { Write-Warning $message }
                "Error"   { Write-Error $message }
            }
        }

        # Convert IDNs to Punycode
        try {
            $Hostname = [System.Globalization.IdnMapping]::new().GetAscii($Hostname)
        } catch {
            LogMessage "Error: Unable to convert to Punycode, possibly invalid Unicode domain." "Error"
            return [PSCustomObject]@{
                Hostname      = $Hostname
                HostnameType  = "Invalid"
                IsValid       = $false
                FQDN          = $null
                NetBIOS       = $null
                Message       = "Invalid: Could not convert Unicode domain to Punycode."
            }
        }

        # Output Object Template
        $output = [PSCustomObject]@{
            Hostname       = $Hostname
            HostnameType   = "Unknown"
            IsValid        = $false
            FQDN           = $null
            NetBIOS        = $null
            Message        = ""
        }

        LogMessage "Processing Hostname: $Hostname" "Info"

        # **Reserved and Special TLDs**
        if ($Hostname -match "^(localhost|example|test|invalid|onion|home|corp|internal)$") {
            LogMessage "Warning: Reserved hostname '$Hostname' cannot be used." "Warning"
            return [PSCustomObject]@{
                Hostname      = $Hostname
                HostnameType  = "Reserved"
                IsValid       = $true
                FQDN          = $null
                NetBIOS       = $null
                Message       = "Warning: Reserved hostname."
            }
        }        
        # **Subdomain Length Check**
        elseif ($Hostname -match "([A-Za-z0-9-]{64,})") {
            LogMessage "Error: Subdomain exceeds 63-character limit." "Error"
            $output.HostnameType = "Invalid"
            $output.IsValid = $false
            $output.Message = "Invalid: Subdomain exceeds 63-character limit."
        }
        # **WINS/NetBIOS Validation**
        elseif ($Hostname -match "^[A-Za-z0-9!@#\$%\^&\(\)\-'{\}\.~]{1,15}$") {
            LogMessage "Valid WINS/NetBIOS Hostname detected." "Info"
            $output.HostnameType = "WINS/NetBIOS"
            $output.IsValid = $true
            $output.FQDN = $Hostname.ToUpper()
            $output.Message = "Valid NetBIOS/WINS Hostname detected."
        }
        # **Hostname Validation (Non-FQDN)**
        elseif ($Hostname -match "^(?!-)([A-Za-z0-9-]{1,63})(?<!-)$") {
            LogMessage "Valid hostname detected." "Info"
            $output.HostnameType = "Hostname"
            $output.IsValid = $true
            $output.FQDN = $Hostname.ToLower()
            $output.Message = "Valid hostname (non-FQDN) detected."
            
            # Derive NetBIOS Hostname (truncate if needed)
            if ($Hostname.Length -gt 15) {
                $output.NetBIOS = $Hostname.Substring(0, 15).ToUpper()
            } else {
                $output.NetBIOS = $Hostname.ToUpper()
            }
        }
        # **FQDN Validation (Root Suffix Required)**
        elseif ($Hostname -match "^(?!-)([A-Za-z0-9-]{1,63})(\.[A-Za-z0-9-]{1,63})+(\.)$") {
            LogMessage "Valid Fully Qualified Domain Hostname (FQDN) detected." "Info"
            $output.HostnameType = "FQDN"
            $output.IsValid = $true
            $output.FQDN = $Hostname.ToLower()
            $output.Message = "Valid FQDN detected with root suffix dot."
            
            # Extract Hostname from FQDN
            $hostname = $Hostname -replace "\..*$", ""
            $output.Hostname = $hostname.ToLower()

            # Derive NetBIOS Hostname from Hostname (truncate if needed)
            if ($hostname.Length -gt 15) {
                $output.NetBIOS = $hostname.Substring(0, 15).ToUpper()
            } else {
                $output.NetBIOS = $hostname.ToUpper()
            }
        }
        # **Invalid Cases with Specific Errors**
        else {
            if ($Hostname.Length -gt 253) {
                LogMessage "Error: Hostname exceeds the maximum 253-character limit." "Error"
                $output.Message = "Invalid: Hostname exceeds 253-character limit."
            }
            elseif ($Hostname -match "[^A-Za-z0-9-.]") {
                LogMessage "Error: Hostname contains invalid characters (only letters, numbers, hyphens, and dots allowed)." "Error"
                $output.Message = "Invalid: Contains unsupported characters."
            }
            elseif ($Hostname -match "^-" -or $Hostname -match "-$") {
                LogMessage "Error: Hostnames/FQDNs cannot start or end with a hyphen (-)." "Error"
                $output.Message = "Invalid: Hostname/FQDN cannot start or end with a hyphen."
            }
            elseif ($Hostname -match "^[A-Za-z0-9-.]+$" -and -not $Hostname.EndsWith(".")) {
                LogMessage "Error: FQDNs must end with a root suffix dot (e.g., 'example.com.')." "Error"
                $output.Message = "Invalid: FQDN missing root suffix dot."
            }
            elseif ($Hostname.Length -gt 15 -and $Hostname -match "^[A-Za-z0-9!@#\$%\^&\(\)-'{\}\.~]+$") {
                LogMessage "Error: NetBIOS/WINS names cannot exceed 15 characters." "Error"
                $output.Message = "Invalid: NetBIOS/WINS Hostname exceeds 15 characters."
            }
            elseif ($Hostname -match "\.\.") {
                LogMessage "Error: Consecutive dots are not allowed in hostnames/FQDNs." "Error"
                $output.Message = "Invalid: Consecutive dots are not allowed."
            }
            elseif ($Hostname -match "[A-Za-z0-9-]\-\-[A-Za-z0-9-]") {
                LogMessage "Error: Double hyphen within a domain label is not allowed (except in IDNs)." "Error"
                $output.Message = "Invalid: Double hyphen within a domain label."
            }                        
            else {
                LogMessage "Error: Hostname format is invalid and does not fit NetBIOS, Hostname, or FQDN standards." "Error"
                $output.Message = "Invalid: Hostname does not conform to any standard."
            }

            $output.HostnameType = "Invalid"
            $output.IsValid = $false
        }

        LogMessage "Validation complete for: $Hostname" "Info"
        return $output
    }
}
