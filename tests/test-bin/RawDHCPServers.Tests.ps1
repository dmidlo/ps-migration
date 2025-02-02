# File: tests\test-bin\RawDHCPServers.Tests.ps1

# Pre-declare a dummy function so that the command exists for mocking.
BeforeAll {
    function dummy-binary { }
}

Describe "Test-RawDHCPServers - External Dependency (Binary Call) Tests" {

    # Avoid actual sleeping in tests
    BeforeEach {
        Mock -CommandName Start-Sleep { }
    }

    Context "When the binary returns a single valid output" {
        It "should return an array with one IP address" {
            # Arrange
            $binaryName = "dummy-binary"
            # Return a controlled string that includes one valid token
            Mock -CommandName $binaryName -MockWith { "siaddr=192.168.1.1" } -Verifiable

            # Act
            # Set Attempts and AttemptTimeout to 0 to run only one iteration without delay.
            $result = Test-RawDHCPServers -BinaryPath $binaryName -Attempts 0 -AttemptTimeout 0

            # Diagnostic output (visible when running tests with -Debug)
            Write-Debug "Single valid output test: Received result: $($result -join ', ')"

            # Assert
            $result | Should -BeExactly @("192.168.1.1")
            Assert-MockCalled -CommandName $binaryName -Times 1 -Scope It
        }
    }

    Context "When the binary returns multiple valid outputs" {
        It "should return both unique IP addresses" {
            # Arrange
            $binaryName = "dummy-binary"
            # Return a string that includes two valid tokens (separated by spaces)
            Mock -CommandName $binaryName -MockWith { "foo siaddr=192.168.1.1 bar siaddr=192.168.1.2" } -Verifiable

            # Act
            $result = Test-RawDHCPServers -BinaryPath $binaryName -Attempts 0 -AttemptTimeout 0

            # Diagnostic output
            Write-Debug "Multiple valid outputs test: Received result: $($result -join ', ')"

            # Assert
            $result | Should -BeExactly @("192.168.1.1", "192.168.1.2")
            Assert-MockCalled -CommandName $binaryName -Times 1 -Scope It
        }
    }

    Context "When the binary returns no matching output" {
        It "should return an empty array" {
            # Arrange
            $binaryName = "dummy-binary"
            # Return a string that does not contain any token with 'siaddr'
            Mock -CommandName $binaryName -MockWith { "no valid output here" } -Verifiable

            # Act
            $result = Test-RawDHCPServers -BinaryPath $binaryName -Attempts 0 -AttemptTimeout 0

            # Diagnostic output
            Write-Debug "No matching output test: Received result: $($result -join ', ')"

            # Assert
            $result | Should -HaveCount 0
            Assert-MockCalled -CommandName $binaryName -Times 1 -Scope It
        }
    }

    Context "Parameterizing the External Call" {
        It "should pass the correct arguments to the binary" {
            # Arrange
            $binaryName = "dummy-binary"
            # Set AttemptTimeout to 5
            $AttemptTimeout = 5

            # Mock the dummy-binary so we can capture how it's called.
            # Note: When the function is invoked, it calls:
            #   & $binaryName @Arguments
            # where $Arguments is defined as: @("--query", "--wait", "--timeout", "$AttemptTimeout")
            Mock -CommandName $binaryName -MockWith {
                # Return a dummy output that satisfies the parser.
                "siaddr=192.168.1.1"
            } -Verifiable

            # Act: Call Test-RawDHCPServers with our dummy binary.
            # We set Attempts to 0 so that the loop only runs once.
            $result = Test-RawDHCPServers -BinaryPath $binaryName -Attempts 0 -AttemptTimeout $AttemptTimeout

            # Assert:
            # Verify that the dummy-binary was called exactly once
            # and that the arguments passed match our expected array.
            Assert-MockCalled -CommandName $binaryName -Times 1 -Scope It -ParameterFilter {
                # In the context of the mock, the parameters are received as an array in $args.
                ($args.Count -eq 4) -and
                ($args[0] -eq "--query") -and
                ($args[1] -eq "--wait") -and
                ($args[2] -eq "--timeout") -and
                ($args[3] -eq "$AttemptTimeout")
            }
        }
    }
}
