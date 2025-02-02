function Start-psMigrationServer {
    [CmdletBinding()]
    param(
        [int]$HttpPort,
        [int]$HttpsPort
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
        
        # Create Event Log Source
        New-PodeLoggingMethod -Terminal | Enable-PodeErrorLogging -Levels Error, Warning, Informational, Verbose, Debug
        New-PodeLoggingMethod -Terminal | Enable-PodeRequestLogging -Raw
        try { 
            [System.Diagnostics.EventLog]::CreateEventSource('Pode', 'Application') 
            New-PodeLoggingMethod -EventViewer | Enable-PodeErrorLogging -Levels Error, Warning, Informational, Verbose, Debug 
            New-PodeLoggingMethod -EventViewer | Enable-PodeRequestLogging -Raw
            [System.Exception]::new("Pode started at $(Get-Date)") | Write-PodeErrorLog -Level informational
        } catch { }

        #Setup Pode Web Templates with Domain Authentication
        Use-PodeWebTemplates -Title "Migration" -Theme Light
        Enable-PodeSessionMiddleware -Duration 1200 -Extend -Strict
        New-PodeAuthScheme -Form | Add-PodeAuthWindowsAd -Name "WinAuth"
        Set-PodeWebLoginPage -Authentication "WinAuth"

        #Setup Database Connection
        $dbConnection = Initialize-DB -DBPath (Get-PodeConfig).databasePath
        Set-PodeState -Name "dbConnection" -Value $dbConnection
        Initialize-Collections -Connection (Get-PodeState -Name "dbConnection") -SampleData
        
        Add-HostServicesStatusTask
        Add-GetKnownHostsTask
        
        New-PodeServerHostsPage
        New-PodeServerToolsPage
    }
}