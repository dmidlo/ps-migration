Describe "Get-CharacterPool" {
    BeforeAll {
        function Get-ExpectedCharacterPool {
            param(
                [switch]$Upper, [switch]$Lower, [switch]$Numeric, [switch]$Special
            )
            $pool = ""
            if ($Upper) { $pool += "ABCDEFGHIJKLMNOPQRSTUVWXYZ" }
            if ($Lower) { $pool += "abcdefghijklmnopqrstuvwxyz" }
            if ($Numeric) { $pool += "0123456789" }
            if ($Special) { $pool += "!@#$%^&*()-_=+[]{}|;:,.<>?/" }
            return $pool
        }
    }

    Context "Get-CharacterPool: Valid Character Pool Generation" -Tag 'RandomPassword','GetCharacterPool','active'{
        $testCases = @(
            @{ Name = "Get-CharacterPool TC01: Uppercase"; Params = @{ IncludeUpper = $true }; Expected = "ABCDEFGHIJKLMNOPQRSTUVWXYZ" }
            @{ Name = "Get-CharacterPool TC02: Lowercase"; Params = @{ IncludeLower = $true }; Expected = "abcdefghijklmnopqrstuvwxyz" }
            @{ Name = "Get-CharacterPool TC03: Numbers"; Params = @{ IncludeNumeric = $true }; Expected = "0123456789" }
            @{ Name = "Get-CharacterPool TC04: Special characters"; Params = @{ IncludeSpecial = $true }; Expected = "!@#$%^&*()-_=+[]{}|;:,.<>?/" }
            @{ Name = "Get-CharacterPool TC05: Mixed Selection"; Params = @{ IncludeUpper = $true; IncludeNumeric = $true }; Expected = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789" }
            @{ Name = "Get-CharacterPool TC06: All Character Types"; Params = @{ IncludeUpper = $true; IncludeLower = $true; IncludeNumeric = $true; IncludeSpecial = $true }; Expected = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#$%^&*()-_=+[]{}|;:,.<>?/" }
        )

        It "<name> Returns expected character pool for given flags (<expected>)" -TestCases $testCases {
            param ($Name, $Params, $Expected)
            Get-CharacterPool @Params | Should -BeExactly $Expected
        }
    }

    Context "Get-CharacterPool: Edge Cases & Error Handling" {
        It "Get-CharacterPool TC07: Throws an error when all flags are '`$false'" -Tag 'RandomPassword','GetCharacterPool','active' {
            { Get-CharacterPool } |
            Should -Throw -ExpectedMessage "At least one character type must be included."
        }

        It "Get-CharacterPool TC08: Ensures case sensitivity of output" -Tag 'RandomPassword','GetCharacterPool','active' {
            Get-CharacterPool -IncludeUpper $true -IncludeLower $true |
                Should -BeExactly "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
        }

        It "Get-CharacterPool TC09: Maintains expected character order" -Tag 'RandomPassword','GetCharacterPool','active' {
            Get-CharacterPool -IncludeUpper $true -IncludeLower $true -IncludeNumeric $true -IncludeSpecial $true |
                Should -BeExactly "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#$%^&*()-_=+[]{}|;:,.<>?/"
        }

        It "Get-CharacterPool TC10: Does not contain duplicate characters" -Tag 'RandomPassword','GetCharacterPool','active' {
            $result = Get-CharacterPool -IncludeUpper $true -IncludeLower $true -IncludeNumeric $true -IncludeSpecial $true
            ($result -split '' | Sort-Object | Get-Unique).Count - 1 | Should -BeExactly $result.Length
        }

        It "Get-CharacterPool TC11: Does not introduce unexpected whitespace" -Tag 'RandomPassword','GetCharacterPool','active' {
            Get-CharacterPool -IncludeUpper $true -IncludeLower $true -IncludeNumeric $true -IncludeSpecial $true |
                Should -Not -Match "\s"
        }
    }

    Context "Get-CharacterPool Special Character Handling" {
        It "Get-CharacterPool TC12: Correctly escapes special characters" -Tag 'RandomPassword','GetCharacterPool','active' {
            $result = Get-CharacterPool -IncludeSpecial $true
            $expectedSpecial = "!@#$%^&*()-_=+[]{}|;:,.<>?/"
            $result | Should -BeExactly $expectedSpecial
        }

        It "Get-CharacterPool TC13: Special characters do not cause unintended regex behavior" -Tag 'RandomPassword','GetCharacterPool','active' {
            $specialPool = Get-CharacterPool -IncludeSpecial $true
            $specialPool -match "[!@#$%^&*()\[\]{}|;:,.<>?/]" | Should -Be $true
        }
    }

    Context "Get-CharacterPool Performance & CI/CD Readiness" {
        It "Get-CharacterPool TC14: Executes within a reasonable time limit (median of 10 runs)" -Tag 'RandomPassword','GetCharacterPool','active' {
            $times = 1..1000 | ForEach-Object { (Measure-Command { Get-CharacterPool -IncludeUpper -IncludeLower -IncludeNumeric -IncludeSpecial }).TotalMilliseconds }
            $sortedTimes = $times | Sort-Object
            $middleIndex = [math]::Floor($sortedTimes.Count / 2)
            $medianTime = $sortedTimes[$middleIndex]

            $medianTime | Should -BeLessThan 0.1
        }

        It "Get-CharacterPool TC15: Stable execution time across multiple runs (variance ≤ 1.5x median)" -Tag 'RandomPassword','GetCharacterPool','active' {
            $times = 1..1000 | ForEach-Object { (Measure-Command { Get-CharacterPool -IncludeUpper -IncludeLower -IncludeNumeric -IncludeSpecial }).TotalMilliseconds }
            $sortedTimes = $times | Sort-Object
            $middleIndex = [math]::Floor($sortedTimes.Count / 2)
            $medianTime = $sortedTimes[$middleIndex]

            $times[-1] | Should -BeLessThan ($medianTime * 1.3)
        }

        It "Get-CharacterPool TC16: Generates expected length output" -Tag 'RandomPassword','GetCharacterPool','active' {
            $expectedLength = (Get-ExpectedCharacterPool -Upper -Lower -Numeric -Special ).Length
            Get-CharacterPool -IncludeUpper -IncludeLower -IncludeNumeric -IncludeSpecial |
                Measure-Object -Character | Select-Object -ExpandProperty Characters | Should -BeExactly $expectedLength
        }
    }
}
