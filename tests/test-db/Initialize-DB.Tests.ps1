# using assembly "..\Ldbc\0.8.11\LiteDB.dll"
Describe "Integration Tests for Initialize-DB" {
    # Define the database file path at the top so it’s available to all tests.

    BeforeEach {
        # Ensure a clean slate by removing any existing test database file.
        $dbPath = Join-Path $env:TEMP "test.db"

        $connectionString = New-DbConnectionString -Culture "en-US" -IgnoreCase -IgnoreNonSpace -IgnoreSymbols -ConnectionType Shared -AutoRebuild -FilePath $dbPath -Upgrade
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

    Context "Database creation and connection string" {
        It "Initialize-DB TC01: should create a new database file and return a valid connection  with expected properties" -Tag 'active' {
            # Arragne: Run the initialization
            $dbConnection = Initialize-DB -DBPath $dbPath -connectionString $connectionString
            # Assert: The database file now exists.
            (Test-Path $dbPath) | Should -BeTrue

            # Assert: A non-null connection object is returned.
            $dbConnection | Should -Not -BeNull
            
            # Validate connection object properties based on expected shape.
            $dbConnection.Mapper    | Should -Be "LiteDB.BsonMapper"
            $dbConnection.FileStorage      | Should -Be "LiteDB.LiteStorage``1[System.String]"
            $dbConnection.UserVersion   | Should -Be 0
            $dbConnection.Timeout       | Should -Be "00:01:00"
            $dbConnection.UTCDate       | Should -Be $true
            $dbConnection.CheckpointSize   | Should -Be 1000
            $dbConnection.Collation     | Should -Be "en-US/IgnoreCase, IgnoreNonSpace, IgnoreSymbols"
        }

        It "Initialize-DB TC02: should update UTC_DATE pragma from false to true to force UTC" -Tag 'active' {
            # Arrange: Setup Basic DB prior to pragma changes.
            $basicDb = New-LiteDatabase -ConnectionString $connectionString
            $pragmas = (Invoke-LiteCommand 'select pragmas from $database;' -As PS -Database $basicDb).pragmas
            $basicDb.Dispose()
            $pragmas | Should -Not -BeNullOrEmpty
            $basicDb_UTC_DATE_pragma = $pragmas.UTC_DATE

            $basicDb_UTC_DATE_pragma | Should -BeFalse

            # Call Initialize-DB to ensure application requirement of UTC_DATE standard output instead of local
            Initialize-DB -connectionString $connectionString
            $db = New-LiteDatabase -ConnectionString $connectionString
            $pragmas = (Invoke-LiteCommand 'select pragmas from $database;' -As PS -Database $db).pragmas
            $db.Dispose()
            $pragmas | Should -Not -BeNullOrEmpty
            $db_UTC_DATE_pragma = $pragmas.UTC_DATE
            $db_UTC_DATE_pragma | Should -BeTrue
            $db_UTC_DATE_pragma | Should -Not -Be $basicDb_UTC_DATE_pragma
        }
    }
}
