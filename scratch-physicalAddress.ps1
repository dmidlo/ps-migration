
using module ".\ps-migration.psd1"
. ".\build.ps1"
$dbPath = ".\StoredObjects\ps-migration.db"
 
Remove-Item -Path $dbPath
Clear-Host
Import-Module .\ps-migration.psd1 -Force
Clear-Host
$dbConnectionString = New-DbConnectionString -Culture "en-US" -IgnoreCase -IgnoreNonSpace -IgnoreSymbols -ConnectionType Shared -AutoRebuild -FilePath $dbPath -Upgrade
Initialize-DB -ConnectionString $dbConnectionString
$db = New-LiteDatabase -ConnectionString $dbConnectionString

$PhysicalAddresses = New-LiteDbAppendOnlyCollection -Database $db -Collection "PhysicalAddresses"

$address1 = [PSCustomObject]@{
    AddressPurpose = [AddressPurpose]::Billing
    AddressType = [AddressType]::Commercial
    StreetAddress1 = "123 honeydew dr"
    StreetAddress2 = "Ste 100"
    Neighborhood = "Havenview"
    County = "Ramsey"
    State = "MN"
    Country = "USA"
    Latitude = ""
    Longitude = ""
}

$dbAddress = New-PhysicalAddress -Database $db
# $dbAddress | Get-Member | ft
# $dbAddress

Write-Host "== FromPS"
$dbAddress1 = New-PhysicalAddress -Database $db -PSCustomObject $address1
# $dbAddress1
# $dbAddress1.GetType() | ft

Write-Host "== ToPS"
$dbAddress1ps = $dbAddress1.ToPS()
# $dbAddress1ps
# $dbAddress1ps.GetType() | ft

Write-Host "== Stage"
$dbAddress1.Stage()
$dbAddress1.StreetAddress2 = "Ste 99"
$dbAddress1.Stage()
$dbaddress1.StreetAddress2 = "Ste 98"
$dbAddress1.Stage()
$dbAddress1.StreetAddress2 = "Ste 100"
$dbAddress1.Stage()
$dbAddress1.Commit()
$dbAddress1.StreetAddress2 = "Ste 101"
$dbAddress1.Stage() | Out-Null
$dbAddress1.Commit() | Out-Null
$dbAddress1.StreetAddress2 = "Ste 100"
$dbAddress1.Stage() | Out-Null
$dbAddress1.Commit() | Out-Null
$dbAddress1.StreetAddress2 = "Ste 102"
$dbAddress1.Stage() | Out-Null
$dbAddress1.Commit() | Out-Null
# $dbAddress1.StreetAddress2 = "Ste 101"
# $dbAddress1.Stage() | Out-Null
# $dbAddress1.Commit() | Out-Null
# $dbAddress1.StreetAddress2 = "Ste 103"
# $dbAddress1.Stage()
# $dbAddress1.StreetAddress2 = "Ste 100"
# $dbAddress1.Stage()
# Write-Host "== Commit"
# $dbAddress2 = New-PhysicalAddress -Database $db -PSCustomObject $address1
# $dbAddress2.Stage()
# $dbAddress2.Commit()