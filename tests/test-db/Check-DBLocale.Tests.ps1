Describe "Integration Tests for Check-DBLocale" {
    # Define the database file path at the top so it’s available to all tests.
    BeforeEach {
        # Ensure a clean slate by removing any existing test database file.
        $dbPath = Join-Path $env:TEMP "test.db"
        if ($dbPath -and (Test-Path $dbPath)) {
            Remove-Item $dbPath -Force
        }

        # Initialize a fresh database connection
        $Connection = Initialize-DB -DBPath $dbPath
    }

    AfterAll {
        # Clean up the test database file after all tests have run.
        if ($dbPath -and (Test-Path $dbPath)) {
            Remove-Item $dbPath -Force
        }
    }

    Context "When UTC_Date is already set to true" {
        BeforeEach {
            # Explicitly set UTC_Date to true in the database
            Find-LiteDBDocument -Collection '$database' -Sql "pragma UTC_Date = true" -Connection $Connection
        }

        It "Check-DBLocale TC01: Should not change anything if UTC_Date is already true" -Tag 'active' {
            # Act
            Check-DBLocale -Connection $Connection

            # Assert: Verify UTC_Date remains true
            $Pragmas = (Find-LiteDBDocument -Collection '$database' -Sql "select pragmas from `$database" -Connection $Connection).pragmas
            $Pragmas.UTC_Date | Should -Be $true
        }
    }

    Context "When UTC_Date is set to false" {
        BeforeEach {
            # Explicitly set UTC_Date to false in the database
            Find-LiteDBDocument -Collection '$database' -Sql "pragma UTC_Date = false" -Connection $Connection
        }

        It "Check-DBLocale TC02: Should update UTC_Date to true if it is initially false" -Tag 'active' {
            # Act
            Check-DBLocale -Connection $Connection

            # Assert: Verify UTC_Date was updated
            $UpdatedPragmas = (Find-LiteDBDocument -Collection '$database' -Sql "select pragmas from `$database" -Connection $Connection).pragmas
            $UpdatedPragmas.UTC_Date | Should -Be $true
        }
    }
}

