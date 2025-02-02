function Start-psMigration {
    [CmdletBinding()]
    param(
        [switch]$Dev,
        [switch]$Test,
        [switch]$ResetDatabase,
        [string]$DatabasePath = ".\StoredObjects\ps-migration.db",
        [switch]$Clear,
        [int]$HttpPort = 8080,
        [int]$HttpsPort = 8443
    )

    # Clear the host if requested
    if ($Clear) {
        Clear-Host
    }

    # Reset the database if requested
    if ($ResetDatabase) {
        Write-Verbose "Resetting the migration database..."
        if (Test-Path $DatabasePath) {
            try {
                Remove-Item $DatabasePath -Force -ErrorAction Stop
                Write-Verbose "Database file removed: $DatabasePath"
            }
            catch {
                Write-Warning "Failed to remove the database file '$DatabasePath': $_"
            }
        }
        else {
            Write-Verbose "No database file found at: $DatabasePath"
        }
    }

    # If in development mode, perform additional tasks
    if ($Dev) {
        # Import the ps-migration module
        $modulePath = Join-Path -Path $PSScriptRoot -ChildPath "ps-migration.psd1"
        try {
            Import-Module -Name $modulePath -Force -ErrorAction Stop
            Write-Verbose "Imported module: $modulePath"
        }
        catch {
            Write-Warning "Failed to import module from '$modulePath': $_"
        }

        Write-Verbose "Maintenance tasks completed."

        # If test mode is specified, run Pester tests
        if ($Test) {
            try {
                # Ensure the Pester module is imported
                if (-not (Get-Module -Name Pester)) {
                    Import-Module -Name Pester -PassThru -ErrorAction Stop | Out-Null
                    Write-Verbose "Imported Pester module."
                }
                Invoke-Pester -Output Detailed -Verbose -Debug
            }
            catch {
                Write-Warning "Failed to run Pester tests: $_"
            }
        }
    }

    # Start the migration server (this happens in both Dev and non-Dev modes)
    try {
        if(-not $Test) {
            Start-psMigrationServer -HttpPort $HttpPort -HttpsPort $HttpsPort
            Write-Verbose "psMigration server started on HTTP port $HttpPort and HTTPS port $HttpsPort."
        }
    }
    catch {
        Write-Error "Failed to start psMigration server: $_"
    }
}
