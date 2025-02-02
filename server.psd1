@{
    HttpPort = 80
    HttpsPort = 443
    BlaineSeachScopeDN = "OU=LL Users,OU=CMI Users,OU=CMI,DC=northstar,DC=local"
    PlymouthSearchScopeDN = "OU=MP Users,OU=CMI Users,OU=CMI,DC=northstar,DC=local"
    northstarSearchScopeDN = "DC=northstar,DC=local"
    databasePath = ".\StoredObjects\ps-migration.db"
    dhcptestPath = "C:\Users\AVT.ASA\Desktop\CMIENTRAIDSYNC-Archive\bin\dhcptest-0.9-win64.exe"
    Server = @{
        Ssl = @{
            Protocols = @("TLS","TLS11","TLS12")
        }
        # FileMonitor = @{
        #     Enable = $true
        #     Include = @("*.psd1", "*.ps1")
        #     ShowFiles = $true
        # }
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