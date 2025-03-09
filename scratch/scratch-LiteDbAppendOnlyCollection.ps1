using module ".\ps-migration.psd1"
. ".\build.ps1"
$dbPath = ".\StoredObjects\ps-migration.db"
 
Remove-Item -Path $dbPath
Clear-Host
Import-Module .\ps-migration.psd1 -Force
Clear-Host
$dbConnectionString = New-DbConnectionString -Culture "en-US" -IgnoreCase -IgnoreNonSpace -IgnoreSymbols -ConnectionType Shared -AutoRebuild -FilePath $dbPath -Upgrade
Initialize-LiteDbDatabase -ConnectionString $dbConnectionString
$db = New-LiteDatabase -ConnectionString $dbConnectionString

$collection = Get-LiteCollection -CollectionName 'Temp' -Database $db
$store = New-LiteDbAppendOnlyCollection -Database $db -Collection $collection
$collection


Write-Host "== Versiondoc1"
$Versiondoc1 = @{
    name = 'Versiondoc1'
    test = 'data'
    dock = "inforamtion"
    store = @(1, 2, 3)
}
$Versiondoc1

Write-Host "++ hash1"
$hash1 = Get-DataHash -DataObject $Versiondoc1
$Versiondoc1['ContentId'] = $hash1.Hash
$Versiondoc1

Write-Host "== Versiondoc2"
$Versiondoc2 = [PSCustomObject]@{
    name = 'Versiondoc2'
    test = 'data2'
    dock = "inforamtion2"
}
$Versiondoc2

Write-Host "++ hash2"
$hash2 = Get-DataHash -DataObject $Versiondoc2
($Versiondoc2 | Add-Member -MemberType NoteProperty -Name "ContentId" -Value $hash2.Hash -PassThru) | Out-Null
$Versiondoc2

Write-Host "== Versiondoc3"
$Versiondoc3 = [PSCustomObject]@{
    name = 'Versiondoc3'
    test = 'data'
    dock = "inforamtion"
    store = @(1, 2, 3)
}
$Versiondoc3

# Write-Host "++ hash3"
# $hash3 = Get-DataHash -DataObject $Versiondoc3
# ($Versiondoc3 | Add-Member -MemberType NoteProperty -Name "ContentId" -Value $hash3.Hash -PassThru) | Out-Null
# $Versiondoc3

# Write-Host "== dbdoc1"
# $Versiondoc1, $Versiondoc2 | Add-LiteData -Collection $collection

# $dbdoc1 = Get-LiteData $collection -Where 'ContentId = @ContentId', @{ContentId = $Versiondoc1.ContentId}
# $dbdoc1

# Write-Host "== dbdoc2"
# $dbdoc2 = $Versiondoc2.ContentId | Get-DbDocumentByContentId -Database $db -Collection $collection
# $dbdoc2

# Write-Host "== dbdoc2 data"
# $dbdoc2 | Add-DbDocument -Database $db -Collection $collection

Write-Host "== dbdoc3 data"
$dbdoc3 = $Versiondoc3 | Add-DbDocument -Database $db -Collection $collection
$dbdoc3

Write-Host "== dbdoc3 namechange"
$nameChangeDoc = $dbdoc3.ContentId | Get-DbDocumentByContent -Database $db -Collection $collection
$nameChangeDoc.name = "dbdoc3"
$dbdoc3b = $nameChangeDoc | Add-DbDocument -Database $db -Collection $collection
$dbdoc3
$dbdoc3b

Write-Host "== dbdoc3 datachange"
$dataChangeDoc = $dbdoc3b.VersionId | Get-DbDocumentByVersionId -Database $db -Collection $collection
$dataChangeDoc.test = "Updated Data"
$dbdoc3c = $dataChangeDoc | Add-DbDocument -Database $db -Collection $collection
$dbdoc3b
$dbdoc3c

Write-Host "== Renew Objects from Db"
$dbdoc3 = $dbdoc3.VersionId | Get-DbDocumentByVersionId -Database $db -Collection $collection
$dbdoc3b = $dbdoc3b.VersionId | Get-DbDocumentByVersionId -Database $db -Collection $collection
$dbdoc3c = $dbdoc3c.VersionId | Get-DbDocumentByVersionId -Database $db -Collection $collection
$dbdoc3
$dbdoc3b
$dbdoc3c

