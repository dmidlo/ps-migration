function Initialize-Collections {
    param(
        [Parameter(Mandatory=$true)]
        [LiteDB.LiteDatabase]
        $Database,
        [switch]
        $SampleData
    )

    Write-PodeHost "Initializing collections and indexes using dbConnection:"
    Out-PodeHost -InputObject $Database

    # Ensure-LiteDBCollection -Database $Database -CollectionName 'Temp' -Indexes @(
    #     [PSCustomObject]@{ Field='Hash'; Unique=$true },
    #     [PSCustomObject]@{ Field="Guid"; Unique=$false}
    # )
    # Ensure-LiteDBCollection -Database $Database -CollectionName 'RecycleBin' -Indexes @(
    #     [PSCustomObject]@{ Field='Hash'; Unique=$true }
    #     [PSCustomObject]@{ Field="Guid"; Unique=$false}
    # )

    ###############################################################################
    # Organizations
    ###############################################################################
    Ensure-LiteDBCollection -Database $Database -CollectionName 'Organizations' -Indexes @(
        [PSCustomObject]@{ Field='Hash'; Unique=$true }
        [PSCustomObject]@{ Field="Guid"; Unique=$false}
    )
    Ensure-LiteDBCollection -Database $Database -CollectionName 'Regions' -Indexes @(
        [PSCustomObject]@{ Field='Hash'; Unique=$true }
        [PSCustomObject]@{ Field="Guid"; Unique=$false}
    )
    Ensure-LiteDBCollection -Database $Database -CollectionName 'Campuses' -Indexes @(
        [PSCustomObject]@{ Field='Hash'; Unique=$true }
        [PSCustomObject]@{ Field="Guid"; Unique=$false}
    )
    Ensure-LiteDBCollection -Database $Database -CollectionName 'Sites' -Indexes @(
        [PSCustomObject]@{ Field='Hash'; Unique=$true }
        [PSCustomObject]@{ Field="Guid"; Unique=$false}
    )
    Ensure-LiteDBCollection -Database $Database -CollectionName 'Floors' -Indexes @(
        [PSCustomObject]@{ Field='Hash'; Unique=$true }
        [PSCustomObject]@{ Field="Guid"; Unique=$false}
    )
    Ensure-LiteDBCollection -Database $Database -CollectionName 'Areas' -Indexes @(
        [PSCustomObject]@{ Field='Hash'; Unique=$true }
        [PSCustomObject]@{ Field="Guid"; Unique=$false}
    )
    Ensure-LiteDBCollection -Database $Database -CollectionName 'Rooms' -Indexes @(
        [PSCustomObject]@{ Field='Hash'; Unique=$true }
        [PSCustomObject]@{ Field="Guid"; Unique=$false}
    )
    Ensure-LiteDBCollection -Database $Database -CollectionName 'Racks' -Indexes @(
        [PSCustomObject]@{ Field='Hash'; Unique=$true }
        [PSCustomObject]@{ Field="Guid"; Unique=$false}
    )
    Ensure-LiteDBCollection -Database $Database -CollectionName 'Panels' -Indexes @(
        [PSCustomObject]@{ Field='Hash'; Unique=$true }
        [PSCustomObject]@{ Field="Guid"; Unique=$false}
    )
    Ensure-LiteDBCollection -Database $Database -CollectionName 'Channels' -Indexes @(
        [PSCustomObject]@{ Field='Hash'; Unique=$true }
        [PSCustomObject]@{ Field="Guid"; Unique=$false}
    )
    Ensure-LiteDBCollection -Database $Database -CollectionName 'Circuits' -Indexes @(
        [PSCustomObject]@{ Field='Hash'; Unique=$true }
        [PSCustomObject]@{ Field="Guid"; Unique=$false}
    )
    Ensure-LiteDBCollection -Database $Database -CollectionName 'Providers' -Indexes @(
        [PSCustomObject]@{ Field='Hash'; Unique=$true }
        [PSCustomObject]@{ Field="Guid"; Unique=$false}
    )

    # Ensure-LiteDBCollection -Database $Database -CollectionName 'Components' -Indexes @(
    #     [PSCustomObject]@{ Field='Hash'; Unique=$true }
    #     [PSCustomObject]@{ Field="Guid"; Unique=$false}
    # )

    Ensure-LiteDBCollection -Database $Database -CollectionName 'Chassis' -Indexes @(
        [PSCustomObject]@{ Field='Hash'; Unique=$true }
        [PSCustomObject]@{ Field="Guid"; Unique=$false}
    )
    ###############################################################################
    # HOSTS
    ###############################################################################
    Ensure-LiteDBCollection -Database $Database -CollectionName 'Modules' -Indexes @(
        [PSCustomObject]@{ Field='Hash'; Unique=$true }
        [PSCustomObject]@{ Field="Guid"; Unique=$false}
    )
    Ensure-LiteDBCollection -Database $Database -CollectionName 'Interfaces' -Indexes @(
        [PSCustomObject]@{ Field='Hash'; Unique=$true }
        [PSCustomObject]@{ Field="Guid"; Unique=$false}
    )
    # Ensure-LiteDBCollection -Connection $Connection -CollectionName 'IPv4Addresses' -Indexes @(
    #     [PSCustomObject]@{ Field='Hash'; Unique=$true }
    # )
    # Ensure-LiteDBCollection -Connection $Connection -CollectionName 'NetworkNames' -Indexes @(
    #     [PSCustomObject]@{ Field='Hash'; Unique=$true }
    # )

    # if ($SampleData) {
    #     $dcHost = Set-dbHost -FriendlyId "DC-001" `
    #             -Hostname "DC01.example.local" `
    #             -IPAddress "10.0.0.10" `
    #             -OSVersion "Windows Server 2022" `
    #             -DomainName "example.local" |
    #         Add-dbHostDomainController -FSMORoles @(
    #             [ordered]@{
    #                 RoleName = 'PDCEmulator'
    #                 FSMOHash = 'HASH-PDCEmulator'
    #                 FSMOGuid = 'GUID-PDCEmulator'
    #             },
    #             [ordered]@{
    #                 RoleName = 'RIDMaster'
    #                 FSMOHash = 'HASH-RIDMaster'
    #                 FSMOGuid = 'GUID-RIDMaster'
    #             },
    #             [ordered]@{
    #                 RoleName = 'InfrastructureMaster'
    #                 FSMOHash = 'HASH-InfrastructureMaster'
    #                 FSMOGuid = 'GUID-InfrastructureMaster'
    #             }
    #         )
    
    #     # Insert DC host data into the database
    #     $newHost = Add-DbDocument -Connection $Connection -CollectionName 'Hosts' -Data $dcHost
    # }

    # $hosts = Find-LiteDBDocument -Collection 'Hosts' -Connection $Connection
    # Out-PodeHost $hosts


    ###############################################################################
    # DOMAINS - FSMORoles
    ###############################################################################
    # Ensure-LiteDBCollection -Connection $Connection -CollectionName 'FSMORoles' -Indexes @( 
    #     [PSCustomObject]@{ Field='Hash'; Unique=$true }
    # )

    # # Define FSMO Roles
    # $FSMORolesData = @(
    #     @{
    #         RoleName = 'PDCEmulator'
    #     },
    #     @{
    #         RoleName = 'RIDMaster'
    #     },
    #     @{
    #         RoleName = 'InfrastructureMaster'
    #     },
    #     @{
    #         RoleName = 'SchemaMaster'
    #     },
    #     @{
    #         RoleName = 'DomainNamingMaster'
    #     }
    # )
    
    # $FSMORoles = @()
    # foreach ($fsmoRole in $FSMORolesData) {
    #     $UTC_Created  = [DateTimeOffset]::UtcNow.ToUnixTimeMilliseconds()
    #     $UTC_Updated  = [DateTimeOffset]::UtcNow.ToUnixTimeMilliseconds()

    #     if ($fsmoRole -in @('SchemaMaster', 'DomainNamingMaster')) {
    #         $Scope = "Forest"
    #     }
    #     else {
    #         $Scope = "Domain"
    #     }

    #     $fsmoRole['UTC_Created']  = [DateTimeOffset]::UtcNow.ToUnixTimeMilliseconds()
    #     $fsmoRole['UTC_Updated']  = [DateTimeOffset]::UtcNow.ToUnixTimeMilliseconds()
    #     $fsmoRole['Scope'] = $Scope

    #    $FSMORoles += $fsmoRole
    # }

    # foreach ($role in $FSMORoles) {
    #     $newFSMORole = Add-DbDocument -Connection $Connection -CollectionName 'FSMORoles' -Data $role
    # }

    # $fsmoRoles = Find-LiteDBDocument -Collection 'FSMORoles' -Connection $Connection
    # Out-PodeHost $fsmoRoles


    # $FSMORoles = @()
    # foreach ($role in $FSMORolesData) {
    #     if ($role -in @('SchemaMaster', 'DomainNamingMaster')) {
    #         $Scope = "Forest"
    #     }
    #     else {
    #         $Scope = "Domain"
    #     }

    #     $fsmoRoleData = @{
    #         RoleName = $role
    #         UTC_Created  = [DateTimeOffset]::UtcNow.ToUnixTimeMilliseconds()
    #         UTC_Updated  = [DateTimeOffset]::UtcNow.ToUnixTimeMilliseconds()
    #         Scope = $Scope
    #     }

    #     $FSMORoles += $fsmoRoleData
    # }

    # # $FSMORoles = Find-LiteDBDocument -Collection 'FSMORoles' -Connection $Connection
    # $FSMORoles | Out-PodeHost

    # $FSMORolesData = $FSMORolesData | ForEach-Object {
    #     if ($_ -in @('SchemaMaster', 'DomainNamingMaster')) {
    #         $Scope = "Forest"
    #     }
    #     else {
    #         $Scope = "Domain"
    #     }

    #     $fsmoRoleData = @{
    #         RoleName = $_
    #         UTC_Created = ([DateTimeOffset]::UtcNow.ToUnixTimeMilliseconds())
    #         Scope          = $Scope
    #     }

    #     $newFSMORole = Add-DbDocument -Connection $Connection -CollectionName 'FSMORoles' -Data $fsmoRoleData
    # }

    # $FSMORoles = Find-LiteDBDocument -Collection 'FSMORoles' -Connection $Connection
    # $FSMORoles | Out-PodeHost    

    
    
    ###############################################################################
    # DOMAINS - Forests
    ###############################################################################
    # Ensure-LiteDBCollection -Connection $Connection -CollectionName 'Forests' -Indexes @(
    #     [PSCustomObject]@{ Field='Hash'; Unique=$true }
    # )

    # if ($SampleData) {
    #     $forestData = @{
    #         FriendlyId       = 'FOREST-ALPHA'
    #         ForestFQDN       = 'example.local'        # The root forest domain
    #         ForestType       = 'OnPrem'               # Possible values: OnPrem, Cloud, Hybrid
    #         RootDomain       = 'example.local'        # The root domain in the forest
    #         SchemaVersion    = '87'                   # Example: Windows Server 2022 schema version
    #         FunctionalLevel  = 'Windows Server 2022'  # Functional level of the forest
        
    #         # Reference to FSMO roles collection
    #         FSMORoles        = @(
    #             @{
    #                 RoleName   = 'SchemaMaster'
    #                 FSMOHash   = 'HASH-SchemaMaster'
    #                 FSMOGuid   = 'GUID-SchemaMaster'
    #             },
    #             @{
    #                 RoleName   = 'DomainNamingMaster'
    #                 FSMOHash   = 'HASH-DomainNamingMaster'
    #                 FSMOGuid   = 'GUID-DomainNamingMaster'
    #             }
    #         )
        
    #         # Trust relationships at the forest level
    #         Trusts           = @(
    #             @{
    #                 TargetForest   = 'anotherforest.local'
    #                 TrustType      = 'Forest'           # Forest Trust
    #                 TrustDirection = 'Bidirectional'    # Incoming, Outgoing, Bidirectional
    #                 TrustMode      = 'Transitive'       # Transitive or NonTransitive
    #                 AuthType       = 'Kerberos'         # Kerberos, NTLM, etc.
    #             },
    #             @{
    #                 TargetForest   = 'external-forest.local'
    #                 TrustType      = 'External'
    #                 TrustDirection = 'Outgoing'
    #                 TrustMode      = 'NonTransitive'
    #                 AuthType       = 'NTLM'
    #             }
    #         )
        
    #         # DNS Configuration for the forest
    #         DNSConfig = @{
    #             RootDNSServers   = @('10.0.0.1', '10.0.0.2')  # Forest-wide primary and secondary DNS servers
    #             Forwarders       = @('8.8.8.8', '8.8.4.4')    # External DNS forwarders
    #             SecureUpdates    = $true
    #         }
        
    #         # Global Catalog Servers within the Forest
    #         GlobalCatalogServers = @(
    #             @{
    #                 Hostname   = 'GC01.example.local'
    #                 IPAddress  = '10.0.0.10'
    #                 SiteName   = 'SiteA'
    #             },
    #             @{
    #                 Hostname   = 'GC02.example.local'
    #                 IPAddress  = '10.0.0.11'
    #                 SiteName   = 'SiteB'
    #             }
    #         )
        
    #         # Sites and Services configuration for AD Forest replication
    #         Sites = @(
    #             @{
    #                 SiteName     = 'SiteA'
    #                 Subnets      = @('10.0.1.0/24', '10.0.2.0/24')
    #                 BridgeheadDC = 'DC01.example.local'
    #             },
    #             @{
    #                 SiteName     = 'SiteB'
    #                 Subnets      = @('192.168.1.0/24')
    #                 BridgeheadDC = 'DC02.example.local'
    #             }
    #         )
        
    #         # UPN Suffixes available across the forest
    #         UPN_Suffixes     = @('example.local', 'example.com')
        
    #         # Forest-wide Security Policies
    #         SecurityPolicies = @{
    #             KerberosPolicy = @{
    #                 MaxTicketLifetimeHours = 10
    #                 MaxRenewAgeDays        = 7
    #                 EnforcePreAuth         = $true
    #             }
    #             NTLMPolicy = @{
    #                 NTLMv1Allowed   = $false
    #                 NTLMv2Required  = $true
    #                 LMHashesStored  = $false
    #             }
    #             LDAPSecurity = @{
    #                 RequireSigning      = $true
    #                 RequireChannelBinding = $true
    #             }
    #         }
        
    #         # Forest-level Certificate Authority (PKI) configuration
    #         CertificateAuthorities = @(
    #             @{
    #                 CAName     = 'Enterprise-CA-1'
    #                 CAType     = 'Enterprise'  # Standalone, Enterprise
    #                 ServerName = 'PKI-Server01.example.local'
    #             },
    #             @{
    #                 CAName     = 'Enterprise-CA-2'
    #                 CAType     = 'Enterprise'
    #                 ServerName = 'PKI-Server02.example.local'
    #             }
    #         )
        
    #         # Metadata timestamps
    #         UTC_Created  = [DateTimeOffset]::UtcNow.ToUnixTimeMilliseconds()
    #         UTC_Updated  = [DateTimeOffset]::UtcNow.ToUnixTimeMilliseconds()
    #     }
        
    #     # Insert forest data into the database
    #     $newForest = Add-DbDocument -Connection $Connection -CollectionName 'Forests' -Data $forestData        
    # }

    ###############################################################################
    # DOMAINS
    ###############################################################################
    # Ensure-LiteDBCollection -Connection $Connection -CollectionName 'Domains' -Indexes @(
    #     [PSCustomObject]@{ Field='Hash'; Unique=$true }
    # )

    # $FSMORolesFromDB = Find-LiteDBDocument -Collection 'FSMORoles' -Connection $Connection

    # if ($SampleData) {
    #     $domainData = @{
    #         FriendlyId       = 'DOM-ALPHA'
    #         FQDN             = 'old-ad.example.local'
    #         NetBIOSName      = 'OLDAD'               # NetBIOS domain name
    #         DomainType       = 'OnPrem'              # Possible values: OnPrem, Cloud, Hybrid
    #         ForestName       = 'example.local'       # Forest to which this domain belongs
    #         ParentDomain     = 'parent.example.local' # If it's a child domain
    #         RootDomain       = 'example.local'       # Top-level root domain in the forest
        
    #         # Reference to FSMO roles collection
    #         FSMORoles        = Find-LiteDBDocument -Collection 'FSMORoles' -Connection $Connection
        
    #         # Reference to Trusts collection
    #         Trusts           = @('old-ad.example.local:new-ad.example.local', 'old-ad.example.local:legacy.example.local')
        
    #         # UPN Suffixes
    #         UPN_Suffixes     = @('old-ad.example.local', 'example.local', 'example.com')
        
    #         # DNS Configuration
    #         DNSSuffixes      = @('old-ad.example.local', 'example.local')
    #         DNSNameServers   = @('10.0.0.1', '10.0.0.2')  # Domain's primary and secondary name servers
    #         DNSSecureUpdates = $true
        
    #         # Linked Domain Controllers (Now referencing Hosts collection)
    #         DomainControllers = @('DC01.old-ad.example.local', 'DC02.old-ad.example.local')
        
    #         # Sibling/Peer Domains (Cross-Domain Coordination)
    #         SiblingDomains = @('child1.old-ad.example.local', 'child2.old-ad.example.local')
        
    #         # Timestamps
    #         UTC_Created  = [DateTimeOffset]::UtcNow.ToUnixTimeMilliseconds()
    #         UTC_Updated  = [DateTimeOffset]::UtcNow.ToUnixTimeMilliseconds()
    #     }
    #     $newDomain = Add-DbDocument -Connection $Connection -CollectionName 'Domains' -Data $domainData
    # }

    


    ###############################################################################
    # DOMAINS - Trusts
    ###############################################################################

    # Ensure-LiteDBCollection -Connection $Connection -CollectionName 'DomainTrusts' -Indexes @( 
    #     [PSCustomObject]@{ Field='Hash'; Unique=$true }
    # )

    # $trustData = @(
    #     @{
    #         SourceDomain   = 'old-ad.example.local'
    #         TargetDomain   = 'new-ad.example.local'
    #         TrustType      = 'Forest'          # Forest, External, Realm, Shortcut
    #         TrustDirection = 'Bidirectional'   # Incoming, Outgoing, Bidirectional
    #         TrustMode      = 'Transitive'      # Transitive or NonTransitive
    #         AuthType       = 'Kerberos'        # Kerberos, NTLM, etc.
    #     },
    #     @{
    #         SourceDomain   = 'old-ad.example.local'
    #         TargetDomain   = 'legacy.example.local'
    #         TrustType      = 'External'
    #         TrustDirection = 'Outgoing'
    #         TrustMode      = 'NonTransitive'
    #         AuthType       = 'NTLM'
    #     }
    # )

    # # Insert trust relationships into the database
    # foreach ($trust in $trustData) {
    #     $trust["UTC_Created"] = ([DateTimeOffset]::UtcNow.ToUnixTimeMilliseconds())
    #     $newTrust = Add-DbDocument -Connection $Connection -CollectionName 'DomainTrusts' -Data $trust
    # }

    ###############################################################################
    # TENANTS
    ###############################################################################
    # Ensure-LiteDBCollection -Connection $Connection -CollectionName 'Tenants' -Indexes @(
    #     [PSCustomObject]@{ Field='Hash'; Unique=$true }
    # )
    # Usage example:
    # $tenantData = @{
    #     FriendlyId = 'TEN-001'
    #     TenantId   = '00000000-1111-2222-3333-444444444444'
    #     TenantName = 'MyTenant'
    #     Region     = 'US'
    #     IsProduction = $true
    #     # Denormalized fields like 'ContactEmail', 'SubscriptionType', etc.
    # }
    # $newTenant = Add-DbDocument -Connection $Connection -CollectionName 'Tenants' -Data $tenantData
    # Write-PodeHost "Inserted Tenant:" $newTenant.FriendlyId

    ###############################################################################
    # USERS
    ###############################################################################
    # Ensure-LiteDBCollection -Connection $Connection -CollectionName 'Users' -Indexes @(
    #     [PSCustomObject]@{ Field='Hash'; Unique=$true }
    # )
    # Usage example:
    # $userData = @{
    #     FriendlyId         = 'USR-001'
    #     UserPrincipalName  = 'jsmith@old-ad.example.local'
    #     SamAccountName     = 'jsmith'
    #     FullName           = 'John Smith'
    #     SourceDomain       = 'old-ad.example.local'  # Denormalized from Domains
    #     TargetDomain       = 'new-ad.example.local'  # Denormalized if known
    #     Status             = 'PendingMigration'
    # }
    # $newUser = Add-DbDocument -Connection $Connection -CollectionName 'Users' -Data $userData
    # Write-PodeHost "Inserted User:" $newUser.FriendlyId

    ###############################################################################
    # GROUPS
    ###############################################################################
    # Ensure-LiteDBCollection -Connection $Connection -CollectionName 'Groups' -Indexes @(
    #     [PSCustomObject]@{ Field='Hash'; Unique=$true }
    # )
    # Usage example:
    # $groupData = @{
    #     FriendlyId = 'GRP-001'
    #     GroupName  = 'Domain Admins'
    #     GroupType  = 'Security'
    #     DomainName = 'old-ad.example.local'  # Denormalized from Domains
    #     Members    = @('USR-001','USR-002')  # Possibly store user references or FriendlyIds
    # }
    # $newGroup = Add-DbDocument -Connection $Connection -CollectionName 'Groups' -Data $groupData
    # Write-PodeHost "Inserted Group:" $newGroup.FriendlyId

    ###############################################################################
    # MIGRATION BATCHES
    ###############################################################################
    # Ensure-LiteDBCollection -Connection $Connection -CollectionName 'MigrationBatches' -Indexes @(
    #     [PSCustomObject]@{ Field='Hash'; Unique=$true }
    # )
    # Usage example:
    # $batchData = @{
    #     FriendlyId      = 'BATCH-001'
    #     BatchName       = 'PilotMigration'
    #     SourceDomain    = 'old-ad.example.local'  # Denormalized domain name
    #     TargetDomain    = 'new-ad.example.local'  # Denormalized domain name
    #     StartTime       = (Get-Date)
    #     Status          = 'InProgress'
    #     ServersIncluded = @('HOST-001')  # Denormalized references to Hosts
    #     UsersIncluded   = @('USR-001','USR-002')
    # }
    # $newBatch = Add-DbDocument -Connection $Connection -CollectionName 'MigrationBatches' -Data $batchData
    # Write-PodeHost "Inserted MigrationBatch:" $newBatch.FriendlyId

    ###############################################################################
    # DHCP SCOPES, LEASES, RESERVATIONS
    ###############################################################################
    # Ensure-LiteDBCollection -Connection $Connection -CollectionName 'DHCP_Scopes' -Indexes @(
    #     [PSCustomObject]@{ Field='Hash'; Unique=$true }
    # )
    # Usage example:
    # $scopeData = @{
    #     FriendlyId  = 'SCP-001'
    #     ScopeName   = 'BuildingA-Floor1'
    #     ServerName  = 'Server01'            # Denormalized from Hosts
    #     StartIP     = '10.0.0.50'
    #     EndIP       = '10.0.0.254'
    #     Mask        = '255.255.255.0'
    #     DomainName  = 'old-ad.example.local' # Denormalized from Domains
    # }
    # $newScope = Add-DbDocument -Connection $Connection -CollectionName 'DHCP_Scopes' -Data $scopeData
    # Write-PodeHost "Inserted DHCP Scope:" $newScope.FriendlyId

    # Ensure-LiteDBCollection -Connection $Connection -CollectionName 'DHCP_Leases' -Indexes @(
    #     [PSCustomObject]@{ Field='Hash'; Unique=$true }
    # )
    # Usage example:
    # $leaseData = @{
    #     IPAddress      = '10.0.0.100'
    #     MACAddress     = '00:1A:2B:3C:4D:5E'
    #     ScopeName      = 'BuildingA-Floor1'  # Denormalized from DHCP_Scopes
    #     ServerName     = 'Server01'
    #     Hostname       = 'CLIENT-PC1'
    #     LeaseStatus    = 'Active'
    #     Expiration     = (Get-Date).AddHours(8)
    # }
    # $newLease = Add-DbDocument -Connection $Connection -CollectionName 'DHCP_Leases' -Data $leaseData
    # Write-PodeHost "Inserted DHCP Lease for IP:" $newLease.IPAddress

    # Ensure-LiteDBCollection -Connection $Connection -CollectionName 'DHCP_Reservations' -Indexes @(
    #     [PSCustomObject]@{ Field='Hash';  Unique=$true }
    # )
    # Usage example:
    # $reservationData = @{
    #     IPAddress  = '10.0.0.150'
    #     MACAddress = '00:FF:AA:BB:CC:DD'
    #     Hostname   = 'PRINTER-01'
    #     ScopeName  = 'BuildingA-Floor1'      # Denormalized from DHCP_Scopes
    #     DomainName = 'old-ad.example.local'   # Denormalized from Domains
    # }
    # $newReservation = Add-DbDocument -Connection $Connection -CollectionName 'DHCP_Reservations' -Data $reservationData
    # Write-PodeHost "Inserted DHCP Reservation for IP:" $newReservation.IPAddress

    ###############################################################################
    # FILE SERVERS & SHARES
    ###############################################################################
    # Ensure-LiteDBCollection -Connection $Connection -CollectionName 'FileServers' -Indexes @(
    #     [PSCustomObject]@{ Field='Hash'; Unique=$true }
    # )
    # Usage example:
    # $fileServerData = @{
    #     FriendlyId  = 'FS-001'
    #     ServerName  = 'Server01'
    #     Role        = 'FileServer'
    #     DomainName  = 'old-ad.example.local'
    #     OSVersion   = 'Windows Server 2022'
    # }
    # $newFileServer = Add-DbDocument -Connection $Connection -CollectionName 'FileServers' -Data $fileServerData
    # Write-PodeHost "Inserted FileServer:" $newFileServer.FriendlyId

    # Ensure-LiteDBCollection -Connection $Connection -CollectionName 'FileShares' -Indexes @(
    #     [PSCustomObject]@{ Field='Hash';   Unique=$true }
    # )
    # Usage example:
    # $shareData = @{
    #     FriendlyId   = 'SHR-001'
    #     ShareName    = 'Public'
    #     UNCPath      = '\\Server01\Public'
    #     ServerName   = 'Server01'  # Denormalized from FileServers or Hosts
    #     Permissions  = @(
    #         @{ User='USR-001'; Access='FullControl' },
    #         @{ Group='GRP-001'; Access='ReadOnly' }
    #     )
    # }
    # $newShare = Add-DbDocument -Connection $Connection -CollectionName 'FileShares' -Data $shareData
    # Write-PodeHost "Inserted FileShare:" $newShare.FriendlyId

    ###############################################################################
    # GROUP POLICY
    ###############################################################################
    # Ensure-LiteDBCollection -Connection $Connection -CollectionName 'GroupPolicy' -Indexes @(
    #     [PSCustomObject]@{ Field='Hash'; Unique=$true }
    # )
    # Usage example:
    # $gpoData = @{
    #     GPOGuid       = '11111111-2222-3333-4444-555555555555'
    #     GPOName       = 'Default Domain Policy'
    #     DomainName    = 'old-ad.example.local'
    #     Enabled       = $true
    #     Enforced      = $false
    #     LinkTargets   = @('OU=HR,DC=old-ad,DC=example,DC=local')
    #     Description   = 'Baseline Security Policies'
    #     Version       = 42
    # }
    # $newGpo = Add-DbDocument -Connection $Connection -CollectionName 'GroupPolicy' -Data $gpoData
    # Write-PodeHost "Inserted GPO:" $newGpo.GPOName

    ###############################################################################
    # DRIVE MAPPINGS
    ###############################################################################
    # Ensure-LiteDBCollection -Connection $Connection -CollectionName 'DriveMappings' -Indexes @(
    #     [PSCustomObject]@{ Field='Hash'; Unique=$true }
    # )
    # Usage example:
    # $driveMapData = @{
    #     FriendlyId   = 'DM-001'
    #     DriveLetter  = 'Z:'
    #     UNCPath      = '\\Server01\Public'  # Denormalized from FileShares
    #     AssignedTo   = 'USR-001'              # Denormalized from Users
    #     AssignedBy   = 'GPO-11111111-2222-3333-4444-555555555555'  # GPO Guid or a string
    #     Persistent   = $true
    # }
    # $newDriveMap = Add-DbDocument -Connection $Connection -CollectionName 'DriveMappings' -Data $driveMapData
    # Write-PodeHost "Inserted DriveMapping:" $newDriveMap.FriendlyId

    ###############################################################################
    # PROFILE MIGRATIONS
    ###############################################################################
    # Ensure-LiteDBCollection -Connection $Connection -CollectionName 'ProfileMigrations' -Indexes @(
    #     [PSCustomObject]@{ Field='Hash'; Unique=$true }
    # )
    # Usage example:
    # $profileMigData = @{
    #     FriendlyId       = 'PMIG-001'
    #     User             = 'USR-001'  # Denormalized from Users
    #     SourceDomain     = 'old-ad.example.local'
    #     TargetDomain     = 'new-ad.example.local'
    #     ToolUsed         = 'USMT'
    #     Status           = 'Completed'
    #     StartTime        = (Get-Date).AddHours(-2)
    #     EndTime          = (Get-Date)
    #     BatchRef         = 'BATCH-001'   # Denormalized from MigrationBatches
    # }
    # $newProfileMig = Add-DbDocument -Connection $Connection -CollectionName 'ProfileMigrations' -Data $profileMigData
    # Write-PodeHost "Inserted Profile Migration:" $newProfileMig.FriendlyId

    ###############################################################################
    # FULL-MESH MIGRATIONS
    ###############################################################################
    # Ensure-LiteDBCollection -Connection $Connection -CollectionName 'FullMeshMigrations' -Indexes @(
    #     [PSCustomObject]@{ Field='Hash'; Unique=$true }
    # )
    # Usage example:
    # $fullMeshData = @{
    #     FriendlyId      = 'FMIG-001'
    #     SourceTenant    = 'TEN-001'                  # Denormalized from Tenants
    #     TargetTenant    = 'TEN-002'
    #     SourceDomain    = 'old-ad.example.local'
    #     TargetDomain    = 'new-ad.example.local'
    #     Phase           = 'Planning'
    #     Steps           = @('Discovery','Prepare','Sync','Cutover')
    #     MigrationStatus = 'NotStarted'
    # }
    # $newFullMesh = Add-DbDocument -Connection $Connection -CollectionName 'FullMeshMigrations' -Data $fullMeshData
    # Write-PodeHost "Inserted Full Mesh Migration:" $newFullMesh.FriendlyId

    ###############################################################################
    # MAILFLOW / MAIL SECURITY APPLIANCES / SMART CONNECTORS
    ###############################################################################
    # Ensure-LiteDBCollection -Connection $Connection -CollectionName 'Mailflow' -Indexes @(
    #     [PSCustomObject]@{ Field='Hash'; Unique=$true }
    # )
    # Usage example:
    # $mailflowData = @{
    #     FriendlyId  = 'MAILFLO-001'
    #     DomainName  = 'old-ad.example.local'
    #     MXRecords   = @('mail1.example.com','mail2.example.com')
    #     InboundConnector = 'Connector-Inbound-123'
    #     OutboundConnector = 'Connector-Outbound-123'
    #     TransportRules   = @('Block EXEs','Spam Filter')
    # }
    # $newMailflow = Add-DbDocument -Connection $Connection -CollectionName 'Mailflow' -Data $mailflowData
    # Write-PodeHost "Inserted Mailflow:" $newMailflow.FriendlyId

    # Ensure-LiteDBCollection -Connection $Connection -CollectionName 'MailSecurityAppliances' -Indexes @(
    #     [PSCustomObject]@{ Field='Hash'; Unique=$true }
    # )
    # Usage example:
    # $applianceData = @{
    #     FriendlyId   = 'MSA-001'
    #     ApplianceName= 'Barracuda1'
    #     IPAddress    = '10.0.0.20'
    #     Vendor       = 'Barracuda'
    #     Model        = 'XYZ-1000'
    #     DomainName   = 'old-ad.example.local'
    # }
    # $newAppliance = Add-DbDocument -Connection $Connection -CollectionName 'MailSecurityAppliances' -Data $applianceData
    # Write-PodeHost "Inserted Mail Security Appliance:" $newAppliance.FriendlyId

    # Ensure-LiteDBCollection -Connection $Connection -CollectionName 'SmartConnectors' -Indexes @(
    #     [PSCustomObject]@{ Field='Hash'; Unique=$true }
    # )
    # Usage example:
    # $connectorData = @{
    #     FriendlyId    = 'CONN-001'
    #     ConnectorName = 'InboundCorpConnector'
    #     ConnectorType = 'Inbound'
    #     HostName      = 'Server01'   # Denormalized from Hosts
    #     TLSRequired   = $true
    #     AuthMethod    = 'Certificate'
    # }
    # $newConnector = Add-DbDocument -Connection $Connection -CollectionName 'SmartConnectors' -Data $connectorData
    # Write-PodeHost "Inserted Smart Connector:" $newConnector.FriendlyId

    ###############################################################################
    # MIGRATION WORKFLOWS
    ###############################################################################
    # Ensure-LiteDBCollection -Connection $Connection -CollectionName 'MigrationWorkflows' -Indexes @(
    #     [PSCustomObject]@{ Field='Hash'; Unique=$true }
    # )
    # Usage example:
    # $workflowData = @{
    #     FriendlyId   = 'WFLOW-001'
    #     WorkflowType = 'FileServerMigrationService'
    #     Status       = 'Running'
    #     SourceServer = 'Server01'
    #     TargetServer = 'Server02'
    #     LastRunTime  = (Get-Date)
    #     Details      = 'Copying files, differential sync...'
    # }
    # $newWorkflow = Add-DbDocument -Connection $Connection -CollectionName 'MigrationWorkflows' -Data $workflowData
    # Write-PodeHost "Inserted Migration Workflow:" $newWorkflow.FriendlyId

    ###############################################################################
    # Write-PodeHost "All collections initialized successfully."
}
