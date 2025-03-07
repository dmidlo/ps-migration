Describe "Convert-ToNormalizedList Tests" {

    BeforeAll {
        $IgnoreFields = [System.Collections.Generic.HashSet[string]]::new()
        $IgnoreFields.Add("IgnoreMe")
    }

    Context "Basic Functionality" {
        It "Convert-ToNormalizedList TC01: Returns an empty list when given an empty list" -Tag 'active' {
            $result = Convert-ToNormalizedList -List @() -IgnoreFields $IgnoreFields
            $result | Should -BeExactly @()
        }

        It "Convert-ToNormalizedList TC02: Returns the same list if elements are already normalized" -Tag 'active' {
            $in = @(1, "test", @{ key = "value" })
            $expected = @(1, "test", [Ordered]@{ key = "value" })
            $result = Convert-ToNormalizedList -List $in -IgnoreFields $IgnoreFields
            ($result | ConvertTo-Json -Depth 10) | Should -Be ($expected | ConvertTo-Json -Depth 10)
        }
    }

    Context "Sorting Behavior" {
        It "Convert-ToNormalizedList TC03: Sorts a list of numbers" -Tag 'active' {
            $result = Convert-ToNormalizedList -List @(3, 1, 2) -IgnoreFields $IgnoreFields
            $result | Should -BeExactly @(1, 2, 3)
        }

        It "Convert-ToNormalizedList TC04: Sorts a list of duplicate numbers correctly" -Tag 'active' {
            $result = Convert-ToNormalizedList -List @(3, 1, 3, 2, 1) -IgnoreFields $IgnoreFields
            $result | Should -BeExactly @(1, 1, 2, 3, 3)
        }

        It "Convert-ToNormalizedList TC05: Sorts a list of strings case-insensitively" -Tag 'active' {
            $result = Convert-ToNormalizedList -List @("B", "a", "C") -IgnoreFields $IgnoreFields
            $result | Should -BeExactly @("a", "B", "C")  
        }

        It "Convert-ToNormalizedList TC06: Does not change order when elements are not all comparable" -Tag 'active' {
            $in = @(1, "string", @{ key = "value" })
            $result = Convert-ToNormalizedList -List $in -IgnoreFields $IgnoreFields
            ($result | ConvertTo-Json -Depth 10) | Should -BeExactly ($in | ConvertTo-Json -Depth 10)
        }
    }

    Context "Null Handling" {
        It "Convert-ToNormalizedList TC07: Preserves `$null` values in their original positions" -Tag 'active' {
            $result = Convert-ToNormalizedList -List @(1, $null, 2) -IgnoreFields $IgnoreFields
            $result | Should -BeExactly @(1, $null, 2)
        }

        It "Convert-ToNormalizedList TC08: Preserves `$null` while sorting sortable elements" -Tag 'active' {
            $result = Convert-ToNormalizedList -List @(3, $null, 1, 2, $null) -IgnoreFields $IgnoreFields
            $result | Should -BeExactly @(1, $null, 2, 3, $null)
        }

        It "Convert-ToNormalizedList TC09: Preserves `$null` in a mixed-type list without sorting" -Tag 'active' {
            $in = @("A", $null, 2, @{ key = "value" })
            $result = Convert-ToNormalizedList -List $in -IgnoreFields $IgnoreFields
            ($result | ConvertTo-Json -Depth 10) | Should -BeExactly ($in | ConvertTo-Json -Depth 10)
        }
    }

    Context "Recursion & Nested Structures" {
        It "Convert-ToNormalizedList TC10: Recursively normalizes nested lists" -Tag 'active' {
            $in = @(@(3, 1, 2), @(9, 7, 8))
            $result = Convert-ToNormalizedList -List $in -IgnoreFields $IgnoreFields
            $expected = @(@(1, 2, 3), @(7, 8, 9))

            $result | Should -BeExactly $expected
        }

        It "Convert-ToNormalizedList TC11: Recursively normalizes deeply nested structures" -Tag 'active' {
            $in = @(@(@(5, 3, 1)), @(@(9, 7, 8)))
            $result = Convert-ToNormalizedList -List $in -IgnoreFields $IgnoreFields
            $expected = @(@(@(1, 3, 5)), @(@(7, 8, 9)))

            $result | Should -BeExactly $expected
        }

        It "Convert-ToNormalizedList TC12: Recursively normalizes dictionaries inside lists" -Tag 'active' {
            $in = @(@{ a = 2; b = 1 }, @{ a = 4; b = 3 })
            $result = Convert-ToNormalizedList -List $in -IgnoreFields $IgnoreFields

            $expected = @(
                [Ordered]@{ a = 2; b = 1 },
                [Ordered]@{ a = 4; b = 3 }
            )

            ($result | ConvertTo-Json -Depth 10) | Should -BeExactly ($expected | ConvertTo-Json -Depth 10)
        }

        It "Convert-ToNormalizedList TC13: Handles ignored fields inside dictionaries in lists" -Tag 'active' {
            $in = @(@{ a = 2; b = 1 }, @{ a = 4; b = 3 })
            $ignoreFields = [System.Collections.Generic.HashSet[string]]::new()
            $ignoreFields.Add("b")

            $result = Convert-ToNormalizedList -List $in -IgnoreFields $ignoreFields
            $expected = @(
                [Ordered]@{ a = 2 },
                [Ordered]@{ a = 4 }
            )

            ($result | ConvertTo-Json -Depth 10) | Should -BeExactly ($expected | ConvertTo-Json -Depth 10)
        }
    }

    Context "Handling Mixed Types" {
        It "Convert-ToNormalizedList TC14: Handles lists with mixed types without errors" -Tag 'active' {
            $in = @(1, "text", $null, @{ key = "value" }, @(5, 2))
            $result = Convert-ToNormalizedList -List $in -IgnoreFields $IgnoreFields
            $result.Count | Should -Be 5
        }

        It "Convert-ToNormalizedList TC15: Maintains stable order in mixed-type lists when sorting is impossible" -Tag 'active' {
            $in = @(1, "string", @{ key = "value" }, @(2, 5))
            $result = Convert-ToNormalizedList -List $in -IgnoreFields $IgnoreFields
            ($result | ConvertTo-Json -Depth 10) | Should -BeExactly ($in | ConvertTo-Json -Depth 10)
        }
    }

    Context "Performance & Scalability" {
        It "Convert-ToNormalizedList TC16: Handles a large list of numbers efficiently" -Tag 'active' {
            $largeList = 1..10000 | Sort-Object { Get-Random }
            $result = Convert-ToNormalizedList -List $largeList -IgnoreFields $IgnoreFields
            $expected = 1..10000

            $result | Should -BeExactly $expected
        }

        It "Convert-ToNormalizedList TC17: Handles a large list of dictionaries efficiently" -Tag 'active' {
            $largeList = @(For ($i = 1; $i -le 1000; $i++) { @{ id = $i; value = (1000 - $i) } })
            $ignoreFields = [System.Collections.Generic.HashSet[string]]::new()
            $ignoreFields.Add("value")

            $result = Convert-ToNormalizedList -List $largeList -IgnoreFields $ignoreFields
            $expected = @(For ($i = 1; $i -le 1000; $i++) { [Ordered]@{ id = $i } })

            # Ensure all keys exist and are sorted
            $sortedKeys = ($expected.Keys | Sort-Object)
            $result.Keys | Should -BeExactly $sortedKeys
        }
    }

    Context "Additional Tests" {
        # It "Convert-ToNormalizedList TC18: Normalizes dictionaries with mixed key types inside a list"  {
        #     $in = @( @{ 1 = "one"; "B" = "bee" } )
        #     $expected = @( [Ordered]@{ 1 = "one"; "B" = "bee" } )

        #     $result = Convert-ToNormalizedList -List $in -IgnoreFields $IgnoreFields
        #     ($result | ConvertTo-Json -Depth 10) | Should -Be ($expected | ConvertTo-Json -Depth 10)
        # }

        It "Convert-ToNormalizedList TC19: Ensures identical dictionaries inside lists remain identical" -Tag 'active' {
            $in = @( @{ "A" = 1; "B" = 2 }, @{ "A" = 1; "B" = 2 } )
            $expected = @( [Ordered]@{ "A" = 1; "B" = 2 }, [Ordered]@{ "A" = 1; "B" = 2 } )

            $result = Convert-ToNormalizedList -List $in -IgnoreFields $IgnoreFields
            ($result | ConvertTo-Json -Depth 10) | Should -Be ($expected | ConvertTo-Json -Depth 10)
        }

        It "Convert-ToNormalizedList TC20: Removes ignored fields inside dictionaries within lists" -Tag 'active' {
            $in = @( @{ "A" = 1; "IgnoreMe" = 999 }, @{ "B" = 2; "IgnoreMe" = 888 } )
            $expected = @( [Ordered]@{ "A" = 1 }, [Ordered]@{ "B" = 2 } )

            $result = Convert-ToNormalizedList -List $in -IgnoreFields $IgnoreFields
            ($result | ConvertTo-Json -Depth 10) | Should -Be ($expected | ConvertTo-Json -Depth 10)
        }

        It "Convert-ToNormalizedList TC21: Sorts a list of dictionaries by key order" -Tag 'active' {
            $in = @( @{ "Z" = 3 }, @{ "A" = 1 } )
            $expected = @( [Ordered]@{ "A" = 1 }, [Ordered]@{ "Z" = 3 } )

            $result = Convert-ToNormalizedList -List $in -IgnoreFields $IgnoreFields
            ($result | ConvertTo-Json -Depth 10) | Should -Be ($expected | ConvertTo-Json -Depth 10)
        }

        It "Convert-ToNormalizedList TC22: Leaves an already sorted list of dictionaries unchanged" -Tag 'active' {
            $in = @( @{ "A" = 1 }, @{ "B" = 2 } )
            $expected = $in  # It should remain unchanged

            $result = Convert-ToNormalizedList -List $in -IgnoreFields $IgnoreFields
            ($result | ConvertTo-Json -Depth 10) | Should -Be ($expected | ConvertTo-Json -Depth 10)
        }

        It "Convert-ToNormalizedList TC23: Recursively normalizes nested lists inside dictionaries in a list" -Tag 'active' {
            $in = @( @{ "List" = @(3, 1, 2) }, @{ "List" = @(9, 7, 8) } )
            $expected = @( [Ordered]@{ "List" = @(1, 2, 3) }, [Ordered]@{ "List" = @(7, 8, 9) } )

            $result = Convert-ToNormalizedList -List $in -IgnoreFields $IgnoreFields
            ($result | ConvertTo-Json -Depth 10) | Should -Be ($expected | ConvertTo-Json -Depth 10)
        }
    }
}

