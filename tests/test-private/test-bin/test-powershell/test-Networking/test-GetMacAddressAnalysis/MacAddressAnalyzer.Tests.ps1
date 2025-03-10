Describe "MacAddressAnalyzer Class Tests" {

    Context "MAC Address Normalization" {

        It "MacAddressAnalyzer <name>: Should normalize MAC addresses with various delimiters and cases (case: '<mac>')" -Tag 'private','bin','powershell','networking','GetMacAddressAnalysis','active' -ForEach @(
            @{name = 'TC01'; mac = "00:1a:2B:3C:4D:5e"},
            @{name = 'TC02'; mac = "00-1a-2b-3C-4d-5E"},
            @{name = 'TC03'; mac = "001A.2B3c.4D5E"},
            @{name = 'TC04'; mac = "001A2B3C4D5E"}
        ) {
            $validMac = "001A2B3C4D5E"
            $result = [MacAddressAnalyzer]::new($mac)
            $result.MacAddress | Should -Be $validMac
        }
        
        It "MacAddressAnalyzer <name>: Should return 'Invalid' for non-hexadecimal and malformed MAC addresses (case: '<mac>')" -Tag 'private','bin','powershell','networking','GetMacAddressAnalysis','active' -ForEach @(
            @{name = 'TC05'; mac = "00:1G:2B:3C:4D:5Z"},
            @{name = 'TC06'; mac = "123456GHIJKL"},
            @{name = 'TC07'; mac = "!@#$%^&*()"},
            @{name = 'TC08'; mac = "001A2B3C4D5EXX"}
        ) {
            $result = [MacAddressAnalyzer]::new($mac)
            $result.ToPsCustomObject().Normalized | Should -Be "Invalid"
        }

        It "MacAddressAnalyzer <name>: Should handle empty and whitespace MAC addresses (case: '<hint>')" -Tag 'private','bin','powershell','networking','GetMacAddressAnalysis','active' -ForEach @(
            @{name = 'TC09'; hint = 'empty string'; mac = ""},
            @{name = 'TC10'; hint = 'whitespace'; mac = " "},
            @{name = 'TC11'; hint = 'tab'; mac = "`t"},
            @{name = 'TC12'; hint = 'newline'; mac = "`n"}
        ) {
            $result = [MacAddressAnalyzer]::new($mac)
            $result.ToPsCustomObject().Normalized | Should -Be 'Invalid'
        }

        It "MacAddressAnalyzer TC13: Should retain the original input for invalid MAC addresses" -Tag 'private','bin','powershell','networking','GetMacAddressAnalysis','active' {
            $badMac = "NotAMac"
            $result = [MacAddressAnalyzer]::new($badMac)
            $result.OriginalInput | Should -Be $badMac
        }
    }

    Context "MacAddressAnalyzer: MAC Address Type Classification" {
        It "MacAddressAnalyzer <name>: Should classify '<mac>' as '<expected>'" -Tag 'private','bin','powershell','networking','GetMacAddressAnalysis','active' -ForEach @(
            @{ name = 'TC14'; mac = "001A2B3C4D5E"; expected = "UnicastGlobal" },
            @{ name = 'TC15'; mac = "010A2B3C4D5E"; expected = "MulticastGlobal" },
            @{ name = 'TC16'; mac = "029A2B3C4D5E"; expected = "UnicastLocal" },
            @{ name = 'TC17'; mac = "03AA2B3C4D5E"; expected = "MulticastLocal" },
            @{ name = 'TC18'; mac = "FFFFFFFFFFFF"; expected = "Broadcast" }
        ) {
                $result = Get-MacAddressAnalysis $mac
                $result.AddressType | Should -Be $expected
        }
    }

    Context "MacAddressAnalyzer: MAC Address Vendor Lookup" {
        It "MacAddressAnalyzer TC19: Should retrieve correct vendor for known OUI" -Tag 'private','bin','powershell','networking','GetMacAddressAnalysis','active' {
            $result = Get-MacAddressAnalysis "000C29AABBCC"
            $result.Vendor | Should -Be "VMware, Inc."
        }

        It "MacAddressAnalyzer TC20: Should return 'Unknown' for an unlisted OUI" -Tag 'private','bin','powershell','networking','GetMacAddressAnalysis','active' {
            $result = Get-MacAddressAnalysis "ABCDEF123456"
            $result.Vendor | Should -Be "Unknown"
        }
    }

    Context "MacAddressAnalyzer: Idempotency Checks" {
        It "MacAddressAnalyzer TC21: Should return the same results on multiple calls with the same MAC" -Tag 'private','bin','powershell','networking','GetMacAddressAnalysis','active' {
            $mac = "00:1A:2B:3C:4D:5E"
            $result1 = Get-MacAddressAnalysis $mac
            $result2 = Get-MacAddressAnalysis $mac

            ($result1 | ConvertTo-Json) | Should -BeExactly ($result2 | ConvertTo-Json)
        }
    }

    Context "MacAddressAnalyzer: Error Handling & Edge Cases" {
        It "MacAddressAnalyzer TC22: Should return <expected> for <type> MAC addresses ('<mac>') with arbitrary special characters" -Tag 'private','bin','powershell','networking','GetMacAddressAnalysis','active' -ForEach @(
            @{expected = "true"; type = "valid"; mac = '00@1A#2B$3C^4D&5E'},
            @{expected = "false"; type = "invalid"; mac = 'UU@VV#WW$XX^YY&ZZ'}
        ) {
            $result = Get-MacAddressAnalysis $mac
        
            if ($type -like "valid") {
                $result.IsValid | Should -Be $true
            }
            else {
                $result.IsValid | Should -Be $false
            }
        }

        It "MacAddressAnalyzer TC23: Should return invalid for all-zero MAC addresses" -Tag 'private','bin','powershell','networking','GetMacAddressAnalysis','active' {
            $result = Get-MacAddressAnalysis "000000000000"
            $result.IsValid | Should -Be $false
        }

        It "MacAddressAnalyzer TC24: Should return invalid for MAC addresses exceeding 12 characters" -Tag 'private','bin','powershell','networking','GetMacAddressAnalysis','active' {
            $result = Get-MacAddressAnalysis "001A2B3C4D5E7F"
            $result.IsValid | Should -Be $false
        }
    }

    Context "Cmdlet Functionality" {
        It "MacAddressAnalyzer TC25: New-MacAddressAnalyzer should return valid MacAddressAnalyzer object" -Tag 'private','bin','powershell','networking','GetMacAddressAnalysis','active' {
            $macAddress = "00:1A:2B:3C:4D:5E"
            $result = New-MacAddressAnalyzer -MacAddress $macAddress
            $result.GetType().Name | Should -Be 'MacAddressAnalyzer'
            
        }

        It "MacAddressAnalyzer TC26: Get-MacAddressAnalysis should return a PSCustomObject" -Tag 'private','bin','powershell','networking','GetMacAddressAnalysis','active' {
            $result = Get-MacAddressAnalysis -MacAddress "00:1A:2B:3C:4D:5E"
            $result | Should -BeOfType "PSCustomObject"
        }

        It "MacAddressAnalyzer TC27: Get-MacAddressAnalysis should correctly classify a MAC" -Tag 'private','bin','powershell','networking','GetMacAddressAnalysis','active' {
            $result = Get-MacAddressAnalysis -MacAddress "00:1A:2B:3C:4D:5E"
            $result.AddressType | Should -Be "UnicastGlobal"
        }
    }
}

