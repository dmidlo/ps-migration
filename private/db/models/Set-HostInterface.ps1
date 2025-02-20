function Set-HostInterface {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        $Connection,
        [string]$Guid,
        [string]$HostGuid, 
        [string]$InterfaceName,
        [string]$MacAddress,
        [string[]]$IPAddresses,
        [switch]$Temp,
        [Parameter(ValueFromPipeline)]
        [hashtable]$Properties
    )

    process {
        $now = [DateTimeOffset]::UtcNow.ToUnixTimeMilliseconds()

        if ($Properties -and ($Properties.Type -like "*Interface")) {
            Write-Output $Properties
        }
        elseif ($Properties -and ($Properties.Type -like "*Host")) {
            Write-Output $Properties
        }
        elseif ($Properties) {
            Write-Output $Properties
        }
        else {
            
        }




        # $IsHost = $false

        # foreach ($key in $Properties.Keys) {
        #     if ($key -like "Interfaces") {
        #         $IsHost = $true
        #     }
        # }

        # function GuidFilter {
        #     if ($Guid) {
        #         return $Guid
        #     }
        #     elseif ((-not $IsHost) -and ($Properties -and $Properties['Guid'])) {
        #         return $Properties['Guid']
        #     }
        #     else {
        #         return [guid]::NewGuid()
        #     }
        # }

        # function TypeFilter {
        #     if ($Type) {
        #         return $Type
        #     }
        #     elseif ($Properties -and $Properties['Type']) {
        #         return $Properties['Type']
        #     }
        #     else {
        #         return "Interface"
        #     }
        # }

        # function HostGuidFilter {
        #     if ($HostGuid) {
        #         return $HostGuid
        #     }
        #     elseif ($Properties -and $Properties['HostGuid']) {
        #         return $Properties['HostGuid']
        #     }
        #     else {
        #         return ""
        #     }
        # }

        # function InterfaceNameFilter {
        #     if ($InterfaceName) {
        #         return $InterfaceName
        #     }
        #     elseif ($Properties -and $Properties['InterfaceName']) {
        #         return $Properties['InterfaceName']
        #     }
        #     else {
        #         return ""
        #     }
        # }

        # function MacAddressFilter {
        #     if ($MacAddress) {
        #         return $MacAddress
        #     }
        #     elseif ($Properties -and $Properties['MacAddress']) {
        #         return $Properties['MacAddress']
        #     }
        #     else {
        #         return ""
        #     }
        # }

        # function IPAddressesFilter {
        #     if($Properties -and ($IPAddresses -and $Properties['IPAddresses'])) {
        #         return Merge-Arrays -Arrays @($IPAddresses, $Properties['IPAddresses'])
        #     }
        #     elseif($IPAddresses) {
        #         return $IPAddresses
        #     } 
        #     elseif($Properties -and $Properties['IPAddresses']) {
        #         return $Properties['IPAddresses']
        #     }
        #     else {
        #         return @()
        #     }
        # }


        # # Create a new host interface object
        # $HostInterface = [ordered]@{
        #     Guid          = (GuidFilter)
        #     HostGuid      = (HostGuidFilter)
        #     InterfaceName = (InterfaceNameFilter)
        #     MacAddress    = (MacAddressFilter)
        #     IPAddresses   = (IPAddressesFilter)
        # }

        # # Update timestamp
        # if ($HostInterface['META_UTCCreated']) {
        #     $HostInterface['META_UTCUpdated'] = $now
        # }
        # else {
        #     $HostInterface['META_UTCCreated'] = $now
        #     $HostInterface['META_UTCUpdated'] = $now
        # }

        # if ($IsHost) {
        #     $HostInterface['HostGuid'] = New-DBRef -ID $Properties['Guid'] -CollectionName "Hosts"

        #     $Properties['Interfaces'] += $HostInterface
            
        #     Write-Output $Properties
        # } else {
        #     Write-Output $HostInterface
        # }
    }
}