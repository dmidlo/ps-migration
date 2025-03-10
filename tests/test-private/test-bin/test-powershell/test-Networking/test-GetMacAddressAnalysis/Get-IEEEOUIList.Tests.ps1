Describe "Get-IEEEOUIList" -Tag "Unit", "Integration" {
    BeforeEach {
        $TestCacheFile = "TestDrive:\ieee_oui_list.clixml"
        $MockOUIData = @"
00-14-22   (hex)    CISCO SYSTEMS, INC.
00-1A-2B   (hex)    APPLE, INC.
"@
        $MockOUIHashTable = @{
            "001422" = "CISCO SYSTEMS, INC."
            "001A2B" = "APPLE, INC."
        }
    }

    AfterEach {
        # Ensure clean TestDrive after each test
        Remove-Item -Path "TestDrive:\*" -Recurse -Force -ErrorAction SilentlyContinue
    }

    Context "Get-IEEEOUIList: When cache file exists and is valid" {
        BeforeEach {
            # Simulate a valid cache file
            $MockOUIHashTable | Export-Clixml -Path $TestCacheFile
        }

        It "Get-IEEEOUIList TC01: should return cached data instead of downloading" -Tag 'bin','powershell','networking','TestMACAddressString','GetIEEEOUIList','active' {
            Mock -CommandName Invoke-WebRequest -MockWith { throw "Should not be called" }

            $Result = Get-IEEEOUIList -CacheFile $TestCacheFile -CacheDays 1
            $Result.Keys | Should -Contain "001422"
            $Result["001422"] | Should -Be "CISCO SYSTEMS, INC."
        }
    }

    Context "When cache file is expired" {
        BeforeEach {
            # Simulate an expired cache file using LastWriteTime instead of CreationTime
            $MockOUIHashTable | Export-Clixml -Path $TestCacheFile
            (Get-Item $TestCacheFile).CreationTime = (Get-Date).AddDays(-2)
        }

        It "Get-IEEEOUIList TC02: should download new OUI data and update the cache" -Tag 'bin','powershell','networking','TestMACAddressString','GetIEEEOUIList','active' {
            Mock -CommandName Invoke-WebRequest -MockWith { @{ Content = $MockOUIData } }
            (Get-Item $TestCacheFile).CreationTime | Should -BeLessOrEqual (Get-Date).AddDays(-2)

            $Result = Get-IEEEOUIList -CacheFile $TestCacheFile -CacheDays 1
            $Result.Count | Should -BeGreaterThan 0

            Test-Path $TestCacheFile | Should -Be $true
            (Get-Item $TestCacheFile).CreationTime | Should -BeGreaterOrEqual (Get-Date).AddMinutes(-5)
        }
    }

    Context "When cache file does not exist" {
        It "Get-IEEEOUIList TC03: should download OUI data and create a new cache file" -Tag 'bin','powershell','networking','TestMACAddressString','GetIEEEOUIList','active' {
            Mock -CommandName Invoke-WebRequest -MockWith { @{ Content = $MockOUIData } }

            $Result = Get-IEEEOUIList -CacheFile $TestCacheFile -CacheDays 1
            $Result.Keys | Should -Contain "001422"
            Test-Path $TestCacheFile | Should -Be $true
        }
    }

    Context "When cache file is corrupt" {
        BeforeEach {
            # Create a corrupt cache file
            Set-Content -Path $TestCacheFile -Value "This is not valid Clixml data"
        }

        It "Get-IEEEOUIList TC04: should handle corrupt cache file and attempt redownload" -Tag 'bin','powershell','networking','TestMACAddressString','GetIEEEOUIList','active' {
            Mock -CommandName Invoke-WebRequest -MockWith { @{ Content = $MockOUIData } }

            { Get-IEEEOUIList -CacheFile $TestCacheFile -CacheDays 1 } | Should -Not -Throw
            Test-Path $TestCacheFile | Should -Be $true
        }
    }

    Context "Integration Test - Valid Cache File" {
        BeforeEach {
            # Save actual OUI data for real integration test
            Get-IEEEOUIList -CacheFile $TestCacheFile -CacheDays 1 | Out-Null
        }

        It "Get-IEEEOUIList TC05: should retrieve valid cached OUI data" -Tag 'bin','powershell','networking','TestMACAddressString','GetIEEEOUIList','active' {
            $Result = Get-IEEEOUIList -CacheFile $TestCacheFile -CacheDays 1
            $Result.Count | Should -BeGreaterThan 0
        }
    }

    Context "Integration Test - Fresh Download" {
        It "Get-IEEEOUIList TC09: should successfully download fresh OUI data" -Tag 'bin','powershell','networking','TestMACAddressString','GetIEEEOUIList','active' {
            $Result = Get-IEEEOUIList -CacheFile $TestCacheFile -CacheDays 0
            $Result.Count | Should -BeGreaterThan 0
        }
    }
}
