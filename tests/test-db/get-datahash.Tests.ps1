Describe "Get-DataHash" {

    Context "Basic Functionality" {
        It "Get-DataHash TC01: Computes correct hash for simple objects"  {
            $data = @{ Name = "Alice"; Age = 30 }
            $result = Get-DataHash -DataObject $data

            $result | Should -BeOfType Hashtable
            $result.Keys | Should -Contain "NormalizedData"
            $result.Keys | Should -Contain "Json"
            $result.Keys | Should -Contain "Hash"
            $result.Json | Should -Match '"Name":"Alice"'
            $result.Json | Should -Match '"Age":30'
        }
    }

    Context "Edge Cases" {
        # It "Get-DataHash TC02: Handles null input correctly" {
        #     $result = Get-DataHash -DataObject $null

        #     $result.NormalizedData | Should -Be $null
        #     $result.Json | Should -Be "null"
        #     $result.Hash | Should -BeExactly (Compute-HashSHA256 "null")
        # }

        It "Get-DataHash TC03: Handles empty hashtable correctly"  {
            $data = @{}
            $result = Get-DataHash -DataObject $data

            $result.NormalizedData | Should -BeOfType PSCustomObject
            $result.Json | Should -Be "{}"
            $result.Hash | Should -BeExactly (Compute-HashSHA256 "{}")
        }

        # It "Get-DataHash TC04: Handles empty array correctly"  {
        #     $data = @()
        #     $result = Get-DataHash -DataObject $data

        #     $result.NormalizedData | Should -BeOfType Object[]
        #     $result.Json | Should -Be "[]"
        #     $result.Hash | Should -BeExactly (Compute-HashSHA256 "[]")
        # }
    }

    Context "Ignored Fields Handling" {
        It "Get-DataHash TC05: Excludes ignored fields from hashing"  {
            $data = @{ Name = "Bob"; Age = 25; Guid = "1234-5678" }
            $result = Get-DataHash -DataObject $data -FieldsToIgnore @("Guid")

            $result.Json | Should -Not -Match "1234-5678"
            $result.Json | Should -Match '"Name":"Bob"'
            $result.Json | Should -Match '"Age":25'
        }

        It "Get-DataHash TC06: Ignores fields case-insensitively"  {
            $data = @{ ID = "XYZ"; name = "Charlie" }
            $result = Get-DataHash -DataObject $data -FieldsToIgnore @("id")

            $result.Json | Should -Not -Match '"ID":"XYZ"'
            $result.Json | Should -Match '"name":"Charlie"'
        }
    }

    Context "Deterministic Hashing" {
        It "Get-DataHash TC07: Produces the same hash for the same input"  {
            $data = @{ Value = 100; Nested = @{ Key = "Data" } }
            $hash1 = (Get-DataHash -DataObject $data).Hash
            $hash2 = (Get-DataHash -DataObject $data).Hash

            $hash1 | Should -BeExactly $hash2
        }

        It "Get-DataHash TC08: Produces different hashes for different inputs"  {
            $hash1 = (Get-DataHash -DataObject @{ A = 1 }).Hash
            $hash2 = (Get-DataHash -DataObject @{ A = 2 }).Hash

            $hash1 | Should -Not -BeExactly $hash2
        }
    }

    # Context "Non-Serializable Objects" {
    #     It "Get-DataHash TC10: Handles script blocks gracefully" {
    #         $data = @{ Script = { "Some Code" } }
    #         { Get-DataHash -DataObject $data } | Should -Throw
    #     }

    #     It "Get-DataHash TC11: Handles System.IntPtr gracefully" {
    #         $data = @{ Ptr = [System.IntPtr]::Zero }
    #         { Get-DataHash -DataObject $data } | Should -Throw
    #     }
    # }

    Context "Nested Ignored Fields" {
        It "Get-DataHash TC12: Ignores case-insensitive fields in nested objects"  {
            $data = @{ Guid = "123"; Nested = @{ GUID = "456" } }
            $result = Get-DataHash -DataObject $data -FieldsToIgnore @("guid")

            $result.Json | Should -Not -Match '"123"'
            $result.Json | Should -Not -Match '"456"'
        }
    }

    # Context "Empty Input String" {
    #     It "Get-DataHash TC13: Handles empty string input correctly"  {
    #         $data = ""
    #         $result = Get-DataHash -DataObject $data

    #         $result.NormalizedData | Should -BeExactly ""
    #         $result.Json | Should -Be "\"\""
    #         $result.Hash | Should -BeExactly (Compute-HashSHA256 '""')
    #     }
    # }
}

