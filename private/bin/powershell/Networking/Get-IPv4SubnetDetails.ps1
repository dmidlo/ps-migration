function Get-IPv4SubnetDetails {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string]$IPAddress,

        [Parameter(Mandatory = $false)]
        [ValidateRange(1, 32)]
        [int]$CIDR
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

        # Validate IP Address
        if ($IPAddress -notmatch '^(\d{1,3}\.){3}\d{1,3}$') {
            LogMessage "Invalid IPv4 format: $IPAddress" "Error"
            return [PSCustomObject]@{
                IPAddress = $IPAddress
                IsValid   = $false
                Message   = "Invalid IPv4 format: $IPAddress"
            }
        }

        # Split and Validate Octets
        $Octets = $IPAddress -split '\.'
        foreach ($Octet in $Octets) {
            if ([int]$Octet -lt 0 -or [int]$Octet -gt 255) {
                LogMessage "Invalid octet value in IP: $IPAddress" "Error"
                return [PSCustomObject]@{
                    IPAddress = $IPAddress
                    IsValid   = $false
                    Message   = "Invalid octet value in IP: $IPAddress"
                }
            }
        }

        LogMessage "Processing IP: $IPAddress" "Info"

        # If no CIDR is provided, return basic validation results
        if (-not $PSBoundParameters.ContainsKey("CIDR")) {
            LogMessage "No CIDR provided. Returning validation result only." "Info"
            return [PSCustomObject]@{
                IPAddress = $IPAddress
                IsValid   = $true
                Message   = "Valid IPv4 format detected. No CIDR provided, so no subnet calculations performed."
            }
        }

        LogMessage "Performing subnet calculations for $IPAddress/$CIDR" "Info"

        # Convert IP to Integer
        function Convert-IPv4ToInt($ip) {
            ($ip -split '\.') | ForEach-Object { [int]$_ } | ForEach-Object -Begin { $int = 0 } -Process { $int = ($int -shl 8) -bor $_ } -End { $int }
        }

        function Convert-IntToIPv4($int) {
            (3..0 | ForEach-Object { ($int -shr ($_ * 8)) -band 255 }) -join '.'
        }

        $ipInt = Convert-IPv4ToInt $IPAddress

        # **FIXED SUBNET MASK CALCULATION**
        $maskInt = ((0xFFFFFFFF -shl (32 - $CIDR)) -band 0xFFFFFFFF)

        # Calculate Addresses
        $networkInt = $ipInt -band $maskInt
        $broadcastInt = $networkInt -bor (-bnot $maskInt -band 0xFFFFFFFF)
        $firstHostInt = if ($CIDR -lt 31) { $networkInt + 1 } else { $networkInt }
        $lastHostInt = if ($CIDR -lt 31) { $broadcastInt - 1 } else { $broadcastInt }

        # Convert Back to IPv4
        $SubnetMask = Convert-IntToIPv4 $maskInt
        $NetworkAddress = Convert-IntToIPv4 $networkInt
        $BroadcastAddress = Convert-IntToIPv4 $broadcastInt
        $FirstUsableHost = Convert-IntToIPv4 $firstHostInt
        $LastUsableHost = Convert-IntToIPv4 $lastHostInt

        # Wildcard Mask (Inverse of Subnet Mask)
        $WildcardMask = Convert-IntToIPv4 (-bnot $maskInt -band 0xFFFFFFFF)

        # Total Addresses & Usable Hosts
        $TotalIPs = [math]::Pow(2, (32 - $CIDR))
        $UsableHosts = if ($CIDR -ge 31) { 0 } else { $TotalIPs - 2 }

        # Determine if IP is a valid host
        $IsHost = ($IPAddress -ne $NetworkAddress -and $IPAddress -ne $BroadcastAddress)

        # Determine IP Class
        $FirstOctet = [int]$Octets[0]
        $IPClass = switch ($FirstOctet) {
            { $_ -le 126 } { "Class A" }
            { $_ -ge 128 -and $_ -le 191 } { "Class B" }
            { $_ -ge 192 -and $_ -le 223 } { "Class C" }
            { $_ -ge 224 -and $_ -le 239 } { "Class D (Multicast)" }
            { $_ -ge 240 } { "Class E (Reserved)" }
        }

        # Determine Public or Private
        $IsPrivate = if (
            ($FirstOctet -eq 10) -or
            ($FirstOctet -eq 172 -and ([int]$Octets[1] -ge 16 -and [int]$Octets[1] -le 31)) -or
            ($FirstOctet -eq 192 -and [int]$Octets[1] -eq 168)
        ) { $true } else { $false }

        # Modify Message If IP is Not a Host
        if (-not $IsHost) {
            if ($IPAddress -eq $NetworkAddress) {
                $err = "$IPAddress is the network address and cannot be assigned to a host."
                LogMessage $err "Warning"
                return [PSCustomObject]@{
                    IPAddress = $IPAddress
                    IsValid   = $true
                    IsHost    = $false
                    Message   = $err
                }
            } elseif ($IPAddress -eq $BroadcastAddress) {
                $err = "$IPAddress is the broadcast address of the subnet and cannot be assigned to a host."
                LogMessage $err "Warning"
                return [PSCustomObject]@{
                    IPAddress = $IPAddress
                    IsValid   = $true
                    IsHost    = $false
                    Message   = $err
                }
            }
        }

        # Create Output Object
        $result = [PSCustomObject]@{
            IPAddress        = $IPAddress
            CIDR             = $CIDR
            SubnetMask       = $SubnetMask
            WildcardMask     = $WildcardMask
            NetworkAddress   = $NetworkAddress
            BroadcastAddress = $BroadcastAddress
            FirstUsableHost  = if ($CIDR -ge 31) { "N/A" } else { $FirstUsableHost }
            LastUsableHost   = if ($CIDR -ge 31) { "N/A" } else { $LastUsableHost }
            TotalIPs         = $TotalIPs
            UsableHosts      = $UsableHosts
            IPClass          = $IPClass
            IsPrivate        = $IsPrivate
            IsValid          = $true
            IsHost           = $IsHost
            Message          = $logs -join "`n"
        }

        LogMessage "Calculation complete for $IPAddress/$CIDR" "Info"

        return $result
    }
}
