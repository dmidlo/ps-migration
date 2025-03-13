Describe "Set-DbObjectCollectionByBundle Integration Tests" -Tag 'Integration' {
    BeforeAll {
        $dbpath = "$env:Temp\temp.db"
        if(Test-Path -Path $dbpath) {
            Remove-Item -Path $dbpath
        }
    }

    BeforeEach {
        $dbConnectionString = New-DbConnectionString -Culture "en-US" -IgnoreCase -IgnoreNonSpace -IgnoreSymbols -ConnectionType Shared -AutoRebuild -FilePath "$env:TEMP\temp.db" -Upgrade
        Initialize-LiteDbDatabase -ConnectionString $dbConnectionString
        $db = New-LiteDatabase -ConnectionString $dbConnectionString
        $Collections = @('Source', 'Dest', 'RefCol')
        foreach ($Collection in $Collections) {
            Initialize-LiteDBCollection -Database $db -CollectionName $Collection -Indexes @(
                [PSCustomObject]@{ Field="VersionId"; Unique=$true },
                [PSCustomObject]@{ Field="BundleId"; Unique=$false },
                [PSCustomObject]@{ Field="ContentMark"; Unique=$false }
            )
        }
        $SourceCollection = Get-LiteCollection -Database $db -CollectionName "Source"
        $DestCollection = Get-LiteCollection -Database $db -CollectionName 'Dest'
        $RefCollection = Get-LiteCollection -Database $db -CollectionName 'RefCol'
    }

    # AfterEach {
    #     Remove-Item -Path "$env:Temp\temp.db"
    # }
    Context "Set-DbObjectCollectionByBundle: Atomic Tests" {

        $TC01 = @{
            Name = "Set-DbOjectCollectionByBundle TC01: Generates ContentMark, VersionId, BundleId, and persists correctly"
            Tag = @('private','db','dbCore','AppendOnlyStore','SetDbObjectCollectionByBundle','active')
            Test = {
                # Seed test data
                $Bundle1Id = [Guid]::NewGuid()
                $bundle1 = @("OriginalData1","OriginalData2","OriginalData3","OriginalData4","OriginalData5","OriginalData6","OriginalData7")
                foreach ($version in $bundle1) {
                    $AddParams = @{
                        Database = [LiteDB.LiteDatabase]$db
                        Collection = [LiteDB.LiteCollection[LiteDB.BsonDocument]]$SourceCollection
                        Data = [PSCustomObject]@{DataField = $version; BundleId = $Bundle1Id}
                    }
                    Add-DbDocument @AddParams
                }
            }
        }
        # It @TC01
    }

    $TC02 = @{
        Name = "Set-DbOjectCollectionByBundle TC02: Generates ContentMark, VersionId, BundleId, and persists correctly"
        Tag = @('private','db','dbCore','AppendOnlyStore','SetDbObjectCollectionByBundle','active')
        Test = {
            # Seed test data
            $Bundle1Id = [Guid]::NewGuid()
            $bundle1 = @("OriginalData1","OriginalData2","OriginalData1","OriginalData2","OriginalData1","OriginalData2","OriginalData1")
            foreach ($version in $bundle1) {
                $AddParams = @{
                    Database = [LiteDB.LiteDatabase]$db
                    Collection = [LiteDB.LiteCollection[LiteDB.BsonDocument]]$SourceCollection
                    Data = [PSCustomObject]@{DataField = $version; BundleId = $Bundle1Id}
                }
                Add-DbDocument @AddParams
            }
        }
    }
    It @TC02

#     $TC03 = @{
#         Name = "Set-DbOjectCollectionByBundle TC03: Generates ContentMark, VersionId, BundleId, and persists correctly"
#         # Tag = @('private','db','dbCore','AppendOnlyStore','SetDbObjectCollectionByBundle','active')
#         Test = {
#             # Seed test data
#             $Bundle1Id = [Guid]::NewGuid()
#             $bundle1 = @("OriginalData1","OriginalData2","OriginalData3","OriginalData1","OriginalData2","OriginalData1","OriginalData2")
#             foreach ($version in $bundle1) {
#                 $AddParams = [PSCustomObject]@{
#                     Database = $db
#                     Collection = $SourceCollection
#                     Data = @{DataField = $version; BundleId = $Bundle1Id}
#                 }
#                 Add-DbDocument @AddParams
#             }
#         }
#     }
#     It @TC03

#     $TC04 = @{
#         Name = "Set-DbOjectCollectionByBundle TC04: Generates ContentMark, VersionId, BundleId, and persists correctly"
#         # Tag = @('private','db','dbCore','AppendOnlyStore','SetDbObjectCollectionByBundle','active')
#         Test = {
#             # Seed test data
#             $Bundle1Id = [Guid]::NewGuid()
#             $bundle1 = @("OriginalData1","OriginalData2","OriginalData3","OriginalData1","OriginalData2","OriginalData3","OriginalData4")
#             foreach ($version in $bundle1) {
#                 $AddParams = [PSCustomObject]@{
#                     Database = $db
#                     Collection = $SourceCollection
#                     Data = @{DataField = $version; BundleId = $Bundle1Id}
#                 }
#                 Add-DbDocument @AddParams
#             }
#         }
#     }
#     It @TC04

#     $TC05 = @{
#         Name = "Set-DbOjectCollectionByBundle TC05: Generates ContentMark, VersionId, BundleId, and persists correctly"
#         # Tag = @('private','db','dbCore','AppendOnlyStore','SetDbObjectCollectionByBundle','active')
#         Test = {
#             # Seed test data
#             $Bundle1Id = [Guid]::NewGuid()
#             $bundle1 = @("OriginalData1","OriginalData2","OriginalData3","OriginalData1","OriginalData2","OriginalData3","OriginalData1")
#             foreach ($version in $bundle1) {
#                 $AddParams = [PSCustomObject]@{
#                     Database = $db
#                     Collection = $SourceCollection
#                     Data = @{DataField = $version; BundleId = $Bundle1Id}
#                 }
#                 Add-DbDocument @AddParams
#             }
#         }
#     }
#     It @TC05

#     $TC06 = @{
#         Name = "Set-DbOjectCollectionByBundle TC06: Generates ContentMark, VersionId, BundleId, and persists correctly"
#         # Tag = @('private','db','dbCore','AppendOnlyStore','SetDbObjectCollectionByBundle','active')
#         Test = {
#             # Seed test data
#             $Bundle1Id = [Guid]::NewGuid()
#             $bundle1 = @("OriginalData1","OriginalData2","OriginalData3","OriginalData2","OriginalData4","OriginalData3","OriginalData5")
#             foreach ($version in $bundle1) {
#                 $AddParams = [PSCustomObject]@{
#                     Database = $db
#                     Collection = $SourceCollection
#                     Data = @{DataField = $version; BundleId = $Bundle1Id}
#                 }
#                 Add-DbDocument @AddParams
#             }
#         }
#     }
#     It @TC06
}
#     BeforeEach {
#         # Reset collections
#         @($SourceCollection, $DestCollection, $RefCollection) | ForEach-Object {
#             Clear-LiteCollection -Database $Database -CollectionName $_
#         }

