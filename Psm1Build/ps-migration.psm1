
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
            [PSCustomObject]@{ Field='Hash'; Unique=$true },
            [PSCustomObject]@{ Field="Guid"; Unique=$false}
        ), $this.Collection.Name)
        $this.EnsureCollection(@(
            [PSCustomObject]@{ Field='Hash'; Unique=$true },
            [PSCustomObject]@{ Field="Guid"; Unique=$false}
        ), 'Temp')
        $this.EnsureCollection(@(
            [PSCustomObject]@{ Field='Hash'; Unique=$true },
            [PSCustomObject]@{ Field="Guid"; Unique=$false}
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
        Confirm-LiteDBCollection -Database $this.Database -CollectionName $this.Collection -Indexes $Indexes
    }

    [void] EnsureCollection([array]$Indexes, [string]$CollectionName) {
        Confirm-LiteDBCollection -Database $this.Database -CollectionName $CollectionName -Indexes $Indexes
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

    [PSCustomObject] GetByHash([string] $Hash) {
        # Delegates to Get-DbDocumentByHash
        return Get-DbDocumentByHash `
            -Database $this.Database `
            -Collection $this.Collection `
            -Hash $Hash
    }

    [PSCustomObject] GetByHash([string] $Hash, [switch] $ResolveRefs) {
        # Delegates to Get-DbDocumentByHash
        return Get-DbDocumentByHash `
            -Database $this.Database `
            -Collection $this.Collection `
            -Hash $Hash `
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

    [PSCustomObject] GetVersion([string]$Hash, [dbVersionSteps]$Version) {
        $out = $null
        if ($Version -eq [dbVersionSteps]::Original) {
            $out = Get-DbDocumentVersion -Database $this.Database -Collection $this.Collection -Hash $Hash -Original
        }
        elseif ($Version -eq [dbVersionSteps]::Latest) {
            $out = Get-DbDocumentVersion -Database $this.Database -Collection $this.Collection -Hash $Hash -Latest
        }
        elseif ($Version -eq [dbVersionSteps]::Previous) {
            $out = Get-DbDocumentVersion -Database $this.Database -Collection $this.Collection -Hash $Hash -Previous
        }
        elseif ($Version -eq [dbVersionSteps]::Next) {
            $out = Get-DbDocumentVersion -Database $this.Database -Collection $this.Collection -Hash $Hash -Next
        }

        return $out
    }

    [PSCustomObject] GetVersion([string]$Hash, [dbVersionSteps]$Version, [switch]$ResolveRefs) {
        $out = $null
        if ($Version -eq [dbVersionSteps]::Original) {
            $out = Get-DbDocumentVersion -Database $this.Database -Collection $this.Collection -Hash $Hash -Original -ResolveRefs
        }
        elseif ($Version -eq [dbVersionSteps]::Latest) {
            $out = Get-DbDocumentVersion -Database $this.Database -Collection $this.Collection -Hash $Hash -Latest -ResolveRefs
        }
        elseif ($Version -eq [dbVersionSteps]::Previous) {
            $out = Get-DbDocumentVersion -Database $this.Database -Collection $this.Collection -Hash $Hash -Previous -ResolveRefs
        }
        elseif ($Version -eq [dbVersionSteps]::Next) {
            $out = Get-DbDocumentVersion -Database $this.Database -Collection $this.Collection -Hash $Hash -Next -ResolveRefs
        }

        return $out
    }

    [System.Object[]] GetVersionsByGuid([Guid] $Guid) {
        # Delegates to Get-DbDocumentVersionsByGuid
        return Get-DbDocumentVersionsByGuid `
            -Database $this.Database `
            -Collection $this.Collection `
            -Guid $Guid
    }

    [System.Object[]] GetVersionsByGuid([Guid] $Guid, [switch] $ResolveRefs) {
        # Delegates to Get-DbDocumentVersionsByGuid
        return Get-DbDocumentVersionsByGuid `
            -Database $this.Database `
            -Collection $this.Collection `
            -Guid $Guid `
            -ResolveRefs
    }

    [System.Object[]] GetDbObject([Guid] $Guid) {
        # Delegates to Get-DbDocumentVersionsByGuid
        return Get-DbDocumentVersionsByGuid `
            -Database $this.Database `
            -Collection $this.Collection `
            -Guid $Guid `
            -AsDbObject
    }

    [PSCustomObject] GetGuidRef([PSCustomObject] $DbGuidRef) {
        return Get-DbGuidRef -Database $this.Database -Collection $this.Collection -DbGuidRef $DbGuidRef
    }

    [PSCustomObject] GetHashRef([PSCustomObject] $DbHashRef) {
        return Get-DbHashRef -Database $this.Database -Collection $this.Collection -DbHashRef $DbHashRef
    }

    [PSCustomObject] NewGuidRef([PSCustomObject] $DbObjectDocument, $Collection) {
        return New-DbGuidRef -DbDocument $DbObjectDocument -Collection $Collection -RefCollection $this.Collection
    }

    static [PSCustomObject] NewGuidRef([PSCustomObject] $DbObjectDocument, $Collection, $RefCollection) {
        return New-DbGuidRef -DbDocument $DbObjectDocument -Collection $Collection -RefCollection $RefCollection
    }

    [Void] MoveDbObjectToCollection([Guid]$Guid, $DestCollection) {
        $Guid | Set-DbObjectCollectionByGuid -Database $this.Database -SourceCollection $this.Collection -DestCollection $DestCollection -NoTimestampUpdate
    }

    [void] MoveDbObjectToCollection([PSObject]$DbObject, $DestCollection) {
        $DbObject[0].Guid | Set-DbObjectCollectionByGuid -Database $this.Database -SourceCollection $this.Collection -DestCollection $DestCollection -NoTimestampUpdate
    }

    [Void] MoveDbObjectFromCollection([Guid]$Guid, $SourceCollection) {
        $Guid | Set-DbObjectCollectionByGuid -Database $this.Database -SourceCollection $SourceCollection -DestCollection $this.Collection -NoTimestampUpdate
    }

    [Void] MoveDbObjectFromCollection([PSObject]$DbObject, $SourceCollection) {
        $DbObject[0].Guid | Set-DbObjectCollectionByGuid -Database $this.Database -SourceCollection $SourceCollection -DestCollection $this.Collection -NoTimestampUpdate
    }

    [void] RecycleDbObject([Guid]$Guid) {
        $now = [DateTimeOffset]::UtcNow.ToUnixTimeMilliseconds()
        $RecycleBin = Get-LiteCollection -Database $this.Database -CollectionName 'RecycleBin'
        $DbObject = $this.GetVersionsByGuid($Guid)
        foreach ($version in $DbObject) {
            $version = ($version | Add-Member -MemberType NoteProperty -Name '$RecycledTime' -Value $now -Force -PassThru)
            $version = ($version | Add-Member -MemberType NoteProperty -Name '$BaseCol' -Value $this.Collection.Name -Force -PassThru)
            $version | Set-LiteData -Collection $this.Collection
        }
        $DbObject = $this.GetVersionsByGuid($DbObject[0].Guid)
        $this.MoveDbObjectToCollection($DbObject, $RecycleBin)
    }

    [void] RecycleDbObject([PSObject]$DbObject) {
        $now = [DateTimeOffset]::UtcNow.ToUnixTimeMilliseconds()
        $RecycleBin = Get-LiteCollection -Database $this.Database -CollectionName 'RecycleBin'
        $DbObject = $this.GetVersionsByGuid($DbObject[0].Guid)
        foreach ($version in $DbObject) {
            $version = ($version | Add-Member -MemberType NoteProperty -Name '$RecycledTime' -Value $now -Force -PassThru)
            $version = ($version | Add-Member -MemberType NoteProperty -Name '$BaseCol' -Value $this.Collection.Name -Force -PassThru)
            $version | Set-LiteData -Collection $this.Collection
        }
        $DbObject = $this.GetVersionsByGuid($DbObject[0].Guid)
        $this.MoveDbObjectToCollection($DbObject, $RecycleBin)
    }

    [void] RestoreDbObject([Guid]$Guid) {
        $RecycleBin = New-LiteDbAppendOnlyCollection -Database $this.Database -Collection 'RecycleBin'
        $DbObject = $RecycleBin.GetVersionsByGuid($Guid)
        foreach ($version in $DbObject) {
            $version.PSObject.Properties.Remove('$BaseCol')
            $version.PSObject.Properties.Remove('$RecycledTime')
            $version | Set-LiteData -Collection $RecycleBin.Collection
        }
        $DbObject = $RecycleBin.GetVersionsByGuid($DbObject[0].Guid)
        $RecycleBin.MoveDbObjectToCollection($DbObject, $this.Collection)
    }

    [void] EmptyRecycleBin() {
        $RecycleBin = Get-LiteCollection -Database $this.Database -CollectionName 'RecycleBin'
        Remove-LiteData -Collection $RecycleBin -Where '$BaseCol = @BaseCol', @{BaseCol = $this.Collection.Name}
    }

    [void] EmptyRecycleBin([Guid]$Guid) {
        $RecycleBin = Get-LiteCollection -Database $this.Database -CollectionName 'RecycleBin'
        Remove-LiteData -Collection $RecycleBin -Where 'Guid = @Guid', @{Guid = $Guid}
    }

    [PSCustomObject] StageDbObjectDocument([PSCustomObject] $PSCustomObject) {
        $Temp = New-LiteDbAppendOnlyCollection -Database $this.Database -Collection 'Temp'
        
        # Add `$DestCol` property to track where the object should go upon commit
        $PSCustomObject = $PSCustomObject | Add-Member -MemberType NoteProperty -Name '$DestCol' -Value $this.Collection.Name -Force -PassThru

        $staged = $Temp._Add($PSCustomObject)

        return $staged
    }

    [System.Object[]] CommitTempObjectAsDbDoc([Guid]$Guid) {
        $Temp = New-LiteDbAppendOnlyCollection -Database $this.Database -Collection 'Temp'
        $DbObject = $Temp.GetVersionsByGuid($Guid)
        $out = $Temp.GetVersion($DbObject[0].Hash, [dbVersionSteps]::Latest, $true)
        $original = $Temp.GetVersion($DbObject[0].Hash, [dbVersionSteps]::Original, $true)
        $out.UTC_Created = $original.UTC_Created
        $out.'$ObjVer' = $original.'$ObjVer'
        $out.PSObject.Properties.Remove('$DestCol')
        $out.PSObject.Properties.Remove('$hashArcs')
        foreach ($version in $DbObject) {
            $versionProps = $version.PSObject.Properties.Name
            if ($versionProps -contains '$Ref' -and $versionProps -contains '$Hash') {
                if ($version.'$Hash' -like $out.Hash) {
                    Write-Host "version: $($version.'$Hash')"
                    Write-Host "out: $($out.Hash)"
                    $out | Set-LiteData -Collection $this.Collection
                }
                else {
                    Remove-LiteData -Collection $Temp.Collection -Where 'Hash = @Hash', @{Hash = $version.Hash}
                }
            }
            else {
                if ($version.Hash -like $out.Hash) {
                    Write-Host "version: $($version.'$Hash')"
                    Write-Host "out: $($out.Hash)"
                    $out | Set-LiteData -Collection $this.Collection
                }
                else{
                    Remove-LiteData -Collection $Temp.Collection -Where 'Hash = @Hash', @{Hash = $version.Hash}
                }
            }
        }
        # $Temp.MoveDbObjectToCollection($out, $this.Collection)
        $return = $this.GetVersionsByGuid($out[0].Guid)
        return $return
    }

    [void] CommitAsDbObject([Guid] $Guid) {
        $Temp = New-LiteDbAppendOnlyCollection -Database $this.Database -Collection 'Temp'
        $DbObject = $Temp.GetVersionsByGuid($Guid)
        foreach ($version in $DbObject) {
            $version.PSObject.Properties.Remove('$DestCol')
            $version | Set-LiteData -Collection $Temp.Collection
        }
        $DbObject = $Temp.GetVersionsByGuid($DbObject[0].Guid)
        $Temp.MoveDbObjectToCollection($DbObject, $this.Collection)
    }

    [void] CommitAllDbDocAsDbObject() {
        $Temp = New-LiteDbAppendOnlyCollection -Database $this.Database -Collection "Temp"
        $Guids = $Temp.GetAll() | Where-Object {$_.'$DestCol' -like $this.Collection.Name} | Select-Object -Unique 'Guid'
        foreach ($guid in $Guids) {
            $guid = [Guid]::Parse($guid.Guid)
            $this.CommitDbDocAsDbObject($guid)
        }
    }

    [void] ClearTemp([Guid] $Guid) {
        $Temp = New-LiteDbAppendOnlyCollection -Database $this.Database -Collection 'Temp'
        $RecycleBin = New-LiteDbAppendOnlyCollection -Database $this.Database -Collection 'RecycleBin'

        $Temp.RecycleDbObject($Guid)
        $RecycleBin.EmptyRecycleBin($Guid)
    }

    [void] ClearTemp() {
        $Temp = New-LiteDbAppendOnlyCollection -Database $this.Database -Collection 'Temp'
        $RecycleBin = New-LiteDbAppendOnlyCollection -Database $this.Database -Collection 'RecycleBin'
        $Guids = $Temp.GetAll() | Where-Object {$_.'$DestCol' -like $this.Collection.Name} | Select-Object -Unique 'Guid'
        foreach ($guid in $Guids) {
            $guid = [Guid]::Parse($guid.Guid)
            $Temp.RecycleDbObject($guid)
            $RecycleBin.EmptyRecycleBin($guid)
        }
    }

    [bool] HashExists([string] $Hash) {
        return Test-LiteData -Collection $this.Collection -Where 'Hash = @Hash', @{Hash = $Hash}
    }

    [bool] GuidExists([Guid] $Guid) {
        return Test-LiteData -Collection $this.Collection -Where 'Guid = @Guid', @{Guid = $Guid}
    }


}

[NoRunspaceAffinity()]
class LiteDbAppendOnlyDocument : LiteDbAppendOnlyCollection {
    # This someday may be helpfully converted to three classes once [Type] `-is` conditionals
    # are backported into supporting code to support additional type safety and project code consistency
    # for now, this will be base class for Standard DB Documents, Temp Db Documents, Recycled DBdocuments, and HashRef/GuidRef Db Documents
    [LiteDB.ObjectId]$_id
    [Guid]$Guid
    [string]$Hash
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

        if ($this.Guid.Guid -like "00000000-0000-0000-0000-000000000000") {
            $classProps.Remove('Guid')
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
        
        if ($this.Hash -like "") {
            $classProps.Remove('Hash')
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
        if ($stagedProps -contains '$Ref' -and $stagedProps -contains '$Hash') {
            $Temp = New-LiteDbAppendOnlyCollection -Database $this.Database -Collection 'Temp'
            $staged = $Temp.GetHashRef($staged)
        }
        $this.Properties = $staged
        $this.FromPS()
        return $staged
    }

    [PSCustomObject] Commit () {
        $commit = $this.CommitTempObjectAsDbDoc($this.Guid)
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

# Export public functions from this module
Export-ModuleMember -Function * -Alias * -Cmdlet * -Variable *

