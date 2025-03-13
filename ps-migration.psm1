
enum MacAddressType {
    UnicastGlobal
    UnicastLocal
    MulticastGlobal
    MulticastLocal
    Broadcast
    Unknown
}

enum MacAddressOriginType {
    Unknown
    ManufacturerAssigned
    VirtualMachine
    Container
    ProtocolVirtual
}

enum dbVersionSteps {
    Next
    Previous
    Latest
    Original
}

enum dbComponentType {
    Component
    Chassis
    Module
    Interface
}

enum AddressPurpose {
    Unknown
    Billing
    Shipping
    Operations
}

enum AddressType {
    Unknown
    Commercial
    Residential
    Other
}

# Module Utilities
$utilitiesFolders = @("private")
foreach ($utilitiesFolder in $utilitiesFolders) {
    Get-ChildItem -Recurse "$PSScriptRoot\$utilitiesFolder\*.ps1" -File | ForEach-Object {
        . $_.FullName
    }
}

# Exported Functions
$exportFolders = @("public")
foreach ($exportFolder in $exportFolders) {
    Get-ChildItem -Recurse "$PSScriptRoot\$exportFolder\*.ps1" -File | ForEach-Object {
        . $_.FullName
    }
}

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

[NoRunspaceAffinity()]
class LiteDbAppendOnlyCollection {
    [LiteDB.LiteDatabase] $Database
    $Collection

    LiteDbAppendOnlyCollection ([LiteDB.LiteDatabase] $Database, [string]$CollectionName) {
        $this.Database = $Database
        $this.Collection = Get-LiteCollection -Database $this.Database -CollectionName $CollectionName
        $this._init_collections()
    }

    LiteDbAppendOnlyCollection ([LiteDB.LiteDatabase] $Database, [PSObject]$Collection) {
        $this.Database   = $Database
        $this.Collection = $Collection
        $this._init_collections()
    }
    
    hidden [void] _init_collections(){
        $this.EnsureCollection(@(
            [PSCustomObject]@{ Field='VersionId'; Unique=$true },
            [PSCustomObject]@{ Field="BundleId"; Unique=$false},
            [PSCustomObject]@{ Field="ContentMark"; Unique=$false}
        ), $this.Collection.Name)
        $this.EnsureCollection(@(
            [PSCustomObject]@{ Field='VersionId'; Unique=$true },
            [PSCustomObject]@{ Field="BundleId"; Unique=$false},
            [PSCustomObject]@{ Field="ContentMark"; Unique=$false}
        ), 'Temp')
        $this.EnsureCollection(@(
            [PSCustomObject]@{ Field='VersionId'; Unique=$true },
            [PSCustomObject]@{ Field="BundleId"; Unique=$false},
            [PSCustomObject]@{ Field="ContentMark"; Unique=$false}
        ), 'RecycleBin')
    }

    hidden [PSObject] _Add([PSCustomObject] $Data) {
        # Delegates to Add-DbDocument
        return Add-DbDocument -Database $this.Database -Collection $this.Collection -Data $Data
    }

    hidden [PSObject] _Add_NoVersionUpdate([PSCustomObject] $Data) {
        # Delegates to Add-DbDocument
        return Add-DbDocument -Database $this.Database -Collection $this.Collection -Data $Data -NoVersionUpdate
    }

    hidden [PSObject] _Add_NoTimestampUpdate([PSCustomObject] $Data) {
        # Delegates to Add-DbDocument
        return Add-DbDocument -Database $this.Database -Collection $this.Collection -Data $Data -NoTimestampUpdate
    }

    hidden [PSObject] _Add_NoVersionOrTimestampUpdate([PSCustomObject] $Data) {
        # Delegates to Add-DbDocument
        return Add-DbDocument -Database $this.Database -Collection $this.Collection -Data $Data -NoVersionUpdate -NoTimestampUpdate
    }

    hidden [PSObject] _Add([PSCustomObject] $Data, [string[]] $IgnoreFields) {
        # Delegates to Add-DbDocument
        return Add-DbDocument -Database $this.Database -Collection $this.Collection -Data $Data -IgnoreFields $IgnoreFields
    }

