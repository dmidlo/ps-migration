Describe "Test-IsNumeric" {

    Context "Valid numeric inputs" {
        It "Test-IsNumeric TC01: should return true for integer values" -Tag 'active' {
            Test-IsNumeric "123" | Should -BeTrue
        }

        It "Test-IsNumeric TC02: should return true for decimal values" -Tag 'active' {
            Test-IsNumeric "3.14" | Should -BeTrue
        }

        It "Test-IsNumeric TC03: should return true for scientific notation" -Tag 'active' {
            Test-IsNumeric "1e4" | Should -BeTrue
        }

        It "Test-IsNumeric TC04: should return true for negative numbers" -Tag 'active' {
            Test-IsNumeric "-42" | Should -BeTrue
        }

        It "Test-IsNumeric TC05: should return true for large numbers" -Tag 'active' {
            Test-IsNumeric "1e308" | Should -BeTrue
        }

        It "Test-IsNumeric TC06: should return true for small numbers" -Tag 'active' {
            Test-IsNumeric "1e-308" | Should -BeTrue
        }

        It "Test-IsNumeric TC07: should return false for positive numbers with explicit plus sign" -Tag 'active' {
            Test-IsNumeric "+123" | Should -BeFalse
        }
    }

    Context "Invalid numeric inputs" {
        It "Test-IsNumeric TC08: should return false for alphabetic strings" -Tag 'active' {
            Test-IsNumeric "abc" | Should -BeFalse
        }

        It "Test-IsNumeric TC09: should return false for alphanumeric strings" -Tag 'active' {
            Test-IsNumeric "123abc" | Should -BeFalse
        }

        It "Test-IsNumeric TC10: should return false for empty string" -Tag 'active' {
            Test-IsNumeric "" | Should -BeFalse
        }

        It "Test-IsNumeric TC11: should return false for null" -Tag 'active' {
            Test-IsNumeric $null | Should -BeFalse
        }

        It "Test-IsNumeric TC12: should return false for whitespace-only strings" -Tag 'active' {
            Test-IsNumeric "   " | Should -BeFalse
        }

        It "Test-IsNumeric TC13: should return false for multiple dots" -Tag 'active' {
            Test-IsNumeric "3.1.4" | Should -BeFalse
        }

        It "Test-IsNumeric TC14: should return false for missing integer part in decimal" -Tag 'active' {
            Test-IsNumeric ".5" | Should -BeFalse
        }

        It "Test-IsNumeric TC15: should return false for missing decimal part" -Tag 'active' {
            Test-IsNumeric "5." | Should -BeFalse
        }

        It "Test-IsNumeric TC16: should return false for misplaced exponent" -Tag 'active' {
            Test-IsNumeric "1e" | Should -BeFalse
        }

        It "Test-IsNumeric TC17: should return false for plus sign without number" -Tag 'active' {
            Test-IsNumeric "+" | Should -BeFalse
        }

        It "Test-IsNumeric TC18: should return false for minus sign without number" -Tag 'active' {
            Test-IsNumeric "-" | Should -BeFalse
        }

        It "Test-IsNumeric TC19: should return false for standalone dot" -Tag 'active' {
            Test-IsNumeric "." | Should -BeFalse
        }
    }

    Context "Special numeric values" {
        It "Test-IsNumeric TC20: should return false for Infinity" -Tag 'active' {
            Test-IsNumeric "Infinity" | Should -BeFalse
        }

        It "Test-IsNumeric TC21: should return false for -Infinity" -Tag 'active' {
            Test-IsNumeric "-Infinity" | Should -BeFalse
        }

        It "Test-IsNumeric TC22: should return false for NaN" -Tag 'active' {
            Test-IsNumeric "NaN" | Should -BeFalse
        }
    }

    Context "Whitespace handling" {
        It "Test-IsNumeric TC23: should return true for leading spaces" -Tag 'active' {
            Test-IsNumeric " 42" | Should -BeTrue
        }

        It "Test-IsNumeric TC24: should return true for trailing spaces" -Tag 'active' {
            Test-IsNumeric "42 " | Should -BeTrue
        }

        It "Test-IsNumeric TC25: should return true for spaces around a number" -Tag 'active' {
            Test-IsNumeric " 42 " | Should -BeTrue
        }

        It "Test-IsNumeric TC26: should return true for non-standard whitespace (tab, newline)" -Tag 'active' {
            Test-IsNumeric "`t42" | Should -BeTrue
        }
    }
}

