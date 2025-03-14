Describe "Set-DbBundleCollection Integration Tests" -Tag 'Integration' {
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
                $null = Add-DbDocument @AddParams
            }

        }

        function SeedSet1 {
            param([switch]$Seed)
            $bundles = [PSCustomObject]@{
                srcBundle1 = [PSCustomObject]@{
                    data = @("OriginalData1","OriginalData2","OriginalData3","OriginalData4","OriginalData5","OriginalData6","OriginalData7")
                    guid = [Guid]::NewGuid()
                }
                srcBundle2 = [PSCustomObject]@{
                    data = @("OriginalData1","OriginalData2","OriginalData1","OriginalData2","OriginalData1","OriginalData2","OriginalData1")
                    guid = [Guid]::NewGuid()
                }
                srcBundle3 = [PSCustomObject]@{
                    data = @("OriginalData1","OriginalData2","OriginalData3","OriginalData1","OriginalData2","OriginalData1","OriginalData2")
                    guid = [Guid]::NewGuid()
                }
                dstBundle1 = [PSCustomObject]@{
                    data = @("OriginalData1","OriginalData2","OriginalData3","OriginalData1","OriginalData2","OriginalData3","OriginalData4")
                    guid = [Guid]::NewGuid()
                }
                dstBundle2 = [PSCustomObject]@{
                    data = @("OriginalData1","OriginalData2","OriginalData3","OriginalData1","OriginalData2","OriginalData3","OriginalData1")
                    guid = [Guid]::NewGuid()
                }
                dstBundle3 = [PSCustomObject]@{
                    data = @("OriginalData1","OriginalData2","OriginalData3","OriginalData2","OriginalData4","OriginalData3","OriginalData5")
                    guid = [Guid]::NewGuid()
                }
            }

            if ($Seed) {
                $props = $bundles.PSObject.Properties.Name
                foreach ($prop in $props) {
                    if ($prop -like '*src*') {
                        SeedDatabase -Database $db -Collection $SourceCollection -Bundle $bundles.$prop.data -BundleId $bundles.$prop.guid
                    }
                    elseif ($prop -like '*dstBundle*') {
                        SeedDatabase -Database $db -Collection $DestCollection -Bundle $bundles.$prop.data -BundleId $bundles.$prop.guid
                    }
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
        $Collections = @('Source', 'Dest', 'Bundles')
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


    Context "Set-DbBundleCollection: Atomic Tests" {
        BeforeEach {
            $bundles = (SeedSet1)
        }
        AfterEach {
            Remove-Item -Path "$env:Temp\temp.db"
        }

        $TC01 = @{
            Name = "Set-DbOjectCollectionByBundle TC01: Generates ContentMark, VersionId, BundleId, and persists correctly"
            Tag = @('private','db','dbCore','AppendOnlyStore','SetDbObjectCollectionByBundle','active')
            Test = {
                $bundleId = $bundles.srcBundle1.guid
                $bundle = $bundles.srcBundle1.data

                # Seed test data
                SeedDatabase -Database $db -Collection $SourceCollection -Bundle $bundle -BundleId $bundleId
                $bundle1 = Get-DbDocumentVersionsByBundle -Database $db -Collection $SourceCollection -BundleId $bundleId


                $bundle1.Count | Should -Be 7
                $VersionIds = $bundle1 | Select-Object -ExpandProperty VersionId | Sort-Object -Unique
                $VersionIds.Count | Should -Be 7
                $BundleIds = $bundle1 | Select-Object -ExpandProperty BundleId | Sort-Object -Unique
                $BundleIds.Count | Should -Be 1
                $ContentMarks = $bundle1 | Select-Object -ExpandProperty ContentMark | Sort-Object -Unique
                $ContentMarks.Count | Should -Be 7
                $VersionRefs = $bundle1 | Where-Object { $_.PSObject.Properties.Name -contains '$VersionId'}
                $VersionRefs.Count | Should -Be 0
                $BundleRefs = $bundle1 | Where-Object { $_.PSObject.Properties.Name -contains '$BundleId'}
                $BundleRefs.Count | Should -Be 0
                $ContentRefs = $bundle1 | Where-Object { $_.PSObject.Properties.Name -contains '$ContentMark'}
                $ContentRefs.Count | Should -Be 0
                $Docs = $bundle1 | Where-Object { $_.PSObject.Properties.Name -notcontains '$Ref'}
                $Docs.Count | Should -Be 7

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
            Name = "Set-DbBundleCollection TC02: Generates ContentMark, VersionId, BundleId, and persists correctly"
            Tag = @('private','db','dbCore','AppendOnlyStore','SetDbObjectCollectionByBundle','active')
            Test = {
                $bundleId = $bundles.srcBundle2.guid
                $bundle = $bundles.srcBundle2.data
                
                # Seed test data
                SeedDatabase -Database $db -Collection $SourceCollection -Bundle $bundle -BundleId $bundleId
                $bundle1 = Get-DbDocumentVersionsByBundle -Database $db -Collection $SourceCollection -BundleId $bundleId


                $bundle1.Count | Should -Be 7
                $VersionIds = $bundle1 | Select-Object -ExpandProperty VersionId | Sort-Object -Unique
                $VersionIds.Count | Should -Be 7
                $BundleIds = $bundle1 | Select-Object -ExpandProperty BundleId | Sort-Object -Unique
                $BundleIds.Count | Should -Be 1
                $ContentMarks = $bundle1 | Select-Object -ExpandProperty ContentMark | Sort-Object -Unique
                $ContentMarks.Count | Should -Be 7
                $VersionRefs = $bundle1 | Where-Object { $_.PSObject.Properties.Name -contains '$VersionId'}
                $VersionRefs.Count | Should -Be 5
                $BundleRefs = $bundle1 | Where-Object { $_.PSObject.Properties.Name -contains '$BundleId'}
                $BundleRefs.Count | Should -Be 0
                $ContentRefs = $bundle1 | Where-Object { $_.PSObject.Properties.Name -contains '$ContentMark'}
                $ContentRefs.Count | Should -Be 0
                $Docs = $bundle1 | Where-Object { $_.PSObject.Properties.Name -notcontains '$Ref'}
                $Docs.Count | Should -Be 2

                $bundle1[6].PSObject.Properties.Name | Should -Not -Contain '$Ref'
                $bundle1[6].'$ObjVer' | Should -Be 1
                $bundle1[6].DataField | Should -Be 'OriginalData1'
                $bundle1[5].PSObject.Properties.Name | Should -Not -Contain '$Ref'
                $bundle1[5].'$ObjVer' | Should -Be 2
                $bundle1[5].DataField | Should -Be 'OriginalData2'
                $bundle1[4].PSObject.Properties.Name | Should -Contain '$Ref'
                $bundle1[4].'$ObjVer' | Should -Be 3
                $bundle1[4].'$VersionId' | Should -Be $bundle1[6].VersionId
                $bundle1[3].PSObject.Properties.Name | Should -Contain '$Ref'
                $bundle1[3].'$ObjVer' | Should -Be 4
                $bundle1[3].'$VersionId' | Should -Be $bundle1[5].VersionId
                $bundle1[2].PSObject.Properties.Name | Should -Contain '$Ref'
                $bundle1[2].'$ObjVer' | Should -Be 5
                $bundle1[2].'$VersionId' | Should -Be $bundle1[6].VersionId
                $bundle1[1].PSObject.Properties.Name | Should -Contain '$Ref'
                $bundle1[1].'$ObjVer' | Should -Be 6
                $bundle1[1].'$VersionId' | Should -Be $bundle1[5].VersionId
                $bundle1[0].PSObject.Properties.Name | Should -Contain '$Ref'
                $bundle1[0].'$ObjVer' | Should -Be 7
                $bundle1[0].'$VersionId' | Should -Be $bundle1[6].VersionId
            }
        }
        It @TC02

        $TC03 = @{
            Name = "Set-DbBundleCollection TC03: Generates ContentMark, VersionId, BundleId, and persists correctly"
            Tag = @('private','db','dbCore','AppendOnlyStore','SetDbObjectCollectionByBundle','active')
            Test = {
                $bundleId = $bundles.srcBundle3.guid
                $bundle = $bundles.srcBundle3.data

                # Seed test data
                SeedDatabase -Database $db -Collection $SourceCollection -Bundle $bundle -BundleId $bundleId
                $bundle1 = Get-DbDocumentVersionsByBundle -Database $db -Collection $SourceCollection -BundleId $bundleId


                $bundle1.Count | Should -Be 7
                $VersionIds = $bundle1 | Select-Object -ExpandProperty VersionId | Sort-Object -Unique
                $VersionIds.Count | Should -Be 7
                $BundleIds = $bundle1 | Select-Object -ExpandProperty BundleId | Sort-Object -Unique
                $BundleIds.Count | Should -Be 1
                $ContentMarks = $bundle1 | Select-Object -ExpandProperty ContentMark | Sort-Object -Unique
                $ContentMarks.Count | Should -Be 7
                $VersionRefs = $bundle1 | Where-Object { $_.PSObject.Properties.Name -contains '$VersionId'}
                $VersionRefs.Count | Should -Be 4
                $BundleRefs = $bundle1 | Where-Object { $_.PSObject.Properties.Name -contains '$BundleId'}
                $BundleRefs.Count | Should -Be 0
                $ContentRefs = $bundle1 | Where-Object { $_.PSObject.Properties.Name -contains '$ContentMark'}
                $ContentRefs.Count | Should -Be 0
                $Docs = $bundle1 | Where-Object { $_.PSObject.Properties.Name -notcontains '$Ref'}
                $Docs.Count | Should -Be 3

                $bundle1[6].PSObject.Properties.Name | Should -Not -Contain '$Ref'
                $bundle1[6].'$ObjVer' | Should -Be 1
                $bundle1[6].DataField | Should -Be 'OriginalData1'
                $bundle1[5].PSObject.Properties.Name | Should -Not -Contain '$Ref'
                $bundle1[5].'$ObjVer' | Should -Be 2
                $bundle1[5].DataField | Should -Be 'OriginalData2'
                $bundle1[4].PSObject.Properties.Name | Should -Not -Contain '$Ref'
                $bundle1[4].'$ObjVer' | Should -Be 3
                $bundle1[4].DataField | Should -Be 'OriginalData3'
                $bundle1[3].PSObject.Properties.Name | Should -Contain '$Ref'
                $bundle1[3].'$ObjVer' | Should -Be 4
                $bundle1[3].'$VersionId' | Should -Be $bundle1[6].VersionId
                $bundle1[2].PSObject.Properties.Name | Should -Contain '$Ref'
                $bundle1[2].'$ObjVer' | Should -Be 5
                $bundle1[2].'$VersionId' | Should -Be $bundle1[5].VersionId
                $bundle1[1].PSObject.Properties.Name | Should -Contain '$Ref'
                $bundle1[1].'$ObjVer' | Should -Be 6
                $bundle1[1].'$VersionId' | Should -Be $bundle1[6].VersionId
                $bundle1[0].PSObject.Properties.Name | Should -Contain '$Ref'
                $bundle1[0].'$ObjVer' | Should -Be 7
                $bundle1[0].'$VersionId' | Should -Be $bundle1[5].VersionId
            }
        }
        It @TC03

        $TC04 = @{
            Name = "Set-DbOjectCollectionByBundle TC04: Generates ContentMark, VersionId, BundleId, and persists correctly"
            Tag = @('private','db','dbCore','AppendOnlyStore','SetDbObjectCollectionByBundle','active')
            Test = {
                $bundleId = $bundles.dstBundle1.guid
                $bundle = $bundles.dstBundle1.data

                # Seed test data
                SeedDatabase -Database $db -Collection $DestCollection -Bundle $bundle -BundleId $bundleId
                $bundle1 = Get-DbDocumentVersionsByBundle -Database $db -Collection $DestCollection -BundleId $bundleId


                $bundle1.Count | Should -Be 7
                $VersionIds = $bundle1 | Select-Object -ExpandProperty VersionId | Sort-Object -Unique
                $VersionIds.Count | Should -Be 7
                $BundleIds = $bundle1 | Select-Object -ExpandProperty BundleId | Sort-Object -Unique
                $BundleIds.Count | Should -Be 1
                $ContentMarks = $bundle1 | Select-Object -ExpandProperty ContentMark | Sort-Object -Unique
                $ContentMarks.Count | Should -Be 7
                $VersionRefs = $bundle1 | Where-Object { $_.PSObject.Properties.Name -contains '$VersionId'}
                $VersionRefs.Count | Should -Be 3
                $BundleRefs = $bundle1 | Where-Object { $_.PSObject.Properties.Name -contains '$BundleId'}
                $BundleRefs.Count | Should -Be 0
                $ContentRefs = $bundle1 | Where-Object { $_.PSObject.Properties.Name -contains '$ContentMark'}
                $ContentRefs.Count | Should -Be 0
                $Docs = $bundle1 | Where-Object { $_.PSObject.Properties.Name -notcontains '$Ref'}
                $Docs.Count | Should -Be 4

                $bundle1[6].PSObject.Properties.Name | Should -Not -Contain '$Ref'
                $bundle1[6].'$ObjVer' | Should -Be 1
                $bundle1[6].DataField | Should -Be 'OriginalData1'
                $bundle1[5].PSObject.Properties.Name | Should -Not -Contain '$Ref'
                $bundle1[5].'$ObjVer' | Should -Be 2
                $bundle1[5].DataField | Should -Be 'OriginalData2'
                $bundle1[4].PSObject.Properties.Name | Should -Not -Contain '$Ref'
                $bundle1[4].'$ObjVer' | Should -Be 3
                $bundle1[4].DataField | Should -Be 'OriginalData3'
                $bundle1[3].PSObject.Properties.Name | Should -Contain '$Ref'
                $bundle1[3].'$ObjVer' | Should -Be 4
                $bundle1[3].'$VersionId' | Should -Be $bundle1[6].VersionId
                $bundle1[2].PSObject.Properties.Name | Should -Contain '$Ref'
                $bundle1[2].'$ObjVer' | Should -Be 5
                $bundle1[2].'$VersionId' | Should -Be $bundle1[5].VersionId
                $bundle1[1].PSObject.Properties.Name | Should -Contain '$Ref'
                $bundle1[1].'$ObjVer' | Should -Be 6
                $bundle1[1].'$VersionId' | Should -Be $bundle1[4].VersionId
                $bundle1[0].PSObject.Properties.Name | Should -Not -Contain '$Ref'
                $bundle1[0].'$ObjVer' | Should -Be 7
                $bundle1[0].DataField | Should -Be 'OriginalData4'
            }
        }
        It @TC04
        
        $TC05 = @{
            Name = "Set-DbOjectCollectionByBundle TC05: Generates ContentMark, VersionId, BundleId, and persists correctly"
            Tag = @('private','db','dbCore','AppendOnlyStore','SetDbObjectCollectionByBundle','active')
            Test = {
                $bundleId = $bundles.dstBundle2.guid
                $bundle = $bundles.dstBundle2.data

                # Seed test data
                SeedDatabase -Database $db -Collection $DestCollection -Bundle $bundle -BundleId $bundleId
                $bundle1 = Get-DbDocumentVersionsByBundle -Database $db -Collection $DestCollection -BundleId $bundleId


                $bundle1.Count | Should -Be 7
                $VersionIds = $bundle1 | Select-Object -ExpandProperty VersionId | Sort-Object -Unique
                $VersionIds.Count | Should -Be 7
                $BundleIds = $bundle1 | Select-Object -ExpandProperty BundleId | Sort-Object -Unique
                $BundleIds.Count | Should -Be 1
                $ContentMarks = $bundle1 | Select-Object -ExpandProperty ContentMark | Sort-Object -Unique
                $ContentMarks.Count | Should -Be 7
                $VersionRefs = $bundle1 | Where-Object { $_.PSObject.Properties.Name -contains '$VersionId'}
                $VersionRefs.Count | Should -Be 4
                $BundleRefs = $bundle1 | Where-Object { $_.PSObject.Properties.Name -contains '$BundleId'}
                $BundleRefs.Count | Should -Be 0
                $ContentRefs = $bundle1 | Where-Object { $_.PSObject.Properties.Name -contains '$ContentMark'}
                $ContentRefs.Count | Should -Be 0
                $Docs = $bundle1 | Where-Object { $_.PSObject.Properties.Name -notcontains '$Ref'}
                $Docs.Count | Should -Be 3

                $bundle1[6].PSObject.Properties.Name | Should -Not -Contain '$Ref'
                $bundle1[6].'$ObjVer' | Should -Be 1
                $bundle1[6].DataField | Should -Be 'OriginalData1'
                $bundle1[5].PSObject.Properties.Name | Should -Not -Contain '$Ref'
                $bundle1[5].'$ObjVer' | Should -Be 2
                $bundle1[5].DataField | Should -Be 'OriginalData2'
                $bundle1[4].PSObject.Properties.Name | Should -Not -Contain '$Ref'
                $bundle1[4].'$ObjVer' | Should -Be 3
                $bundle1[4].DataField | Should -Be 'OriginalData3'
                $bundle1[3].PSObject.Properties.Name | Should -Contain '$Ref'
                $bundle1[3].'$ObjVer' | Should -Be 4
                $bundle1[3].'$VersionId' | Should -Be $bundle1[6].VersionId
                $bundle1[2].PSObject.Properties.Name | Should -Contain '$Ref'
                $bundle1[2].'$ObjVer' | Should -Be 5
                $bundle1[2].'$VersionId' | Should -Be $bundle1[5].VersionId
                $bundle1[1].PSObject.Properties.Name | Should -Contain '$Ref'
                $bundle1[1].'$ObjVer' | Should -Be 6
                $bundle1[1].'$VersionId' | Should -Be $bundle1[4].VersionId
                $bundle1[0].PSObject.Properties.Name | Should -Contain '$Ref'
                $bundle1[0].'$ObjVer' | Should -Be 7
                $bundle1[0].'$VersionId' | Should -Be $bundle1[6].VersionId
            }
        }
        It @TC05
        
        $TC06 = @{
            Name = "Set-DbOjectCollectionByBundle TC06: Generates ContentMark, VersionId, BundleId, and persists correctly"
            Tag = @('private','db','dbCore','AppendOnlyStore','SetDbObjectCollectionByBundle','active')
            Test = {
                $bundleId = $bundles.dstBundle3.guid
                $bundle = $bundles.dstBundle3.data

                # Seed test data
                SeedDatabase -Database $db -Collection $DestCollection -Bundle $bundle -BundleId $bundleId
                $bundle1 = Get-DbDocumentVersionsByBundle -Database $db -Collection $DestCollection -BundleId $bundleId


                $bundle1.Count | Should -Be 7
                $VersionIds = $bundle1 | Select-Object -ExpandProperty VersionId | Sort-Object -Unique
                $VersionIds.Count | Should -Be 7
                $BundleIds = $bundle1 | Select-Object -ExpandProperty BundleId | Sort-Object -Unique
                $BundleIds.Count | Should -Be 1
                $ContentMarks = $bundle1 | Select-Object -ExpandProperty ContentMark | Sort-Object -Unique
                $ContentMarks.Count | Should -Be 7
                $VersionRefs = $bundle1 | Where-Object { $_.PSObject.Properties.Name -contains '$VersionId'}
                $VersionRefs.Count | Should -Be 2
                $BundleRefs = $bundle1 | Where-Object { $_.PSObject.Properties.Name -contains '$BundleId'}
                $BundleRefs.Count | Should -Be 0
                $ContentRefs = $bundle1 | Where-Object { $_.PSObject.Properties.Name -contains '$ContentMark'}
                $ContentRefs.Count | Should -Be 0
                $Docs = $bundle1 | Where-Object { $_.PSObject.Properties.Name -notcontains '$Ref'}
                $Docs.Count | Should -Be 5

                $bundle1[6].PSObject.Properties.Name | Should -Not -Contain '$Ref'
                $bundle1[6].'$ObjVer' | Should -Be 1
                $bundle1[6].DataField | Should -Be 'OriginalData1'
                $bundle1[5].PSObject.Properties.Name | Should -Not -Contain '$Ref'
                $bundle1[5].'$ObjVer' | Should -Be 2
                $bundle1[5].DataField | Should -Be 'OriginalData2'
                $bundle1[4].PSObject.Properties.Name | Should -Not -Contain '$Ref'
                $bundle1[4].'$ObjVer' | Should -Be 3
                $bundle1[4].DataField | Should -Be 'OriginalData3'
                $bundle1[3].PSObject.Properties.Name | Should -Contain '$Ref'
                $bundle1[3].'$ObjVer' | Should -Be 4
                $bundle1[3].'$VersionId' | Should -Be $bundle1[5].VersionId
                $bundle1[2].PSObject.Properties.Name | Should -Not -Contain '$Ref'
                $bundle1[2].'$ObjVer' | Should -Be 5
                $bundle1[2].DataField | Should -Be 'OriginalData4'
                $bundle1[1].PSObject.Properties.Name | Should -Contain '$Ref'
                $bundle1[1].'$ObjVer' | Should -Be 6
                $bundle1[1].'$VersionId' | Should -Be $bundle1[4].VersionId
                $bundle1[0].PSObject.Properties.Name | Should -Not -Contain '$Ref'
                $bundle1[0].'$ObjVer' | Should -Be 7
                $bundle1[0].DataField | Should -Be 'OriginalData5'
            }
        }
        It @TC06
    
        $TC07 = @{
            Name = "Set-DbOjectCollectionByBundle TC07: Generates ContentMark, VersionId, BundleId, and persists correctly"
            Tag = @('private','db','dbCore','AppendOnlyStore','SetDbObjectCollectionByBundle','active')
            Test = {
                $SeedSet1 = (SeedSet1 -Seed)
                $SrcSet1 = Get-DbDocumentAll -Database $db -Collection $SourceCollection
                $SrcSet1.Count | Should -Be 21
                $DstSet1 = Get-DbDocumentAll -Database $db -Collection $SourceCollection
                $DstSet1.Count | Should -Be 21
            }
        }
        It @TC07
    }

    It "should move an object while preserving all expected properties" {
        $SeedSet1 = (SeedSet1 -Seed)
        $SeedSet1 | Should -BeNullOrEmpty
        $OriginalObject = Get-DbDocumentByVersion -Database $Database -Collection $SourceCollection -VersionId "v1"

        Set-DbBundleCollection -BundleId $BundleId -Database $Database -SourceCollection $SourceCollection -DestCollection $DestCollection

        $MovedObject = Get-DbDocumentByVersion -Database $Database -Collection $DestCollection -VersionId "v1"
        $MovedObject | Should -Not -BeNullOrEmpty

        $OriginalObject.PSObject.Properties | Where-Object { $_.Name -notin @("CollectionName", "Timestamp") } | ForEach-Object {
            $_.Value | Should -Be $MovedObject.($_.Name)
        }

        Get-DbDocumentByVersion -Database $Database -Collection $SourceCollection -VersionId "v1" | Should -BeNullOrEmpty
    }
}


#         It "should preserve document VersionId and BundleId after movement" {
#             $OriginalObject = Get-DbDocumentByVersion -Database $Database -Collection $SourceCollection -VersionId "v1"

#             Set-DbBundleCollection -BundleId $BundleId -Database $Database -SourceCollection $SourceCollection -DestCollection $DestCollection

#             $MovedObject = Get-DbDocumentByVersion -Database $Database -Collection $DestCollection -VersionId "v1"
#             $MovedObject.VersionId | Should -Be $OriginalObject.VersionId
#             $MovedObject.BundleId | Should -Be $OriginalObject.BundleId
#         }
#     }

#     Context "Edge Cases & Error Handling" {
#         It "should handle an empty source collection without error" {
#             Clear-LiteCollection -Database $Database -CollectionName $SourceCollection

#             { Set-DbBundleCollection -BundleId $BundleId -Database $Database -SourceCollection $SourceCollection -DestCollection $DestCollection } | Should -Not -Throw

#             (Get-LiteCollection -Database $Database -CollectionName $DestCollection).Count | Should -Be 0
#         }

#         It "should throw an error for an invalid BundleId" {
#             { Set-DbBundleCollection -BundleId "invalid-id" -Database $Database -SourceCollection $SourceCollection -DestCollection $DestCollection } | Should -Throw -ErrorId "InvalidBundleId"
#         }

#         It "should correctly move multiple documents" {
#             $SecondVersion = @{
#                 VersionId = "v2"
#                 BundleId = $BundleId
#                 DataField = "SecondData"
#             }
#             Add-DbDocument -Database $Database -Collection $SourceCollection -Data $SecondVersion | Out-Null

#             Set-DbBundleCollection -BundleId $BundleId -Database $Database -SourceCollection $SourceCollection -DestCollection $DestCollection

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

#             Set-DbBundleCollection -BundleId $BundleId -Database $Database -SourceCollection $SourceCollection -DestCollection $DestCollection

#             $MovedObject = Get-DbDocumentByVersion -Database $Database -Collection $DestCollection -VersionId "v3"
#             $MovedObject | Should -Not -BeNullOrEmpty
#         }
#     }

#     Context "Transaction Handling & Rollback" {
#         It "should rollback all changes on failure" {
#             Add-DbDocument -Database $Database -Collection $SourceCollection -Data @{Invalid = $null} | Out-Null

#             { Set-DbBundleCollection -BundleId $BundleId -Database $Database -SourceCollection $SourceCollection -DestCollection $DestCollection } | Should -Throw

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

#             { Set-DbBundleCollection -BundleId $BundleId -Database $Database -SourceCollection $SourceCollection -DestCollection $DestCollection } | Should -Throw

#             Get-DbDocumentByVersion -Database $Database -Collection $RefCollection -VersionId "ref1" | Should -Not -BeNullOrEmpty
#         }
#     }

#     Context "Flags: NoVersionUpdate & NoTimestampUpdate" {
#         It "should retain VersionId when NoVersionUpdate flag is used" {
#             Set-DbBundleCollection -BundleId $BundleId -Database $Database -SourceCollection $SourceCollection -DestCollection $DestCollection -NoVersionUpdate

#             $MovedObject = Get-DbDocumentByVersion -Database $Database -Collection $DestCollection -VersionId "v1"
#             $MovedObject.VersionId | Should -Be "v1"
#         }

#         It "should retain Timestamp when NoTimestampUpdate flag is used" {
#             $OriginalObject = Get-DbDocumentByVersion -Database $Database -Collection $SourceCollection -VersionId "v1"
            
#             Set-DbBundleCollection -BundleId $BundleId -Database $Database -SourceCollection $SourceCollection -DestCollection $DestCollection -NoTimestampUpdate

#             $MovedObject = Get-DbDocumentByVersion -Database $Database -Collection $DestCollection -VersionId "v1"
#             $MovedObject.Timestamp | Should -Be $OriginalObject.Timestamp
#         }

#         It "should preserve optional fields when both flags are used" {
#             $OriginalObject = Get-DbDocumentByVersion -Database $Database -Collection $SourceCollection -VersionId "v1"

#             Set-DbBundleCollection -BundleId $BundleId -Database $Database -SourceCollection $SourceCollection -DestCollection $DestCollection -NoVersionUpdate -NoTimestampUpdate

#             $MovedObject = Get-DbDocumentByVersion -Database $Database -Collection $DestCollection -VersionId "v1"
#             $MovedObject.VersionId | Should -Be $OriginalObject.VersionId
#             $MovedObject.Timestamp | Should -Be $OriginalObject.Timestamp
#         }
#     }
# }
