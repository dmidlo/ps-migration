function Test-MACAddressString {
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [Alias('MAC')]
        [string]$MacAddress,
        [string]$CacheFile,
        [int]$CacheDays,
        [switch]$SkipOUI
    )

    process {
        # Output Object Template
        $output = [PSCustomObject]@{
            IsValid        = $false
            MacAddress  = $null
            Message = ""
        }

        # Ensure input is not null or empty
        if ([string]::IsNullOrWhiteSpace($MacAddress)) {
            $err = "Invalid input: MAC address cannot be empty or null."
            Write-Error $err
            $output.MacAddress = $MacAddress
            $output.Message = $err
            return $output
        }

        # Remove common separators and whitespace
        $cleanedMac = $MacAddress -replace '[-:\.\s]', ''

        # Validate length
        if ($cleanedMac.Length -ne 12) {
            $err = "Invalid MAC address length: $MacAddress"
            Write-Error $err
            $output.MacAddress = $MacAddress
            $output.Message = $err
            return $output
        }

        # Validate that all characters are hexadecimal (0-9, A-F)
        if ($cleanedMac -notmatch '^[0-9A-Fa-f]{12}$') {
            $err = "Invalid MAC address format: contains non-hexadecimal characters - $MacAddress"
            Write-Error $err
            $output.MacAddress = $MacAddress
            $output.Message = $err
            return $output
        }

        # Convert to uppercase for consistency
        $cleanedMac = $cleanedMac.ToUpper()

        # Check if it's a broadcast address (FF:FF:FF:FF:FF:FF)
        if ($cleanedMac -eq 'FFFFFFFFFFFF') {
            $err = "Invalid MAC address: Cannot be a broadcast address - $MacAddress"
            Write-Error $err
            $output.MacAddress = $MacAddress
            $output.Message = $err
            return $output
        }

        # Extract first byte and convert it to an integer
        $firstByte = [convert]::ToInt32($cleanedMac.Substring(0, 2), 16)

        # Check if it's a multicast address (first byte's least significant bit is 1)
        if ($firstByte -band 1) {
            $err = "Invalid MAC address: Cannot be a multicast address - $MacAddress"
            Write-Error $err
            $output.MacAddress = $MacAddress
            $output.Message = $err
            return $output
        }

        # Check if it is a valid OUI
        if (-not $SkipOUI) {
            $OUIList = Get-IEEEOUIList -CacheFile $CacheFile -CacheDays $CacheDays
            if (-not (Test-OUI -MacAddress $cleanedMac -OUIHashTable $OUIList)) {
                $err = "Unregistered OUI: $OUI is not found in the official IEEE list."
                Write-Error $err
                $output.MacAddress = $MacAddress
                $output.Message = $err
                return $output
            }
        }

        

        # Format as colon-separated uppercase
        $formattedMac = ($cleanedMac -split '(?<=\G.{2})(?=.)') -join ':'
        Write-Output $formattedMac
        $output.MacAddress = $formattedMac
        $output.IsValid = $true
        return $output
    }
}
