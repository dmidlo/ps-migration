[NoRunspaceAffinity()]
class MacAddressAnalyzer {

    static [string] $OUI_CACHE_PATH = "$env:TEMP\ieee_oui_list.clixml"
    static [int] $CACHE_DAYS = 1
    static [string] $OUI_URL = "https://standards-oui.ieee.org/oui/oui.txt"

    static [hashtable] $VirtualMachineOUIList = @{
        '000C29' = "VMware"
        '005056' = "VMware"
        '000569' = "VMware"
        '505054' = "VMware"
        '001A92' = "Microsoft Hyper-V"
        '001C14' = "Microsoft Hyper-V"
        '00155D' = "Microsoft Hyper-V"
        '0003FF' = "Xen"
        '0002A5' = "Xen Hypervisors"
        '000D56' = "Citrix XenServer"
        '000F4B' = "XenSource"
        '00163E' = "Parallels"
        '080027' = "VirtualBox"
        '0A0027' = "VirtualBox"
        '001C42' = "Virtual Iron"
        '525400' = "QEMU/KVM"
        'FA163E' = "OpenStack"
        '0002B3' = "Huawei FusionCompute"
        '000D3A' = "Nutanix AHV"
        '0003BA' = "Amazon AWS Nitro Hypervisor"
        '001C50' = "Google Compute Engine"
        '0001C0' = "Sun Microsystems Virtualization"
        '020C42' = "QEMU/KVM Alternative"
        '001E67' = "Cisco Virtual Machines"
    }

    static [hashtable] $ProtocolMacList = @{
        '00000C07AC' = "HSRP Virtual MAC"
        '00005E0001' = "VRRP Virtual MAC"
        '00005E0002' = "VRRP IPv6 Virtual MAC"
        '0007B400'   = "CARP Virtual MAC"
        '0180C2000000' = "Spanning Tree Protocol (STP)"
        '0180C2000001' = "Ethernet Slow Protocols (LACP, PAgP)"
        '0180C2000002' = "IEEE 802.3 Pause Frames"
        '0180C2000003' = "LLDP (Link Layer Discovery Protocol)"
        '0180C200000E' = "EAP over LAN (802.1X Authentication)"
        '01005E' = "IPv4 Multicast"
        '333300' = "IPv6 Multicast"
        '0180C2000020' = "GARP VLAN Registration Protocol (GVRP)"
        '0180C2000021' = "Multiple VLAN Registration Protocol (MVRP)"
        '00000C9F' = "GLBP (Gateway Load Balancing Protocol)"
        '00000C07AF' = "HSRPv2"
        '0000AA' = "DECnet Phase IV"
        'CF0049' = "Fibre Channel over Ethernet (FCoE)"
    }

    static [hashtable] $ContainerMacList = @{
        '0242' = 'Docker'
        '0A57' = 'CoreOS/rkt'
        '0250' = 'LXC'
        '0E57' = 'Podman'
        '0F27' = 'CRI-O'
        '0B57' = 'K3s'
        '1A02' = 'Kubernetes Flannel'
        '5254' = 'Cloud Foundry'
        'E6B0' = 'AWS Firecracker'
    }



    [string] $MacAddress
    [string] $OriginalInput
    [bool] $IsValid
    [string] $ValidationMessage

    MacAddressAnalyzer([string] $Mac) {
        $this.OriginalInput = $Mac ?? ""
        $this.ValidationMessage = ""
        $normalizedMac = $this.NormalizeMacAddress($Mac)

        if ($normalizedMac -notlike 'Invalid') {
            $this.MacAddress = $normalizedMac
        } else {
            $this.MacAddress = $this.OriginalInput
            $this.ValidationMessage = "Invalid MAC format: Must be 12 hexadecimal characters."
        }
    }

    hidden [string] NormalizeMacAddress([string]$mac) {
        if (-not $mac -or $mac -match '^\s*$') { return "Invalid" }
        $normalized = ($mac -creplace "[:\-\.\@\#\$\^\%\&\;\,\/\\\[\]\{\}\(\)\`"\`'\``\ \|]", '').Trim().ToUpper()
        $out = if ($normalized -and $normalized -match '^[0-9A-F]{12}$') { $normalized } else { "Invalid" }
        $out = if ($out -notmatch '^0{12}$') { $out } else { "Invalid" }
        return $out
    }

