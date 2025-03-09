Describe "Convert-ToNormalizedData" {

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
        It "Convert-ToNormalizedData TC01: Returns 'null' when given 'null'" -Tag 'active' {
            Convert-ToNormalizedData -InputObject $null -IgnoreFields $IgnoreFields | Should -BeExactly $null
        }

        It "Convert-ToNormalizedData TC02: Returns primitive values as-is" -Tag 'active' {
            Convert-ToNormalizedData -InputObject 42 -IgnoreFields $IgnoreFields | Should -BeExactly 42
            Convert-ToNormalizedData -InputObject "Hello" -IgnoreFields $IgnoreFields | Should -BeExactly "Hello"
            Convert-ToNormalizedData -InputObject $true -IgnoreFields $IgnoreFields | Should -BeExactly $true
        }
    }

    Context "Handling PSCustomObjects" {
        # It "Convert-ToNormalizedData TC03: Unwraps a single-property PSCustomObject" {
        #     $obj = New-Object PSCustomObject -Property @{ Value = 123 }
        #     Convert-ToNormalizedData -InputObject $obj -IgnoreFields $IgnoreFields | Should -BeExactly 123
        # }

        It "Convert-ToNormalizedData TC04: Treats a multi-property PSCustomObject as a dictionary" -Tag 'active' {
            $obj = New-Object PSCustomObject -Property @{ A = 1; B = 2 }
            $expected = [Ordered]@{ A = 1; B = 2 }

            $result = Convert-ToNormalizedData -InputObject $obj -IgnoreFields $IgnoreFields
            ($result | ConvertTo-Json -Depth 10) | Should -Be ($expected | ConvertTo-Json -Depth 10)
        }
    }

    Context "Handling Dictionaries" {
        It "Convert-ToNormalizedData TC05: Normalizes a hashtable with sorted keys" -Tag 'active' {
            $dict = @{ B = "Value2"; A = "Value1" }
            $expected = [Ordered]@{ A = "Value1"; B = "Value2" }

            $result = Convert-ToNormalizedData -InputObject $dict -IgnoreFields $IgnoreFields
            ($result | ConvertTo-Json -Depth 10) | Should -Be ($expected | ConvertTo-Json -Depth 10)
        }
    }

    Context "Handling Enumerables (Non-String)" {
        It "Convert-ToNormalizedData TC06: Normalizes an array by sorting its elements" -Tag 'active' {
            $list = @(3, 1, 2)
            $expected = @(1, 2, 3)

            $result = Convert-ToNormalizedData -InputObject $list -IgnoreFields $IgnoreFields
            $result | Should -Be $expected
        }

        It "Convert-ToNormalizedData TC07: Preserves 'null' values in an array at their original index" -Tag 'active' {
            $list = @(3, $null, 1, 2)
            $expected = @(1, $null, 2, 3)

            $result = Convert-ToNormalizedData -InputObject $list -IgnoreFields $IgnoreFields
            $result | Should -Be $expected
        }
    }

    Context "Handling Deeply Nested Structures" {
        It "Convert-ToNormalizedData TC08: Normalizes a complex nested dictionary and lists" -Tag 'active' {
            $in = @{
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

            $result = Convert-ToNormalizedData -InputObject $in -IgnoreFields $IgnoreFields
            ($result | ConvertTo-Json -Depth 10) | Should -Be ($expected | ConvertTo-Json -Depth 10)
        }
    }

    Context "Handling Mixed-Type Lists" {
        It "Convert-ToNormalizedData TC09: Returns list with stable order when sorting is not possible" -Tag 'active' {
            $in = @(1, "string", @{ key = "value" })
            $result = Convert-ToNormalizedData -InputObject $in -IgnoreFields $IgnoreFields
            ($result | ConvertTo-Json -Depth 10) | Should -Be ($in | ConvertTo-Json -Depth 10)
        }

        It "Convert-ToNormalizedData TC10: Ensures identical dictionaries inside lists remain identical" -Tag 'active' {
            $in = @( @{ "A" = 1; "B" = 2 }, @{ "A" = 1; "B" = 2 } )
            $expected = @( [Ordered]@{ "A" = 1; "B" = 2 }, [Ordered]@{ "A" = 1; "B" = 2 } )

            $result = Convert-ToNormalizedData -InputObject $in -IgnoreFields $IgnoreFields
            ($result | ConvertTo-Json -Depth 10) | Should -Be ($expected | ConvertTo-Json -Depth 10)
        }
    }

    Context "Handling Large Inputs (Performance Tests)" {
        It "Convert-ToNormalizedData TC11: Efficiently processes a large list of numbers" -Tag 'active' {
            $largeList = 1..10000 | Sort-Object { Get-Random }
            $result = Convert-ToNormalizedData -InputObject $largeList -IgnoreFields $IgnoreFields
            $expected = 1..10000

            $result | Should -BeExactly $expected
        }

        It "Convert-ToNormalizedData TC12: Efficiently processes a large dictionary with sorted keys" -Tag 'active' {
            $largeDict = @{}
            for ($i = 1; $i -le 1000; $i++) {
                $largeDict["Key$i"] = "Value$i"
            }

            $expected = [Ordered]@{}
            foreach ($key in $largeDict.Keys | Sort-Object) {
                $expected[$key] = $largeDict[$key]
            }

            $result = Convert-ToNormalizedData -InputObject $largeDict -IgnoreFields $IgnoreFields

            $sortedKeys = ($expected.Keys | Sort-Object)
            $result.Keys | Should -BeExactly $sortedKeys
        }
    }

    Context "Handling Ignored Fields" {
        It "Convert-ToNormalizedData TC13: Removes ignored fields inside dictionaries" -Tag 'active' {
            $in = @{ "A" = 1; "IgnoreMe" = 999 }
            $ignoreFields = [System.Collections.Generic.HashSet[string]]::new()
            $ignoreFields.Add("IgnoreMe")

            $expected = [Ordered]@{ "A" = 1 }
            $result = Convert-ToNormalizedData -InputObject $in -IgnoreFields $ignoreFields

            ($result | ConvertTo-Json -Depth 10) | Should -Be ($expected | ConvertTo-Json -Depth 10)
        }
    }

    Context "Additional Tests" {
        It "Convert-ToNormalizedData TC14: Handles dictionaries with non-string keys" -Tag 'active' {
            $in = @{ 1 = "One"; 2 = "Two"; "A" = "Letter" }
            $expected = [Ordered]@{ "1" = "One"; "2" = "Two"; "A" = "Letter" }
            
            $result = Convert-ToNormalizedData -InputObject $in -IgnoreFields $IgnoreFields
            ($result | ConvertTo-Json -Depth 10) | Should -Be ($expected | ConvertTo-Json -Depth 10)
        }

        It "Convert-ToNormalizedData TC15: Does not attempt to sort mixed-type lists" -Tag 'active' {
            $in = @(1, "string", @{ key = "value" })
            $expected = $in  # Expecting the same order
            
            $result = Convert-ToNormalizedData -InputObject $in -IgnoreFields $IgnoreFields
            ($result | ConvertTo-Json -Depth 10) | Should -Be ($expected | ConvertTo-Json -Depth 10)
        }

        It "Convert-ToNormalizedData TC16: Returns empty list as empty list" -Tag 'active' {
            $in = @()
            $expected = @()

            $result = Convert-ToNormalizedData -InputObject $in -IgnoreFields $IgnoreFields
            $result | Should -BeExactly $expected
        }

        It "Convert-ToNormalizedData TC17: Removes ignored fields at all levels" -Tag 'active' {
            $in = @{
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

            $result = Convert-ToNormalizedData -InputObject $in -IgnoreFields $ignoreFields
            ($result | ConvertTo-Json -Depth 10) | Should -Be ($expected | ConvertTo-Json -Depth 10)
        }

    }
}
