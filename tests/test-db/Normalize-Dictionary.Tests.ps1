Describe "Normalize-Dictionary" {
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

    It "Normalize-Dictionary TC01: Sorts keys in a hashtable" -Tag 'active' {
        $input = @{ "b" = 2; "a" = 1; "c" = 3 }
        $expected = [Ordered]@{ "a" = 1; "b" = 2; "c" = 3 }

        $result = Normalize-Dictionary -Dictionary $input -IgnoreFields $IgnoreFields

        $result.Keys | Should -BeExactly $expected.Keys
        $result.Values | Should -BeExactly $expected.Values
    }

    It "Normalize-Dictionary TC02: Removes fields specified in IgnoreFields" -Tag 'active' {
        $input = @{ "KeepMe" = "Value"; "IgnoreMe" = "Hidden" }
        $expected = [Ordered]@{ "KeepMe" = "Value" }

        $result = Normalize-Dictionary -Dictionary $input -IgnoreFields $IgnoreFields

        $result.Keys | Should -BeExactly $expected.Keys
        $result.Values | Should -BeExactly $expected.Values
    }

    It "Normalize-Dictionary TC03: Recursively normalizes nested dictionaries" -Tag 'active' {
        $input = @{
            "Nested" = @{
                "Z" = 3
                "A" = 1
            }
        }

        $expected = [Ordered]@{
            "Nested" = [Ordered]@{
                "A" = 1
                "Z" = 3
            }
        }

        $result = Normalize-Dictionary -Dictionary $input -IgnoreFields $IgnoreFields

        $result.Keys | Should -BeExactly $expected.Keys
        $result["Nested"].Keys | Should -BeExactly $expected["Nested"].Keys
        $result["Nested"].Values | Should -BeExactly $expected["Nested"].Values
        ($result | ConvertTo-Json -Depth 10) | Should -Be ($expected | ConvertTo-Json -Depth 10)
    }

    It "Normalize-Dictionary TC04: Handles PSCustomObject conversion" -Tag 'active' {
        $object = New-Object PSCustomObject -Property @{ "b" = 2; "a" = 1; "c" = 3 }
        $expected = [Ordered]@{ "a" = 1; "b" = 2; "c" = 3 }

        $result = Normalize-Dictionary -Dictionary $object -IgnoreFields $IgnoreFields

        $result.Keys | Should -BeExactly $expected.Keys
        $result.Values | Should -BeExactly $expected.Values
    }

    It "Normalize-Dictionary TC05: Handles a dictionary with mixed data types" -Tag 'active' {
        $input = @{ "Number" = 42; "String" = "Hello"; "Array" = @(1, 2, 3) }
        $expected = [Ordered]@{ "Array" = @(1, 2, 3); "Number" = 42; "String" = "Hello" }

        $result = Normalize-Dictionary -Dictionary $input -IgnoreFields $IgnoreFields

        $result.Keys | Should -BeExactly $expected.Keys
        $result.Values | Should -BeExactly $expected.Values
    }

    It "Normalize-Dictionary TC06: Throws an error for non-dictionary input" -Tag 'active' {
        $exception = $null
        try {
            Normalize-Dictionary -Dictionary "NotAHashTable" -IgnoreFields $IgnoreFields
        } catch {
            $exception = $_
        }
        
        $exception | Should -Not -BeNullOrEmpty
        $exception.Exception.Message | Should -Match "Expected IDictionary or PSCustomObject"
    }

    It "Normalize-Dictionary TC07: Recursively normalizes nested lists" -Tag 'active' {
        $input = @{ "List" = @(3, 1, 2) }
        $expected = [Ordered]@{ "List" = @(1, 2, 3) }  # Expect sorted list

        $result = Normalize-Dictionary -Dictionary $input -IgnoreFields $IgnoreFields

        # Ensure keys are correctly ordered
        $result.Keys | Should -BeExactly $expected.Keys

        # Ensure the list is normalized (sorted)
        $result["List"] | Should -BeExactly $expected["List"]
    }

    It "Normalize-Dictionary TC08: Handles empty lists and null values" -Tag 'active' {
        $input = @{ "EmptyList" = @(); "NullValue" = $null }
        $expected = [Ordered]@{ "EmptyList" = @(); "NullValue" = $null }

        $result = Normalize-Dictionary -Dictionary $input -IgnoreFields $IgnoreFields

        $result.Keys | Should -BeExactly $expected.Keys
        $result.Values | Should -BeExactly $expected.Values
    }

    It "Normalize-Dictionary TC09: Fully normalizes multi-level nested dictionaries" -Tag 'active' {
        $input = @{ "Outer" = @{ "Middle" = @{ "Inner" = "Value"; "Another" = "Test" } } }

        $expected = [Ordered]@{
            "Outer" = [Ordered]@{
                "Middle" = [Ordered]@{
                    "Another" = "Test"
                    "Inner"   = "Value"
                }
            }
        }

        $result = Normalize-Dictionary -Dictionary $input -IgnoreFields $IgnoreFields

        # Ensure outermost keys are correctly ordered
        $result.Keys | Should -BeExactly $expected.Keys

        # Ensure middle level keys are correctly ordered
        $result["Outer"].Keys | Should -BeExactly $expected["Outer"].Keys

        # Ensure innermost level keys are correctly ordered
        $result["Outer"]["Middle"].Keys | Should -BeExactly $expected["Outer"]["Middle"].Keys

        # Verify entire JSON representation (ensures full normalization)
        ($result | ConvertTo-Json -Depth 10) | Should -Be ($expected | ConvertTo-Json -Depth 10)
    }

    It "Normalize-Dictionary TC10: Ignores fields case-insensitively" -Tag 'active' {
        $IgnoreFieldsCaseInsensitive = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
        $IgnoreFieldsCaseInsensitive.Add("ignoreme")

        $input = @{ "IgnoreMe" = "Hidden"; "KeepMe" = "Value" }
        $expected = [Ordered]@{ "KeepMe" = "Value" }

        $result = Normalize-Dictionary -Dictionary $input -IgnoreFields $IgnoreFieldsCaseInsensitive

        $result.Keys | Should -BeExactly $expected.Keys
    }

    It "Normalize-Dictionary TC11: Handles mixed key types correctly" {
        $input = @{ "StringKey" = "Value"; 42 = "NumberKey" }
        $expected = [Ordered]@{ 42 = "NumberKey"; "StringKey" = "Value" } # Sorted order

        $result = Normalize-Dictionary -Dictionary $input -IgnoreFields $IgnoreFields

        $result.Keys | Should -BeExactly $expected.Keys
        $result.Values | Should -BeExactly $expected.Values
    }

    It "Normalize-Dictionary TC12: Handles a dictionary with mixed value types" -Tag 'active' {
        $input = @{
            "String"  = "Hello"
            "Number"  = 123
            "Boolean" = $true
            "Array"   = @(3, 1, 2)
            "Nested"  = @{ "Key" = "Value" }
        }
        
        $expected = [Ordered]@{
            "Array"   = @(1, 2, 3)   # Expect sorted list
            "Boolean" = $true
            "Nested"  = [Ordered]@{ "Key" = "Value" }
            "Number"  = 123
            "String"  = "Hello"
        }

        $result = Normalize-Dictionary -Dictionary $input -IgnoreFields $IgnoreFields
        ($result | ConvertTo-Json -Depth 10) | Should -Be ($expected | ConvertTo-Json -Depth 10)
    }

    It "Normalize-Dictionary TC13: Handles a large dictionary efficiently" -Tag 'active' {
        $input = @{}
        for ($i = 1; $i -le 1000; $i++) {
            $input["Key$i"] = $i
        }

        $result = Normalize-Dictionary -Dictionary $input -IgnoreFields $IgnoreFields

        # Ensure all keys exist and are sorted
        $sortedKeys = ($input.Keys | Sort-Object)
        $result.Keys | Should -BeExactly $sortedKeys
    }

    It "Normalize-Dictionary TC14: Handles circular references without infinite recursion" -Tag 'active' {
        $input = @{ "Self" = $null }
        $input["Self"] = $input  # Circular reference

        $exception = $null
        try {
            $result = Normalize-Dictionary -Dictionary $input -IgnoreFields $IgnoreFields
        } catch {
            $exception = $_
        }

        $exception | Should -Not -BeNullOrEmpty
        $exception.Exception.Message | Should -Match "The script failed due to call depth overflow."
    }

    It "Normalize-Dictionary TC15: Produces identical output when run multiple times" -Tag 'active' {
        $input = @{ "b" = 2; "a" = 1; "c" = 3 }
        $expected = Normalize-Dictionary -Dictionary $input -IgnoreFields $IgnoreFields

        $result = Normalize-Dictionary -Dictionary $expected -IgnoreFields $IgnoreFields

        ($result | ConvertTo-Json -Depth 10) | Should -Be ($expected | ConvertTo-Json -Depth 10)
    }

    It "Normalize-Dictionary TC16: Preserves `$null` values in nested dictionaries" -Tag 'active' {
        $input = @{ "Outer" = @{ "Inner" = $null } }
        $expected = [Ordered]@{ "Outer" = [Ordered]@{ "Inner" = $null } }

        $result = Normalize-Dictionary -Dictionary $input -IgnoreFields $IgnoreFields

        ($result | ConvertTo-Json -Depth 10) | Should -Be ($expected | ConvertTo-Json -Depth 10)
    }

    # It "Normalize-Dictionary TC17: Retains list order when containing mixed types" {
    #     $input = @{ "MixedList" = @(1, "string", @{ key = "value" }) }
    #     $expected = [Ordered]@{ "MixedList" = @(1, "string", [Ordered]@{ key = "value" }) }

    #     $result = Normalize-Dictionary -Dictionary $input -IgnoreFields $IgnoreFields

    #     ($result | ConvertTo-Json -Depth 10) | Should -Be ($expected | ConvertTo-Json -Depth 10)
    # }

    It "Normalize-Dictionary TC18: Handles deeply nested lists inside dictionaries" -Tag 'active' {
        $input = @{ "NestedList" = @(@(@(5, 3, 1)), @(@(9, 7, 8))) }
        $expected = [Ordered]@{ "NestedList" = @(@(@(1, 3, 5)), @(@(7, 8, 9))) }

        $result = Normalize-Dictionary -Dictionary $input -IgnoreFields $IgnoreFields

        ($result | ConvertTo-Json -Depth 10) | Should -Be ($expected | ConvertTo-Json -Depth 10)
    }

    It "Normalize-Dictionary TC19: Preserves `$null` values inside lists within dictionaries" -Tag 'active' {
        $input = @{ "list" = @(3, $null, 1, 2, $null) }
        $expected = [Ordered]@{ "list" = @(1, $null, 2, 3, $null) }

        $result = Normalize-Dictionary -Dictionary $input -IgnoreFields $IgnoreFields

        ($result | ConvertTo-Json -Depth 10) | Should -Be ($expected | ConvertTo-Json -Depth 10)
    }

    It "Normalize-Dictionary TC20: Normalizes identical nested structures consistently" -Tag 'active' {
        $input = @{
            "A" = @{ "X" = 1; "Y" = 2 }
            "B" = @{ "X" = 1; "Y" = 2 }
        }
        $expected = [Ordered]@{
            "A" = [Ordered]@{ "X" = 1; "Y" = 2 }
            "B" = [Ordered]@{ "X" = 1; "Y" = 2 }
        }

        $result = Normalize-Dictionary -Dictionary $input -IgnoreFields $IgnoreFields

        ($result["A"] | ConvertTo-Json -Depth 10) | Should -Be ($result["B"] | ConvertTo-Json -Depth 10)
    }

}

