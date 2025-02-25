Describe "Is-Numeric" {

    Context "Valid numeric inputs" {
        It "Is-Numeric TC01: should return true for integer values" -Tag 'active' {
            Is-Numeric "123" | Should -BeTrue
        }

        It "Is-Numeric TC02: should return true for decimal values" -Tag 'active' {
            Is-Numeric "3.14" | Should -BeTrue
        }

        It "Is-Numeric TC03: should return true for scientific notation" -Tag 'active' {
            Is-Numeric "1e4" | Should -BeTrue
        }

        It "Is-Numeric TC04: should return true for negative numbers" -Tag 'active' {
            Is-Numeric "-42" | Should -BeTrue
        }

        It "Is-Numeric TC05: should return true for large numbers" -Tag 'active' {
            Is-Numeric "1e308" | Should -BeTrue
        }

        It "Is-Numeric TC06: should return true for small numbers" -Tag 'active' {
            Is-Numeric "1e-308" | Should -BeTrue
        }

        It "Is-Numeric TC07: should return false for positive numbers with explicit plus sign" -Tag 'active' {
            Is-Numeric "+123" | Should -BeFalse
        }
    }

    Context "Invalid numeric inputs" {
        It "Is-Numeric TC08: should return false for alphabetic strings" -Tag 'active' {
            Is-Numeric "abc" | Should -BeFalse
        }

        It "Is-Numeric TC09: should return false for alphanumeric strings" -Tag 'active' {
            Is-Numeric "123abc" | Should -BeFalse
        }

        It "Is-Numeric TC10: should return false for empty string" -Tag 'active' {
            Is-Numeric "" | Should -BeFalse
        }

        It "Is-Numeric TC11: should return false for null" -Tag 'active' {
            Is-Numeric $null | Should -BeFalse
        }

        It "Is-Numeric TC12: should return false for whitespace-only strings" -Tag 'active' {
            Is-Numeric "   " | Should -BeFalse
        }

        It "Is-Numeric TC13: should return false for multiple dots" -Tag 'active' {
            Is-Numeric "3.1.4" | Should -BeFalse
        }

        It "Is-Numeric TC14: should return false for missing integer part in decimal" -Tag 'active' {
            Is-Numeric ".5" | Should -BeFalse
        }

        It "Is-Numeric TC15: should return false for missing decimal part" -Tag 'active' {
            Is-Numeric "5." | Should -BeFalse
        }

        It "Is-Numeric TC16: should return false for misplaced exponent" -Tag 'active' {
            Is-Numeric "1e" | Should -BeFalse
        }

        It "Is-Numeric TC17: should return false for plus sign without number" -Tag 'active' {
            Is-Numeric "+" | Should -BeFalse
        }

        It "Is-Numeric TC18: should return false for minus sign without number" -Tag 'active' {
            Is-Numeric "-" | Should -BeFalse
        }

        It "Is-Numeric TC19: should return false for standalone dot" -Tag 'active' {
            Is-Numeric "." | Should -BeFalse
        }
    }

    Context "Special numeric values" {
        It "Is-Numeric TC20: should return false for Infinity" -Tag 'active' {
            Is-Numeric "Infinity" | Should -BeFalse
        }

        It "Is-Numeric TC21: should return false for -Infinity" -Tag 'active' {
            Is-Numeric "-Infinity" | Should -BeFalse
        }

        It "Is-Numeric TC22: should return false for NaN" -Tag 'active' {
            Is-Numeric "NaN" | Should -BeFalse
        }
    }

    Context "Whitespace handling" {
        It "Is-Numeric TC23: should return true for leading spaces" -Tag 'active' {
            Is-Numeric " 42" | Should -BeTrue
        }

        It "Is-Numeric TC24: should return true for trailing spaces" -Tag 'active' {
            Is-Numeric "42 " | Should -BeTrue
        }

        It "Is-Numeric TC25: should return true for spaces around a number" -Tag 'active' {
            Is-Numeric " 42 " | Should -BeTrue
        }

        It "Is-Numeric TC26: should return true for non-standard whitespace (tab, newline)" -Tag 'active' {
            Is-Numeric "`t42" | Should -BeTrue
        }
    }
}