    hidden [PSObject] _Add_NoVersionUpdate([PSCustomObject] $Data, [string[]] $IgnoreFields) {
        # Delegates to Add-DbDocument
        return Add-DbDocument -Database $this.Database -Collection $this.Collection -Data $Data -NoVersionUpdate -IgnoreFields $IgnoreFields
    }

    hidden [PSObject] _Add_NoTimestampUpdate([PSCustomObject] $Data, [string[]] $IgnoreFields) {
        # Delegates to Add-DbDocument
        return Add-DbDocument -Database $this.Database -Collection $this.Collection -Data $Data -NoTimestampUpdate -IgnoreFields $IgnoreFields
    }

    hidden [PSObject] _Add_NoVersionOrTimestampUpdate([PSCustomObject] $Data, [string[]] $IgnoreFields) {
        # Delegates to Add-DbDocument
        return Add-DbDocument -Database $this.Database -Collection $this.Collection -Data $Data -NoVersionUpdate -NoTimestampUpdate -IgnoreFields $IgnoreFields
    }

    [void] EnsureCollection([array]$Indexes) {
        Initialize-LiteDbCollection -Database $this.Database -CollectionName $this.Collection -Indexes $Indexes
    }

    [void] EnsureCollection([array]$Indexes, [string]$CollectionName) {
        Initialize-LiteDbCollection -Database $this.Database -CollectionName $CollectionName -Indexes $Indexes
    }

    [System.Object[]] GetAll() {
        # Delegates to Get-DbDocumentAll
        return Get-DbDocumentAll `
            -Database $this.Database `
            -Collection $this.Collection
    }

    [System.Object[]] GetAll([switch] $ResolveRefs) {
        # Delegates to Get-DbDocumentAll
        return Get-DbDocumentAll `
            -Database $this.Database `
            -Collection $this.Collection `
            -ResolveRefs:$ResolveRefs
    }

    [PSCustomObject] GetByVersionId([string] $VersionId) {
        # Delegates to Get-DbDocumentByVersion
        return Get-DbDocumentByVersion `
            -Database $this.Database `
            -Collection $this.Collection `
            -VersionId $VersionId
    }

    [PSCustomObject] GetByVersionId([string] $VersionId, [switch] $ResolveRefs) {
        # Delegates to Get-DbDocumentByVersion
        return Get-DbDocumentByVersion `
            -Database $this.Database `
            -Collection $this.Collection `
            -VersionId $VersionId `
            -ResolveRefs:$ResolveRefs
    }

    [PSCustomObject] GetById([Object] $Id) {
        # Delegates to Get-DbDocumentById
        return Get-DbDocumentById `
            -Database $this.Database `
            -Collection $this.Collection `
            -Id $Id
    }

    [PSCustomObject] GetById([Object] $Id, [switch] $ResolveRefs) {
        # Delegates to Get-DbDocumentById
        return Get-DbDocumentById `
            -Database $this.Database `
            -Collection $this.Collection `
            -Id $Id `
            -ResolveRefs:$ResolveRefs
    }

    [PSCustomObject] GetVersion([string]$VersionId, [dbVersionSteps]$Version) {
        $out = $null
        if ($Version -eq [dbVersionSteps]::Original) {
            $out = Get-DbDocumentVersion -Database $this.Database -Collection $this.Collection -VersionId $VersionId -Original
        }
        elseif ($Version -eq [dbVersionSteps]::Latest) {
            $out = Get-DbDocumentVersion -Database $this.Database -Collection $this.Collection -VersionId $VersionId -Latest
        }
        elseif ($Version -eq [dbVersionSteps]::Previous) {
            $out = Get-DbDocumentVersion -Database $this.Database -Collection $this.Collection -VersionId $VersionId -Previous
        }
        elseif ($Version -eq [dbVersionSteps]::Next) {
            $out = Get-DbDocumentVersion -Database $this.Database -Collection $this.Collection -VersionId $VersionId -Next
        }

        return $out
    }

    [PSCustomObject] GetVersion([string]$VersionId, [dbVersionSteps]$Version, [switch]$ResolveRefs) {
        $out = $null
        if ($Version -eq [dbVersionSteps]::Original) {
            $out = Get-DbDocumentVersion -Database $this.Database -Collection $this.Collection -VersionId $VersionId -Original -ResolveRefs
        }
        elseif ($Version -eq [dbVersionSteps]::Latest) {
            $out = Get-DbDocumentVersion -Database $this.Database -Collection $this.Collection -VersionId $VersionId -Latest -ResolveRefs
        }
        elseif ($Version -eq [dbVersionSteps]::Previous) {
            $out = Get-DbDocumentVersion -Database $this.Database -Collection $this.Collection -VersionId $VersionId -Previous -ResolveRefs
        }
        elseif ($Version -eq [dbVersionSteps]::Next) {
            $out = Get-DbDocumentVersion -Database $this.Database -Collection $this.Collection -VersionId $VersionId -Next -ResolveRefs
        }

        return $out
    }

    [System.Object[]] GetVersionsByBundle([Guid] $BundleId) {
        # Delegates to Get-DbDocumentVersionsByBundle
        return Get-DbDocumentVersionsByBundle `
            -Database $this.Database `
            -Collection $this.Collection `
            -BundleId $BundleId
    }

