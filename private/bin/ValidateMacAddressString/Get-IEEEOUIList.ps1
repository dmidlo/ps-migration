function Get-IEEEOUIList {
    [CmdletBinding()]
    param (
        [string]$OUIUrl = "https://standards-oui.ieee.org/oui/oui.txt",
        [string]$CacheFile = "$PSScriptRoot\StoredObjects\OUIList.clixml",
        [int]$CacheDays = 1
    )

    process {
        try {
            if ((Test-Path $CacheFile) -and ($CacheDays -gt 0)) {
                $FileAge = (Get-Item $CacheFile).CreationTime
                $ExpirationTime = $FileAge.AddDays($CacheDays)
            
                if ((Get-Date) -lt $ExpirationTime) {
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