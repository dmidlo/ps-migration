Describe "Add-DbDocument Integration Tests" {
    BeforeAll {
        # Setup LiteDB Database File in Temp
        $dbPath = "$env:TEMP\temp.db"
        if (Test-Path $dbPath) { Remove-Item -Path $dbPath -Force }
        $db = New-Object LiteDB.LiteDatabase($dbPath)
        $collection = "TestCollection"
    }

    AfterAll {
        if (Test-Path $dbPath) { Remove-Item -Path $dbPath -Force }
    }

    Context "✅ Functional Tests" {
        It "should insert a new document and retrieve it" {
            $sampleData = [PSCustomObject]@{ Name = "TestDocument"; Content = "Test content."; BundleId = "12345" }
            $result = Add-DbDocument -Database $db -Collection $collection -Data $sampleData

            $result | Should -BeOfType [PSCustomObject]
            $result.BundleId | Should -Be $sampleData.BundleId
            $result.ContentId | Should -Not -BeNullOrEmpty
            $result.VersionId | Should -Not -BeNullOrEmpty
        }

        # It "should return the same document when inserting duplicate" {
        #     $sampleData = [PSCustomObject]@{ Name = "TestDocument"; Content = "Test content."; BundleId = "12345" }
        #     $result1 = Add-DbDocument -Database $db -Collection $collection -Data $sampleData
        #     $result2 = Add-DbDocument -Database $db -Collection $collection -Data $sampleData

        #     $result1.VersionId | Should -Be $result2.VersionId
        #     $result1.ContentId | Should -Be $result2.ContentId
        # }

        # It "should create distinct records for different documents" {
        #     $data1 = [PSCustomObject]@{ Name = "Doc1"; Content = "First" }
        #     $data2 = [PSCustomObject]@{ Name = "Doc2"; Content = "Second" }

        #     $result1 = Add-DbDocument -Database $db -Collection $collection -Data $data1
        #     $result2 = Add-DbDocument -Database $db -Collection $collection -Data $data2

        #     $result1.VersionId | Should -Not -Be $result2.VersionId
        # }
    }

    # Context "🚨 Edge Case Handling" {
    #     It "should generate a BundleId if missing" {
    #         $data = [PSCustomObject]@{ Name = "NoBundleDoc"; Content = "No BundleId" }
    #         $result = Add-DbDocument -Database $db -Collection $collection -Data $data

    #         $result.BundleId | Should -Not -BeNullOrEmpty
    #     }

    #     It "should not update UTC_Updated if NoTimestampUpdate is set" {
    #         $sampleData = [PSCustomObject]@{ Name = "TimestampTest"; Content = "Initial" }
    #         $result1 = Add-DbDocument -Database $db -Collection $collection -Data $sampleData
    #         Start-Sleep -Milliseconds 100
    #         $result2 = Add-DbDocument -Database $db -Collection $collection -Data $sampleData -NoTimestampUpdate

    #         $result1.UTC_Updated | Should -Be $result2.UTC_Updated
    #     }

    #     It "should correctly increment ObjVer" {
    #         $sampleData = [PSCustomObject]@{ Name = "VersionTest"; Content = "Versioning" }
    #         Add-DbDocument -Database $db -Collection $collection -Data $sampleData
    #         $result = Add-DbDocument -Database $db -Collection $collection -Data $sampleData

    #         $result.'$ObjVer' | Should -Be 2
    #     }

    #     It "should not increment ObjVer when NoVersionUpdate is set" {
    #         $sampleData = [PSCustomObject]@{ Name = "NoVersionTest"; Content = "Versioning" }
    #         Add-DbDocument -Database $db -Collection $collection -Data $sampleData
    #         $result = Add-DbDocument -Database $db -Collection $collection -Data $sampleData -NoVersionUpdate

    #         $result.'$ObjVer' | Should -BeNullOrEmpty
    #     }

    #     It "should throw an error for empty data" {
    #         { Add-DbDocument -Database $db -Collection $collection -Data ([PSCustomObject]@{}) } | Should -Throw
    #     }
    # }

    # Context "❌ Error Handling" {
    #     It "should throw an error if LiteDB fails to assign _id" {
    #         $corruptData = [PSCustomObject]@{ Name = "CorruptData"; Content = "Invalid" }
    #         { 
    #             Add-DbDocument -Database $db -Collection $collection -Data $corruptData | Out-Null
    #             $result = Add-DbDocument -Database $db -Collection $collection -Data $corruptData
    #             if (-not $result._id) { throw "LiteDB returned a document without an _id." }
    #         } | Should -Throw "LiteDB returned a document without an _id."
    #     }

    #     It "should throw error when database insertion fails" {
    #         $sampleData = [PSCustomObject]@{ Name = "TestDocument"; Content = "Failure Test" }
    #         { Add-DbDocument -Database $null -Collection $collection -Data $sampleData } | Should -Throw
    #     }

    #     It "should throw error when required parameters are missing" {
    #         $sampleData = [PSCustomObject]@{ Name = "TestDocument"; Content = "Missing Params" }
    #         { Add-DbDocument -Collection $collection -Data $sampleData } | Should -Throw
    #         { Add-DbDocument -Database $db -Data $sampleData } | Should -Throw
    #     }
    # }

    # Context "🆕 Additional Tests" {
    #     It "should respect ignored fields in hash computation" {
    #         $data = [PSCustomObject]@{ Name = "TestDoc"; Content = "Some content"; ExtraField = "IgnoreThis" }
    #         $result = Add-DbDocument -Database $db -Collection $collection -Data $data -IgnoreFields @("ExtraField")

    #         $result.ContentId | Should -Not -Contain "IgnoreThis"
    #     }

    #     It "should handle concurrent insertions without duplicates" {
    #         $sampleData = [PSCustomObject]@{ Name = "ConcurrencyTest"; Content = "Concurrent" }
    #         $results = 1..5 | ForEach-Object { Add-DbDocument -Database $db -Collection $collection -Data $sampleData }

    #         ($results | Group-Object VersionId).Count | Should -Be 1
    #     }

    #     It "should ensure idempotency for repeated inserts" {
    #         $sampleData = [PSCustomObject]@{ Name = "IdempotencyTest"; Content = "Repeatable" }
    #         $result1 = Add-DbDocument -Database $db -Collection $collection -Data $sampleData
    #         $result2 = Add-DbDocument -Database $db -Collection $collection -Data $sampleData

    #         $result1.VersionId | Should -Be $result2.VersionId
    #     }

    #     It "should correctly update UTC timestamps when required" {
    #         $sampleData = [PSCustomObject]@{ Name = "TimestampUpdate"; Content = "Timing Test" }
    #         $result1 = Add-DbDocument -Database $db -Collection $collection -Data $sampleData
    #         Start-Sleep -Milliseconds 100
    #         $result2 = Add-DbDocument -Database $db -Collection $collection -Data $sampleData

    #         $result2.UTC_Updated | Should -Not -Be $result1.UTC_Updated
    #     }

    #     It "should not overwrite existing content unless version changes" {
    #         $originalData = [PSCustomObject]@{ Name = "StableDoc"; Content = "Original Content" }
    #         $modifiedData = [PSCustomObject]@{ Name = "StableDoc"; Content = "Modified Content" }

    #         Add-DbDocument -Database $db -Collection $collection -Data $originalData
    #         $result = Add-DbDocument -Database $db -Collection $collection -Data $modifiedData

    #         $result.Content | Should -Be "Original Content"
    #     }
    # }
}