    hidden [bool] IsVirtualMachineMac([string]$prefix6, [ref]$VendorInfo) {
        if (-not $prefix6) { return $false }

        if ([MacAddressAnalyzer]::VirtualMachineOUIList.ContainsKey($prefix6)) {
            $VendorInfo.Value = [MacAddressAnalyzer]::VirtualMachineOUIList[$prefix6]
            return $true
        }

        return $false
    }

    hidden [bool] IsContainerMac([string]$Prefix4, [ref]$VendorInfo) {
        if (-not $Prefix4) {return $false }

        if ([MacAddressAnalyzer]::ContainerMacList.ContainsKey($Prefix4)) {
            $VendorInfo.Value = [MacAddressAnalyzer]::ContainerMacList[$Prefix4]
            return $true
        }
        return $false
    }

    hidden [bool] IsProtocolVirtualMac([string]$Prefix12, [ref]$VendorInfo) {
        if (-not $Prefix12) { return $false }

        if ([MacAddressAnalyzer]::ProtocolMacList.ContainsKey($Prefix12)) {
            $VendorInfo.Value = [MacAddressAnalyzer]::ProtocolMacList[$Prefix12]
            return $true
        }

        return $false
    }


    [MacAddressType] GetMacAddressType() {
        if (-not $this.MacAddress -or $this.MacAddress -eq 'Invalid') { 
            return [MacAddressType]::Unknown 
        }

        if ($this.MacAddress -eq 'FFFFFFFFFFFF') {
            $this.ValidationMessage = "Invalid: Broadcast MAC address detected."
            return [MacAddressType]::Broadcast
        }

        try {
            $firstByte = [Convert]::ToByte($this.MacAddress.Substring(0, 2), 16)

            switch ($firstByte -band 0x3) {
                0 { return [MacAddressType]::UnicastGlobal }
                1 { return [MacAddressType]::MulticastGlobal }
                2 { return [MacAddressType]::UnicastLocal }
                3 { return [MacAddressType]::MulticastLocal }
            }
        } catch {
            # Catch any unexpected errors and return Unknown
            $this.ValidationMessage = "Error processing MAC address."
        }

        return [MacAddressType]::Unknown # Ensure a return value in all cases
    }

    [MacAddressOriginType] GetMacAddressOrigin([ref]$VendorInfo, [bool]$SkipOUI = $false) {
        if (-not $this.MacAddress -or $this.MacAddress -eq 'Invalid') { return [MacAddressOriginType]::Unknown }
        $prefix6 = $this.GetOUI()
        $prefix4 = $this.GetOUI(4)
        $Prefix12 = $this.GetOUI(12)

        if ($this.IsVirtualMachineMac($prefix6, [ref]$VendorInfo)) { return [MacAddressOriginType]::VirtualMachine }
        if ($this.IsContainerMac($prefix4, [ref]$VendorInfo)) { return [MacAddressOriginType]::Container }
        if ($this.IsProtocolVirtualMac($Prefix12, [ref]$VendorInfo)) { return [MacAddressOriginType]::ProtocolVirtual }

        if (!$SkipOUI) {
            $VendorInfo.Value = $this.GetVendorInfo()
            if ($VendorInfo.Value -ne "Unknown") {
                return [MacAddressOriginType]::ManufacturerAssigned
            }
        }

        return [MacAddressOriginType]::Unknown
    }

    hidden [string] GetOUI() {
        $length = 6
        if (-not $this.MacAddress -or $this.MacAddress -eq 'Invalid' -or $this.MacAddress.Length -lt $length) { return "" }
        $out = $this.MacAddress.Substring(0, $length).ToUpper()
        return $out
    }

    hidden [string] GetOUI([int]$length) {
        if (-not $this.MacAddress -or $this.MacAddress -eq 'Invalid' -or $this.MacAddress.Length -lt $length) { return "" }
        $out = $this.MacAddress.Substring(0, $length).ToUpper()
        return $out
    }

