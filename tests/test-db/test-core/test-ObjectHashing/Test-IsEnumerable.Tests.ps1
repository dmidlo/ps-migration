Describe 'Test-IsEnumerable' {
    Context 'When Value is null' {
        It 'Test-IsEnumerable TC01: Returns $false for $null' -Tag 'active' {
            Test-IsEnumerable -Value $null | Should -Be $false
        }
    }

    Context 'When Value is a primitive type' {
        It 'Test-IsEnumerable TC02: Returns $false for an integer' -Tag 'active' {
            Test-IsEnumerable -Value 42 | Should -Be $false
        }

        It 'Test-IsEnumerable TC03: Returns $false for a boolean' -Tag 'active' {
            Test-IsEnumerable -Value $true | Should -Be $false
        }
    }

    Context 'When Value is a string' {
        It 'Test-IsEnumerable TC04: Returns $false for a non-empty string' -Tag 'active' {
            Test-IsEnumerable -Value "hello" | Should -Be $false
        }

        It 'Test-IsEnumerable TC05: Returns $false for an empty string' -Tag 'active' {
            Test-IsEnumerable -Value "" | Should -Be $false
        }
    }

    Context 'When Value is an array' {
        It 'Test-IsEnumerable TC06: Returns $true for an empty array' -Tag 'active' {
            Test-IsEnumerable -Value @() | Should -Be $true
        }

        It 'Test-IsEnumerable TC07: Returns $true for a non-empty array' -Tag 'active' {
            Test-IsEnumerable -Value @(1,2,3) | Should -Be $true
        }
    }

    Context 'When Value is a hashtable' {
        It 'Test-IsEnumerable TC08: Returns $true for an empty hashtable' -Tag 'active' {
            Test-IsEnumerable -Value @{} | Should -Be $true
        }

        It 'Test-IsEnumerable TC09: Returns $true for a non-empty hashtable' -Tag 'active' {
            Test-IsEnumerable -Value @{ Key = 'Value' } | Should -Be $true
        }
    }

    Context 'When Value is a collection object' {
        It 'Test-IsEnumerable TC10: Returns $true for an ArrayList' -Tag 'active' {
            $list = [System.Collections.ArrayList]::new()
            Test-IsEnumerable -Value $list | Should -Be $true
        }

        It 'Test-IsEnumerable TC11: Returns $true for a Generic List' -Tag 'active' {
            $genericList = [System.Collections.Generic.List[int]]::new()
            Test-IsEnumerable -Value $genericList | Should -Be $true
        }

        It 'Test-IsEnumerable TC12: Returns $true for a Queue' -Tag 'active' {
            $queue = [System.Collections.Queue]::new()
            Test-IsEnumerable -Value $queue | Should -Be $true
        }
        It 'Test-IsEnumerable TC13: Returns $true for an OrderedDictionary' -Tag 'active' {
            $orderedDict = [System.Collections.Specialized.OrderedDictionary]::new()
            Test-IsEnumerable -Value $orderedDict | Should -Be $true
        }

    }

    Context 'When Value is a non-enumerable object' {
        It 'Test-IsEnumerable TC14: Returns $false for a PSCustomObject' -Tag 'active' {
            $obj = [PSCustomObject]@{}
            Test-IsEnumerable -Value $obj | Should -Be $false
        }


        It 'Test-IsEnumerable TC15: Returns $false for a script block' -Tag 'active' {
            $scriptBlock = { param($x) $x }
            Test-IsEnumerable -Value $scriptBlock | Should -Be $false
        }

        It 'Test-IsEnumerable TC16: Returns $false for a COM object' -Tag 'active' {
            $comObject = New-Object -ComObject Scripting.Dictionary
            Test-IsEnumerable -Value $comObject | Should -Be $false
        }

        It 'Test-IsEnumerable TC17: Returns $false for a StringEnumerator' -Tag 'active' {
            $stringCollection = New-Object System.Collections.Specialized.StringCollection
            $stringCollection.AddRange(@('a','b','c'))
            $stringEnum = $stringCollection.GetEnumerator()
            
            Test-IsEnumerable -Value $stringEnum | Should -Be $false
        }

        It 'Test-IsEnumerable TC18: Returns $false for [DBNull]::Value' -Tag 'active' {
            Test-IsEnumerable -Value ([DBNull]::Value) | Should -Be $false
        }
    }
}
