
#     It "T24: Ensures Get-DbDocumentByVersion never returns multiple documents" {
#         $doc = [PSCustomObject]@{ Name = "TestDocument" }
#         $inserted = Add-DbDocument -Database $db -Collection $TestCollection -Data $doc

#         # Simulate multiple matching documents by inserting a duplicate VersionId
#         $TestCollection.Insert(@{ VersionId = $inserted.VersionId; Name = "Duplicate" })

#         { Add-DbDocument -Database $db -Collection $TestCollection -Data $doc } | Should -Throw
#     }