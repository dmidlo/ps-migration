#region Global Validation Data
# A global hashtable mapping abbreviated Windows OS versions to supported features/roles.
# This design can be replaced with enums or custom objects for stricter type checking.
$Global:SupportedWindowsFeatures = @{
    "Windows Server 2008 R2 - Foundation" = @(
        "Active Directory Domain Services",
        "DHCP Server",
        "DNS Server",
        "File Services",
        "Print Services",
        "Web Server (IIS)"
    )
    "Windows Server 2008 R2 - Standard - Desktop" = @(
        "Active Directory Domain Services",
        "Active Directory Certificate Services",
        "DHCP Server",
        "DNS Server",
        "File Services",
        "Print Services",
        "Web Server (IIS)",
        "Hyper-V",
        "Remote Desktop Services",
        "Failover Clustering"
    )
    "Windows Server 2008 R2 - Standard - Core" = @(
        "Active Directory Domain Services",
        "DHCP Server",
        "DNS Server",
        "File Services",
        "Print Services",
        "Web Server (IIS)",
        "Hyper-V"
    )
    "Windows Server 2008 R2 - Enterprise - Desktop" = @(
        "Active Directory Domain Services",
        "Active Directory Certificate Services",
        "Active Directory Federation Services",
        "DHCP Server",
        "DNS Server",
        "File Services",
        "Print Services",
        "Web Server (IIS)",
        "Hyper-V",
        "Remote Desktop Services",
        "Failover Clustering"
    )
    "Windows Server 2008 R2 - Enterprise - Core" = @(
        "Active Directory Domain Services",
        "Active Directory Certificate Services",
        "DHCP Server",
        "DNS Server",
        "File Services",
        "Print Services",
        "Web Server (IIS)",
        "Hyper-V",
        "Failover Clustering"
    )
    "Windows Server 2008 R2 - Datacenter - Desktop" = @(
        "Active Directory Domain Services",
        "Active Directory Certificate Services",
        "Active Directory Federation Services",
        "DHCP Server",
        "DNS Server",
        "File Services",
        "Print Services",
        "Web Server (IIS)",
        "Hyper-V",
        "Remote Desktop Services",
        "Failover Clustering"
    )
    "Windows Server 2008 R2 - Datacenter - Core" = @(
        "Active Directory Domain Services",
        "Active Directory Certificate Services",
        "DHCP Server",
        "DNS Server",
        "File Services",
        "Print Services",
        "Web Server (IIS)",
        "Hyper-V",
        "Failover Clustering"
    )
    "Windows Server 2008 R2 - Web" = @(
        "Web Server (IIS)",
        "FTP Server"
    )
    "Windows Server 2008 R2 - HPC Server" = @(
        "Active Directory Domain Services",
        "DHCP Server",
        "DNS Server",
        "File Services",
        "Print Services",
        "Web Server (IIS)",
        "Hyper-V",
        "Failover Clustering"
    )
    "Windows Server 2008 R2 - Itanium" = @(
        "Active Directory Domain Services",
        "Active Directory Certificate Services",
        "DHCP Server",
        "DNS Server",
        "File Services",
        "Print Services",
        "Web Server (IIS)",
        "Failover Clustering"
    )
    "Windows Server 2012 - Foundation" = @(
        "Active Directory Domain Services",
        "DHCP Server",
        "DNS Server",
        "File and Storage Services",
        "Print and Document Services",
        "Web Server (IIS)"
    )
    "Windows Server 2012 - Essentials" = @(
        "Active Directory Domain Services",
        "DHCP Server",
        "DNS Server",
        "File and Storage Services",
        "Print and Document Services",
        "Web Server (IIS)"
    )
    "Windows Server 2012 - Standard - Desktop" = @(
        "Active Directory Domain Services",
        "DHCP Server",
        "DNS Server",
        "File and Storage Services",
        "Print and Document Services",
        "Web Server (IIS)",
        "Hyper-V",
        "Windows Server Update Services (WSUS)",
        "IP Address Management (IPAM)",
        "Failover Clustering",
        "Active Directory Certificate Services",
        "Server Core Mode"
    )
    "Windows Server 2012 - Standard - Core" = @(
        "Active Directory Domain Services",
        "DHCP Server",
        "DNS Server",
        "File and Storage Services",
        "Print and Document Services",
        "Web Server (IIS)",
        "Hyper-V",
        "Windows Server Update Services (WSUS)",
        "IP Address Management (IPAM)",
        "Failover Clustering",
        "Active Directory Certificate Services"
    )
    "Windows Server 2012 - Datacenter - Desktop" = @(
        "Active Directory Domain Services",
        "DHCP Server",
        "DNS Server",
        "File and Storage Services",
        "Print and Document Services",
        "Web Server (IIS)",
        "Hyper-V",
        "Windows Server Update Services (WSUS)",
        "IP Address Management (IPAM)",
        "Failover Clustering",
        "Active Directory Certificate Services",
        "Server Core Mode"
    )
    "Windows Server 2012 - Datacenter - Core" = @(
        "Active Directory Domain Services",
        "DHCP Server",
        "DNS Server",
        "File and Storage Services",
        "Print and Document Services",
        "Web Server (IIS)",
        "Hyper-V",
        "Windows Server Update Services (WSUS)",
        "IP Address Management (IPAM)",
        "Failover Clustering",
        "Active Directory Certificate Services"
    )
    "Windows Server 2012 R2 - Foundation" = @(
        "Active Directory Domain Services",
        "DHCP Server",
        "DNS Server",
        "File and Storage Services",
        "Print and Document Services",
        "Web Server (IIS)"
    )
    "Windows Server 2012 R2 - Essentials" = @(
        "Active Directory Domain Services",
        "DHCP Server",
        "DNS Server",
        "File and Storage Services",
        "Print and Document Services",
        "Web Server (IIS)"
    )
    "Windows Server 2012 R2 - Standard - Desktop" = @(
        "Active Directory Domain Services",
        "DHCP Server",
        "DNS Server",
        "File and Storage Services",
        "Print and Document Services",
        "Web Server (IIS)",
        "Hyper-V",
        "Windows Server Update Services (WSUS)",
        "IP Address Management (IPAM)",
        "Failover Clustering",
        "Active Directory Certificate Services",
        "Server Core Mode"
    )
    "Windows Server 2012 R2 - Standard - Core" = @(
        "Active Directory Domain Services",
        "DHCP Server",
        "DNS Server",
        "File and Storage Services",
        "Print and Document Services",
        "Web Server (IIS)",
        "Hyper-V",
        "Windows Server Update Services (WSUS)",
        "IP Address Management (IPAM)",
        "Failover Clustering",
        "Active Directory Certificate Services"
    )
    "Windows Server 2012 R2 - Datacenter - Desktop" = @(
        "Active Directory Domain Services",
        "DHCP Server",
        "DNS Server",
        "File and Storage Services",
        "Print and Document Services",
        "Web Server (IIS)",
        "Hyper-V",
        "Windows Server Update Services (WSUS)",
        "IP Address Management (IPAM)",
        "Failover Clustering",
        "Active Directory Certificate Services",
        "Server Core Mode"
    )
    "Windows Server 2012 R2 - Datacenter - Core" = @(
        "Active Directory Domain Services",
        "DHCP Server",
        "DNS Server",
        "File and Storage Services",
        "Print and Document Services",
        "Web Server (IIS)",
        "Hyper-V",
        "Windows Server Update Services (WSUS)",
        "IP Address Management (IPAM)",
        "Failover Clustering",
        "Active Directory Certificate Services"
    )
    "Windows Server 2016 - Essentials" = @(
        "Active Directory Services",
        "DHCP Server",
        "DNS Server",
        "Remote Desktop Services",
        "Enhanced Hyper-V",
        "IIS",
        "WSUS",
        "Storage Services",
        "IPAM",
        "Shielded Virtual Machines",
        "Containers"
    )
    "Windows Server 2016 - Standard - Desktop" = @(
        "Active Directory Services",
        "DHCP Server",
        "DNS Server",
        "Remote Desktop Services",
        "Enhanced Hyper-V",
        "IIS",
        "WSUS",
        "Storage Services",
        "IPAM",
        "Hyper-V Replica"
    )
    "Windows Server 2016 - Standard - Core" = @(
        "Active Directory Services",
        "DHCP Server",
        "DNS Server",
        "Hyper-V",
        "IIS",
        "WSUS",
        "Storage Services",
        "IPAM",
        "Hyper-V Replica"
    )
    "Windows Server 2016 - Datacenter - Desktop" = @(
        "Active Directory Services",
        "DHCP Server",
        "DNS Server",
        "Remote Desktop Services",
        "Enhanced Hyper-V",
        "IIS",
        "WSUS",
        "Storage Services",
        "IPAM",
        "Hyper-V Replica"
    )
    "Windows Server 2016 - Datacenter - Core" = @(
        "Active Directory Services",
        "DHCP Server",
        "DNS Server",
        "Hyper-V",
        "IIS",
        "WSUS",
        "Storage Services",
        "IPAM",
        "Hyper-V Replica"
    )
    "Windows Server 2016 - Nano" = @(
        "DHCP Server",
        "DNS Server",
        "Hyper-V",
        "IIS",
        "WSUS",
        "Storage Services",
        "IPAM",
        "Hyper-V Replica"
    )
    "Windows Server 2019 - Essentials" = @(
        "Active Directory Services",
        "DHCP Server",
        "DNS Server",
        "Remote Desktop Services",
        "Enhanced Hyper-V",
        "IIS",
        "WSUS",
        "Storage Services",
        "IPAM",
        "Shielded Virtual Machines",
        "Containers"
    )
    "Windows Server 2019 - Standard - Desktop" = @(
        "Active Directory Services",
        "DHCP Server",
        "DNS Server",
        "Remote Desktop Services",
        "Enhanced Hyper-V",
        "IIS",
        "WSUS",
        "Storage Services",
        "IPAM",
        "Hyper-V Replica"
    )
    "Windows Server 2019 - Standard - Core" = @(
        "Active Directory Services",
        "DHCP Server",
        "DNS Server",
        "Hyper-V",
        "IIS",
        "WSUS",
        "Storage Services",
        "IPAM",
        "Hyper-V Replica"
    )
    "Windows Server 2019 - Datacenter - Desktop" = @(
        "Active Directory Services",
        "DHCP Server",
        "DNS Server",
        "Remote Desktop Services",
        "Enhanced Hyper-V",
        "IIS",
        "WSUS",
        "Storage Services",
        "IPAM",
        "Hyper-V Replica"
    )
    "Windows Server 2019 - Datacenter - Core" = @(
        "Active Directory Services",
        "DHCP Server",
        "DNS Server",
        "Hyper-V",
        "IIS",
        "WSUS",
        "Storage Services",
        "IPAM",
        "Hyper-V Replica"
    )
    "Windows Server 2019 - Nano" = @(
        "DHCP Server",
        "DNS Server",
        "Hyper-V",
        "IIS",
        "WSUS",
        "Storage Services",
        "IPAM",
        "Hyper-V Replica"
    )
    "Windows Server 2022 - Essentials" = @(
        "Active Directory Services",
        "DHCP Server",
        "DNS Server",
        "Remote Desktop Services",
        "Enhanced Hyper-V",
        "IIS",
        "WSUS",
        "Storage Services",
        "IPAM",
        "Shielded Virtual Machines",
        "Containers"
    )
    "Windows Server 2022 - Standard - Desktop" = @(
        "Active Directory Services",
        "DHCP Server",
        "DNS Server",
        "Remote Desktop Services",
        "Enhanced Hyper-V",
        "IIS",
        "WSUS",
        "Storage Services",
        "IPAM",
        "Hyper-V Replica"
    )
    "Windows Server 2022 - Standard - Core" = @(
        "Active Directory Services",
        "DHCP Server",
        "DNS Server",
        "Hyper-V",
        "IIS",
        "WSUS",
        "Storage Services",
        "IPAM",
        "Hyper-V Replica"
    )
    "Windows Server 2022 - Datacenter - Desktop" = @(
        "Active Directory Services",
        "DHCP Server",
        "DNS Server",
        "Remote Desktop Services",
        "Enhanced Hyper-V",
        "IIS",
        "WSUS",
        "Storage Services",
        "IPAM",
        "Hyper-V Replica"
    )
    "Windows Server 2022 - Datacenter - Core" = @(
        "Active Directory Services",
        "DHCP Server",
        "DNS Server",
        "Hyper-V",
        "IIS",
        "WSUS",
        "Storage Services",
        "IPAM",
        "Hyper-V Replica"
    )
    "Windows Server 2022 - Nano" = @(
        "DHCP Server",
        "DNS Server",
        "Hyper-V",
        "IIS",
        "WSUS",
        "Storage Services",
        "IPAM",
        "Hyper-V Replica"
    )
    "Windows Server 2025 - Essentials" = @(
        "Active Directory Services",
        "DHCP Server",
        "DNS Server",
        "Remote Desktop Services",
        "Enhanced Hyper-V",
        "IIS",
        "WSUS",
        "Storage Services",
        "IPAM",
        "Shielded Virtual Machines",
        "Containers"
    )
    "Windows Server 2025 - Standard - Desktop" = @(
        "Active Directory Services",
        "DHCP Server",
        "DNS Server",
        "Remote Desktop Services",
        "Enhanced Hyper-V",
        "IIS",
        "WSUS",
        "Storage Services",
        "IPAM",
        "Hyper-V Replica"
    )
    "Windows Server 2025 - Standard - Core" = @(
        "Active Directory Services",
        "DHCP Server",
        "DNS Server",
        "Hyper-V",
        "IIS",
        "WSUS",
        "Storage Services",
        "IPAM",
        "Hyper-V Replica"
    )
    "Windows Server 2025 - Datacenter - Desktop" = @(
        "Active Directory Services",
        "DHCP Server",
        "DNS Server",
        "Remote Desktop Services",
        "Enhanced Hyper-V",
        "IIS",
        "WSUS",
        "Storage Services",
        "IPAM",
        "Hyper-V Replica"
    )
    "Windows Server 2025 - Datacenter - Core" = @(
        "Active Directory Services",
        "DHCP Server",
        "DNS Server",
        "Hyper-V",
        "IIS",
        "WSUS",
        "Storage Services",
        "IPAM",
        "Hyper-V Replica"
    )
    "Windows Server 2025 - Nano" = @(
        "DHCP Server",
        "DNS Server",
        "Hyper-V",
        "IIS",
        "WSUS",
        "Storage Services",
        "IPAM",
        "Hyper-V Replica"
    )
}

