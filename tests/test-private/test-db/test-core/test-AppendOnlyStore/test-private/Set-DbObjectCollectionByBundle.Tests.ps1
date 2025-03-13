Describe "Set-DbObjectCollectionByBundle Integration Tests" -Tag 'Integration' {
    BeforeAll {
        function SeedDatabase {
            param($Database, $Collection, $Bundle, $BundleId)

            # Seed test data
            if (-not $BundleId) {
                $BundleId = [Guid]::NewGuid()
            }
            foreach ($version in $Bundle) {
                $AddParams = @{
                    Database = [LiteDB.LiteDatabase]$Database
                    Collection = [LiteDB.LiteCollection[LiteDB.BsonDocument]]$Collection
                    Data = [PSCustomObject]@{DataField = $version; BundleId = $BundleId}
                }
                Add-DbDocument @AddParams
            }

        }

        function SeedSet1 {
            $bundles = [PSCustomObject]@{
                $srcBundle1 = @("OriginalData1","OriginalData2","OriginalData3","OriginalData4","OriginalData5","OriginalData6","OriginalData7")
                $srcGuid1 = [Guid]::NewGuid()
                $srcBundle2 = @("OriginalData1","OriginalData2","OriginalData1","OriginalData2","OriginalData1","OriginalData2","OriginalData1")
                $srcGuid2 = [Guid]::NewGuid()
                $srcBundle3 = @("OriginalData1","OriginalData2","OriginalData3","OriginalData1","OriginalData2","OriginalData1","OriginalData2")
                $srcGuid3 = [Guid]::NewGuid()
                $dstBundle1 = @("OriginalData1","OriginalData2","OriginalData3","OriginalData1","OriginalData2","OriginalData3","OriginalData4")
                $dstGuid1 = [Guid]::NewGuid()
                $dstBundle2 = @("OriginalData1","OriginalData2","OriginalData3","OriginalData1","OriginalData2","OriginalData3","OriginalData1")
                $dstGuid2 = [Guid]::NewGuid()
                $dstBundle3 = @("OriginalData1","OriginalData2","OriginalData3","OriginalData2","OriginalData4","OriginalData3","OriginalData5")
                $dstGuid3 = [Guid]::NewGuid()
            }

            $props = $bundles.PSObject.Properties.Name
            foreach ($prop in $props) {
                $id = $prop[-1]

                if ($prop -like '*srcBundle*') {
                    $guidProp = "srcGuid$id"
                    SeedDatabase -Database $db -Collection $SourceCollection -Bundle $bundles.$prop -BundleId $bundles.$guidProp
                }
                elseif ($prop -like '*dstBundle*') {
                    $guidProp = "dstGuid$id"
                    SeedDatabase -Database $db -Collection $DestCollection -Bundle $bundles.$prop -BundleId $bundles.$guidProp
                }
            }

            return $bundles
        }

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


    Context "Set-DbObjectCollectionByBundle: Atomic Tests" {
        AfterEach {
            Remove-Item -Path "$env:Temp\temp.db"
        }

        $TC01 = @{
            Name = "Set-DbOjectCollectionByBundle TC01: Generates ContentMark, VersionId, BundleId, and persists correctly"
            Tag = @('private','db','dbCore','AppendOnlyStore','SetDbObjectCollectionByBundle','active')
            Test = {
                # Seed test data
                $bundle1 = @("OriginalData1","OriginalData2","OriginalData3","OriginalData4","OriginalData5","OriginalData6","OriginalData7")

                $BundleId = [Guid]::NewGuid()
                SeedDatabase -Database $db -Collection $SourceCollection -Bundle $bundle1 -BundleId $BundleId
                $bundle1 = Get-DbDocumentVersionsByBundle -Database $db -Collection $SourceCollection -BundleId $BundleId


                $bundle1.Count | Should -Be 7
                $VersionIds = $bundle1 | Select-Object -ExpandProperty VersionId | Sort-Object -Unique
                $VersionIds.Count | Should -Be 7
                $BundleIds = $bundle1 | Select-Object -ExpandProperty BundleId | Sort-Object -Unique
                $BundleIds.Count | Should -Be 1
                $ContentMarks = $bundle1 | Select-Object -ExpandProperty ContentMark | Sort-Object -Unique
                $ContentMarks.Count | Should -Be 7
                $bundle1[0] | Should -BeNullOrEmpty

                $bundle1[6].PSObject.Properties.Name | Should -Not -Contain '$Ref'
                $bundle1[6].'$ObjVer' | Should -Be 1
                $bundle1[6].DataField | Should -Be 'OriginalData1'
                $bundle1[5].PSObject.Properties.Name | Should -Not -Contain '$Ref'
                $bundle1[5].'$ObjVer' | Should -Be 2
                $bundle1[5].DataField | Should -Be 'OriginalData2'
                $bundle1[4].PSObject.Properties.Name | Should -Not -Contain '$Ref'
                $bundle1[4].'$ObjVer' | Should -Be 3
                $bundle1[4].DataField | Should -Be 'OriginalData3'
                $bundle1[3].PSObject.Properties.Name | Should -Not -Contain '$Ref'
                $bundle1[3].'$ObjVer' | Should -Be 4
                $bundle1[3].DataField | Should -Be 'OriginalData4'
                $bundle1[2].PSObject.Properties.Name | Should -Not -Contain '$Ref'
                $bundle1[2].'$ObjVer' | Should -Be 5
                $bundle1[2].DataField | Should -Be 'OriginalData5'
                $bundle1[1].PSObject.Properties.Name | Should -Not -Contain '$Ref'
                $bundle1[1].'$ObjVer' | Should -Be 6
                $bundle1[1].DataField | Should -Be 'OriginalData6'
                $bundle1[0].PSObject.Properties.Name | Should -Not -Contain '$Ref'
                $bundle1[0].'$ObjVer' | Should -Be 7
                $bundle1[0].DataField | Should -Be 'OriginalData7'
            }
        }
        It @TC01

        $TC02 = @{
            Name = "Set-DbOjectCollectionByBundle TC02: Generates ContentMark, VersionId, BundleId, and persists correctly"
            Tag = @('private','db','dbCore','AppendOnlyStore','SetDbObjectCollectionByBundle','active')
            Test = {
                # Seed test data
                $bundle1 = @("OriginalData1","OriginalData2","OriginalData1","OriginalData2","OriginalData1","OriginalData2","OriginalData1")
                SeedDatabase -Database $db -Collection $SourceCollection -Bundle $bundle1
            }
        }
        It @TC02

        $TC03 = @{
            Name = "Set-DbOjectCollectionByBundle TC03: Generates ContentMark, VersionId, BundleId, and persists correctly"
            Tag = @('private','db','dbCore','AppendOnlyStore','SetDbObjectCollectionByBundle','active')
            Test = {
                # Seed test data
                $bundle1 = @("OriginalData1","OriginalData2","OriginalData3","OriginalData1","OriginalData2","OriginalData1","OriginalData2")
                SeedDatabase -Database $db -Collection $SourceCollection -Bundle $bundle1
            }
        }
        It @TC03

        $TC04 = @{
            Name = "Set-DbOjectCollectionByBundle TC04: Generates ContentMark, VersionId, BundleId, and persists correctly"
            Tag = @('private','db','dbCore','AppendOnlyStore','SetDbObjectCollectionByBundle','active')
            Test = {
                # Seed test data
                $bundle1 = @("OriginalData1","OriginalData2","OriginalData3","OriginalData1","OriginalData2","OriginalData3","OriginalData4")
                SeedDatabase -Database $db -Collection $DestCollection -Bundle $bundle1
            }
        }
        It @TC04
        
        $TC05 = @{
            Name = "Set-DbOjectCollectionByBundle TC05: Generates ContentMark, VersionId, BundleId, and persists correctly"
            Tag = @('private','db','dbCore','AppendOnlyStore','SetDbObjectCollectionByBundle','active')
            Test = {
                # Seed test data
                $bundle1 = @("OriginalData1","OriginalData2","OriginalData3","OriginalData1","OriginalData2","OriginalData3","OriginalData1")
                SeedDatabase -Database $db -Collection $DestCollection -Bundle $bundle1
            }
        }
        It @TC05
        
        $TC06 = @{
            Name = "Set-DbOjectCollectionByBundle TC06: Generates ContentMark, VersionId, BundleId, and persists correctly"
            Tag = @('private','db','dbCore','AppendOnlyStore','SetDbObjectCollectionByBundle','active')
            Test = {
                # Seed test data
                $bundle1 = @("OriginalData1","OriginalData2","OriginalData3","OriginalData2","OriginalData4","OriginalData3","OriginalData5")
                SeedDatabase -Database $db -Collection $DestCollection -Bundle $bundle1
            }
        }
        It @TC06
    }
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
