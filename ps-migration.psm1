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
class LiteDbAppendOnlyStore {
    [LiteDB.LiteDatabase] $Database
    $Collection

    LiteDbAppendOnlyStore ([LiteDB.LiteDatabase] $Database, $Collection) {
        $this.Database   = $Database
        $this.Collection = $Collection
    }

    [PSObject] Create([PSCustomObject] $Data) {
        # Delegates to Add-DbDocument
        return Add-DbDocument `
            -Database $this.Database `
            -Collection $this.Collection `
            -Data $Data
    }

    [PSObject] Create([PSCustomObject] $Data, [string[]] $IgnoreFields) {
        # Delegates to Add-DbDocument
        return Add-DbDocument `
            -Database $this.Database `
            -Collection $this.Collection `
            -Data $Data `
            -IgnoreFields $IgnoreFields
    }

    [void] EnsureCollection([string] $CollectionName, [array]$Indexes) {
        Ensure-LiteDBCollection -Database $this.Database -CollectionName $CollectionName -Indexes $Indexes
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

    [System.Object[]] ReadAll() {
        # Delegates to Get-DbDocumentAll
        return Get-DbDocumentAll `
            -Datbase $this.Database `
            -Collection $this.Collection
    }

    [System.Object[]] ReadAll([switch] $ResolveRefs) {
        # Delegates to Get-DbDocumentAll
        return Get-DbDocumentAll `
            -Datbase $this.Database `
            -Collection $this.Collection `
            -ResolveRefs:$ResolveRefs
    }

    [PSCustomObject] ReadByHash([string] $Hash) {
        # Delegates to Get-DbDocumentByHash
        return Get-DbDocumentByHash `
            -Database $this.Database `
            -Collection $this.Collection `
            -Hash $Hash
    }

    [PSCustomObject] ReadByHash([string] $Hash, [switch] $ResolveRefs) {
        # Delegates to Get-DbDocumentByHash
        return Get-DbDocumentByHash `
            -Database $this.Database `
            -Collection $this.Collection `
            -Hash $Hash `
            -ResolveRefs:$ResolveRefs
    }

    [PSCustomObject] ReadById([Object] $Id) {
        # Delegates to Get-DbDocumentById
        return Get-DbDocumentById `
            -Database $this.Database `
            -Collection $this.Collection `
            -Id $Id
    }

    [PSCustomObject] ReadById([Object] $Id, [switch] $ResolveRefs) {
        # Delegates to Get-DbDocumentById
        return Get-DbDocumentById `
            -Database $this.Database `
            -Collection $this.Collection `
            -Id $Id `
            -ResolveRefs:$ResolveRefs
    }

    [PSCustomObject] ReadVersion(
        [string]$Hash,
        [dbVersionSteps]$Version
    ) {
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

    [PSCustomObject] ReadVersion(
        [string]$Hash,
        [dbVersionSteps]$Version,
        [switch]$ResolveRefs
    ) {
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

    [PSCustomObject] GetGuidRef([PSCustomObject] $DbGuidRef) {
        return Get-DbGuidRef -Database $this.Database -Collection $this.Collection -DbGuidRef $DbGuidRef
    }

    [PSCustomObject] GetHashRef([PSCustomObject] $DbHashRef) {
        return Get-DbHashRef -Database $this.Database -Collection $this.Collection -DbHashRef $DbHashRef
    }

    # Need a method to move documents from one collection to another when documents may also have DbRefs that may also need updating
    [void] Delete([string] $Hash) {
        throw "Delete not implemented. This is an append-only (forward-only) journaling system."
    }
}


# Export public functions from this module
Export-ModuleMember -Function * -Alias * -Cmdlet * -Variable *
