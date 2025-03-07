[NoRunspaceAffinity()]
class PhysicalAddress : LiteDbAppendOnlyDocument {
    [AddressPurpose]$AddressPurpose
    [AddressType]$AddressType
    [string]$StreetAddress1
    [string]$StreetAddress2
    [string]$Neighborhood
    [string]$County
    [string]$State
    [string]$Country
    [string]$Latitude
    [string]$Longitude

    PhysicalAddress($Database) : base($Database, 'PhysicalAddresses') {}

    PhysicalAddress($Database, [PSCustomObject]$Properties) : base($Database, 'PhysicalAddresses', $Properties) {}

}