#     }

#     AfterAll {
#         Remove-Item -Path $TempDbPath -Force -ErrorAction SilentlyContinue
#     }

#     Context "Basic Object Movement" {
#         It "should move an object while preserving all expected properties" {
#             $OriginalObject = Get-DbDocumentByVersion -Database $Database -Collection $SourceCollection -VersionId "v1"

#             Set-DbObjectCollectionByBundle -BundleId $BundleId -Database $Database -SourceCollection $SourceCollection -DestCollection $DestCollection

#             $MovedObject = Get-DbDocumentByVersion -Database $Database -Collection $DestCollection -VersionId "v1"
#             $MovedObject | Should -Not -BeNullOrEmpty

#             $OriginalObject.PSObject.Properties | Where-Object { $_.Name -notin @("CollectionName", "Timestamp") } | ForEach-Object {
#                 $_.Value | Should -Be $MovedObject.($_.Name)
#             }

#             Get-DbDocumentByVersion -Database $Database -Collection $SourceCollection -VersionId "v1" | Should -BeNullOrEmpty
#         }

#         It "should preserve document VersionId and BundleId after movement" {
#             $OriginalObject = Get-DbDocumentByVersion -Database $Database -Collection $SourceCollection -VersionId "v1"

#             Set-DbObjectCollectionByBundle -BundleId $BundleId -Database $Database -SourceCollection $SourceCollection -DestCollection $DestCollection

#             $MovedObject = Get-DbDocumentByVersion -Database $Database -Collection $DestCollection -VersionId "v1"
#             $MovedObject.VersionId | Should -Be $OriginalObject.VersionId
#             $MovedObject.BundleId | Should -Be $OriginalObject.BundleId
#         }
#     }

#     Context "Edge Cases & Error Handling" {
#         It "should handle an empty source collection without error" {
#             Clear-LiteCollection -Database $Database -CollectionName $SourceCollection

#             { Set-DbObjectCollectionByBundle -BundleId $BundleId -Database $Database -SourceCollection $SourceCollection -DestCollection $DestCollection } | Should -Not -Throw

#             (Get-LiteCollection -Database $Database -CollectionName $DestCollection).Count | Should -Be 0
#         }

