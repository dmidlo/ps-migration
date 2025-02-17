Describe "Integration Tests for Ensure-LiteDBCollection" {

    BeforeEach {
        # Define a unique test database path for isolation.
        $dbPath = Join-Path $env:TEMP "test_EnsureLiteDB.db"

        # Ensure a clean state before each test.
        if ($dbPath -and (Test-Path $dbPath)) {
            Remove-Item $dbPath -Force
        }

        # Open a real LiteDB connection for testing.
        $dbConnection = Initialize-DB -DBPath $dbPath
    }

    AfterAll {
        # Cleanup after all tests
        if ($dbPath -and (Test-Path $dbPath)) {
            Remove-Item $dbPath -Force
        }
    }

    Context "Ensuring Collection Exists" {
        It "Ensure-LiteDBCollection TC01: should create a new collection when it does not exist" -Tag 'active' {
            # Act: Ensure the collection exists.
            Ensure-LiteDBCollection -Connection $dbConnection -CollectionName "TestCollection"

            # Assert: The collection now exists in the database.
            $existingCollections = $dbConnection.GetCollectionNames()
            $existingCollections | Should -Contain "TestCollection"
        }

        It "Ensure-LiteDBCollection TC02: should not fail when the collection already exists" -Tag 'active' {
            # Arrange: Pre-create the collection.
            $dbConnection.GetCollection("TestCollection") | Out-Null

            # Act: Ensure the collection exists again.
            Ensure-LiteDBCollection -Connection $dbConnection -CollectionName "TestCollection"

            # Assert: The collection still exists.
            $existingCollections = $dbConnection.GetCollectionNames()
            $existingCollections | Should -Contain "TestCollection"
        }
    }

    Context "Creating Indexes" {
        # It "Ensure-LiteDBCollection TC03: should create an index on a valid field" {
        #     # Act: Create an index on the 'Title' field.
        #     $indexes = @(
        #         [PSCustomObject]@{ Field = "Title"; Unique = $true }
        #     )
        #     Ensure-LiteDBCollection -Connection $dbConnection -CollectionName "Movies" -Indexes $indexes

        #     # Assert: Index exists.
        #     $indexList = Get-LiteDBIndex -Collection "Movies" -Connection $dbConnection
        #     $indexList.Field | Should -Contain "Title"
        # }

        # It "Ensure-LiteDBCollection TC04: should create multiple indexes successfully" {
        #     # Act: Create indexes on multiple fields.
        #     $indexes = @(
        #         [PSCustomObject]@{ Field = "Title"; Unique = $true },
        #         [PSCustomObject]@{ Field = "Genre"; Expression = "LOWER($.Genre)" }
        #     )
        #     Ensure-LiteDBCollection -Connection $dbConnection -CollectionName "Movies" -Indexes $indexes

        #     # Assert: Both indexes exist.
        #     $collection = $dbConnection.GetCollection("Movies")
        #     $indexList = $collection.GetIndexes()
        #     $indexList.Field | Should -Contain "Title"
        #     $indexList.Field | Should -Contain "Genre"
        # }

        # It "Ensure-LiteDBCollection TC05: should not create duplicate indexes on repeated calls" {
        #     # Arrange: Define an index.
        #     $indexes = @(
        #         [PSCustomObject]@{ Field = "Title"; Unique = $true }
        #     )

        #     # Act: Run twice.
        #     Ensure-LiteDBCollection -Connection $dbConnection -CollectionName "Movies" -Indexes $indexes
        #     Ensure-LiteDBCollection -Connection $dbConnection -CollectionName "Movies" -Indexes $indexes

        #     # Assert: Index exists, but only once.
        #     $collection = $dbConnection.GetCollection("Movies")
        #     $indexList = $collection.GetIndexes()
        #     ($indexList | Where-Object { $_.Field -eq "Title" }).Count | Should -Be 1
        # }
    }

    Context "Edge Cases" {
        # It "Ensure-LiteDBCollection TC06: should handle an empty Indexes array gracefully" {
        #     # Act: Run with no indexes.
        #     Ensure-LiteDBCollection -Connection $dbConnection -CollectionName "Movies" -Indexes @()

        #     # Assert: Collection exists, but no indexes were created.
        #     $collection = $dbConnection.GetCollection("Movies")
        #     $indexList = $collection.GetIndexes()
        #     $indexList | Should -BeEmpty
        # }

        It "Ensure-LiteDBCollection TC07: should throw an error if CollectionName is null" -Tag 'active' {
            { Ensure-LiteDBCollection -Connection $dbConnection -CollectionName $null } | Should -Throw
        }

        It "Ensure-LiteDBCollection TC08: should throw an error if CollectionName is empty" -Tag 'active' {
            { Ensure-LiteDBCollection -Connection $dbConnection -CollectionName "" } | Should -Throw
        }

        It "Ensure-LiteDBCollection TC09: should throw an error when Index definition is missing 'Field' property" -Tag 'active' {
            # Arrange: Define an invalid index (missing `Field`).
            $indexes = @(
                [PSCustomObject]@{ Unique = $true }
            )

            # Act + Assert: Ensure it throws an error.
            { Ensure-LiteDBCollection -Connection $dbConnection -CollectionName "Movies" -Indexes $indexes } | Should -Throw
        }
    }

    # Context "Error Handling" {
    #     It "Ensure-LiteDBCollection TC10: should log error and continue when index creation fails" {
    #         # Arrange: Try to create an index with an invalid field name.
    #         $indexes = @(
    #             [PSCustomObject]@{ Field = "Invalid#Field"; Unique = $true }
    #         )

    #         # Act: Capture warnings/errors.
    #         $warnings = $null
    #         $wrapped = { Ensure-LiteDBCollection -Connection $dbConnection -CollectionName "Movies" -Indexes $indexes }
    #         $warnings = ($wrapped 2>&1) -match "Could not create index"

    #         # Assert: Warning was generated.
    #         $warnings | Should -Be $true
    #     }
    # }

    Context "Performance Testing" {
        It "Ensure-LiteDBCollection TC11: should create 100 indexes within a reasonable time" -Tag 'active' {
            # Arrange: Generate 100 unique indexes.
            $largeIndexes = 1..100 | ForEach-Object { [PSCustomObject]@{ Field = "Field$_" } }

            # Act: Measure execution time.
            $executionTime = Measure-Command {
                Ensure-LiteDBCollection -Connection $dbConnection -CollectionName "Movies" -Indexes $largeIndexes
            }

            # Assert: Execution should be under 5 seconds.
            $executionTime.TotalSeconds | Should -BeLessThan 5
        }
    }
}