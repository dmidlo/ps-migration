Describe 'Is-Enumerable' {
    Context 'When Value is null' {
        It 'Is-Enumerable TC01: Returns $false for $null' -Tag 'active' {
            Is-Enumerable -Value $null | Should -Be $false
        }
    }

    Context 'When Value is a primitive type' {
        It 'Is-Enumerable TC02: Returns $false for an integer' -Tag 'active' {
            Is-Enumerable -Value 42 | Should -Be $false
        }

        It 'Is-Enumerable TC03: Returns $false for a boolean' -Tag 'active' {
            Is-Enumerable -Value $true | Should -Be $false
        }
    }

    Context 'When Value is a string' {
        It 'Is-Enumerable TC04: Returns $false for a non-empty string' -Tag 'active' {
            Is-Enumerable -Value "hello" | Should -Be $false
        }

        It 'Is-Enumerable TC05: Returns $false for an empty string' -Tag 'active' {
            Is-Enumerable -Value "" | Should -Be $false
        }
    }

    Context 'When Value is an array' {
        It 'Is-Enumerable TC06: Returns $true for an empty array' -Tag 'active' {
            Is-Enumerable -Value @() | Should -Be $true
        }

        It 'Is-Enumerable TC07: Returns $true for a non-empty array' -Tag 'active' {
            Is-Enumerable -Value @(1,2,3) | Should -Be $true
        }
    }

    Context 'When Value is a hashtable' {
        It 'Is-Enumerable TC08: Returns $true for an empty hashtable' -Tag 'active' {
            Is-Enumerable -Value @{} | Should -Be $true
        }

        It 'Is-Enumerable TC09: Returns $true for a non-empty hashtable' -Tag 'active' {
            Is-Enumerable -Value @{ Key = 'Value' } | Should -Be $true
        }
    }

    Context 'When Value is a collection object' {
        It 'Is-Enumerable TC10: Returns $true for an ArrayList' -Tag 'active' {
            $list = [System.Collections.ArrayList]::new()
            Is-Enumerable -Value $list | Should -Be $true
        }

        It 'Is-Enumerable TC11: Returns $true for a Generic List' -Tag 'active' {
            $genericList = [System.Collections.Generic.List[int]]::new()
            Is-Enumerable -Value $genericList | Should -Be $true
        }

        It 'Is-Enumerable TC12: Returns $true for a Queue' -Tag 'active' {
            $queue = [System.Collections.Queue]::new()
            Is-Enumerable -Value $queue | Should -Be $true
        }
        It 'Is-Enumerable TC13: Returns $true for an OrderedDictionary' -Tag 'active' {
            $orderedDict = [System.Collections.Specialized.OrderedDictionary]::new()
            Is-Enumerable -Value $orderedDict | Should -Be $true
        }

    }

    Context 'When Value is a non-enumerable object' {
        It 'Is-Enumerable TC14: Returns $false for a PSCustomObject' -Tag 'active' {
            $obj = [PSCustomObject]@{}
            Is-Enumerable -Value $obj | Should -Be $false
        }


        It 'Is-Enumerable TC15: Returns $false for a script block' -Tag 'active' {
            $scriptBlock = { param($x) $x }
            Is-Enumerable -Value $scriptBlock | Should -Be $false
        }

        It 'Is-Enumerable TC16: Returns $false for a COM object' -Tag 'active' {
            $comObject = New-Object -ComObject Scripting.Dictionary
            Is-Enumerable -Value $comObject | Should -Be $false
        }

        It 'Is-Enumerable TC17: Returns $false for a StringEnumerator' -Tag 'active' {
            $stringCollection = New-Object System.Collections.Specialized.StringCollection
            $stringCollection.AddRange(@('a','b','c'))
            $stringEnum = $stringCollection.GetEnumerator()
            
            Is-Enumerable -Value $stringEnum | Should -Be $false
        }

        It 'Is-Enumerable TC18: Returns $false for [DBNull]::Value' -Tag 'active' {
            Is-Enumerable -Value ([DBNull]::Value) | Should -Be $false
        }
    }
}
