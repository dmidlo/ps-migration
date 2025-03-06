using module ".\ps-migration.psd1"
$dbPath = ".\StoredObjects\ps-migration.db"
 
Remove-Item -Path $dbPath
Clear-Host
Import-Module .\ps-migration.psd1 -Force
Clear-Host
$dbConnectionString = New-DbConnectionString -Culture "en-US" -IgnoreCase -IgnoreNonSpace -IgnoreSymbols -ConnectionType Shared -AutoRebuild -FilePath $dbPath -Upgrade
Initialize-DB -ConnectionString $dbConnectionString
$db = New-LiteDatabase -ConnectionString $dbConnectionString

$collection = Get-LiteCollection -CollectionName 'Temp' -Database $db
$store = New-LiteDbAppendOnlyCollection -Database $db -Collection $collection
$collection


Write-Host "== hashdoc1"
$hashdoc1 = @{
    name = 'hashdoc1'
    test = 'data'
    dock = "inforamtion"
    store = @(1, 2, 3)
}
$hashdoc1

Write-Host "++ hash1"
$hash1 = Get-DataHash -DataObject $hashdoc1
$hashdoc1['Hash'] = $hash1.Hash
$hashdoc1

Write-Host "== hashdoc2"
$hashdoc2 = [PSCustomObject]@{
    name = 'hashdoc2'
    test = 'data2'
    dock = "inforamtion2"
}
$hashdoc2

Write-Host "++ hash2"
$hash2 = Get-DataHash -DataObject $hashdoc2
($hashdoc2 | Add-Member -MemberType NoteProperty -Name "Hash" -Value $hash2.Hash -PassThru) | Out-Null
$hashdoc2

Write-Host "== hashdoc3"
$hashdoc3 = [PSCustomObject]@{
    name = 'hashdoc3'
    test = 'data'
    dock = "inforamtion"
    store = @(1, 2, 3)
}
$hashdoc3

# Write-Host "++ hash3"
# $hash3 = Get-DataHash -DataObject $hashdoc3
# ($hashdoc3 | Add-Member -MemberType NoteProperty -Name "Hash" -Value $hash3.Hash -PassThru) | Out-Null
# $hashdoc3

# Write-Host "== dbdoc1"
# $hashdoc1, $hashdoc2 | Add-LiteData -Collection $collection

# $dbdoc1 = Get-LiteData $collection -Where 'Hash = @Hash', @{Hash = $hashdoc1.Hash}
# $dbdoc1

# Write-Host "== dbdoc2"
# $dbdoc2 = $hashdoc2.Hash | Get-DbDocumentByHash -Database $db -Collection $collection
# $dbdoc2

# Write-Host "== dbdoc2 data"
# $dbdoc2 | Add-DbDocument -Database $db -Collection $collection

Write-Host "== dbdoc3 data"
$dbdoc3 = $hashdoc3 | Add-DbDocument -Database $db -Collection $collection
$dbdoc3

Write-Host "== dbdoc3 namechange"
$nameChangeDoc = $dbdoc3.Hash | Get-DbDocumentByHash -Database $db -Collection $collection
$nameChangeDoc.name = "dbdoc3"
$dbdoc3b = $nameChangeDoc | Add-DbDocument -Database $db -Collection $collection
$dbdoc3
$dbdoc3b

Write-Host "== dbdoc3 datachange"
$dataChangeDoc = $dbdoc3b.Hash | Get-DbDocumentByHash -Database $db -Collection $collection
$dataChangeDoc.test = "Updated Data"
$dbdoc3c = $dataChangeDoc | Add-DbDocument -Database $db -Collection $collection
$dbdoc3b
$dbdoc3c

Write-Host "== Renew Objects from Db"
$dbdoc3 = $dbdoc3.Hash | Get-DbDocumentByHash -Database $db -Collection $collection
$dbdoc3b = $dbdoc3b.Hash | Get-DbDocumentByHash -Database $db -Collection $collection
$dbdoc3c = $dbdoc3c.Hash | Get-DbDocumentByHash -Database $db -Collection $collection
$dbdoc3
$dbdoc3b
$dbdoc3c

Write-Host "== Get All Documents from Temp"
Get-DbDocumentAll -Database $db -Collection $collection

Write-Host "== Versions by Guid - Ldbc"
$dbdoc3c.Guid
$dbdoc3c.Guid | Get-DbDocumentVersionsByGuid -Database $db -Collection $collection

Write-Host "== Get Next Version"
$dbdoc3b
$dbdoc3b.Hash | Get-DbDocumentVersion -Database $db -Collection $collection -Next

