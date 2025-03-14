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
        $BundleId | Set-DbBundleCollection -Database $this.Database -SourceCollection $this.Collection -DestCollection $DestCollection -NoTimestampUpdate
    }

    [void] MoveDbObjectToCollection([PSObject]$DbObject, $DestCollection) {
        $DbObject[0].BundleId | Set-DbBundleCollection -Database $this.Database -SourceCollection $this.Collection -DestCollection $DestCollection -NoTimestampUpdate
    }

    [Void] MoveDbObjectFromCollection([Guid]$BundleId, $SourceCollection) {
        $BundleId | Set-DbBundleCollection -Database $this.Database -SourceCollection $SourceCollection -DestCollection $this.Collection -NoTimestampUpdate
    }

    [Void] MoveDbObjectFromCollection([PSObject]$DbObject, $SourceCollection) {
        $DbObject[0].BundleId | Set-DbBundleCollection -Database $this.Database -SourceCollection $SourceCollection -DestCollection $this.Collection -NoTimestampUpdate
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