#region Helper Function: Update-PropertyIfNeeded
function Update-PropertyIfNeeded {
    <#
    .SYNOPSIS
        Non–destructively update a property on the target object unless –Force is specified.
    .PARAMETER Target
        The target object (an ordered hashtable) to update.
    .PARAMETER Key
        The property key.
    .PARAMETER Value
        The new value for that property.
    .PARAMETER Force
        If specified, always update the value.
    .OUTPUTS
        The updated target object.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [hashtable]$Target,

        [Parameter(Mandatory)]
        [string]$Key,

        [Parameter(Mandatory)]
        $Value,

        [Switch]$Force
    )

    if ($Force -or (-not $Target.ContainsKey($Key)) -or ([string]::IsNullOrEmpty("$($Target[$Key])"))) {
        $Target[$Key] = $Value
    }
}
#endregion Helper Function

#region New-dbHost
function New-dbHost {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [string]$MACAddress,

        [Parameter()]
        [hashtable]$Properties,

        [Switch]$Force,

        [Switch]$NewProp  # Feature flag for adding new properties
    )

    process {
        $now = [DateTimeOffset]::UtcNow.ToUnixTimeMilliseconds()
        # Create a new host object with initial (ordered) properties.
        $dbHost = [ordered]@{
            MACAddress         = $MACAddress
            IPAddress          = $null
            HostType           = $null
            Hostname           = $null
            FQDN               = $null
            DomainOrWorkgroup  = $null
            LastUsers          = @()
            OS                 = $null
            VirtualMachine     = $null
            ClusterNodeMember  = $null
            Role               = $null
            Services           = [ordered]@{
                WindowsRoles = @()
                LinuxRoles   = @()
                DHCP         = $false
                DNS          = $false
            }
            AD_Roles           = @()
            FSMORoles          = @()
            META_UTCCreated    = $now
            META_UTCUpdated    = $now
        }

        if ($Properties) {
            foreach ($key in $Properties.Keys) {
                if ($NewProp -and (-not $dbHost.Contains($key))) {
                    # Add new properties only if -NewProp is specified
                    $dbHost[$key] = $Properties[$key]
                } else {
                    # Use Update-PropertyIfNeeded for existing properties
                    Update-PropertyIfNeeded -Target $dbHost -Key $key -Value $Properties[$key] -Force:($Force.IsPresent)
                }
            }
        }

        Write-Output $dbHost
    }
}
#endregion New-dbHost