Write-Host "== Get Previous Version"
$dbdoc3b
$dbdoc3b.Hash | Get-DbDocumentVersion -Database $db -Collection $collection -Previous

Write-Host "== Get Latest Version"
$dbdoc3b
$latest = $dbdoc3b.Hash | Get-DbDocumentVersion -Database $db -Collection $collection -Latest
$latest

Write-Host "== Get Original Version"
$dbdoc3b
$original = $dbdoc3b.Hash | Get-DbDocumentVersion -Database $db -Collection $collection -Original
$original

Write-host "== Attempt Next, get latest"
$latest.Hash | Get-DbDocumentVersion -Database $db -Collection $collection -Next

Write-host "== Attempt Prebvious, get original"
$original.Hash | Get-DbDocumentVersion -Database $db -Collection $collection -Previous

Write-Host "== DbGuidRef"
$dbdoc3
New-DbGuidRef -DbDocument $dbdoc3 -Collection $collection -RefCollection $collection

Write-Host "== DbHashRef"
$dbdoc3
New-DbHashRef -DbDocument $dbdoc3 -Collection $collection -RefCollection $collection

Write-Host "== Allow Old hash in not lastest version"
$dbdoc3
$dbdoc5 = $dbdoc3 | Add-DbDocument -Database $db -Collection $collection
$dbdoc5

Write-Host "== Allow Old hash not in lastest version - again."
$nameChangeDoc = $dbdoc3c.Hash | Get-DbDocumentByHash -Database $db -Collection $collection
$nameChangeDoc.name = "dbdoc3d"
$dbdoc3d = $nameChangeDoc | Add-DbDocument -Database $db -Collection $collection
$dbdoc3c
$dbdoc3d
$dbdoc6 = $dbdoc3 | Add-DbDocument -Database $db -Collection $collection
$dbdoc6
$dbdoc7 = $dbdoc3 | Add-DbDocument -Database $db -Collection $collection

Write-Host "++ Getting Versions"
$dbdoc7.Guid | Get-DbDocumentVersionsByGuid -Database $db -Collection $collection

Write-Host "== Get-DbHashRef"
$dbdoc7
$dbdoc7 | Get-DbHashRef -Database $db -Collection $collection


Write-Host "== Resolve List of mixed documents and refs"
$Versions = $dbdoc7.Guid | Get-DbDocumentVersionsByGuid -Database $db -Collection $collection
$Versions
Write-Host "++ resolved list"
$resolvedVersions = $dbdoc7.Guid | Get-DbDocumentVersionsByGuid -Database $db -Collection $collection -ResolveRefs
$resolvedVersions

Write-Host "== Renew Objects from Db"
$dbdoc3 = $dbdoc3.Hash | Get-DbDocumentByHash -Database $db -Collection $collection
$dbdoc3b = $dbdoc3b.Hash | Get-DbDocumentByHash -Database $db -Collection $collection
$dbdoc3c = $dbdoc3c.Hash | Get-DbDocumentByHash -Database $db -Collection $collection
$dbdoc3d = $dbdoc3d.Hash | Get-DbDocumentByHash -Database $db -Collection $collection
$dbdoc5 = $dbdoc5.Hash | Get-DbDocumentByHash -Database $db -Collection $collection
$dbdoc6 = $dbdoc6.Hash | Get-DbDocumentByHash -Database $db -Collection $collection
$dbdoc7 = $dbdoc7.Hash | Get-DbDocumentByHash -Database $db -Collection $collection
$dbdoc3
$dbdoc3b
$dbdoc3c
$dbdoc3d
$dbdoc5
$dbdoc6
$dbdoc7

Write-Host "== Get All Documetns from collection - resolved"
Get-DbDocumentAll -Database $db -Collection $collection -ResolveRefs

Write-Host "== Resolving a Single by Hash"
$dbdoc7
$dbdoc7.Hash | Get-DbDocumentByHash -Database $db -Collection $collection -ResolveRefs

Write-Host "== Resolving a Single by Id"
$dbdoc7
$dbdoc7._id | Get-DbDocumentById -Database $db -Collection $collection -ResolveRefs

Write-Host "== Resolving Latest"
$dbdoc3d.Hash | Get-DbDocumentVersion -Database $db -Collection $collection -Latest
$dbdoc3d.Hash | Get-DbDocumentVersion -Database $db -Collection $collection -Latest -ResolveRefs

Write-Host "== Testing the Class"
$store
$store.GetType() | ft
$store | Get-Member -MemberType Method -Force | ft