    [System.Object[]] GetVersionsByBundle([Guid] $BundleId, [switch] $ResolveRefs) {
        # Delegates to Get-DbDocumentVersionsByBundle
        return Get-DbDocumentVersionsByBundle `
            -Database $this.Database `
            -Collection $this.Collection `
            -BundleId $BundleId `
            -ResolveRefs
    }

    [System.Object[]] GetDbObject([Guid] $BundleId) {
        # Delegates to Get-DbDocumentVersionsByBundle
        return Get-DbDocumentVersionsByBundle `
            -Database $this.Database `
            -Collection $this.Collection `
            -BundleId $BundleId `
            -AsDbObject
    }

    [PSCustomObject] GetBundleRef([PSCustomObject] $DbBundleRef) {
        return Get-DbBundleRef -Database $this.Database -Collection $this.Collection -DbBundleRef $DbBundleRef
    }

    [PSCustomObject] GetVersionRef([PSCustomObject] $DbVersionRef) {
        return Get-DbVersionRef -Database $this.Database -Collection $this.Collection -DbVersionRef $DbVersionRef
    }

    [PSCustomObject] NewBundleRef([PSCustomObject] $DbObjectDocument, $Collection) {
        return New-DbBundleRef -DbDocument $DbObjectDocument -Collection $Collection -RefCollection $this.Collection
    }

    static [PSCustomObject] NewBundleRef([PSCustomObject] $DbObjectDocument, $Collection, $RefCollection) {
        return New-DbBundleRef -DbDocument $DbObjectDocument -Collection $Collection -RefCollection $RefCollection
    }

    [Void] MoveDbObjectToCollection([Guid]$BundleId, $DestCollection) {
        $BundleId | Set-DbObjectCollectionByBundle -Database $this.Database -SourceCollection $this.Collection -DestCollection $DestCollection -NoTimestampUpdate
    }

    [void] MoveDbObjectToCollection([PSObject]$DbObject, $DestCollection) {
        $DbObject[0].BundleId | Set-DbObjectCollectionByBundle -Database $this.Database -SourceCollection $this.Collection -DestCollection $DestCollection -NoTimestampUpdate
    }

    [Void] MoveDbObjectFromCollection([Guid]$BundleId, $SourceCollection) {
        $BundleId | Set-DbObjectCollectionByBundle -Database $this.Database -SourceCollection $SourceCollection -DestCollection $this.Collection -NoTimestampUpdate
    }

    [Void] MoveDbObjectFromCollection([PSObject]$DbObject, $SourceCollection) {
        $DbObject[0].BundleId | Set-DbObjectCollectionByBundle -Database $this.Database -SourceCollection $SourceCollection -DestCollection $this.Collection -NoTimestampUpdate
    }

