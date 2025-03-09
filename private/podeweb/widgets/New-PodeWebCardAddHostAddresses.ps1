Function New-PodeWebCardAddHostAddresses {
    New-PodeWebCard -Name "AddHostAddresses" -DisplayName "Add Host Addresses" -Content @(
        New-PodeWebGrid -Width 2 -Cells @(
            New-PodeWebCell -Content @(
                New-PodeWebTextbox -DisplayName "Chassis Serial Number" -Name "ChassisSerial" -PrependIcon "barcode" -HelpText "ABC123456789"
            )
            New-PodeWebCell -Content @(
                New-PodeWebTextbox -DisplayName "MAC Address" -Name "MacAddress" -PrependIcon "ethernet" -HelpText "00:1A:2B:3C:4D:5E"
            )
            New-PodeWebCell -Content @(
                New-PodeWebTextbox -DisplayName "IPv4 Address" -Name "IPv4Address" -PrependIcon "ip-network-outline" -HelpText "192.168.1.1"
            )
            New-PodeWebCell -Content @(
                New-PodeWebTextbox -DisplayName "IPv4 CIDR" -Name "IPv4CIDR" -PrependIcon "ip-network" -HelpText "24" -AutoComplete {
                    $IPv4CIDRs = (1..32) | ForEach-Object { "$_" }

                    return $IPv4CIDRs
                }
            )
        )
        New-PodeWebTextbox -DisplayName "Hostname" -Name "Hostname" -PrependIcon "monitor" -HelpText "my-computer, MYCOMPUTER.local, my-computer.mydomain.com. (FQDN is best.)"
        # New-PodeWebTextbox -DisplayName "IPv6 Address" -Name "IPv6Address" -PrependIcon "server-network" -HelpText "2001:db8::1"
        # New-PodeWebTextbox -DisplayName "IPv6 CIDR" -Name "IPv6CIDR" -PrependIcon "file-document-outline" -HelpText "2001:db8::/32"
        # New-PodeWebTextbox -DisplayName "DUID (DHCP Unique Identifier - IPv6)" -Name "DUID" -PrependIcon "router-network" -HelpText "00:03:00:01:aa:bb:cc:dd:ee:ff"
        # New-PodeWebTextbox -DisplayName "EUI-64 (Extended Unique Identifier - IPv6/IEEE 802)" -Name "EUI64" -PrependIcon "chip" -HelpText "00-1A-2B-FF-FE-3C-4D-5E"
        # New-PodeWebTextbox -DisplayName "Bluetooth Device Address (BD_ADDR)" -Name "BD_ADDR" -PrependIcon "bluetooth" -HelpText "00:1B:44:11:3A:B7"
        # New-PodeWebTextbox -DisplayName "iSCSI Qualified Name (IQN)" -Name "IQN" -PrependIcon "harddisk" -HelpText "iqn.1991-05.com.example:storage.disk1"
        # New-PodeWebTextbox -DisplayName "WWN (World Wide Name - Fibre Channel)" -Name "WWN" -PrependIcon "link-variant" -HelpText "50:0a:09:81:02:3b:8c:7d"
        # New-PodeWebTextbox -DisplayName "UUID (Universally Unique Identifier)" -Name "UUID" -PrependIcon "fingerprint" -HelpText "550e8400-e29b-41d4-a716-446655440000"
        # New-PodeWebTextbox -DisplayName "GUID (Globally Unique Identifier)" -Name "GUID" -PrependIcon "key-variant" -HelpText "3F2504E0-4F89-41D3-9A0C-0305E82C3301"
        # New-PodeWebTextbox -DisplayName "NAA (Network Address Authority - Storage)" -Name "NAA" -PrependIcon "database" -HelpText "0x5000A72030098A27"
        # New-PodeWebTextbox -DisplayName "IMSI (International Mobile Subscriber Identity)" -Name "IMSI" -PrependIcon "cellphone-wireless" -HelpText "310150123456789"
        # New-PodeWebTextbox -DisplayName "IMEI (International Mobile Equipment Identity)" -Name "IMEI" -PrependIcon "cellphone-settings" -HelpText "356938035643809"
        # New-PodeWebTextbox -DisplayName "UPN (User Principal Name - Active Directory)" -Name "UPN" -PrependIcon "account" -HelpText "user@example.com"
        # New-PodeWebTextbox -DisplayName "URN (Uniform Resource Name)" -Name "URN" -PrependIcon "link" -HelpText "urn:isbn:0451450523"
        # New-PodeWebTextbox -DisplayName "ORCID (Open Researcher and Contributor ID)" -Name "ORCID" -PrependIcon "book-account" -HelpText "0000-0002-1825-0097"
        # New-PodeWebTextbox -DisplayName "DUNS (Data Universal Numbering System - Business)" -Name "DUNS" -PrependIcon "domain" -HelpText "123456789"
        # New-PodeWebTextbox -DisplayName "ARIN Handle (American Registry for Internet Numbers)" -Name "ARINHandle" -PrependIcon "web" -HelpText "JDOE-ARIN"
        # New-PodeWebTextbox -DisplayName "Grid ID (Global Research Identifier Database)" -Name "GridID" -PrependIcon "database-outline" -HelpText "grid.12345.67"
        # New-PodeWebTextbox -DisplayName "PURL (Persistent Uniform Resource Locator)" -Name "PURL" -PrependIcon "link-box" -HelpText "http://purl.org/example/resource"
        # New-PodeWebTextbox -DisplayName "EAN (European Article Number)" -Name "EAN" -PrependIcon "barcode-scan" -HelpText "4006381333931"
        # New-PodeWebTextbox -DisplayName "ISIN (International Securities Identification Number)" -Name "ISIN" -PrependIcon "finance" -HelpText "US0378331005"
        # New-PodeWebTextbox -DisplayName "LEI (Legal Entity Identifier)" -Name "LEI" -PrependIcon "domain" -HelpText "54930084UKLVMY22DS16"
        # New-PodeWebTextbox -DisplayName "GS1 GIAI (Global Individual Asset Identifier)" -Name "GS1GIAI" -PrependIcon "package-variant" -HelpText "123456789012345678"
        # New-PodeWebTextbox -DisplayName "GS1 GSRN (Global Service Relation Number)" -Name "GS1GSRN" -PrependIcon "account-supervisor" -HelpText "1234567890123"
        # New-PodeWebTextbox -DisplayName "GS1 SSCC (Serial Shipping Container Code)" -Name "GS1SSCC" -PrependIcon "truck-delivery" -HelpText "123456789012345678"
        # New-PodeWebTextbox -DisplayName "GS1 GTIN (Global Trade Item Number)" -Name "GS1GTIN" -PrependIcon "barcode" -HelpText "0123456789012"
        # New-PodeWebTextbox -DisplayName "GLN (Global Location Number)" -Name "GLN" -PrependIcon "map-marker" -HelpText "1234567890123"
        # New-PodeWebTextbox -DisplayName "DID (Decentralized Identifier)" -Name "DID" -PrependIcon "lock-outline" -HelpText "did:example:123456789abcdefghi"
        # New-PodeWebTextbox -DisplayName "XRI (Extensible Resource Identifier)" -Name "XRI" -PrependIcon "xml" -HelpText "xri://@example*resource"
        # New-PodeWebTextbox -DisplayName "SHA-1 Hash Fingerprint" -Name "SHA1" -PrependIcon "fingerprint" -HelpText "3f786850e387550fdab836ed7e6dc881de23001b"
        # New-PodeWebTextbox -DisplayName "SHA-256 Hash Fingerprint" -Name "SHA256" -PrependIcon "fingerprint" -HelpText "d2d2d0d0c4e8b1641e379f9a437ea702f7a6d3b4f658c3f4a49b6c6d73cb49fd"
        # New-PodeWebTextbox -DisplayName "PGP Key Fingerprint" -Name "PGPFingerprint" -PrependIcon "key" -HelpText "6F3F6C89DDF1F32A3EEC53E5A1C47C6C982DF1E9"
        # New-PodeWebTextbox -DisplayName "SPKI (Subject Public Key Info) Fingerprint" -Name "SPKIFingerprint" -PrependIcon "certificate" -HelpText "sha256-base64:abcdef1234567890abcdef1234567890abcdef1234567890"
    )
}