Write-Host "== Class Create"
Write-Host "++ hashdoc8"
$hashdoc8 = [PSCustomObject]@{
    name = 'hashdoc8'
    data = 'test'
    information = "dock"
    store = @(1, "a", @{fun = "times"; number1 =1; list = @("i1", "i2", "i3")})
    # "`$Ref" = "ref"
}
$hashdoc8 | fl
Write-Host "++ Create"
($hashdoc8 = $store._Add($hashdoc8)) | Out-Null
$hashdoc8 | fl

Write-Host "++ GetVersionsByGuid"
($Versions = $store.GetVersionsByGuid($dbdoc7.Guid)) | Out-Null
$Versions | ft

Write-Host "++ GetVersionsByGuid - Resolve `$Refs"
($Versions = $store.GetVersionsByGuid($dbdoc7.Guid, $true)) | Out-Null
$Versions | ft

Write-Host "++ Get-DbObject"
($Versions = $store.GetDbObject($dbdoc7.Guid)) | Out-Null
$Versions | ft

Write-Host "++ ReadAll"
($allTempDocs = $store.GetAll()) | Out-Null
$allTempDocs | ft

Write-Host "++ ReadAll - Resolve `$Refs"
($allTempDocsResolved = $store.GetAll($true)) | Out-Null
$allTempDocsResolved | ft

Write-Host "++ ReadByHash"
($dbdoc7_hashRead = $store.GetByHash($dbdoc7.Hash)) | Out-Null
$dbdoc7_hashRead | fl

Write-Host "++ ReadByHash - Resolve `$Refs"
($dbdoc7_hashRead = $store.GetByHash($dbdoc7.Hash, $true)) | Out-Null
$dbdoc7_hashRead | fl

Write-Host "++ ReadById"
($dbdoc7_idRead = $store.GetById($dbdoc7._id)) | Out-Null
$dbdoc7_idRead | fl

Write-Host "++ ReadById - Resolve `$Refs"
($dbdoc7_idRead = $store.GetById($dbdoc7._id, $true)) | Out-Null
$dbdoc7_idRead | fl

Write-Host "++ ReadVersion - Original"
($dbdoc3b_original = $store.GetVersion($dbdoc3b.Hash, [dbVersionSteps]::Original)) | Out-Null
$dbdoc3b_original | fl

Write-Host "++ ReadVersion - Original - Resolve `$Refs"
($dbdoc3b_original = $store.GetVersion($dbdoc3b.Hash, [dbVersionSteps]::Original), $true) | Out-Null
$dbdoc3b_original | fl

Write-Host "++ ReadVersion - Latest"
($dbdoc3b_original = $store.GetVersion($dbdoc3b.Hash, [dbVersionSteps]::Latest)) | Out-Null
$dbdoc3b_original | fl

Write-Host "++ ReadVersion - Latest - Resolve `$Refs"
($dbdoc3b_original = $store.GetVersion($dbdoc3b.Hash, [dbVersionSteps]::Latest, $true)) | Out-Null
$dbdoc3b_original | fl

Write-Host "++ ReadVersion - Previous"
($dbdoc3b_original = $store.GetVersion($dbdoc3b.Hash, [dbVersionSteps]::Previous)) | Out-Null
$dbdoc3b_original | fl

Write-Host "++ ReadVersion - Previous - Resolve `$Refs"
($dbdoc3b_original = $store.GetVersion($dbdoc3b.Hash, [dbVersionSteps]::Previous, $true)) | Out-Null
$dbdoc3b_original | fl

Write-Host "++ ReadVersion - Next"
($dbdoc3b_original = $store.GetVersion($dbdoc3b.Hash, [dbVersionSteps]::Next)) | Out-Null
$dbdoc3b_original | fl

Write-Host "++ ReadVersion - Next - Resolve `$Refs"
($dbdoc3b_original = $store.GetVersion($dbdoc3b.Hash, [dbVersionSteps]::Next, $true)) | Out-Null
$dbdoc3b_original | fl

Write-Host "++ GetHashRef"
($hashRef = $store.GetHashRef($dbdoc7)) | Out-Null
# $hashRef


Write-Host "++ Ensure Collection"
$store2 = New-LiteDbAppendOnlyCollection -Database $db -Collection 'TestCollection'
$store.Collection
$store2.Collection

Write-Host "== Change Collections"
($store.MoveDbObjectToCollection($dbdoc3.Guid, $store2.Collection)) | Out-Null
($store2.MoveDbObjectToCollection($dbdoc3.Guid, $store.Collection))| Out-Null

($store2.MoveDbObjectFromCollection($dbdoc3.Guid, $store.Collection)) | Out-Null

Write-host "== Get a DbObject"
($hashdoc9 = $store.GetByHash($hashdoc8.Hash)) | Out-Null
$hashdoc9.data = "more test data"
($hashdoc9 = $store._Add($hashdoc9)) | Out-Null

