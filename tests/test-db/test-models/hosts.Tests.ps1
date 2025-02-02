function Get-TestHost {
    param(
        [string]$MACAddress = (Get-Random -Maximum 1000000 | ForEach-Object { "00:11:22:33:44:{0:00}" -f $_ })
    )
    return (New-dbHost -MACAddress $MACAddress)
}

# Begin Pester tests.
Describe "FluentHostBuilder Module Tests" {

    #----------------------------------
    # 1. New-dbHost Tests
    #----------------------------------
    Describe "New-dbHost" {
        Describe "New-dbHost" {
            It "TC-01: Should create a new host object with default properties" {
                Write-Host "Calling New-dbHost..."
                $dbHost = New-dbHost -MACAddress "00:11:22:33:44:55"
                Write-Host "Returned Object: $($dbHost | Out-String)"
                $dbHost | Should -BeOfType [System.Collections.Specialized.OrderedDictionary]
                $dbHost.MACAddress | Should -Be "00:11:22:33:44:55"
                $dbHost.IPAddress | Should -BeNullOrEmpty
                $dbHost.HostType | Should -BeNullOrEmpty
                $dbHost.Services | Should -Not -BeNullOrEmpty
                ($dbHost.Keys -contains "META_UTCCreated") | Should -Be $true
                ($dbHost.Keys -contains "META_UTCUpdated") | Should -Be $true
            }
        }        
        It "TC-02: Should merge additional properties when provided" {
            $props = @{ CustomProp = "TestValue" }
            $dbHost = New-dbHost -MACAddress "00:11:22:33:44:55" -Properties $props -NewProp
            $dbHost.CustomProp | Should -Be "TestValue"
        }
    }

    #----------------------------------
    # 2. Set-HostBasic Tests
    #----------------------------------
    Describe "Set-HostBasic" {
        # It "TC-03: Should update the IPAddress property" {
        #     $dbHost = Get-TestHost
        #     $initialTimestamp = $dbHost.META_UTCUpdated
        #     $dbHost = $dbHost | Set-HostBasic -IPAddress "192.168.1.100"
        #     $dbHost.IPAddress | Should -Be "192.168.1.100"
        #     $dbHost.META_UTCUpdated | Should -BeGreaterThan $initialTimestamp
        # }
        It "TC-04: Should update additional properties provided via the hashtable" {
            $dbHost = Get-TestHost
            $dbHost = $dbHost | Set-HostBasic -Properties @{ ExtraBasic = "ExtraValue" }
            $dbHost.ExtraBasic | Should -Be "ExtraValue"
        }
        It "TC-05: Should ignore an empty IP address (remain $null or original)" {
            $dbHost = Get-TestHost
            $dbHost = $dbHost | Set-HostBasic -IPAddress "192.168.1.100"
            $dbHost = $dbHost | Set-HostBasic -IPAddress ""
            $dbHost.IPAddress | Should -Be "192.168.1.100"
        }
    }

    #----------------------------------
    # 3. Set-HostType Tests
    #----------------------------------
    Describe "Set-HostType" {
        It "TC-06: Should update the HostType to 'Server'" {
            $dbHost = Get-TestHost
            $dbHost = $dbHost | Set-HostType -Type "Server"
            $dbHost.HostType | Should -Be "Server"
        }
        It "TC-07: Should merge additional properties via hashtable" {
            $dbHost = Get-TestHost
            $dbHost = $dbHost | Set-HostType -Type "Printer" -Properties @{ ExtraType = "PropValue" }
            $dbHost.ExtraType | Should -Be "PropValue"
        }
        It "TC-08: Should throw an error for an empty HostType" {
            $dbHost = Get-TestHost
            { $dbHost | Set-HostType -Type "" } | Should -Throw
        }
    }

    #----------------------------------
    # 4. Set-HostDetails Tests
    #----------------------------------
    Describe "Set-HostDetails" {
        It "TC-09: Should update Hostname, FQDN, DomainOrWorkgroup, and OS" {
            $dbHost = Get-TestHost
            $dbHost = $dbHost | Set-HostDetails -Hostname "server01" -FQDN "server01.example.com" `
                        -DomainOrWorkgroup "EXAMPLE" -OS "Windows Server 2019"
            $dbHost.Hostname           | Should -Be "server01"
            $dbHost.FQDN               | Should -Be "server01.example.com"
            $dbHost.DomainOrWorkgroup  | Should -Be "EXAMPLE"
            $dbHost.OS                 | Should -Be "Windows Server 2019"
        }
        It "TC-10: Should update ClusterNodeMember only when explicitly provided" {
            $dbHost = Get-TestHost
            $dbHost = $dbHost | Set-HostDetails -ClusterNodeMember $true
            $dbHost.ClusterNodeMember | Should -Be $true
        }
        It "TC-11: Should merge additional properties if provided" {
            $dbHost = Get-TestHost
            $dbHost = $dbHost | Set-HostDetails -Hostname "TestHost" -Properties @{ DetailExtra = "ExtraDetail" }
            $dbHost.DetailExtra | Should -Be "ExtraDetail"
        }
    }

    #----------------------------------
    # 5. Set-HostServices Tests
    #----------------------------------
    Describe "Set-HostServices" {
        Context "With OS specified (role validation enabled)" {
            # It "TC-12: Should update valid WindowsRoles (e.g. 'IIS', 'DNS Server')" {
            #     $dbHost = Get-TestHost | Set-HostDetails -OS "Windows Server 2019"
            #     $dbHost = $dbHost | Set-HostServices -WindowsRoles @("IIS", "DNS Server")
            #     # Roles are sorted by design.
            #     $dbHost.Services.WindowsRoles | Should -BeExactly @("DNS Server", "IIS")
            # }
            # It "TC-13: Should throw an error for an unsupported Windows role" {
            #     $dbHost = Get-TestHost | Set-HostDetails -OS "Windows Server 2019"
            #     { $dbHost | Set-HostServices -WindowsRoles @("UnsupportedRole") } | Should -Throw -ErrorMessage '*Validation Error*'
            # }
        }
        Context "Without OS specified (no validation)" {
            It "TC-14: Should update WindowsRoles without validating the role" {
                $dbHost = Get-TestHost
                $dbHost = $dbHost | Set-HostServices -WindowsRoles @("NonValidatedRole")
                $dbHost.Services.WindowsRoles | Should -BeExactly @("NonValidatedRole")
            }
        }
        It "TC-15: Should update LinuxRoles and enable DHCP and DNS" {
            $dbHost = Get-TestHost
            $dbHost = $dbHost | Set-HostServices -LinuxRoles @("Web Server") -DHCP -DNS
            $dbHost.Services.LinuxRoles | Should -BeExactly @("Web Server")
            $dbHost.Services.DHCP       | Should -Be $true
            $dbHost.Services.DNS        | Should -Be $true
        }
        # It "TC-16: Should merge additional properties into Services if provided" {
        #     $dbHost = Get-TestHost
        #     $dbHost = $dbHost | Set-HostServices -Properties @{ ExtraService = "Extra" }
        #     $dbHost.Services.ExtraService | Should -Be "Extra"
        # }
    }

    #----------------------------------
    # 6. Set-HostAsDomainController Tests
    #----------------------------------
    Describe "Set-HostAsDomainController" {
        It "TC-17: Should mark the host as DomainController and update AD_Roles" {
            $dbHost = Get-TestHost
            $dbHost = $dbHost | Set-HostAsDomainController -AD_Roles @("GlobalCatalog", "PrimaryDomainController")
            $dbHost.Role     | Should -Be "DomainController"
            $dbHost.AD_Roles | Should -BeExactly @("GlobalCatalog", "PrimaryDomainController")
        }
        It "TC-18: With ReadOnly flag, should set Role to ReadOnlyDomainController and clear FSMORoles" {
            $dbHost = Get-TestHost
            $dbHost = $dbHost | Set-HostAsDomainController -ReadOnly -FSMORoles @(@{RoleName="Schema Master"})
            $dbHost.Role         | Should -Be "ReadOnlyDomainController"
            $dbHost.FSMORoles.Count | Should -Be 0
        }
        It "TC-19: Should merge FSMORoles correctly when additional roles are provided" {
            $fsmorole1 = @{ RoleName = "Role1" }
            $fsmorole2 = @{ RoleName = "Role2" }
            $dbHost = Get-TestHost | Set-HostAsDomainController -FSMORoles @($fsmorole1)
            $dbHost = $dbHost | Set-HostAsDomainController -FSMORoles @($fsmorole2)
            # Check that both roles are present.
            $dbHost.FSMORoles | ForEach-Object { $_.RoleName } | Should -Contain "Role1"
            $dbHost.FSMORoles | ForEach-Object { $_.RoleName } | Should -Contain "Role2"
        }
        # It "TC-20: Should merge AD_Roles correctly across multiple invocations" {
        #     $dbHost = Get-TestHost | Set-HostAsDomainController -AD_Roles @("GlobalCatalog")
        #     $dbHost = $dbHost | Set-HostAsDomainController -AD_Roles @("PrimaryDomainController")
        #     $dbHost.AD_Roles | Should -BeExactly @("GlobalCatalog", "PrimaryDomainController")
        # }
    }

    #----------------------------------
    # 7. Force Parameter Behavior and Metadata Tests
    #----------------------------------
    Describe "Force Parameter and Metadata Updates" {
        It "TC-21 & TC-26: Without -Force, non-empty property should not be updated" {
            $dbHost = Get-TestHost | Set-HostBasic -IPAddress "192.168.1.100"
            $dbHost = $dbHost | Set-HostBasic -IPAddress "10.0.0.1"
            $dbHost.IPAddress | Should -Be "192.168.1.100"
        }
        # It "TC-22 & TC-28: With -Force, property should be updated" {
        #     $dbHost = Get-TestHost | Set-HostBasic -IPAddress "192.168.1.100"
        #     $dbHost = $dbHost | Set-HostBasic -IPAddress "10.0.0.1" -Force
        #     $dbHost.IPAddress | Should -Be "10.0.0.1"
        # }
        It "TC-23: Each update should produce a later META_UTCUpdated timestamp" {
            $dbHost = Get-TestHost | Set-HostBasic -IPAddress "192.168.1.100"
            $timestamp1 = $dbHost.META_UTCUpdated
            Start-Sleep -Milliseconds 10
            $dbHost = $dbHost | Set-HostBasic -IPAddress "192.168.1.100" -Force
            $timestamp2 = $dbHost.META_UTCUpdated
            $timestamp2 | Should -BeGreaterThan $timestamp1
        }
    }

    #----------------------------------
    # 8. Fluent Pipeline Permutations
    #----------------------------------
    Describe "Fluent Pipeline Permutations" {
        # It "TC-24: Should chain all cmdlets and update all properties accordingly" {
        #     $dbHost = New-dbHost -MACAddress "00:11:22:33:44:55" |
        #             Set-HostBasic -IPAddress "192.168.1.100" |
        #             Set-HostType -Type "Server" |
        #             Set-HostDetails -Hostname "SRV01" -FQDN "srv01.example.com" -DomainOrWorkgroup "EXAMPLE" -OS "Windows Server 2019" |
        #             Set-HostServices -WindowsRoles @("IIS", "DNS Server") -DHCP -DNS |
        #             Set-HostAsDomainController -AD_Roles @("GlobalCatalog", "PrimaryDomainController")
        #     $dbHost.IPAddress              | Should -Be "192.168.1.100"
        #     $dbHost.HostType               | Should -Be "Server"
        #     $dbHost.Hostname               | Should -Be "SRV01"
        #     $dbHost.FQDN                   | Should -Be "srv01.example.com"
        #     $dbHost.DomainOrWorkgroup      | Should -Be "EXAMPLE"
        #     $dbHost.OS                     | Should -Be "Windows Server 2019"
        #     $dbHost.Services.WindowsRoles  | Should -BeExactly @("DNS Server", "IIS")
        #     $dbHost.Services.DHCP          | Should -Be $true
        #     $dbHost.Services.DNS           | Should -Be $true
        #     $dbHost.Role                   | Should -Be "DomainController"
        #     $dbHost.AD_Roles               | Should -BeExactly @("GlobalCatalog", "PrimaryDomainController")
        # }
        It "TC-25: Permutation – Set-HostServices before Set-HostBasic" {
            $dbHost = New-dbHost -MACAddress "00:11:22:33:44:55" |
                    Set-HostServices -WindowsRoles @("IIS", "DNS Server") |
                    Set-HostBasic -IPAddress "192.168.1.100"
            $dbHost.Services.WindowsRoles | Should -BeExactly @("DNS Server", "IIS")
            $dbHost.IPAddress             | Should -Be "192.168.1.100"
        }
        It "TC-26: Permutation – Set-HostDetails before Set-HostType" {
            $dbHost = New-dbHost -MACAddress "00:11:22:33:44:55" |
                    Set-HostDetails -Hostname "SRV01" -OS "Windows Server 2019" |
                    Set-HostType -Type "Server"
            $dbHost.Hostname  | Should -Be "SRV01"
            $dbHost.OS        | Should -Be "Windows Server 2019"
            $dbHost.HostType  | Should -Be "Server"
        }
        It "TC-27: Duplicate invocation with a forced update" {
            $dbHost = New-dbHost -MACAddress "00:11:22:33:44:55" |
                    Set-HostBasic -IPAddress "192.168.1.100" |
                    Set-HostBasic -IPAddress "10.0.0.1" -Force
            $dbHost.IPAddress | Should -Be "10.0.0.1"
        }
        # It "TC-28: Multiple calls to Set-HostAsDomainController should merge AD_Roles" {
        #     $dbHost = New-dbHost -MACAddress "00:11:22:33:44:55" |
        #             Set-HostAsDomainController -AD_Roles @("GlobalCatalog") |
        #             Set-HostAsDomainController -AD_Roles @("PrimaryDomainController") -Force
        #     $dbHost.AD_Roles | Should -BeExactly @("GlobalCatalog", "PrimaryDomainController")
        # }
    }

    #----------------------------------
    # 9. OS–Specific Role Validation Tests
    #----------------------------------
    Describe "OS-Specific Role Validation" {
        # It "TC-29: Should throw an error when adding 'Containers' on Windows Server 2012" {
        #     $dbHost = New-dbHost -MACAddress "00:11:22:33:44:55" | Set-HostDetails -OS "Windows Server 2012"
        #     { $dbHost | Set-HostServices -WindowsRoles @("Containers") } | Should -Throw -ErrorMessage '*Validation Error*'
        # }
        # It "TC-30: Should accept 'Windows Admin Center' on Windows Server 2019" {
        #     $dbHost = New-dbHost -MACAddress "00:11:22:33:44:55" | Set-HostDetails -OS "Windows Server 2019"
        #     $dbHost = $dbHost | Set-HostServices -WindowsRoles @("Windows Admin Center")
        #     $dbHost.Services.WindowsRoles | Should -Contain "Windows Admin Center"
        # }
        # It "TC-31: Should accept 'SMB over QUIC' on Windows Server 2025" {
        #     $dbHost = New-dbHost -MACAddress "00:11:22:33:44:55" | Set-HostDetails -OS "Windows Server 2025"
        #     $dbHost = $dbHost | Set-HostServices -WindowsRoles @("SMB over QUIC")
        #     $dbHost.Services.WindowsRoles | Should -Contain "SMB over QUIC"
        # }
        # It "TC-32: Should accept 'Hyper-V Replica' on Windows Server 2016" {
        #     $dbHost = New-dbHost -MACAddress "00:11:22:33:44:55" | Set-HostDetails -OS "Windows Server 2016"
        #     $dbHost = $dbHost | Set-HostServices -WindowsRoles @("Hyper-V Replica")
        #     $dbHost.Services.WindowsRoles | Should -Contain "Hyper-V Replica"
        # }
    }

    #----------------------------------
    # 10. Performance & Load Testing
    #----------------------------------
    Describe "Performance and Load" {
        # It "TC-33: Should create and configure 1000 host objects within acceptable time" {
        #     $count = 1000
        #     $hosts = 1..$count | ForEach-Object {
        #         New-dbHost -MACAddress ("00:11:22:33:44:{0:00}" -f $_) |
        #         Set-HostBasic -IPAddress "192.168.1.100" |
        #         Set-HostType -Type "Server" |
        #         Set-HostDetails -Hostname ("SRV{0}" -f $_) -FQDN ("srv{0}.example.com" -f $_) -OS "Windows Server 2019" |
        #         Set-HostServices -WindowsRoles @("IIS", "DNS Server") -DHCP -DNS |
        #         Set-HostAsDomainController -AD_Roles @("GlobalCatalog", "PrimaryDomainController")
        #     }
        #     $hosts.Count | Should -Be $count
        # }
        # It "TC-34: Extended pipeline execution with all cmdlets should succeed" {
        #     $dbHost = New-dbHost -MACAddress "00:11:22:33:44:55" |
        #             Set-HostBasic -IPAddress "192.168.1.100" |
        #             Set-HostType -Type "Server" |
        #             Set-HostDetails -Hostname "SRV01" -FQDN "srv01.example.com" -OS "Windows Server 2019" |
        #             Set-HostServices -WindowsRoles @("IIS", "DNS Server") -DHCP -DNS |
        #             Set-HostAsDomainController -AD_Roles @("GlobalCatalog", "PrimaryDomainController")
        #     $dbHost | Should -Not -BeNullOrEmpty
        # }
        It "TC-35: Should process a large-scale update on 10,000 hosts" {
            $count = 10000
            $hosts = 1..$count | ForEach-Object {
                New-dbHost -MACAddress ("00:11:22:33:44:{0:00}" -f $_) |
                Set-HostBasic -IPAddress "192.168.1.100"
            }
            $hosts.Count | Should -Be $count
        }
    }

    #----------------------------------
    # 11. Concurrency and Race Condition Tests
    #----------------------------------
    Describe "Concurrency and Race Conditions" {
        # It "TC-36: Should handle concurrent pipeline updates using background jobs" {
        #     # Create a host and update it concurrently in two separate jobs.
        #     $dbHost = Get-TestHost
        #     $job1 = Start-Job -ScriptBlock {
        #         param($h)
        #         $h | Set-HostBasic -IPAddress "192.168.1.101" -Force
        #     } -ArgumentList $dbHost
        #     $job2 = Start-Job -ScriptBlock {
        #         param($h)
        #         $h | Set-HostDetails -Hostname "ConcurrentSRV" -OS "Windows Server 2019" -Force
        #     } -ArgumentList $dbHost
        #     Wait-Job -Job $job1, $job2 -Timeout 10 | Out-Null
        #     $update1 = Receive-Job -Job $job1
        #     $update2 = Receive-Job -Job $job2
        #     # For testing purposes, manually merge the expected values.
        #     $dbHost.IPAddress = $update1.IPAddress
        #     $dbHost.Hostname  = $update2.Hostname
        #     $dbHost.OS        = $update2.OS
        #     $dbHost.IPAddress | Should -Be "192.168.1.101"
        #     $dbHost.Hostname  | Should -Be "ConcurrentSRV"
        #     $dbHost.OS        | Should -Be "Windows Server 2019"
        # }
        # It "TC-37: Simultaneous force vs non-force updates: Forced update should prevail" {
        #     $dbHost = Get-TestHost | Set-HostBasic -IPAddress "192.168.1.100"
        #     $jobForce = Start-Job -ScriptBlock {
        #         param($h)
        #         $h | Set-HostBasic -IPAddress "10.0.0.1" -Force
        #     } -ArgumentList $dbHost
        #     $jobNonForce = Start-Job -ScriptBlock {
        #         param($h)
        #         $h | Set-HostBasic -IPAddress "172.16.0.1"
        #     } -ArgumentList $dbHost
        #     Wait-Job -Job $jobForce, $jobNonForce -Timeout 10 | Out-Null
        #     $resultForce = Receive-Job -Job $jobForce
        #     # The forced update should be the final value.
        #     $resultForce.IPAddress | Should -Be "10.0.0.1"
        # }
    }
}