#         It "should throw an error for an invalid BundleId" {
#             { Set-DbObjectCollectionByBundle -BundleId "invalid-id" -Database $Database -SourceCollection $SourceCollection -DestCollection $DestCollection } | Should -Throw -ErrorId "InvalidBundleId"
#         }

#         It "should correctly move multiple documents" {
#             $SecondVersion = @{
#                 VersionId = "v2"
#                 BundleId = $BundleId
#                 DataField = "SecondData"
#             }
#             Add-DbDocument -Database $Database -Collection $SourceCollection -Data $SecondVersion | Out-Null

#             Set-DbObjectCollectionByBundle -BundleId $BundleId -Database $Database -SourceCollection $SourceCollection -DestCollection $DestCollection

#             @("v1", "v2") | ForEach-Object {
#                 Get-DbDocumentByVersion -Database $Database -Collection $DestCollection -VersionId $_ | Should -Not -BeNullOrEmpty
#             }
#         }

#         It "should correctly move documents with missing optional properties" {
#             $PartialVersion = @{
#                 VersionId = "v3"
#                 BundleId = $BundleId
#             }
#             Add-DbDocument -Database $Database -Collection $SourceCollection -Data $PartialVersion | Out-Null

#             Set-DbObjectCollectionByBundle -BundleId $BundleId -Database $Database -SourceCollection $SourceCollection -DestCollection $DestCollection

#             $MovedObject = Get-DbDocumentByVersion -Database $Database -Collection $DestCollection -VersionId "v3"
#             $MovedObject | Should -Not -BeNullOrEmpty
#         }
#     }

#     Context "Transaction Handling & Rollback" {
#         It "should rollback all changes on failure" {
#             Add-DbDocument -Database $Database -Collection $SourceCollection -Data @{Invalid = $null} | Out-Null

#             { Set-DbObjectCollectionByBundle -BundleId $BundleId -Database $Database -SourceCollection $SourceCollection -DestCollection $DestCollection } | Should -Throw

#             (Get-LiteCollection -Database $Database -CollectionName $SourceCollection).Count | Should -Be 1
#             (Get-LiteCollection -Database $Database -CollectionName $DestCollection).Count | Should -Be 0
#         }

#         It "should not leave orphaned references on rollback" {
#             $ReferenceDoc = @{
#                 VersionId = "ref1"
#                 BundleId = $BundleId
#                 '$Ref' = $SourceCollection
#             }
#             Add-DbDocument -Database $Database -Collection $RefCollection -Data $ReferenceDoc | Out-Null

#             Add-DbDocument -Database $Database -Collection $SourceCollection -Data @{Invalid = $null} | Out-Null

#             { Set-DbObjectCollectionByBundle -BundleId $BundleId -Database $Database -SourceCollection $SourceCollection -DestCollection $DestCollection } | Should -Throw

#             Get-DbDocumentByVersion -Database $Database -Collection $RefCollection -VersionId "ref1" | Should -Not -BeNullOrEmpty
#         }
#     }

#     Context "Flags: NoVersionUpdate & NoTimestampUpdate" {
#         It "should retain VersionId when NoVersionUpdate flag is used" {
#             Set-DbObjectCollectionByBundle -BundleId $BundleId -Database $Database -SourceCollection $SourceCollection -DestCollection $DestCollection -NoVersionUpdate

#             $MovedObject = Get-DbDocumentByVersion -Database $Database -Collection $DestCollection -VersionId "v1"
#             $MovedObject.VersionId | Should -Be "v1"
#         }

#         It "should retain Timestamp when NoTimestampUpdate flag is used" {
#             $OriginalObject = Get-DbDocumentByVersion -Database $Database -Collection $SourceCollection -VersionId "v1"
            
#             Set-DbObjectCollectionByBundle -BundleId $BundleId -Database $Database -SourceCollection $SourceCollection -DestCollection $DestCollection -NoTimestampUpdate

#             $MovedObject = Get-DbDocumentByVersion -Database $Database -Collection $DestCollection -VersionId "v1"
#             $MovedObject.Timestamp | Should -Be $OriginalObject.Timestamp
#         }

#         It "should preserve optional fields when both flags are used" {
#             $OriginalObject = Get-DbDocumentByVersion -Database $Database -Collection $SourceCollection -VersionId "v1"

#             Set-DbObjectCollectionByBundle -BundleId $BundleId -Database $Database -SourceCollection $SourceCollection -DestCollection $DestCollection -NoVersionUpdate -NoTimestampUpdate

#             $MovedObject = Get-DbDocumentByVersion -Database $Database -Collection $DestCollection -VersionId "v1"
#             $MovedObject.VersionId | Should -Be $OriginalObject.VersionId
#             $MovedObject.Timestamp | Should -Be $OriginalObject.Timestamp
#         }
#     }
# }