    [void] RecycleDbObject([Guid]$BundleId) {
        $now = [DateTimeOffset]::UtcNow.ToUnixTimeMilliseconds()
        $RecycleBin = Get-LiteCollection -Database $this.Database -CollectionName 'RecycleBin'
        $DbObject = $this.GetVersionsByBundle($BundleId)
        foreach ($version in $DbObject) {
            $version = ($version | Add-Member -MemberType NoteProperty -Name '$RecycledTime' -Value $now -Force -PassThru)
            $version = ($version | Add-Member -MemberType NoteProperty -Name '$BaseCol' -Value $this.Collection.Name -Force -PassThru)
            $version | Set-LiteData -Collection $this.Collection
        }
        $DbObject = $this.GetVersionsByBundle($DbObject[0].BundleId)
        $this.MoveDbObjectToCollection($DbObject, $RecycleBin)
    }

    [void] RecycleDbObject([PSObject]$DbObject) {
        $now = [DateTimeOffset]::UtcNow.ToUnixTimeMilliseconds()
        $RecycleBin = Get-LiteCollection -Database $this.Database -CollectionName 'RecycleBin'
        $DbObject = $this.GetVersionsByBundle($DbObject[0].BundleId)
        foreach ($version in $DbObject) {
            $version = ($version | Add-Member -MemberType NoteProperty -Name '$RecycledTime' -Value $now -Force -PassThru)
            $version = ($version | Add-Member -MemberType NoteProperty -Name '$BaseCol' -Value $this.Collection.Name -Force -PassThru)
            $version | Set-LiteData -Collection $this.Collection
        }
        $DbObject = $this.GetVersionsByBundle($DbObject[0].BundleId)
        $this.MoveDbObjectToCollection($DbObject, $RecycleBin)
    }

    [void] RestoreDbObject([Guid]$BundleId) {
        $RecycleBin = New-LiteDbAppendOnlyCollection -Database $this.Database -Collection 'RecycleBin'
        $DbObject = $RecycleBin.GetVersionsByBundle($BundleId)
        foreach ($version in $DbObject) {
            $version.PSObject.Properties.Remove('$BaseCol')
            $version.PSObject.Properties.Remove('$RecycledTime')
            $version | Set-LiteData -Collection $RecycleBin.Collection
        }
        $DbObject = $RecycleBin.GetVersionsByBundle($DbObject[0].BundleId)
        $RecycleBin.MoveDbObjectToCollection($DbObject, $this.Collection)
    }

    [void] EmptyRecycleBin() {
        $RecycleBin = Get-LiteCollection -Database $this.Database -CollectionName 'RecycleBin'
        Remove-LiteData -Collection $RecycleBin -Where '$BaseCol = @BaseCol', @{BaseCol = $this.Collection.Name}
    }

    [void] EmptyRecycleBin([Guid]$BundleId) {
        $RecycleBin = Get-LiteCollection -Database $this.Database -CollectionName 'RecycleBin'
        Remove-LiteData -Collection $RecycleBin -Where 'BundleId = @BundleId', @{BundleId = $BundleId}
    }

    [PSCustomObject] StageDbObjectDocument([PSCustomObject] $PSCustomObject) {
        $Temp = New-LiteDbAppendOnlyCollection -Database $this.Database -Collection 'Temp'
        
        # Add `$DestCol` property to track where the object should go upon commit
        $PSCustomObject = $PSCustomObject | Add-Member -MemberType NoteProperty -Name '$DestCol' -Value $this.Collection.Name -Force -PassThru

        $staged = $Temp._Add($PSCustomObject)

        return $staged
    }

