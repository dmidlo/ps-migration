function Set-dbHost {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [LiteDB.LiteDatabase]$Connection,
        [string]$Guid,
        [string]$ChassisSerial,
        [hashtable[]]$Interfaces,
        [hashtable[]]$NetworkNames,
        [switch]$Temp,
        [Parameter(ValueFromPipeline)]
        [hashtable]$Properties
    )

    process {
        $now = [DateTimeOffset]::UtcNow.ToUnixTimeMilliseconds()

        function GuidFilter {
            if ($Guid) {
                return $Guid
            }
            elseif ($Properties -and $Properties['Guid']) {
                return $Properties['Guid']
            }
            else {
                return [guid]::NewGuid()
            }
        }

        function TypeFilter {
            if ($Type) {
                return $Type
            }
            elseif ($Properties -and $Properties['Type']) {
                return $Properties['Type']
            }
            else {
                return "basicHost"
            }
        }

        function ChassisSerialFilter {
            if ($ChassisSerial) {
                return $ChassisSerial
            }
            elseif ($Properties -and $Properties['ChassisSerial']) {
                return $Properties['ChassisSerial']
            }
            else {
                return ""
            }
        }

        function InterfacesFilter {
            if($Properties -and ($Interfaces -and $Properties['Interfaces'])) {
                return Merge-Arrays -Arrays @($Interfaces, $Properties['Interfaces'])
            }
            elseif($Interfaces) {
                return $Interfaces
            } 
            elseif($Properties -and $Properties['Interfaces']) {
                return $Properties['Interfaces']
            }
            else {
                return @()
            }
        }

        function NetworkNamesFilter {
            if($Properties -and ($NetworkNames -and $Properties['NetworkNames'])) {
                return Merge-Arrays -Arrays @($NetworkNames, $Properties['NetworkNames'])
            }
            elseif($NetworkNames) {
                return $NetworkNames
            } 
            elseif($Properties -and $Properties['NetworkNames']) {
                return $Properties['NetworkNames']
            }
            else {
                return @()
            }
        }

        $dbHost = [ordered]@{
            Guid               = (GuidFilter)
            Type               = (TypeFilter)
            ChassisSerial      = (ChassisSerialFilter)
            Interfaces         = (InterfacesFilter)
            NetworkNames       = (NetworkNamesFilter)
        }

        # Update timestamp
        if ($dbHost['META_UTCCreated']) {
            $dbHost['META_UTCUpdated'] = $now
        }
        else {
            $dbHost['META_UTCCreated'] = $now
            $dbHost['META_UTCUpdated'] = $now
        }

        if ($Temp) {
            $dbHost = Add-DbDocument -CollectionName "Temp" -Connection $Connection -Data $dbHost
        } else {
            $dbHost = Add-DbDocument -CollectionName "Hosts" -Connection $Connection -Data $dbHost
        }

        Write-Output $dbHost
    }
}
#endregion Set-dbHost