Write-Host "== Get All Documents from Temp"
Get-DbDocumentAll -Database $db -Collection $collection

Write-Host "== Versions by Bundle - Ldbc"
$dbdoc3c.BundleId
$dbdoc3c.BundleId | Get-DbDocumentVersionsByBundle -Database $db -Collection $collection

Write-Host "== Get Next Version"
$dbdoc3b
$dbdoc3b.VersionId | Get-DbDocumentVersion -Database $db -Collection $collection -Next

Write-Host "== Get Previous Version"
$dbdoc3b
$dbdoc3b.VersionId | Get-DbDocumentVersion -Database $db -Collection $collection -Previous

Write-Host "== Get Latest Version"
$dbdoc3b
$latest = $dbdoc3b.VersionId | Get-DbDocumentVersion -Database $db -Collection $collection -Latest
$latest

Write-Host "== Get Original Version"
$dbdoc3b
$original = $dbdoc3b.VersionId | Get-DbDocumentVersion -Database $db -Collection $collection -Original
$original

Write-host "== Attempt Next, get latest"
$latest.VersionId | Get-DbDocumentVersion -Database $db -Collection $collection -Next

Write-host "== Attempt Prebvious, get original"
$original.VersionId | Get-DbDocumentVersion -Database $db -Collection $collection -Previous

Write-Host "== DbBundleRef"
$dbdoc3
New-DbBundleRef -DbDocument $dbdoc3 -Collection $collection -RefCollection $collection

Write-Host "== DbVersionRef"
$dbdoc3
New-DbVersionRef -DbDocument $dbdoc3 -Collection $collection -RefCollection $collection

Write-Host "== Allow Old VersionId in not lastest version"
$dbdoc3
$dbdoc5 = $dbdoc3 | Add-DbDocument -Database $db -Collection $collection
$dbdoc5

Write-Host "== Allow Old VersionId not in lastest version - again."
$nameChangeDoc = $dbdoc3c.VersionId | Get-DbDocumentByVersionId -Database $db -Collection $collection
$nameChangeDoc.name = "dbdoc3d"
$dbdoc3d = $nameChangeDoc | Add-DbDocument -Database $db -Collection $collection
$dbdoc3c
$dbdoc3d
$dbdoc6 = $dbdoc3 | Add-DbDocument -Database $db -Collection $collection
$dbdoc6
$dbdoc7 = $dbdoc3 | Add-DbDocument -Database $db -Collection $collection

Write-Host "++ Getting Versions"
$dbdoc7.BundleId | Get-DbDocumentVersionsByBundle -Database $db -Collection $collection

Write-Host "== Get-DbVersionRef"
$dbdoc7
$dbdoc7 | Get-DbVersionRef -Database $db -Collection $collection


Write-Host "== Resolve List of mixed documents and refs"
$Versions = $dbdoc7.BundleId | Get-DbDocumentVersionsByBundle -Database $db -Collection $collection
$Versions
Write-Host "++ resolved list"
$resolvedVersions = $dbdoc7.BundleId | Get-DbDocumentVersionsByBundle -Database $db -Collection $collection -ResolveRefs
$resolvedVersions

Write-Host "== Renew Objects from Db"
$dbdoc3 = $dbdoc3.VersionId | Get-DbDocumentByVersionId -Database $db -Collection $collection
$dbdoc3b = $dbdoc3b.VersionId | Get-DbDocumentByVersionId -Database $db -Collection $collection
$dbdoc3c = $dbdoc3c.VersionId | Get-DbDocumentByVersionId -Database $db -Collection $collection
$dbdoc3d = $dbdoc3d.VersionId | Get-DbDocumentByVersionId -Database $db -Collection $collection
$dbdoc5 = $dbdoc5.VersionId | Get-DbDocumentByVersionId -Database $db -Collection $collection
$dbdoc6 = $dbdoc6.VersionId | Get-DbDocumentByVersionId -Database $db -Collection $collection
$dbdoc7 = $dbdoc7.VersionId | Get-DbDocumentByVersionId -Database $db -Collection $collection
$dbdoc3
$dbdoc3b
$dbdoc3c
$dbdoc3d
$dbdoc5
$dbdoc6
$dbdoc7

