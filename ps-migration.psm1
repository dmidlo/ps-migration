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

    hidden [PSObject] Add([PSCustomObject] $Data) {
        # Delegates to Add-DbDocument
        return Add-DbDocument -Database $this.Database -Collection $this.Collection -Data $Data
    }

    hidden [PSObject] Add_NoVersionUpdate([PSCustomObject] $Data) {
        # Delegates to Add-DbDocument
        return Add-DbDocument -Database $this.Database -Collection $this.Collection -Data $Data -NoVersionUpdate
    }

    hidden [PSObject] Add_NoTimestampUpdate([PSCustomObject] $Data) {
        # Delegates to Add-DbDocument
        return Add-DbDocument -Database $this.Database -Collection $this.Collection -Data $Data -NoTimestampUpdate
    }

    hidden [PSObject] Add_NoVersionOrTimestampUpdate([PSCustomObject] $Data) {
        # Delegates to Add-DbDocument
        return Add-DbDocument -Database $this.Database -Collection $this.Collection -Data $Data -NoVersionUpdate -NoTimestampUpdate
    }

    hidden [PSObject] Add([PSCustomObject] $Data, [string[]] $IgnoreFields) {
        # Delegates to Add-DbDocument
        return Add-DbDocument -Database $this.Database -Collection $this.Collection -Data $Data -IgnoreFields $IgnoreFields
    }

    hidden [PSObject] Add_NoVersionUpdate([PSCustomObject] $Data, [string[]] $IgnoreFields) {
        # Delegates to Add-DbDocument
        return Add-DbDocument -Database $this.Database -Collection $this.Collection -Data $Data -NoVersionUpdate -IgnoreFields $IgnoreFields
    }

    hidden [PSObject] Add_NoTimestampUpdate([PSCustomObject] $Data, [string[]] $IgnoreFields) {
        # Delegates to Add-DbDocument
        return Add-DbDocument -Database $this.Database -Collection $this.Collection -Data $Data -NoTimestampUpdate -IgnoreFields $IgnoreFields
    }

    hidden [PSObject] Add_NoVersionOrTimestampUpdate([PSCustomObject] $Data, [string[]] $IgnoreFields) {
        # Delegates to Add-DbDocument
        return Add-DbDocument -Database $this.Database -Collection $this.Collection -Data $Data -NoVersionUpdate -NoTimestampUpdate -IgnoreFields $IgnoreFields
    }

    [void] EnsureCollection([array]$Indexes) {
        Ensure-LiteDBCollection -Database $this.Database -CollectionName $this.Collection -Indexes $Indexes
    }

    [void] EnsureCollection([array]$Indexes, [string]$CollectionName) {
        Ensure-LiteDBCollection -Database $this.Database -CollectionName $CollectionName -Indexes $Indexes
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
        $Guid | Set-DbObjectCollectionByGuid -Database $this.Database -SourceCollection $this.Collection -DestCollection $DestCollection
    }

    [void] MoveDbObjectToCollection([PSObject]$DbObject, $DestCollection) {
        $DbObject[0].Guid | Set-DbObjectCollectionByGuid -Database $this.Database -SourceCollection $this.Collection -DestCollection $DestCollection
    }

    [Void] MoveDbObjectFromCollection([Guid]$Guid, $SourceCollection) {
        $Guid | Set-DbObjectCollectionByGuid -Database $this.Database -SourceCollection $SourceCollection -DestCollection $this.Collection
    }

    [Void] MoveDbObjectFromCollection([PSObject]$DbObject, $SourceCollection) {
        $DbObject[0].Guid | Set-DbObjectCollectionByGuid -Database $this.Database -SourceCollection $SourceCollection -DestCollection $this.Collection
    }

    static [Void] MoveDbObject([Guid]$Guid, [LiteDB.LiteDatabase]$Database, $SourceCollection, $DestCollection) {
        $Guid | Set-DbObjectCollectionByGuid -Database $Database -SourceCollection $SourceCollection -DestCollection $DestCollection
    }

    static [Void] MoveDbObject([PSObject]$DbObject, [LiteDB.LiteDatabase]$Database, $SourceCollection, $DestCollection) {
        $DbObject[0].Guid | Set-DbObjectCollectionByGuid -Database $Database -SourceCollection $SourceCollection -DestCollection $DestCollection
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
        $RecycleBin = Get-LiteCollection -Database $this.Database -CollectionName "RecycleBin"
        $DbObject = $this.GetVersionsByGuid($Guid)
        foreach ($version in $DbObject) {
            Write-Host $version.'$BaseCol'
            $version.PSObject.Properties.Remove('$BaseCol')
            Write-Host $version.'$BaseCol'
        }
        foreach ($version in $DbObject) {
            $version.PSObject.Properties.Remove('$BaseCol')
            $version.PSObject.Properties.Remove('$RecycledTime')
            $version | Set-LiteData -Collection $RecycleBin
        }
        $DbObject = $this.GetVersionsByGuid($DbObject[0].Guid)
        $this.MoveDbObjectFromCollection($RecycleBin)
    }

    [void] EmptyRecycleBin() {
        $RecycleBin = Get-LiteCollection -Database $this.Database -CollectionName 'RecycleBin'
        Remove-LiteData -Collection $RecycleBin -Where '$BaseCol = @BaseCol', @{BaseCol = $this.Collection.Name}
    }

    [void] EmptyRecycleBin([Guid]$Guid) {
        $RecycleBin = Get-LiteCollection -Database $this.Database -CollectionName 'RecycleBin'
        Remove-LiteData -Collection $RecycleBin -Where 'Guid = @Guid', @{Guid = $Guid}
    }

    [void] StageDbObject([PSCustomObject] $DbObject) {
        $Temp = Get-LiteCollection -Database $this.Database -CollectionName 'Temp'
        
        # Add `$DestCol` property to track where the object should go upon commit
        $DbObject = $DbObject | Add-Member -MemberType NoteProperty -Name '$DestCol' -Value $this.Collection.Name -Force -PassThru
        
        Add-LiteData -Collection $Temp -InputObject $DbObject
    }

    [void] CommitDbObject([Guid] $Guid) {
        $Temp = Get-LiteCollection -Database $this.Database -CollectionName 'Temp'
        $DbObject = Get-LiteData -Collection $Temp -Where 'Guid = @Guid', @{Guid = $Guid}

        if ($DbObject) {
            # Determine target collection from $DestCol
            $TargetCollection = Get-LiteCollection -Database $this.Database -CollectionName $DbObject[0].'$DestCol'

            # Remove `$DestCol` property before committing
            $DbObject | ForEach-Object {
                $_.PSObject.Properties.Remove('$DestCol')
            }

            $this.MoveDbObjectToCollection($DbObject, $TargetCollection)
        }
    }

    [void] ClearTemp([Guid] $Guid) {
        $Temp = Get-LiteCollection -Database $this.Database -CollectionName 'Temp'
        $DbObject = Get-LiteData -Collection $Temp -Where 'Guid = @Guid', @{Guid = $Guid}

        if ($DbObject -and ($DbObject[0].'$DestCol' -eq $this.Collection.Name)) {
            $this.RecycleDbObject($DbObject)
        }
    }

    [void] ClearTemp() {
        $Temp = Get-LiteCollection -Database $this.Database -CollectionName 'Temp'
        $DbObjects = Get-LiteData -Collection $Temp -Where '$DestCol = @DestCol', @{DestCol = $this.Collection.Name}

        foreach ($DbObject in $DbObjects) {
            $this.RecycleDbObject($DbObject)
        }
    }

    [bool] HashExists([string] $Hash) {
        return Test-LiteData -Collection $this.Collection -Where 'Hash = @Hash', @{Hash = $Hash}
    }

    [bool] GuidExists([Guid] $Guid) {
        return Test-LiteData -Collection $this.Collection -Where 'Guid = @Guid', @{Guid = $Guid}
    }


}


# Export public functions from this module
Export-ModuleMember -Function * -Alias * -Cmdlet * -Variable *
