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

    LiteDbAppendOnlyCollection ([LiteDB.LiteDatabase] $Database, $Collection) {
        $this.Database   = $Database
        $this.Collection = $Collection
    }

    [PSObject] Add([PSCustomObject] $Data) {
        # Delegates to Add-DbDocument
        return Add-DbDocument -Database $this.Database -Collection $this.Collection -Data $Data
    }

    [PSObject] Add_NoVersionUpdate([PSCustomObject] $Data) {
        # Delegates to Add-DbDocument
        return Add-DbDocument -Database $this.Database -Collection $this.Collection -Data $Data -NoVersionUpdate
    }

    [PSObject] Add_NoTimestampUpdate([PSCustomObject] $Data) {
        # Delegates to Add-DbDocument
        return Add-DbDocument -Database $this.Database -Collection $this.Collection -Data $Data -NoTimestampUpdate
    }

    [PSObject] Add_NoVersionOrTimestampUpdate([PSCustomObject] $Data) {
        # Delegates to Add-DbDocument
        return Add-DbDocument -Database $this.Database -Collection $this.Collection -Data $Data -NoVersionUpdate -NoTimestampUpdate
    }

    [PSObject] Add([PSCustomObject] $Data, [string[]] $IgnoreFields) {
        # Delegates to Add-DbDocument
        return Add-DbDocument -Database $this.Database -Collection $this.Collection -Data $Data -IgnoreFields $IgnoreFields
    }

    [PSObject] Add_NoVersionUpdate([PSCustomObject] $Data, [string[]] $IgnoreFields) {
        # Delegates to Add-DbDocument
        return Add-DbDocument -Database $this.Database -Collection $this.Collection -Data $Data -NoVersionUpdate -IgnoreFields $IgnoreFields
    }

    [PSObject] Add_NoTimestampUpdate([PSCustomObject] $Data, [string[]] $IgnoreFields) {
        # Delegates to Add-DbDocument
        return Add-DbDocument -Database $this.Database -Collection $this.Collection -Data $Data -NoTimestampUpdate -IgnoreFields $IgnoreFields
    }

    [PSObject] Add_NoVersionOrTimestampUpdate([PSCustomObject] $Data, [string[]] $IgnoreFields) {
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
            -Datbase $this.Database `
            -Collection $this.Collection
    }

    [System.Object[]] GetAll([switch] $ResolveRefs) {
        # Delegates to Get-DbDocumentAll
        return Get-DbDocumentAll `
            -Datbase $this.Database `
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

    # TODO [ ]: Need a method to move documents from one collection to another when documents may also have DbRefs that may also need updating

    [void] Delete([string] $Hash) {
        throw "Delete not implemented. This is an append-only (forward-only) journaling system."
    }
}


# Export public functions from this module
Export-ModuleMember -Function * -Alias * -Cmdlet * -Variable *
