function Start-PsMigration {
    [CmdletBinding()]
    param(
        [switch]$Dev,
        [switch]$Test,
        [switch]$ResetDatabase,
        [string]$DatabasePath = "$PSScriptRoot\StoredObjects\ps-migration.db",
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
        $module = "ps-migration"
        try {
            Import-Module -Name $module -Force -ErrorAction Stop
            Write-Verbose "Imported module: $module"
        }
        catch {
            Write-Warning "Failed to import module '$module': $_"
        }

        Write-Verbose "Maintenance tasks completed."

        # If test mode is specified, run Pester tests
        if ($Test) {
            try {
                # Ensure the Pester module is imported
                if (-not (Get-Module -Name Pester)) {
                    $null = Import-Module -Name Pester -PassThru -ErrorAction Stop
                    Write-Verbose "Imported Pester module."
                }

                # Create a new Pester configuration object using New-PesterConfiguration
                $PesterDebugConfiguration = New-PesterConfiguration

                # Enable Debugging Messages
                # $PesterDebugConfiguration.Debug.WriteDebugMessages = $true
                # $PesterDebugConfiguration.Debug.WriteDebugMessagesFrom = @('*')  # Capture all debug sources
                # $PesterDebugConfiguration.Debug.ShowFullErrors = $true           # Show full error stack traces

                # Enable Navigation Markers in VS Code
                $PesterDebugConfiguration.Debug.ShowNavigationMarkers = $true

                # Set Error Handling for Tests
                $PesterDebugConfiguration.Should.ErrorAction = 'Stop'  # Stop execution on the first encountered error

                # Configure Test Run Behavior
                $PesterDebugConfiguration.Run.PassThru = $true         # Return results to pipeline for further analysis
                $PesterDebugConfiguration.Run.SkipRun = $false         # Ensure tests actually run
                $PesterDebugConfiguration.Run.SkipRemainingOnFailure = 'Block' # Stop execution within a block if a test fails

                # Filter Configuration for Debugging Specific Tests
                $PesterDebugConfiguration.Filter.Tag = @('AppendOnlyStore')  # Run only tests with these tags
                # $PesterDebugConfiguration.Filter.ExcludeTag = @('Slow')        # Exclude slow tests from debug runs

                # Code Coverage Settings
                # $PesterDebugConfiguration.CodeCoverage.Enabled = $true         # Enable code coverage
                # $PesterDebugConfiguration.CodeCoverage.OutputFormat = 'CoverageGutters' # More detailed output format
                # $PesterDebugConfiguration.CodeCoverage.OutputPath = 'cov.xml'
                # $PesterDebugConfiguration.CodeCoverage.UseBreakpoints = $false # Use Profiler-based tracing instead of breakpoints
                # $PesterDebugConfiguration.CodeCoverage.SingleHitBreakpoints = $true

                # Test Result Logging
                # $PesterDebugConfiguration.TestResult.Enabled = $true
                # $PesterDebugConfiguration.TestResult.OutputFormat = 'NUnit3' # Standard NUnit XML format
                # $PesterDebugConfiguration.TestResult.OutputPath = 'testResults.xml'

                # Output Configuration
                $PesterDebugConfiguration.Output.Verbosity = 'Detailed' # Provide maximum output details
                # $PesterDebugConfiguration.Output.StackTraceVerbosity = 'Full' # Show full stack traces for errors
                # $PesterDebugConfiguration.Output.RenderMode = 'Ansi'  # Use ANSI for better terminal output formatting

                # Enabling TestDrive and TestRegistry for Isolated Testing
                $PesterDebugConfiguration.TestDrive.Enabled = $true
                $PesterDebugConfiguration.TestRegistry.Enabled = $true

                # Store the Configuration Globally in $PesterPreference
                $PesterPreference = $PesterDebugConfiguration

                Invoke-Pester -Configuration $PesterDebugConfiguration
            }
            catch {
                Write-Warning "Failed to run Pester tests: $_"
            }
        }
    }

    # Start the migration server (this happens in both Dev and non-Dev modes)
    try {
        if(-not $Test) {
            Start-PsMigrationServer -HttpPort $HttpPort -HttpsPort $HttpsPort -Dev:$Dev.IsPresent
            Write-Verbose "psMigration server started on HTTP port $HttpPort and HTTPS port $HttpsPort."
        }
    }
    catch {
        Write-Error "Failed to start psMigration server: $_"
    }
}
