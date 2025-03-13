
#     # ✅ T27: Insert a document where $Ref exists but is malformed (not a valid VersionId)
#     It "T27: Fails gracefully when $Ref is malformed" {
#         $doc = [PSCustomObject]@{ '$Ref' = "INVALID_VERSION_ID" }

#         { Add-DbDocument -Database $db -Collection $TestCollection -Data $doc } | Should -Throw
#     }

#     It "T26: Ensures New-DbVersionRef correctly generates and resolves references" {
#         $doc1 = [PSCustomObject]@{ Name = "Version1" }
#         $inserted1 = Add-DbDocument -Database $db -Collection $TestCollection -Data $doc1

#         $doc2 = [PSCustomObject]@{ Name = "Version2"; '$Ref' = $inserted1.VersionId }
#         $inserted2 = Add-DbDocument -Database $db -Collection $TestCollection -Data $doc2

#         $retrieved = $TestCollection.FindOne({ VersionId = $inserted2.VersionId })

#         $retrieved.'$Ref' | Should -Be $inserted1.VersionId
#     }