Write-Host "== Get All Documetns from collection - resolved"
Get-DbDocumentAll -Database $db -Collection $collection -ResolveRefs

Write-Host "== Resolving a Single by VersionId"
$dbdoc7
$dbdoc7.VersionId | Get-DbDocumentByVersionId -Database $db -Collection $collection -ResolveRefs

Write-Host "== Resolving a Single by Id"
$dbdoc7
$dbdoc7._id | Get-DbDocumentById -Database $db -Collection $collection -ResolveRefs

Write-Host "== Resolving Latest"
$dbdoc3d.VersionId | Get-DbDocumentVersion -Database $db -Collection $collection -Latest
$dbdoc3d.VersionId | Get-DbDocumentVersion -Database $db -Collection $collection -Latest -ResolveRefs

Write-Host "== Testing the Class"
$store
$store.GetType() | ft
$store | Get-Member -MemberType Method -Force | ft

Write-Host "== Class Create"
Write-Host "++ Versiondoc8"
$Versiondoc8 = [PSCustomObject]@{
    name = 'Versiondoc8'
    data = 'test'
    information = "dock"
    store = @(1, "a", @{fun = "times"; number1 =1; list = @("i1", "i2", "i3")})
    # "`$Ref" = "ref"
}
$Versiondoc8 | fl
Write-Host "++ Create"
($Versiondoc8 = $store._Add($Versiondoc8)) | Out-Null
$Versiondoc8 | fl

Write-Host "++ GetVersionsByBundle"
($Versions = $store.GetVersionsByBundle($dbdoc7.BundleId)) | Out-Null
$Versions | ft

Write-Host "++ GetVersionsByBundle - Resolve `$Refs"
($Versions = $store.GetVersionsByBundle($dbdoc7.BundleId, $true)) | Out-Null
$Versions | ft

Write-Host "++ Get-DbObject"
($Versions = $store.GetDbObject($dbdoc7.BundleId)) | Out-Null
$Versions | ft

Write-Host "++ ReadAll"
($allTempDocs = $store.GetAll()) | Out-Null
$allTempDocs | ft

Write-Host "++ ReadAll - Resolve `$Refs"
($allTempDocsResolved = $store.GetAll($true)) | Out-Null
$allTempDocsResolved | ft

Write-Host "++ ReadByVersion"
($dbdoc7_VersionRead = $store.GetByVersion($dbdoc7.VersionId)) | Out-Null
$dbdoc7_VersionRead | fl

Write-Host "++ ReadByVersion - Resolve `$Refs"
($dbdoc7_VersionRead = $store.GetByVersion($dbdoc7.VersionId, $true)) | Out-Null
$dbdoc7_VersionRead | fl

Write-Host "++ ReadById"
($dbdoc7_idRead = $store.GetById($dbdoc7._id)) | Out-Null
$dbdoc7_idRead | fl

Write-Host "++ ReadById - Resolve `$Refs"
($dbdoc7_idRead = $store.GetById($dbdoc7._id, $true)) | Out-Null
$dbdoc7_idRead | fl

Write-Host "++ ReadVersion - Original"
($dbdoc3b_original = $store.GetVersion($dbdoc3b.VersionId, [dbVersionSteps]::Original)) | Out-Null
$dbdoc3b_original | fl

Write-Host "++ ReadVersion - Original - Resolve `$Refs"
($dbdoc3b_original = $store.GetVersion($dbdoc3b.VersionId, [dbVersionSteps]::Original), $true) | Out-Null
$dbdoc3b_original | fl

Write-Host "++ ReadVersion - Latest"
($dbdoc3b_original = $store.GetVersion($dbdoc3b.VersionId, [dbVersionSteps]::Latest)) | Out-Null
$dbdoc3b_original | fl