Function New-PodeWebCardAddHostAddressesValidator {
    # Validate at least one field
    $fields = @("MacAddress", "IPv4Address", "Hostname", "ChassisSerial")

    # Check if ALL fields have a length of 0
    if (-not ($fields | Where-Object { $WebEvent.Data[$_].Length -gt 0 })) {
        Out-PodeWebValidation -Name "ChassisSerial" -Message "Must provide at least one point of network identity."
    }

    $Connection = (Get-PodeState -Name "dbConnection")

    ## No Validation for Chassis Serial Number Needed.
    if($WebEvent.Data -and ($WebEvent.Data['ChassisSerial'].Length -gt 0)) {
        $WebEvent.Session.Data['newHost'] = $WebEvent.Session.Data['newHost'] | Set-dbHost -ChassisSerial $WebEvent.Data['ChassisSerial']
        $WebEvent.Session.Data['newHost'] = Add-DbDocument -Connection $Connection -CollectionName 'Temp' -Data $WebEvent.Session.Data['newHost']
        Save-PodeSession -Force
    }

    # Mac Address Validation
    # Allow for no entry `-gt 0`
    if($WebEvent.Data['MacAddress'].Length -gt 0) {
        $MacAddress = Test-MACAddressString -MacAddress $WebEvent.Data['MacAddress']
        if (-not $MacAddress.IsValid) {
            Out-PodeWebValidation -Name "MacAddress" -Message $MacAddress.Message
        }

        $WebEvent.Session.Data['newInterfaces'] = @(Set-HostInterface -MacAddress $MacAddress.MacAddress)
        # Write-PodeHost "================================="
        # Write-PodeHost "================================="
        # foreach ($key in $WebEvent.Session.Data['newHost'].Keys) {
        #     Out-PodeHost $key
            

        #     Write-PodeHost "================================="
        # }
        # Write-PodeHost "================================="
        # Out-PodeHost $WebEvent.Session.Data['newInterfaces']
        # Write-PodeHost "================================="
    }

    # Validate IPv4 Address and CIDR
    if ((($WebEvent.Data['IPv4CIDR'].Length -gt 0) -and -not (([int]$WebEvent.Data['IPv4CIDR'] -ge 1) -and ([int]$WebEvent.Data['IPv4CIDR'] -le 32)))) {
        Out-PodeWebValidation -Name "IPv4CIDR" -Message "IPv4 CIDR out of range. Should be [1-32]. Leave Blank if Unknown."
    }
    if (($WebEvent.Data['IPv4Address'].Length -gt 0) -and ($WebEvent.Data['IPv4CIDR'].Length -gt 0)) {
        $IPv4 = Get-IPv4SubnetDetails -IPAddress $WebEvent.Data['IPv4Address'] -CIDR $WebEvent.Data['IPv4CIDR']
        if(-not $IPv4.IsHost) {
            Out-PodeWebValidation -Name "IPv4Address" -Message $IPv4.Message
        }
    } 
    elseif ($WebEvent.Data['IPv4Address'].Length -gt 0) {
        $IPv4 = Get-IPv4SubnetDetails -IPAddress $WebEvent.Data['IPv4Address']
        if(-not $IPv4.IsValid) {
            Out-PodeWebValidation -Name "IPv4Address" -Message $IPv4.Message
        }
    }

    # Hostname Validation
    if($WebEvent.Data['Hostname'].Length -gt 0) {
        $Hostname = Test-HostnameFormat -Hostname $WebEvent.Data['Hostname']
        if(-not $Hostname.IsValid) {
            Out-PodeWebValidation -Name "Hostname" -Message $Hostname.Message
        }
    }
}
