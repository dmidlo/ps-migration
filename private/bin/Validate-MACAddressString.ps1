function Get-IEEEOUIList {
    [CmdletBinding()]
    param (
        [string]$OUIUrl = "https://standards-oui.ieee.org/oui/oui.txt",
        [string]$CacheFile = "$env:TEMP\OUIList.clixml",
        [int]$CacheDays = 1
    )

    process {
        try {
            if ((Test-Path $CacheFile) -and ($CacheDays -gt 0)) {
                $FileAge = (Get-Item $CacheFile).CreationTime
                if ((Get-Date) - $FileAge -lt (New-TimeSpan -Days $CacheDays)) {
                    return Import-Clixml -Path $CacheFile
                }
            }

            Write-Verbose "Downloading OUI list from IEEE..."
            $OUIData = Invoke-WebRequest -Uri $OUIUrl -UseBasicParsing | Select-Object -ExpandProperty Content
            
            if (-not $OUIData) {
                throw "OUI data download failed or returned empty content."
            }
            
            $OUIHashTable = @{}
            $OUIData -split "`n" | ForEach-Object {
                if ($_ -match '^([0-9A-Fa-f]{2}-[0-9A-Fa-f]{2}-[0-9A-Fa-f]{2})\s+\(hex\)\s+(.+)$') {
                    $OUIHashTable[$matches[1] -replace '-', ''] = $matches[2].Trim()
                }
            }

            if ($OUIHashTable.Count -eq 0) {
                throw "Parsed OUI list is empty, possible download or format issue."
            }

            $OUIHashTable | Export-Clixml -Path $CacheFile
            return $OUIHashTable
        } catch {
            Write-Error "Failed to retrieve OUI list: $_"
            return @{}
        }
    }
}


function Validate-OUI {
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


function Validate-MACAddressString {
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [Alias('MAC')]
        [string]$MacAddress,
        [switch]$SkipOUI
    )

    process {
        # Ensure input is not null or empty
        if ([string]::IsNullOrWhiteSpace($MacAddress)) {
            $err = "Invalid input: MAC address cannot be empty or null."
            Write-Error $err
            return $false, $err
        }

        # Remove common separators and whitespace
        $cleanedMac = $MacAddress -replace '[-:\.\s]', ''

        # Validate length
        if ($cleanedMac.Length -ne 12) {
            $err = "Invalid MAC address length: $MacAddress"
            Write-Error $err
            return $false, $err
        }

        # Validate that all characters are hexadecimal (0-9, A-F)
        if ($cleanedMac -notmatch '^[0-9A-Fa-f]{12}$') {
            $err = "Invalid MAC address format: contains non-hexadecimal characters - $MacAddress"
            Write-Error $err
            return $false, $err
        }

        # Convert to uppercase for consistency
        $cleanedMac = $cleanedMac.ToUpper()

        # Check if it's a broadcast address (FF:FF:FF:FF:FF:FF)
        if ($cleanedMac -eq 'FFFFFFFFFFFF') {
            $err = "Invalid MAC address: Cannot be a broadcast address - $MacAddress"
            Write-Error $err
            return $false, $err
        }

        # Extract first byte and convert it to an integer
        $firstByte = [convert]::ToInt32($cleanedMac.Substring(0, 2), 16)

        # Check if it's a multicast address (first byte's least significant bit is 1)
        if ($firstByte -band 1) {
            $err = "Invalid MAC address: Cannot be a multicast address - $MacAddress"
            Write-Error $err
            return $false, $err
        }

        # Check if it is a valid OUI
        if (-not $SkipOUI) {
            $OUIList = Get-IEEEOUIList -CacheDays 1
            if (-not (Validate-OUI -MacAddress $cleanedMac -OUIHashTable $OUIList)) {
                $err = "Unregistered OUI: $OUI is not found in the official IEEE list."
                Write-Error $err
                return $false, $err
            }
        }

        

        # Format as colon-separated uppercase
        $formattedMac = ($cleanedMac -split '(?<=\G.{2})(?=.)') -join ':'
        Write-Output $formattedMac
        return $true, $formattedMac
    }
}