    [System.Object[]] CommitTempObjectAsDbDoc([Guid]$BundleId) {
        $Temp = New-LiteDbAppendOnlyCollection -Database $this.Database -Collection 'Temp'
        $DbObject = $Temp.GetVersionsByBundle($BundleId)
        $out = $Temp.GetVersion($DbObject[0].VersionId, [dbVersionSteps]::Latest, $true)
        $original = $Temp.GetVersion($DbObject[0].VersionId, [dbVersionSteps]::Original, $true)
        $out.UTC_Created = $original.UTC_Created
        $out.'$ObjVer' = $original.'$ObjVer'
        $out.PSObject.Properties.Remove('$DestCol')
        $out.PSObject.Properties.Remove('$VersionArcs')
        foreach ($version in $DbObject) {
            $versionProps = $version.PSObject.Properties.Name
            if ($versionProps -contains '$Ref' -and $versionProps -contains '$VersionId') {
                if ($version.'$VersionId' -like $out.VersionId) {
                    Write-Host "version: $($version.'$VersionId')"
                    Write-Host "out: $($out.VersionId)"
                    $out | Set-LiteData -Collection $this.Collection
                }
                else {
                    Remove-LiteData -Collection $Temp.Collection -Where 'VersionId = @VersionId', @{VersionId = $version.VersionId}
                }
            }
            else {
                if ($version.VersionId -like $out.VersionId) {
                    Write-Host "version: $($version.'$VersionId')"
                    Write-Host "out: $($out.VersionId)"
                    $out | Set-LiteData -Collection $this.Collection
                }
                else{
                    Remove-LiteData -Collection $Temp.Collection -Where 'VersionId = @VersionId', @{VersionId = $version.VersionId}
                }
            }
        }
        # $Temp.MoveDbObjectToCollection($out, $this.Collection)
        $return = $this.GetVersionsByBundle($out[0].BundleId)
        return $return
    }

    [void] CommitAsDbObject([Guid] $BundleId) {
        $Temp = New-LiteDbAppendOnlyCollection -Database $this.Database -Collection 'Temp'
        $DbObject = $Temp.GetVersionsByBundle($BundleId)
        foreach ($version in $DbObject) {
            $version.PSObject.Properties.Remove('$DestCol')
            $version | Set-LiteData -Collection $Temp.Collection
        }
        $DbObject = $Temp.GetVersionsByBundle($DbObject[0].BundleId)
        $Temp.MoveDbObjectToCollection($DbObject, $this.Collection)
    }

    [void] CommitAllDbDocAsDbObject() {
        $Temp = New-LiteDbAppendOnlyCollection -Database $this.Database -Collection "Temp"
        $BundleIds = $Temp.GetAll() | Where-Object {$_.'$DestCol' -like $this.Collection.Name} | Select-Object -Unique 'BundleId'
        foreach ($BundleId in $BundleIds) {
            $BundleId = [Guid]::Parse($BundleId.Guid)
            $this.CommitDbDocAsDbObject($BundleId)
        }
    }

    [void] ClearTemp([Guid] $BundleId) {
        $Temp = New-LiteDbAppendOnlyCollection -Database $this.Database -Collection 'Temp'
        $RecycleBin = New-LiteDbAppendOnlyCollection -Database $this.Database -Collection 'RecycleBin'

        $Temp.RecycleDbObject($BundleId)
        $RecycleBin.EmptyRecycleBin($BundleId)
    }

    [void] ClearTemp() {
        $Temp = New-LiteDbAppendOnlyCollection -Database $this.Database -Collection 'Temp'
        $RecycleBin = New-LiteDbAppendOnlyCollection -Database $this.Database -Collection 'RecycleBin'
        $BundleIds = $Temp.GetAll() | Where-Object {$_.'$DestCol' -like $this.Collection.Name} | Select-Object -Unique 'BundleId'
        foreach ($BundleId in $BundleIds) {
            $BundleId = [Guid]::Parse($BundleId.Guid)
            $Temp.RecycleDbObject($BundleId)
            $RecycleBin.EmptyRecycleBin($BundleId)
        }
    }

    [bool] VersionExists([string] $VersionId) {
        return Test-LiteData -Collection $this.Collection -Where 'VersionId = @VersionId', @{VersionId = $VersionId}
    }

    [bool] BundleExists([Guid] $BundleId) {
        return Test-LiteData -Collection $this.Collection -Where 'BundleId = @BundleId', @{BundleId = $BundleId}
    }


}

