Describe "Normalize-Data" {

    BeforeAll {
        $ignores = @(
                "IgnoreMe"
                # "Count",
                # "IsFixedSize",
                # "IsReadOnly",
                # "IsSynchronized",
                # "Length",
                # "LongLength",
                # "Rank",
                # "SyncRoot"
            )
        $IgnoreFields = [System.Collections.Generic.HashSet[string]]::new()
        $ignores | ForEach-Object { $IgnoreFields.Add($_)}
    }

    Context "Basic Functionality" {
        It "Normalize-Data TC01: Returns 'null' when given 'null'"  {
            Normalize-Data -InputObject $null -IgnoreFields $IgnoreFields | Should -BeExactly $null
        }

        It "Normalize-Data TC02: Returns primitive values as-is"  {
            Normalize-Data -InputObject 42 -IgnoreFields $IgnoreFields | Should -BeExactly 42
            Normalize-Data -InputObject "Hello" -IgnoreFields $IgnoreFields | Should -BeExactly "Hello"
            Normalize-Data -InputObject $true -IgnoreFields $IgnoreFields | Should -BeExactly $true
        }
    }

    Context "Handling PSCustomObjects" {
        # It "Normalize-Data TC03: Unwraps a single-property PSCustomObject" {
        #     $obj = New-Object PSCustomObject -Property @{ Value = 123 }
        #     Normalize-Data -InputObject $obj -IgnoreFields $IgnoreFields | Should -BeExactly 123
        # }

        It "Normalize-Data TC04: Treats a multi-property PSCustomObject as a dictionary"  {
            $obj = New-Object PSCustomObject -Property @{ A = 1; B = 2 }
            $expected = [Ordered]@{ A = 1; B = 2 }

            $result = Normalize-Data -InputObject $obj -IgnoreFields $IgnoreFields
            ($result | ConvertTo-Json -Depth 10) | Should -Be ($expected | ConvertTo-Json -Depth 10)
        }
    }

    Context "Handling Dictionaries" {
        It "Normalize-Data TC05: Normalizes a hashtable with sorted keys"  {
            $dict = @{ B = "Value2"; A = "Value1" }
            $expected = [Ordered]@{ A = "Value1"; B = "Value2" }

            $result = Normalize-Data -InputObject $dict -IgnoreFields $IgnoreFields
            ($result | ConvertTo-Json -Depth 10) | Should -Be ($expected | ConvertTo-Json -Depth 10)
        }
    }

    Context "Handling Enumerables (Non-String)" {
        It "Normalize-Data TC06: Normalizes an array by sorting its elements"  {
            $list = @(3, 1, 2)
            $expected = @(1, 2, 3)

            $result = Normalize-Data -InputObject $list -IgnoreFields $IgnoreFields
            $result | Should -Be $expected
        }

        It "Normalize-Data TC07: Preserves 'null' values in an array at their original index"  {
            $list = @(3, $null, 1, 2)
            $expected = @(1, $null, 2, 3)

            $result = Normalize-Data -InputObject $list -IgnoreFields $IgnoreFields
            $result | Should -Be $expected
        }
    }

    Context "Handling Deeply Nested Structures" {
        It "Normalize-Data TC08: Normalizes a complex nested dictionary and lists"  {
            $input = @{
                Unsorted = @(3, 1, 2)
                Dict = @{ Z = "Last"; A = "First" }
                Nested = @{
                    Numbers = @(9, 5, 7)
                }
            }

            $expected = [Ordered]@{
                Dict = [Ordered]@{ A = "First"; Z = "Last" }
                Nested = [Ordered]@{
                    Numbers = @(5, 7, 9)
                }
                Unsorted = @(1, 2, 3)
            }

            $result = Normalize-Data -InputObject $input -IgnoreFields $IgnoreFields
            ($result | ConvertTo-Json -Depth 10) | Should -Be ($expected | ConvertTo-Json -Depth 10)
        }
    }

    Context "Handling Mixed-Type Lists" {
        It "Normalize-Data TC09: Returns list with stable order when sorting is not possible"  {
            $input = @(1, "string", @{ key = "value" })
            $result = Normalize-Data -InputObject $input -IgnoreFields $IgnoreFields
            ($result | ConvertTo-Json -Depth 10) | Should -Be ($input | ConvertTo-Json -Depth 10)
        }

        It "Normalize-Data TC10: Ensures identical dictionaries inside lists remain identical"  {
            $input = @( @{ "A" = 1; "B" = 2 }, @{ "A" = 1; "B" = 2 } )
            $expected = @( [Ordered]@{ "A" = 1; "B" = 2 }, [Ordered]@{ "A" = 1; "B" = 2 } )

            $result = Normalize-Data -InputObject $input -IgnoreFields $IgnoreFields
            ($result | ConvertTo-Json -Depth 10) | Should -Be ($expected | ConvertTo-Json -Depth 10)
        }
    }

    Context "Handling Large Inputs (Performance Tests)" {
        It "Normalize-Data TC11: Efficiently processes a large list of numbers"  {
            $largeList = 1..10000 | Sort-Object { Get-Random }
            $result = Normalize-Data -InputObject $largeList -IgnoreFields $IgnoreFields
            $expected = 1..10000

            $result | Should -BeExactly $expected
        }

        It "Normalize-Data TC12: Efficiently processes a large dictionary with sorted keys"  {
            $largeDict = @{}
            for ($i = 1; $i -le 1000; $i++) {
                $largeDict["Key$i"] = "Value$i"
            }

            $expected = [Ordered]@{}
            foreach ($key in $largeDict.Keys | Sort-Object) {
                $expected[$key] = $largeDict[$key]
            }

            $result = Normalize-Data -InputObject $largeDict -IgnoreFields $IgnoreFields

            $sortedKeys = ($expected.Keys | Sort-Object)
            $result.Keys | Should -BeExactly $sortedKeys
        }
    }

    Context "Handling Ignored Fields" {
        It "Normalize-Data TC13: Removes ignored fields inside dictionaries"  {
            $input = @{ "A" = 1; "IgnoreMe" = 999 }
            $ignoreFields = [System.Collections.Generic.HashSet[string]]::new()
            $ignoreFields.Add("IgnoreMe")

            $expected = [Ordered]@{ "A" = 1 }
            $result = Normalize-Data -InputObject $input -IgnoreFields $ignoreFields

            ($result | ConvertTo-Json -Depth 10) | Should -Be ($expected | ConvertTo-Json -Depth 10)
        }
    }

    Context "Additional Tests" {
        It "Normalize-Data TC14: Handles dictionaries with non-string keys"  {
            $input = @{ 1 = "One"; 2 = "Two"; "A" = "Letter" }
            $expected = [Ordered]@{ "1" = "One"; "2" = "Two"; "A" = "Letter" }
            
            $result = Normalize-Data -InputObject $input -IgnoreFields $IgnoreFields
            ($result | ConvertTo-Json -Depth 10) | Should -Be ($expected | ConvertTo-Json -Depth 10)
        }

        It "Normalize-Data TC15: Does not attempt to sort mixed-type lists"  {
            $input = @(1, "string", @{ key = "value" })
            $expected = $input  # Expecting the same order
            
            $result = Normalize-Data -InputObject $input -IgnoreFields $IgnoreFields
            ($result | ConvertTo-Json -Depth 10) | Should -Be ($expected | ConvertTo-Json -Depth 10)
        }

        It "Normalize-Data TC16: Returns empty list as empty list"  {
            $input = @()
            $expected = @()

            $result = Normalize-Data -InputObject $input -IgnoreFields $IgnoreFields
            $result | Should -BeExactly $expected
        }

        It "Normalize-Data TC17: Removes ignored fields at all levels"  {
            $input = @{
                "Keep" = 1
                "RemoveMe" = 2
                "Nested" = @{
                    "RemoveMe" = 3
                    "Keep" = 4
                }
            }

            $ignoreFields = [System.Collections.Generic.HashSet[string]]::new()
            $ignoreFields.Add("RemoveMe")

            $expected = [Ordered]@{
                "Keep" = 1
                "Nested" = [Ordered]@{ "Keep" = 4 }
            }

            $result = Normalize-Data -InputObject $input -IgnoreFields $ignoreFields
            ($result | ConvertTo-Json -Depth 10) | Should -Be ($expected | ConvertTo-Json -Depth 10)
        }

    }
}
