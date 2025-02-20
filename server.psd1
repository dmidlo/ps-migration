@{
    HttpPort = 80
    HttpsPort = 443
    databasePath = ".\StoredObjects\ps-migration.db"
    dhcptestPath = ".\private\bin\dhcptest-0.9-win64.exe"
    Server = @{
        Ssl = @{
            Protocols = @("TLS","TLS11","TLS12")
        }
        FileMonitor = @{
            Enable = $true
            Include = @("*.psd1", "*.ps1")
            ShowFiles = $true
        }
    }
    Web = @{
        Compression = @{
            Enable = $true
        }
    }
    Audience = 'Your backend AppId' # backend API AppId
    TenantId = 'Your TenantId'
    issuers = @("https://login.microsoftonline.com/your tenant Id/v2.0", "https://login.microsoftonline.com/-anothertenantId-/v2.0")
}