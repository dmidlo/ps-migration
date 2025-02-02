function Start-psMigrationServer {
    [CmdletBinding()]
    param(
        [int]$HttpPort,
        [int]$HttpsPort,
        [switch]$Dev
    )

    Write-Host "Starting ps-migration on port $HttpPort..."

    Start-PodeServer -RootPath "$((Get-Location).Path)" -EnablePool Tasks -Browse -ScriptBlock {
        if ($HttpPort) {
            $usedHttpPort = $HttpPort
        } else {
            $usedHttpPort = (Get-PodeConfig).HttpPort
        }

        if ($HttpsPort) {
            $usedHttpsPort = $HttpsPort
        } else {
            $usedHttpsPort = (Get-PodeConfig).HttpsPort
        }
        
        
        # Add HTTP Endpoints
        Add-PodeEndpoint -Address 0.0.0.0 -Port $usedHttpPort -Protocol Http -Hostname "localhost"
        Add-PodeEndpoint -Address 0.0.0.0 -Port $usedHttpPort -Protocol Http -Hostname "migration"
        
        # Create Dev Terminal Logging
        if ($Dev) {
            New-PodeLoggingMethod -Terminal | Enable-PodeErrorLogging -Levels Error, Warning, Informational, Verbose, Debug
            New-PodeLoggingMethod -Terminal | Enable-PodeRequestLogging -Raw
        }

        # Setup Logging to Windows Event Log
        try { 
            [System.Diagnostics.EventLog]::CreateEventSource('Pode', 'Application') 
            New-PodeLoggingMethod -EventViewer | Enable-PodeErrorLogging -Levels Error, Warning, Informational, Verbose, Debug 
            New-PodeLoggingMethod -EventViewer | Enable-PodeRequestLogging -Raw
            [System.Exception]::new("Pode started at $(Get-Date)") | Write-PodeErrorLog -Level informational
        } catch { }

        # Setup Pod.Web Templates
        Use-PodeWebTemplates -Title "Migration" -Theme Light

        # Setup Session Handling
        Enable-PodeSessionMiddleware -Duration 1200 -Extend -Strict
        
        if (-not $Dev) {
            # Setup Login Form With Domain Authentication
            New-PodeAuthScheme -Form | Add-PodeAuthWindowsAd -Name "WinAuth"
            Set-PodeWebLoginPage -Authentication "WinAuth"
        }

        #Setup Database Connection
        $dbConnection = Initialize-DB -DBPath (Get-PodeConfig).databasePath
        Set-PodeState -Name "dbConnection" -Value $dbConnection
        Initialize-Collections -Connection (Get-PodeState -Name "dbConnection") -SampleData
        
        # Register Tasks with Web Server
        Add-HostServicesStatusTask
        Add-GetKnownHostsTask
        
        # Main
        New-PodeServerHostsPage
        New-PodeServerToolsPage
    }
}