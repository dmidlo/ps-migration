Describe "Add-DbDocument" {

    BeforeEach {
        # Define a unique test database path for isolation.
        $dbPath = Join-Path $env:TEMP "test_EnsureLiteDB.db"

        # Ensure a clean state before each test.
        if ($dbPath -and (Test-Path $dbPath)) {
            Remove-Item $dbPath -Force
        }

        # Open a real LiteDB connection for testing.
        $dbConnection = Initialize-DB -DBPath $dbPath
        $testCollectionName = "TestCollection"
        Confirm-LiteDBCollection -Connection $dbConnection -CollectionName $testCollectionName -Indexes @(
            [PSCustomObject]@{ Field='Hash'; Unique=$true }
        )
    }

    AfterEach {
        # Cleanup after each test
        if ($dbPath -and (Test-Path $dbPath)) {
            Remove-Item $dbPath -Force
        }
    }

    Context "Ensures a Valid Guid" {
        It "add-dbdocument TC01: It checks for the existence of Guid key, and adds a guid if it doesn't exist." {
            # Arrange
            $inputHashtable = @{ key = "value" }

            # Act
            $result = Add-DbDocument -Data $inputHashtable -Connection $dbConnection -Collection $testCollectionName

            # Assert
            $result.Keys | Should -Contain 'Guid'
        }

        It "add-dbdocument TC02: When it creates a guid, the guid is a valid guid" -ForEach @(
            @{
                InputHashtable = @{ key = "value" }
                Expected = $true
            }
            @{
                InputHashtable = @{ Guid = "not a guid - Tested in TC02" }
                Expected = $false
            }
            @{
                InputHashtable = @{ Guid = [guid]::NewGuid()}
                Expected = $true
            }
        ) {
            # Act
            $result = Add-DbDocument -Data $InputHashtable -Connection $dbConnection -Collection $testCollectionName
            
            # Assert
            if ($Expected) {
                $result['Guid'] | Should -BeOfType 'System.Guid'
            }
            else {
                $result['Guid'] | Should -Not -BeOfType 'System.Guid'
            }
        }
    }

    Context "Checks for duplicates" {
        It "add-dbdocument TC03: it overwrites the hash of an object with a recacluated hash" -ForEach @(
            @{
                InputHashtable = @{ key = "value" }
                Expected = $true
            }
            @{
                InputHashtable = @{
                    key ="value"
                    Hash = "SomeHash"
                }
            }
        ) {
            # Act
            $result = Add-DbDocument -Data $InputHashtable -Connection $dbConnection -Collection $testCollectionName


            #Assert
            $result.Keys | Should -Contain 'Hash'
            $result.Hash | Should -Not -Be "SomeHash"
        }
    }
}