Write-Host "++ ReadVersion - Latest - Resolve `$Refs"
($dbdoc3b_original = $store.GetVersion($dbdoc3b.VersionId, [dbVersionSteps]::Latest, $true)) | Out-Null
$dbdoc3b_original | fl

Write-Host "++ ReadVersion - Previous"
($dbdoc3b_original = $store.GetVersion($dbdoc3b.VersionId, [dbVersionSteps]::Previous)) | Out-Null
$dbdoc3b_original | fl

Write-Host "++ ReadVersion - Previous - Resolve `$Refs"
($dbdoc3b_original = $store.GetVersion($dbdoc3b.VersionId, [dbVersionSteps]::Previous, $true)) | Out-Null
$dbdoc3b_original | fl

Write-Host "++ ReadVersion - Next"
($dbdoc3b_original = $store.GetVersion($dbdoc3b.VersionId, [dbVersionSteps]::Next)) | Out-Null
$dbdoc3b_original | fl

Write-Host "++ ReadVersion - Next - Resolve `$Refs"
($dbdoc3b_original = $store.GetVersion($dbdoc3b.VersionId, [dbVersionSteps]::Next, $true)) | Out-Null
$dbdoc3b_original | fl

Write-Host "++ GetVersionRef"
($VersionRef = $store.GetVersionRef($dbdoc7)) | Out-Null
# $VersionRef


Write-Host "++ Ensure Collection"
$store2 = New-LiteDbAppendOnlyCollection -Database $db -Collection 'TestCollection'
$store.Collection
$store2.Collection

Write-Host "== Change Collections"
($store.MoveDbObjectToCollection($dbdoc3.BundleId, $store2.Collection)) | Out-Null
($store2.MoveDbObjectToCollection($dbdoc3.BundleId, $store.Collection))| Out-Null

($store2.MoveDbObjectFromCollection($dbdoc3.BundleId, $store.Collection)) | Out-Null

Write-host "== Get a DbObject"
($Versiondoc9 = $store.GetByVersion($Versiondoc8.VersionId)) | Out-Null
$Versiondoc9.data = "more test data"
($Versiondoc9 = $store._Add($Versiondoc9)) | Out-Null

($Versiondoc10 = $store.GetByVersion($Versiondoc9.VersionId)) | Out-Null
$Versiondoc10.data = "test"
($Versiondoc10 = $store._Add($Versiondoc10)) | Out-Null

($Versiondoc11 = $store.GetByVersion($Versiondoc10.VersionId, $true)) | Out-Null
$Versiondoc11.data = "even more test data"
($Versiondoc11 = $store._Add($Versiondoc11)) | out-null

($dbObj1 = $store.GetDbObject($Versiondoc11.BundleId)) 
# $dbObj1 | fl

Write-Host "== Recycle DbObject"
($store.RecycleDbObject($dbObj1)) | Out-Null
$RecycleBin = New-LiteDbAppendOnlyCollection -Database $db -Collection 'RecycleBin'
($recycledObj1 = ($RecycleBin.GetDbObject($Versiondoc11.BundleId))) | Out-Null
$recycledObj1.GetType()

$store2.RecycleDbObject($dbdoc3.BundleId)

$store.RestoreDbObject($recycledObj1[0].BundleId)

$store.RecycleDbObject($recycledObj1)

# $store.EmptyRecycleBin($recycledObj1[0].BundleId)

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

$store2.CommitDbDocAsDbObject($stagedDoc1.BundleId)
# $store2.ClearTemp($stagedDoc2.BundleId)
# $store2.ClearTemp()

# $stagedDoc1.Version
# $store2.VersionExists($stagedDoc1.VersionId)
# $store2.BundleExists($stagedDoc1.BundleId)
# # $store2.CommitAllDbDocAsDbObject()

Write-Host "++ GetBundleRef"
($newDbBundleRef = New-DbBundleRef -Collection $collection -RefCollection $collection -DbDocument $dbdoc3) | Out-Null
($newDbBundleRef = $newDbBundleRef | Add-DbDocument -Database $db -Collection $collection) | Out-Null
($BundleRef = $store2.GetBundleRef($newDbBundleRef)) | Out-Null
$BundleRef