[NoRunspaceAffinity()]
class LiteDbAppendOnlyDocument : LiteDbAppendOnlyCollection {
    # This someday may be helpfully converted to three classes once [Type] `-is` conditionals
    # are backported into supporting code to support additional type safety and project code consistency
    # for now, this will be base class for Standard DB Documents, Temp Db Documents, Recycled DBdocuments, and VersionRef/BundleRef Db Documents
    [LiteDB.ObjectId]$_id
    [string]$ContentMark
    [Guid]$BundleId
    [string]$VersionId
    [int64]$UTC_Created
    [int64]$UTC_Updated
    [PSCustomObject]$Properties

    LiteDbAppendOnlyDocument($Database, $Collection) : base($Database, $Collection) {}

    LiteDbAppendOnlyDocument($Database, $Collection, [PSCustomObject]$PSCustomObject) : base($Database, $Collection){
        $this.Properties = $PSCustomObject
        $this.FromPS()
    }

    [void] FromPS() {
        $props = $this.Properties.PSObject.Properties.Name
        $classProps = $this.PSObject.Properties.Name
        
        $instanceProps = [PSCustomObject]@{}
        foreach ($prop in $props) {
            if($classProps -contains $prop) {
                $this.$prop = $this.Properties.$prop
            } else {
                $instanceProps = $instanceProps | Add-Member -MemberType NoteProperty -Name $prop -Value $this.Properties.$prop -PassThru
            }
        }
        $this.Properties = $instanceProps
    }

    [PSCustomObject] ToPS() {
        $out = [PSCustomObject]@{}
        $classProps = [System.Collections.ArrayList]($this.PSObject.Properties.Name)

        $classProps.Remove('Database')
        $classProps.Remove('Collection')

        if ($this.BundleId.Guid -like "00000000-0000-0000-0000-000000000000") {
            $classProps.Remove('BundleId')
        }

        if ($this.UTC_Created -eq 0) {
            $classProps.Remove('UTC_Created')
        }

        if ($this.UTC_Updated -eq 0) {
            $classProps.Remove('UTC_Updated')
        }

        if ($this.ObjVer -eq 0) {
            $classProps.Remove('ObjVer')
        }

        if ($this._id -like "") {
            $classProps.Remove('_id')
        }
        
        if ($this.VersionId -like "") {
            $classProps.Remove('VersionId')
        }

        if (($this.Properties | Get-Member -MemberType NoteProperty).Count -eq 0){
            $classProps.Remove('Properties')
        } else {
            $instanceProps = $this.Properties.PSObject.Properties.Name
            foreach ($instanceProp in $instanceProps) {
                $out = $out | Add-Member -MemberType NoteProperty -Name $instanceProp -Value $this.Properties.$instanceProp -PassThru
            }
            $classProps.Remove('Properties')
        }

        foreach ($classProp in $classProps) {
            $out = $out | Add-Member -MemberType NoteProperty -Name $classProp -Value $this.$classProp -PassThru
        }
        return $out
    }

    [PsCustomObject] Stage() {
        $Obj = $this.ToPS()
        $staged = $this.StageDbObjectDocument($Obj)
        $stagedProps = $staged.PSObject.Properties.Name
        if ($stagedProps -contains '$Ref' -and $stagedProps -contains '$VersionId') {
            $Temp = New-LiteDbAppendOnlyCollection -Database $this.Database -Collection 'Temp'
            $staged = $Temp.GetVersionRef($staged)
        }
        $this.Properties = $staged
        $this.FromPS()
        return $staged
    }

    [PSCustomObject] Commit () {
        $commit = $this.CommitTempObjectAsDbDoc($this.BundleId)
        $this.Properties = $commit[0]
        $this.FromPS()
        return $commit
    }
}

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

# Module Utilities
$utilitiesFolders = @("private")
foreach ($utilitiesFolder in $utilitiesFolders) {
    Get-ChildItem -Recurse "$PSScriptRoot\$utilitiesFolder\*.ps1" -File | ForEach-Object {
        . $_.FullName
    }
}

# Exported Functions
$exportFolders = @("public")
foreach ($exportFolder in $exportFolders) {
    Get-ChildItem -Recurse "$PSScriptRoot\$exportFolder\*.ps1" -File | ForEach-Object {
        . $_.FullName
    }
}

# Export public functions from this module
Export-ModuleMember -Function * -Alias * -Cmdlet * -Variable *

