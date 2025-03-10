function Get-IEEEOUIList {
    [CmdletBinding()]
    param (
        [string]$CacheFile = "$env:TEMP\ieee_oui_list.clixml",
        [int]$CacheDays = 1,
        [string]$OUIUrl = "https://standards-oui.ieee.org/oui/oui.txt"
    )

    process {
        try {
            # Check if a valid cached file exists
            if ((Test-Path $CacheFile) -and ($CacheDays -gt 0)) {
                if ((Get-Item $CacheFile).CreationTime.AddDays($CacheDays) -gt (Get-Date)) {
                    Write-Verbose "Using cached OUI data from: $CacheFile"
                    Write-Output (Import-Clixml -Path $CacheFile)
                    return
                } else {
                    Write-Verbose "Cache expired. Removing old file: $CacheFile"
                    Remove-Item -Path $CacheFile -Force
                }
            }

            # Download the latest OUI list
            Write-Verbose "Downloading OUI list from IEEE..."
            $OUIData = Invoke-WebRequest -Uri $OUIUrl -UseBasicParsing | Select-Object -ExpandProperty Content

            if (-not $OUIData) {
                Write-Error "OUI data download failed: Empty content received."
                Write-Output @{}
                return
            }

            # Parse OUI data
            $OUIHashTable = @{}
            $OUIData -split "`n" | ForEach-Object {
                if ($_ -match '^(?<OUI>[0-9A-Fa-f]{2}-[0-9A-Fa-f]{2}-[0-9A-Fa-f]{2})\s+\(hex\)\s+(?<Vendor>.+)$') {
                    $OUIHashTable[$matches.OUI -replace '-', ''] = $matches.Vendor.Trim()
                }
            }

            if ($OUIHashTable.Count -eq 0) {
                Write-Error "Parsed OUI list is empty. Possible format issue."
                Write-Output @{}
                return
            }

            # Save to cache
            $OUIHashTable | Export-Clixml -Path $CacheFile
            (Get-Item $CacheFile).CreationTime = (Get-Date)
            Write-Output $OUIHashTable
        } catch {
            Write-Error "Failed to retrieve OUI list: $_"
            Write-Output @{}
        }
    }
}