    hidden [string] GetVendorInfo() {
        $OUIList = [MacAddressAnalyzer]::GetOUIList()
        $out = $OUIList[$this.GetOUI()] ?? "Unknown"
        return $out
    }

    static [hashtable] GetOUIList() {
        $ouiList = Get-IEEEOUIList -CacheFile ([MacAddressAnalyzer]::OUI_CACHE_PATH) -CacheDays ([MacAddressAnalyzer]::CACHE_DAYS) -OUIUrl ([MacAddressAnalyzer]::OUI_URL)
        return $ouiList
    }

    [PSCustomObject] ToPsCustomObject() {
        return $this.ToPsCustomObject($false)
    }

    [PSCustomObject] ToPsCustomObject([bool]$SkipOUI) {
        $ExpectedType = $null
        $ExpectedOrigin = $null
        $addressType = $this.GetMacAddressType()
        $vendorInfo = $this.GetVendorInfo()
        $originType = $this.GetMacAddressOrigin([ref]$vendorInfo, $SkipOUI)

        $typeValid = $ExpectedType -eq $null -or $addressType -eq $ExpectedType
        $originValid = $ExpectedOrigin -eq $null -or $originType -eq $ExpectedOrigin
        $this.IsValid = (-not $this.ValidationMessage) -and $typeValid -and $originValid

        return [PSCustomObject]@{
            InputMacAddress   = $this.OriginalInput
            Normalized   = $this.IsValid ? $this.MacAddress : "Invalid"
            IsValid      = $this.IsValid
            FormattedMac = $this.IsValid ? ($this.MacAddress -split '(?<=\G.{2})(?=.)') -join ':' : "Invalid"
            Vendor       = $vendorInfo ?? "Unknown"
            AddressType  = $addressType.ToString()
            OriginType   = $originType.ToString()
            Message      = $this.ValidationMessage
        }
    }

    [PSCustomObject] ToPsCustomObject([MacAddressType]$ExpectedType) {
        return $this.ToPsCustomObject($ExpectedType, $false)
    }

    [PSCustomObject] ToPsCustomObject([MacAddressType]$ExpectedType, [bool]$SkipOUI) {
        $ExpectedOrigin = $null
        $addressType = $this.GetMacAddressType()
        $vendorInfo = $this.GetVendorInfo()
        $originType = $this.GetMacAddressOrigin([ref]$vendorInfo, $SkipOUI)

        $typeValid = $ExpectedType -eq $null -or $addressType -eq $ExpectedType
        $originValid = $ExpectedOrigin -eq $null -or $originType -eq $ExpectedOrigin
        $this.IsValid = (-not $this.ValidationMessage) -and $typeValid -and $originValid

        return [PSCustomObject]@{
            InputMacAddress   = $this.OriginalInput
            Normalized   = $this.IsValid ? $this.MacAddress : "Invalid"
            IsValid      = $this.IsValid
            FormattedMac = $this.IsValid ? ($this.MacAddress -split '(?<=\G.{2})(?=.)') -join ':' : "Invalid"
            Vendor       = $vendorInfo ?? "Unknown"
            AddressType  = $addressType.ToString()
            OriginType   = $originType.ToString()
            Message      = $this.ValidationMessage
        }
    }

    [PSCustomObject] ToPsCustomObject([MacAddressOriginType]$ExpectedOrigin) {
        return $this.ToPsCustomObject($ExpectedOrigin, $false)
    }

    [PSCustomObject] ToPsCustomObject([MacAddressOriginType]$ExpectedOrigin, [bool]$SkipOUI) {
        $ExpectedType = $null
        $addressType = $this.GetMacAddressType()
        $vendorInfo = $this.GetVendorInfo()
        $originType = $this.GetMacAddressOrigin([ref]$vendorInfo, $SkipOUI)

        $typeValid = $ExpectedType -eq $null -or $addressType -eq $ExpectedType
        $originValid = $ExpectedOrigin -eq $null -or $originType -eq $ExpectedOrigin
        $this.IsValid = (-not $this.ValidationMessage) -and $typeValid -and $originValid

        return [PSCustomObject]@{
            InputMacAddress   = $this.OriginalInput
            Normalized   = $this.IsValid ? $this.MacAddress : "Invalid"
            IsValid      = $this.IsValid
            FormattedMac = $this.IsValid ? ($this.MacAddress -split '(?<=\G.{2})(?=.)') -join ':' : "Invalid"
            Vendor       = $vendorInfo ?? "Unknown"
            AddressType  = $addressType.ToString()
            OriginType   = $originType.ToString()
            Message      = $this.ValidationMessage
        }
    }

