Describe "Add-DbDocument Integration Tests" -Tag 'Integration' {
    BeforeAll {
        $dbPath = "$env:Temp\temp.db"
        if (Test-Path -Path $dbPath) {
            Remove-Item -Path $dbPath
        }
    }

    BeforeEach {
        $dbConnectionString = New-DbConnectionString -Culture "en-US" -IgnoreCase -IgnoreNonSpace -IgnoreSymbols -ConnectionType Shared -AutoRebuild -FilePath "$env:TEMP\temp.db" -Upgrade
        Initialize-LiteDbDatabase -ConnectionString $dbConnectionString
        $db = New-LiteDatabase -ConnectionString $dbConnectionString
        Initialize-LiteDBCollection -Database $db -CollectionName "Temp" -Indexes @(
            [PSCustomObject]@{ Field="VersionId"; Unique=$true },
            [PSCustomObject]@{ Field="BundleId"; Unique=$false },
            [PSCustomObject]@{ Field="ContentMark"; Unique=$false }
        )
        $TempCollection = Get-LiteCollection -Database $db -CollectionName "Temp"
        Initialize-LiteDBCollection -Database $db -CollectionName "RecycleBin" -Indexes @(
            [PSCustomObject]@{ Field="VersionId"; Unique=$true },
            [PSCustomObject]@{ Field="BundleId"; Unique=$false },
            [PSCustomObject]@{ Field="ContentMark"; Unique=$false }
        )
        $RecycleBinCollection = Get-LiteCollection -Database $db -CollectionName 'RecycleBin'
        Initialize-LiteDBCollection -Database $db -CollectionName "TestCollection" -Indexes @(
            [PSCustomObject]@{ Field="VersionId"; Unique=$true },
            [PSCustomObject]@{ Field="BundleId"; Unique=$false },
            [PSCustomObject]@{ Field="ContentMark"; Unique=$false }
        )
        $TestCollection = Get-LiteCollection -Database $db -CollectionName 'TestCollection'
    }


    Context "Add-DbDocument: Atomic Tests" {
        AfterEach {
            Remove-Item -Path "$env:Temp\temp.db"
        }

        $TC01 = @{
            Name = "Add-DbDocument TC01: Generates ContentMark, VersionId, BundleId, and persists correctly"
            Tag = @('private','db','dbCore','AppendOnlyStore','AddDbDocument','active')
            Test = {
                $doc = [PSCustomObject]@{ Name = "TestDocument" }
                $inserted = Add-DbDocument -Database $db -Collection $TestCollection -Data $doc
                $inserted.ContentMark | Should -Not -BeNullOrEmpty
                $inserted.BundleId | Should -Not -BeNullOrEmpty
                $inserted.VersionId | Should -Not -BeNullOrEmpty
                
                $retrieved = Get-LiteData -Collection $TestCollection -ById $inserted._id
                $retrieved | Should -Not -BeNullOrEmpty
                $retrieved.BundleId | Should -Not -BeNullOrEmpty
                $retrieved.ContentMark | Should -Not -BeNullOrEmpty
                $retrieved.VersionId | Should -Not -BeNullOrEmpty
            }
        }
        It @TC01

        $TC02 = @{
            Name = "Add-DbDocument TC02: Preserves existing BundleId and generates new ContentMark, VersionId"
            Tag = @('private','db','dbCore','AppendOnlyStore','AddDbDocument','active')
            Test = {
                $bundleId = [Guid]::NewGuid().ToString()
                $doc = [PSCustomObject]@{ Name = "TestDocument"; BundleId = $bundleId }
                $inserted = Add-DbDocument -Database $db -Collection $TestCollection -Data $doc
                $doc.BundleId | Should -Be $bundleId 

                $retrieved = Get-LiteData -Collection $TestCollection -ById $doc._id

                $retrieved.BundleId | Should -Be $bundleId
                $retrieved.ContentMark | Should -Not -BeNullOrEmpty
                $retrieved.VersionId | Should -Not -BeNullOrEmpty
            }
        }
        It @TC02

        $TC03 = @{
            Name = "Add-DbDocument TC03: Skips redundant insert if VersionId is unchanged"
            Tag = @('private','db','dbCore','AppendOnlyStore','AddDbDocument','active')
            Test = {
                $doc1 = [PSCustomObject]@{ Name = "TestDocument" }
                $doc2 = [PSCustomObject]@{ Name = "TestDocument" }
                $firstInsert = Add-DbDocument -Database $db -Collection $TestCollection -Data $doc1
                # VersionId Requires ContentMark and BundleId to be Generated.
                $doc2 = $doc2 | Add-Member -MemberType NoteProperty -Name 'BundleId' -Value $firstInsert.BundleId -PassThru
                $secondInsert = Add-DbDocument -Database $db -Collection $TestCollection -Data $doc2
                $secondInsert.ContentMark | Should -Be $firstInsert.ContentMark
        
                $docsInCollection = Get-DbDocumentByContentMark -Database $db -Collection $TestCollection -ContentMark $firstInsert.ContentMark
                $docsInCollection.GetType().Name | Should -Be 'List`1'
                $docsInCollection.Count | Should -Be 1  # Only one document should exist
                $secondInsert.VersionId | Should -Be $firstInsert.VersionId
            }
        }
        It @TC03

        $TC04 = @{
            Name = "Add-DbDocument TC04: Detects hash collision and forces a new VersionId"
            Tag = @('private','db','dbCore','AppendOnlyStore','AddDbDocument','active')
            Test = {
                $doc1 = [PSCustomObject]@{ Name = "TestDocument" }
                $inserted1 = Add-DbDocument -Database $db -Collection $TestCollection -Data $doc1
        
                $doc2 = [PSCustomObject]@{ Name = "TestDocument"; ExtraField = "NewContent" }
                $doc2 = $doc2 | Add-Member -MemberType NoteProperty -Name 'BundleId' -Value $inserted1.BundleId -PassThru
                $inserted2 = Add-DbDocument -Database $db -Collection $TestCollection -Data $doc2
        
                $inserted2.BundleId | Should -Be $inserted1.BundleId
                $inserted2.VersionId | Should -Not -Be $inserted1.VersionId
            }
        }
        It @TC04

        $TC05 = @{
            Name = "Add-DbDocument TC05: Creates new VersionId when content changes within a bundle"
            Tag = @('private','db','dbCore','AppendOnlyStore','AddDbDocument','active')
            Test = {
                $bundleId = [Guid]::NewGuid()
                $doc1 = [PSCustomObject]@{ Name = "TestDocument"; BundleId = $bundleId }
                $inserted1 = Add-DbDocument -Database $db -Collection $TestCollection -Data $doc1
        
                $doc2 = [PSCustomObject]@{ Name = "TestDocument"; BundleId = $bundleId; Modified = "true" }
                $inserted2 = Add-DbDocument -Database $db -Collection $TestCollection -Data $doc2
        
                $inserted2.VersionId | Should -Not -Be $inserted1.VersionId
                $inserted2.BundleId | Should -Be $inserted1.BundleId
            }
        }
        It @TC05
    
        $TC06 = @{
            Name = "Add-DbDocument TC06: Skips insert if `$Ref points to the latest version"
            Tag = @('private','db','dbCore','AppendOnlyStore','AddDbDocument','active')
            Test =  {
                $doc = [PSCustomObject]@{ Name = "TestDocument" }
                $inserted = Add-DbDocument -Database $db -Collection $TestCollection -Data $doc
        
                $docWithRef = New-DbVersionRef -DbDocument $inserted -Collection $TestCollection -RefCollection $TestCollection
                $refInsert = Add-DbDocument -Database $db -Collection $TestCollection -Data $docWithRef
        
                $retrievedDocs = Get-DbDocumentVersionsByBundle -Database $db -Collection $TestCollection -BundleId $refInsert.BundleId
                $retrievedDocs.Count | Should -Be 1  # No duplicate insert should occur
            }
        }
        It @TC06

        $TC07 = @{
            Name = "Add-DbDocument TC07: Fails gracefully when `$Ref points to an invalid version"
            Tag = @('private','db','dbCore','AppendOnlyStore','AddDbDocument','active')
            Test = {
                $doc = [PSCustomObject]@{ Name = "TestDocument" }
                $inserted = Add-DbDocument -Database $db -Collection $TestCollection -Data $doc
        
                $docWithInvalidRef = New-DbVersionRef -DbDocument $inserted -Collection $TestCollection -RefCollection $TestCollection
                $docWithInvalidRef.'$VersionId' = (Get-DataHash -DataObject $docWithInvalidRef -FieldsToIgnore @('none')).Hash
        
                { Add-DbDocument -Database $db -Collection $TestCollection -Data $docWithInvalidRef } | Should -Throw
            }
        }
        It @TC07

        $TC08 = @{
            Name = "Add-DbDocument TC08: Returns all matching documents across bundles" 
            Tag = @('private','db','dbCore','AppendOnlyStore','AddDbDocument','active')
            Test = {
                $doc1 = [PSCustomObject]@{ Name = "SharedContent"}
                $doc2 = [PSCustomObject]@{ Name = "SharedContent"}
                Add-DbDocument -Database $db -Collection $TestCollection -Data $doc1
                Add-DbDocument -Database $db -Collection $TestCollection -Data $doc2
    
                $retrievedDocs = Get-DbDocumentByContentMark -Database $db -Collection $TestCollection -ContentMark $doc1.ContentMark
    
                $retrievedDocs.Count | Should -Be 2
            } 
        }
        It @TC08 

        $TC09 = @{
            Name = "Add-DbDocument TC09: Returns exactly one document matching VersionId"
            Tag = @('private','db','dbCore','AppendOnlyStore','AddDbDocument','active')
            Test = {
                $doc = [PSCustomObject]@{ Name = "TestDocument" }
                $inserted = Add-DbDocument -Database $db -Collection $TestCollection -Data $doc
    
                $docWithVersionRef = [PSCustomObject]@{ 'TestDocument2' = $inserted.VersionId }
                $insertedRef = Add-DbDocument -Database $db -Collection $TestCollection -Data $docWithVersionRef
    
                $retrieved = Get-DbDocumentByVersion -Database $db -Collection $TestCollection -VersionId $inserted.VersionId
    
                $retrieved.Count | Should -Be 1
            } 
        }
        It @TC09

        $TC10 = @{
            Name = "Add-DbDocument TC10: Returns all documents in a bundle, sorted most recent first"
            Tag = @('private','db','dbCore','AppendOnlyStore','AddDbDocument','active')
            Test = {
                $bundleId = [Guid]::NewGuid()
                $doc1 = [PSCustomObject]@{ Name = "First"; BundleId = $bundleId }
                $doc2 = [PSCustomObject]@{ Name = "Second"; BundleId = $bundleId }
                Add-DbDocument -Database $db -Collection $TestCollection -Data $doc1
                Add-DbDocument -Database $db -Collection $TestCollection -Data $doc2
        
                $retrievedDocs = Get-DbDocumentVersionsByBundle -Database $db -Collection $TestCollection -BundleId $bundleId
        
                $retrievedDocs[0].Name | Should -Be "Second"
                $retrievedDocs[1].Name | Should -Be "First"
            }
        }
        It @TC10

        $TC11 = @{
            Name = "Add-DbDocument TC11: Retrieves all matching documents by ContentMark"
            Tag = @('private','db','dbCore','AppendOnlyStore','AddDbDocument','active')
            Test = {
                $doc1 = [PSCustomObject]@{ Name = "TestDocument" }
                $inserted1 = Add-DbDocument -Database $db -Collection $TestCollection -Data $doc1

                $doc2 = [PSCustomObject]@{ Name = "TestDocument" }  # Same content
                $inserted2 = Add-DbDocument -Database $db -Collection $TestCollection -Data $doc2

                $retrievedDocs = Get-DbDocumentByContentMark -Database $db -Collection $TestCollection -ContentMark $inserted1.ContentMark

                $retrievedDocs.Count | Should -Be 2  # Two versions should exist
            }
        }
        It @TC11
    
        $TC12 = @{
            Name = "Add-DbDocument TC12: UTC_Created and UTC_Updated timestamps are set and updated"
            Tag = @('private','db','dbCore','AppendOnlyStore','AddDbDocument','active')
            Test = {
                $doc = [PSCustomObject]@{ Name = "TestDocument" }
                $inserted = Add-DbDocument -Database $db -Collection $TestCollection -Data $doc

                $retrieved = Get-DbDocumentByVersion -Database $db -Collection $TestCollection -VersionId $inserted.VersionId
                
                $retrieved.UTC_Created | Should -Not -BeNullOrEmpty
                $retrieved.UTC_Created.GetType().Name | Should -Be 'Int64'
                $retrieved.UTC_Updated | Should -Not -BeNullOrEmpty
                $retrieved.UTC_Updated.GetType().Name | Should -Be 'Int64'
                $gte = if ($retrieved.UTC_Updated -ge $retrieved.UTC_Created) {$true} else {$false}
                $gte | Should -Be $true
            }
        }
        It @TC12

        $TC13 = @{
            Name = "Add-DbDocument TC13: Should throw if Timestamps are missing when -NoTimestampUpdate is Used"
            Tag = @('private','db','dbCore','AppendOnlyStore','AddDbDocument','active')
            Test = {
                $doc = [PSCustomObject]@{ Name = "TestDocument" }
                $inserted = Add-DbDocument -Database $db -Collection $TestCollection -Data $doc
    
                Start-Sleep -Milliseconds 10  # Simulate time passing
    
                $docEdit = [PSCustomObject]@{ Name = "TestDocument2"; BundleId = $inserted.BundleId }
                { Add-DbDocument -Database $db -Collection $TestCollection -Data $docEdit -NoTimestampUpdate } | Should -Throw
            }
        }
        It @TC13 
        
        $TC14 = @{
            Name = "Add-DbDocument TC14: `$ObjVer increments for each new version within a BundleId"
            Tag = @('private','db','dbCore','AppendOnlyStore','AddDbDocument','active')
            Test = {
                $bundleId = [Guid]::NewGuid()
                $doc1 = [PSCustomObject]@{ Name = "Version1"; BundleId = $bundleId }
                $inserted1 = Add-DbDocument -Database $db -Collection $TestCollection -Data $doc1
    
                $doc2 = [PSCustomObject]@{ Name = "Version2"; BundleId = $bundleId }
                $inserted2 = Add-DbDocument -Database $db -Collection $TestCollection -Data $doc2
    
                $inserted2.'$ObjVer' | Should -Be ($inserted1.'$ObjVer' + 1)
            }
        }
        It @TC14
        
        $TC15 = @{
            Name = "Add-DbDocument TC15: Assigns a new BundleId when explicitly set to '`$null'"
            Tag = @('private','db','dbCore','AppendOnlyStore','AddDbDocument','active')
            Test = {
                $doc = [PSCustomObject]@{ Name = "TestDocument"; BundleId = $null }
                $inserted = Add-DbDocument -Database $db -Collection $TestCollection -Data $doc
    
                $inserted.BundleId | Should -Not -BeNullOrEmpty
            }
        }
        It @TC15

        $TC16 = @{
            Name = "Add-DbDocument TC16: UTC_Updated remains unchanged when NoTimestampUpdate is enabled. VersionId must not exist in collection"
            Tag = @('private','db','dbCore','AppendOnlyStore','AddDbDocument','active')
            Test = {
                $doc = [PSCustomObject]@{ Name = "TestDocument" }
                $inserted1 = Add-DbDocument -Database $db -Collection $TestCollection -Data $doc
                
                Start-Sleep -Milliseconds 100  # Simulate time passing
                $inserted2 = Get-DbDocumentByVersion -Database $db -Collection $TestCollection -VersionId $inserted1.VersionId
                $result = Remove-LiteData -Collection $TestCollection -ById $inserted1._id -Result
                $result | Should -Be 1

                $inserted2 = Add-DbDocument -Database $db -Collection $TestCollection -Data $inserted2 -NoTimestampUpdate
                $inserted3 = Get-DbDocumentByVersion -Database $db -Collection $TestCollection -VersionId $inserted2.VersionId

                $inserted1.UTC_Updated | Should -Be $inserted3.UTC_Updated
                $inserted1.UTC_Created | Should -Be $inserted3.UTC_Created
            }
        }
        It @TC16
    }
}