#region Set-HostBasic
function Set-HostBasic {
    <#
    .SYNOPSIS
        Adds or updates basic network properties (e.g. IPAddress) on a host.
    .DESCRIPTION
        Updates the host object with basic properties. Accepts input via the pipeline or
        directly via parameters and a supplemental hashtable for additional key/value updates.
    .EXAMPLE
        New-dbHost -MACAddress "00:11:22:33:44:55" |
            Set-HostBasic -IPAddress "192.168.1.100"
    #>
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline = $true, Position = 0)]
        [hashtable]$InputObject,

        [Parameter()]
        [string]$IPAddress,

        [Parameter()]
        [hashtable]$Properties,

        [Switch]$Force
    )

    process {
        if ($IPAddress) {
            Update-PropertyIfNeeded -Target $InputObject -Key "IPAddress" -Value $IPAddress -Force:$Force
        }
        if ($Properties) {
            foreach ($key in $Properties.Keys) {
                Update-PropertyIfNeeded -Target $InputObject -Key $key -Value $Properties[$key] -Force:$Force
            }
        }
        $InputObject.META_UTCUpdated = [DateTimeOffset]::UtcNow.ToUnixTimeMilliseconds()
        Write-Output $InputObject
    }
}
#endregion Set-HostBasic

#region Set-HostType
function Set-HostType {
    <#
    .SYNOPSIS
        Sets the type of the host (e.g. Workstation, Server, Printer, Router/Switch, etc.).
    .EXAMPLE
        … | Set-HostType -Type "Server"
    #>
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline = $true, Position = 0)]
        [hashtable]$InputObject,

        [Parameter(Mandatory, Position = 1)]
        [ValidateNotNullOrEmpty()]
        [string]$Type,

        [Parameter()]
        [hashtable]$Properties,

        [Switch]$Force
    )
    process {
        Update-PropertyIfNeeded -Target $InputObject -Key "HostType" -Value $Type -Force:$Force

        if ($Properties) {
            foreach ($key in $Properties.Keys) {
                Update-PropertyIfNeeded -Target $InputObject -Key $key -Value $Properties[$key] -Force:$Force
            }
        }
        $InputObject.META_UTCUpdated = [DateTimeOffset]::UtcNow.ToUnixTimeMilliseconds()
        Write-Output $InputObject
    }
}
#endregion Set-HostType