    [PSCustomObject] ToPsCustomObject([MacAddressType]$ExpectedType, [MacAddressOriginType]$ExpectedOrigin) {
        return $this.ToPsCustomObject($ExpectedType, $ExpectedOrigin, $false)
    }

    [PSCustomObject] ToPsCustomObject([MacAddressType]$ExpectedType, [MacAddressOriginType]$ExpectedOrigin, [bool]$SkipOUI) {
        $addressType = $this.GetMacAddressType()
        $vendorInfo = $this.GetVendorInfo()
        $originType = $this.GetMacAddressOrigin([ref]$vendorInfo, $SkipOUI)

        $typeValid = $ExpectedType -eq $null -or $addressType -eq $ExpectedType
        $originValid = $ExpectedOrigin -eq $null -or $originType -eq $ExpectedOrigin
        $this.IsValid = (-not $this.ValidationMessage) -and $typeValid -and $originValid

        return [PSCustomObject]@{
            InputMacAddress   = $this.OriginalInput
            Normalized   = $this.IsValid ? $this.MacAddress : "Invalid"
            IsValid      = $this.IsValid
            FormattedMac = $this.IsValid ? ($this.MacAddress -split '(?<=\G.{2})(?=.)') -join ':' : "Invalid"
            Vendor       = $vendorInfo ?? "Unknown"
            AddressType  = $addressType.ToString()
            OriginType   = $originType.ToString()
            Message      = $this.ValidationMessage
        }
    }

    static [PSCustomObject] ParseMacAddress([string] $Mac) {
        return ([MacAddressAnalyzer]::new($Mac).ToPsCustomObject())
    }

    static [PSCustomObject] ParseMacAddress([string] $Mac, [bool]$SkipOUI) {
        return ([MacAddressAnalyzer]::new($Mac).ToPsCustomObject($SkipOUI))
    }

    static [PSCustomObject] ParseMacAddress([string]$Mac, [MacAddressType]$ExpectedType) {
        return ([MacAddressAnalyzer]::new($Mac).ToPsCustomObject($ExpectedType))
    }

    static [PSCustomObject] ParseMacAddress([string] $Mac, [MacAddressType]$ExpectedType, [bool]$SkipOUI) {
        return ([MacAddressAnalyzer]::new($Mac).ToPsCustomObject($ExpectedType, $SkipOUI))
    }

    static [PSCustomObject] ParseMacAddress([string]$Mac, [MacAddressOriginType]$ExpectedOrigin) {
        return ([MacAddressAnalyzer]::new($Mac).ToPsCustomObject($ExpectedOrigin))
    }

    static [PSCustomObject] ParseMacAddress([string]$Mac, [MacAddressOriginType]$ExpectedOrigin, [bool]$SkipOUI) {
        return ([MacAddressAnalyzer]::new($Mac).ToPsCustomObject($ExpectedOrigin, $SkipOUI))
    }

    static [PSCustomObject] ParseMacAddress([string]$Mac, [MacAddressType]$ExpectedType, [MacAddressOriginType]$ExpectedOrigin) {
        return ([MacAddressAnalyzer]::new($Mac).ToPsCustomObject($ExpectedType, $ExpectedOrigin))
    }

    static [PSCustomObject] ParseMacAddress([string] $Mac, [MacAddressType]$ExpectedType, [MacAddressOriginType]$ExpectedOrigin, [bool]$SkipOUI) {
        return ([MacAddressAnalyzer]::new($Mac).ToPsCustomObject($ExpectedType, $ExpectedOrigin, $SkipOUI))
    }
}
