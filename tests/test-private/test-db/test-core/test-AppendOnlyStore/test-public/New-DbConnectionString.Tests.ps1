# Describe "New-DbConnectionString - Integration Tests" {

#     BeforeAll {
#         # Define test database paths (using temp directory)
#         $TestDbPath1 = "$env:TEMP\TestDatabase1.db"
#         $TestDbPath2 = "$env:TEMP\TestDatabase2.db"
        
#         # Cleanup any leftover test files
#         Remove-Item -Path $TestDbPath1, $TestDbPath2 -ErrorAction SilentlyContinue
#     }

#     Context "Basic Functionality" {
#         It "should return a LiteDB.ConnectionString object with the correct filename" {
#             $result = New-DbConnectionString -FilePath $TestDbPath1
#             $result | Should -BeOfType ([LiteDB.ConnectionString])
#             $result.Filename | Should -Be $TestDbPath1
#         }
#     }

#     Context "ReadOnly Mode" {
#         It "should set ReadOnly mode when specified" {
#             $result = New-DbConnectionString -FilePath $TestDbPath1 -ReadOnly
#             $result.ReadOnly | Should -Be $true
#         }

#         It "should NOT set ReadOnly mode when not specified" {
#             $result = New-DbConnectionString -FilePath $TestDbPath1
#             $result.ReadOnly | Should -Be $false
#         }
#     }

#     Context "Collation Settings" {
#         It "should set correct collation when IgnoreCase is enabled" {
#             $result = New-DbConnectionString -FilePath $TestDbPath1 -IgnoreCase
#             $result.Collation | Should -Not -BeNullOrEmpty
#         }

#         It "should set default collation when no collation flags are set" {
#             $result = New-DbConnectionString -FilePath $TestDbPath1
#             $result.Collation | Should -Not -BeNullOrEmpty
#         }
#     }

#     Context "Password Handling" {
#         It "should store the correct password when provided" {
#             $securePassword = ConvertTo-SecureString "TestPass123" -AsPlainText -Force
#             $cred = New-Object PSCredential ("User", $securePassword)

#             $result = New-DbConnectionString -FilePath $TestDbPath1 -Password $cred
#             $result.Password | Should -Be "TestPass123"
#         }

#         It "should not store a password if none is provided" {
#             $result = New-DbConnectionString -FilePath $TestDbPath1
#             $result.Password | Should -BeNullOrEmpty
#         }
#     }

#     Context "Connection Type" {
#         It "should default to Direct connection type" {
#             $result = New-DbConnectionString -FilePath $TestDbPath1
#             $result.Connection | Should -Be ([LiteDB.ConnectionType]::Direct)
#         }

#         It "should allow setting ConnectionType to Shared" {
#             $result = New-DbConnectionString -FilePath $TestDbPath1 -ConnectionType "Shared"
#             $result.Connection | Should -Be ([LiteDB.ConnectionType]::Shared)
#         }
#     }

#     Context "Database Size and Upgrade" {
#         It "should set InitialSize correctly when provided" {
#             $result = New-DbConnectionString -FilePath $TestDbPath1 -InitialSize 102400
#             $result.InitialSize | Should -Be 102400
#         }

#         It "should set Upgrade flag when specified" {
#             $result = New-DbConnectionString -FilePath $TestDbPath1 -Upgrade
#             $result.Upgrade | Should -Be $true
#         }

#         It "should NOT set Upgrade flag when not specified" {
#             $result = New-DbConnectionString -FilePath $TestDbPath1
#             $result.Upgrade | Should -Be $false
#         }
#     }

#     Context "File Path Handling" {
#         It "should accept valid file paths and return the correct filename" {
#             $result = New-DbConnectionString -FilePath $TestDbPath2
#             $result.Filename | Should -Be $TestDbPath2
#         }
#     }

#     Context "Edge Cases" {
#         It "should throw an error when FilePath is missing" {
#             { New-DbConnectionString } | Should -Throw
#         }

#         It "should throw an error for invalid ConnectionType" {
#             { New-DbConnectionString -FilePath $TestDbPath1 -ConnectionType "Invalid" } | Should -Throw
#         }

#         It "should throw an error when given an excessively large InitialSize" {
#             { New-DbConnectionString -FilePath $TestDbPath1 -InitialSize [long]::MaxValue } | Should -Throw
#         }
#     }

#     AfterAll {
#         # Cleanup test files
#         Remove-Item -Path $TestDbPath1, $TestDbPath2 -ErrorAction SilentlyContinue
#     }
# }