#region Set-HostDetails
function Set-HostDetails {
    <#
    .SYNOPSIS
        Enriches the host object with detailed information.
    .DESCRIPTION
        Adds or updates detailed properties such as Hostname, FQDN, DomainOrWorkgroup,
        operating system details, and whether the host is a cluster node member.
    .EXAMPLE
        … | Set-HostDetails -Hostname "server01" -FQDN "server01.example.com" `
                           -DomainOrWorkgroup "EXAMPLE" -OS "Windows Server 2019"
    #>
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline = $true, Position = 0)]
        [hashtable]$InputObject,

        [Parameter()]
        [string]$Hostname,

        [Parameter()]
        [string]$FQDN,

        [Parameter()]
        [string]$DomainOrWorkgroup,

        [Parameter()]
        [string]$OS,

        [Parameter()]
        [bool]$ClusterNodeMember,

        [Parameter()]
        [hashtable]$Properties,

        [Switch]$Force
    )
    process {
        if ($Hostname) {
            Update-PropertyIfNeeded -Target $InputObject -Key "Hostname" -Value $Hostname -Force:$Force
        }
        if ($FQDN) {
            Update-PropertyIfNeeded -Target $InputObject -Key "FQDN" -Value $FQDN -Force:$Force
        }
        if ($DomainOrWorkgroup) {
            Update-PropertyIfNeeded -Target $InputObject -Key "DomainOrWorkgroup" -Value $DomainOrWorkgroup -Force:$Force
        }
        if ($OS) {
            Update-PropertyIfNeeded -Target $InputObject -Key "OS" -Value $OS -Force:$Force
        }
        if ($PSBoundParameters.ContainsKey('ClusterNodeMember')) {
            Update-PropertyIfNeeded -Target $InputObject -Key "ClusterNodeMember" -Value $ClusterNodeMember -Force:$Force
        }
        if ($Properties) {
            foreach ($key in $Properties.Keys) {
                Update-PropertyIfNeeded -Target $InputObject -Key $key -Value $Properties[$key] -Force:$Force
            }
        }
        $InputObject.META_UTCUpdated = [DateTimeOffset]::UtcNow.ToUnixTimeMilliseconds()
        Write-Output $InputObject
    }
}
#endregion Set-HostDetails

#region Set-HostServices
function Set-HostServices {
    <#
    .SYNOPSIS
        Configures service–related properties on the host.
    .DESCRIPTION
        Adds Windows and/or Linux roles as well as enables features such as DHCP and DNS.
        For Windows roles, validation is performed against the supported features based on the OS.
    .EXAMPLE
        … | Set-HostServices -WindowsRoles @("Domain Controller", "Web Server") -DHCP -DNS
    #>
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline = $true, Position = 0)]
        [hashtable]$InputObject,

        [Parameter()]
        [string[]]$WindowsRoles,

        [Parameter()]
        [string[]]$LinuxRoles,

        [Parameter()]
        [Switch]$DHCP,

        [Parameter()]
        [Switch]$DNS,

        [Parameter()]
        [hashtable]$Properties,

        [Switch]$Force
    )
    process {
        # Ensure the Services property exists.
        if (-not $InputObject.Services) {
            $InputObject.Services = [ordered]@{
                WindowsRoles = @()
                LinuxRoles   = @()
                DHCP         = $false
                DNS          = $false
            }
        }

        # Validate WindowsRoles against supported features if OS is specified.
        if ($InputObject.OS -and $WindowsRoles) {
            # Find the matching OS key from our global supported features table.
            $osKey = ($Global:SupportedWindowsFeatures.Keys | Where-Object { $InputObject.OS -match $_ })[0]
            if ($osKey) {
                foreach ($role in $WindowsRoles) {
                    if (-not ($Global:SupportedWindowsFeatures[$osKey] -contains $role)) {
                        Throw "Validation Error: '$role' is not supported on Windows Server $osKey."
                    }
                }
            }
        }

        # Process Windows roles.
        if ($WindowsRoles) {
            if ($Force -or ($InputObject.Services.WindowsRoles.Count -eq 0)) {
                $InputObject.Services.WindowsRoles = $WindowsRoles | Sort-Object
            }
            else {
                foreach ($role in $WindowsRoles) {
                    if (-not ($InputObject.Services.WindowsRoles -contains $role)) {
                        $InputObject.Services.WindowsRoles += $role
                    }
                }
                $InputObject.Services.WindowsRoles = $InputObject.Services.WindowsRoles | Sort-Object
            }
        }
        # Process Linux roles.
        if ($LinuxRoles) {
            if ($Force -or ($InputObject.Services.LinuxRoles.Count -eq 0)) {
                $InputObject.Services.LinuxRoles = $LinuxRoles | Sort-Object
            }
            else {
                foreach ($role in $LinuxRoles) {
                    if (-not ($InputObject.Services.LinuxRoles -contains $role)) {
                        $InputObject.Services.LinuxRoles += $role
                    }
                }
                $InputObject.Services.LinuxRoles = $InputObject.Services.LinuxRoles | Sort-Object
            }
        }
        if ($PSBoundParameters.ContainsKey("DHCP")) {
            $InputObject.Services.DHCP = $true
        }
        if ($PSBoundParameters.ContainsKey("DNS")) {
            $InputObject.Services.DNS = $true
        }
        if ($Properties) {
            foreach ($key in $Properties.Keys) {
                Update-PropertyIfNeeded -Target $InputObject.Services -Key $key -Value $Properties[$key] -Force:$Force
            }
        }

        $InputObject.META_UTCUpdated = [DateTimeOffset]::UtcNow.ToUnixTimeMilliseconds()
        Write-Output $InputObject
    }
}
#endregion Set-HostServices

#region Set-HostAsDomainController
function Set-HostAsDomainController {
    <#
    .SYNOPSIS
        Marks the host as a Domain Controller and configures related properties.
    .DESCRIPTION
        This cmdlet sets the host’s Role property and adds Domain Controller–specific fields
        such as AD_Roles and FSMORoles. When the -ReadOnly switch is specified, FSMO roles are cleared.
    .EXAMPLE
        … | Set-HostAsDomainController -AD_Roles @("GlobalCatalog", "PrimaryDomainController")
    #>
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline = $true, Position = 0)]
        [hashtable]$InputObject,

        [Parameter()]
        [Switch]$ReadOnly,

        [Parameter()]
        [string[]]$AD_Roles = @('GlobalCatalog','PrimaryDomainController'),

        [Parameter()]
        [hashtable[]]$FSMORoles = @(),

        [Parameter()]
        [hashtable]$Properties,

        [Switch]$Force
    )
    process {
        if ($ReadOnly) {
            $InputObject.Role = 'ReadOnlyDomainController'
            $InputObject.FSMORoles = @()
        }
        else {
            $InputObject.Role = 'DomainController'
            # Update FSMO roles if provided.
            if ($FSMORoles -and $FSMORoles.Count -gt 0) {
                if ($Force -or ($InputObject.FSMORoles.Count -eq 0)) {
                    $InputObject.FSMORoles = $FSMORoles
                }
                else {
                    foreach ($role in $FSMORoles) {
                        # Append role if not already present (comparing by RoleName).
                        $exists = $InputObject.FSMORoles | Where-Object { $_.RoleName -eq $role.RoleName }
                        if (-not $exists) {
                            $InputObject.FSMORoles += $role
                        }
                    }
                    $InputObject.FSMORoles = $InputObject.FSMORoles | Sort-Object -Property RoleName
                }
            }
        }

        # Update AD_Roles similarly.
        if ($Force -or ($InputObject.AD_Roles.Count -eq 0)) {
            $InputObject.AD_Roles = $AD_Roles | Sort-Object
        }
        else {
            foreach ($role in $AD_Roles) {
                if (-not ($InputObject.AD_Roles -contains $role)) {
                    $InputObject.AD_Roles += $role
                }
            }
            $InputObject.AD_Roles = $InputObject.AD_Roles | Sort-Object
        }

        if ($Properties) {
            foreach ($key in $Properties.Keys) {
                Update-PropertyIfNeeded -Target $InputObject -Key $key -Value $Properties[$key] -Force:$Force
            }
        }
        $InputObject.META_UTCUpdated = [DateTimeOffset]::UtcNow.ToUnixTimeMilliseconds()
        Write-Output $InputObject
    }
}
#endregion Set-HostAsDomainController