($hashdoc10 = $store.GetByHash($hashdoc9.Hash)) | Out-Null
$hashdoc10.data = "test"
($hashdoc10 = $store._Add($hashdoc10)) | Out-Null

($hashdoc11 = $store.GetByHash($hashdoc10.Hash, $true)) | Out-Null
$hashdoc11.data = "even more test data"
($hashdoc11 = $store._Add($hashdoc11)) | out-null

($dbObj1 = $store.GetDbObject($hashdoc11.Guid)) 
# $dbObj1 | fl

Write-Host "== Recycle DbObject"
($store.RecycleDbObject($dbObj1)) | Out-Null
$RecycleBin = New-LiteDbAppendOnlyCollection -Database $db -Collection 'RecycleBin'
($recycledObj1 = ($RecycleBin.GetDbObject($hashdoc11.Guid))) | Out-Null
$recycledObj1.GetType()

$store2.RecycleDbObject($dbdoc3.Guid)

$store.RestoreDbObject($recycledObj1[0].Guid)

$store.RecycleDbObject($recycledObj1)

# $store.EmptyRecycleBin($recycledObj1[0].Guid)

# $store2.EmptyRecycleBin()

$storeDoc1 = [PSCustomObject]@{
    Name1 = "Value1"
    Name2 = "Value2"
    Name3 = "Value3"
}

$stagedDoc1 = $store2.StageDbObjectDocument($storeDoc1)
$stagedDoc1.Name1 = "Value4"
$stagedDoc1 = $store2.StageDbObjectDocument($stagedDoc1)
$stagedDoc1.Name2 = "Value5"
$stagedDoc1 = $store2.StageDbObjectDocument($stagedDoc1)
$stagedDoc1.Name3 = "Value6"
$stagedDoc1 = $store2.StageDbObjectDocument($stagedDoc1)

$storeDoc2 = [PSCustomObject]@{
    Name1 = "Value7"
    Name2 = "Value8"
    Name3 = "Value9"
}

$stagedDoc2 = $store2.StageDbObjectDocument($storeDoc2)
$stagedDoc2 = $store2.StageDbObjectDocument($storeDoc2)
$stagedDoc2.Name1 = "Value10"
$stagedDoc2 = $store2.StageDbObjectDocument($stagedDoc2)
$stagedDoc2.Name2 = "Value11"
$stagedDoc2 = $store2.StageDbObjectDocument($stagedDoc2)
$stagedDoc2.Name3 = "Value12"
$stagedDoc2 = $store2.StageDbObjectDocument($stagedDoc2)

$storeDoc3 = [PSCustomObject]@{
    Name1 = "Value13"
    Name2 = "Value14"
    Name3 = "Value15"
}

$stagedDoc3 = $store2.StageDbObjectDocument($storeDoc3)
$stagedDoc3.Name1 = "Value16"
$stagedDoc3 = $store2.StageDbObjectDocument($stagedDoc3)
$stagedDoc3.Name2 = "Value17"
$stagedDoc3 = $store2.StageDbObjectDocument($stagedDoc3)
$stagedDoc3.Name3 = "Value18"
$stagedDoc3 = $store2.StageDbObjectDocument($stagedDoc3)

$storeDoc4 = [PSCustomObject]@{
    Name1 = "Value19"
    Name2 = "Value20"
    Name3 = "Value21"
}

$stagedDoc4 = $store2.StageDbObjectDocument($storeDoc4)
$stagedDoc4.Name1 = "Value22"
$stagedDoc4 = $store2.StageDbObjectDocument($stagedDoc4)
$stagedDoc4.Name2 = "Value23"
$stagedDoc4 = $store2.StageDbObjectDocument($stagedDoc4)
$stagedDoc4.Name3 = "Value24"
$stagedDoc4 = $store2.StageDbObjectDocument($stagedDoc4)

$store2.CommitDbDocAsDbObject($stagedDoc1.Guid)
# $store2.ClearTemp($stagedDoc2.Guid)
# $store2.ClearTemp()

# $stagedDoc1.Hash
# $store2.HashExists($stagedDoc1.Hash)
# $store2.GuidExists($stagedDoc1.Guid)
# # $store2.CommitAllDbDocAsDbObject()

Write-Host "++ GetGuidRef"
($newDbGuidRef = New-DbGuidRef -Collection $collection -RefCollection $collection -DbDocument $dbdoc3) | Out-Null
($newDbGuidRef = $newDbGuidRef | Add-DbDocument -Database $db -Collection $collection) | Out-Null
($guidRef = $store2.GetGuidRef($newDbGuidRef)) | Out-Null
$guidRef