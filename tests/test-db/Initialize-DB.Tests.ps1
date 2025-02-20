Describe "Integration Tests for Initialize-DB" {
    # Define the database file path at the top so it’s available to all tests.

    BeforeEach {
        # Ensure a clean slate by removing any existing test database file.
        $dbPath = Join-Path $env:TEMP "test.db"
        if ($dbPath -and (Test-Path $dbPath)) {
            Remove-Item $dbPath -Force
        }
    }

    AfterAll {
        # Clean up the test database file after all tests have run.
        $dbPath = Join-Path $env:TEMP "test.db"
        if ($dbPath -and (Test-Path $dbPath)) {
            Remove-Item $dbPath -Force
        }
    }

    Context "Database creation and connection" {
        It "Initialize-DB TC01: should create a new database file and return a valid connection string with expected properties" -Tag 'active' {
            # Arragne: Run the initialization
            $connectionString = Initialize-DB -DBPath $dbPath
            # Assert: The database file now exists.
            (Test-Path $dbPath) | Should -BeTrue

            # Assert: A non-null connection object is returned.
            $connectionString | Should -Not -BeNull
            
            # Validate connection object properties based on expected shape.
            $connectionString.Connection    | Should -Be "Shared"
            $connectionString.Filename      | Should -Be $dbPath
            $connectionString.InitialSize   | Should -Be 0
            $connectionString.ReadOnly      | Should -Be $false
            $connectionString.Upgrade       | Should -Be $true
            $connectionString.AutoRebuild   | Should -Be $true
            $connectionString.Collation     | Should -Be "en-US/IgnoreCase, IgnoreNonSpace, IgnoreSymbols"
        }
    }

    Context "Using an existing database file" {
        BeforeEach {
            # Pre-create an empty file to simulate an existing database.
            $dbPath = Join-Path $env:TEMP "test.db"
            Initialize-DB -DBPath $dbPath
        }

        It "Initialize-DB TC02: should use the existing database file and return a valid connection with expected properties"  {

            # Assert: The file still exists.
            (Test-Path $dbPath) | Should -BeTrue

            # Act: Initialize the database using the existing file.
            $connection = Initialize-DB -DBPath $dbPath

            # Assert: The file still exists.
            (Test-Path $dbPath) | Should -BeTrue
            
            # Assert: A non-null connection object is returned.
            $connection | Should -Not -BeNull

            # Validate key connection object properties.
            $connection.Database  | Should -Be $dbPath
            $connection.Collation | Should -Be "en-US/IgnoreCase"
        }
    }

    Context "Edge Cases" {
        It "should throw an error if DBPath is null"  {
            { Initialize-DB -DBPath $null } | Should -Throw
        }

        It "should throw an error if DBPath is an empty string"  {
            { Initialize-DB -DBPath "" } | Should -Throw
        }
    }

    Context "Error Handling" {
        It "should log error details and rethrow if an error occurs"  {
            # Passing a directory path instead of a file should trigger an error.
            { Initialize-DB -DBPath $env:TEMP } | Should -Throw
        }
    }
}
