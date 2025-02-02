<#
.SYNOPSIS
    Retrieves modules that declare a dependency on a specified module.

.DESCRIPTION
    The Get-ReverseModuleDependency cmdlet examines installed modules and identifies those that
    declare a dependency on a target module via the RequiredModules key in their manifest.
    It accepts PSModuleInfo objects from the pipeline (or uses all available modules if none are provided)
    and outputs a flat collection of custom objects. Optionally, a visual reverse dependency tree is
    displayed on the host.

.PARAMETER InputObject
    Optional. One or more PSModuleInfo objects (for example, from Get-Module -ListAvailable). The cmdlet
    accepts pipeline input.

.PARAMETER ModuleName
    The name of the module to search for as a dependency. This parameter is required.

.PARAMETER ModuleVersion
    Optional. The version of the module dependency to match. If specified, only modules that require the
    target module at this exact version will be returned.

.PARAMETER AsTree
    Switch. If provided, the cmdlet writes a visual reverse dependency tree to the host.
    (Note that the pipeline output remains a flat collection.)

.EXAMPLE
    Get-Module -ListAvailable | Get-ReverseModuleDependency -ModuleName 'MyModule'

    This example pipes all available modules into the cmdlet and returns those modules that declare a
    dependency on 'MyModule'.

.EXAMPLE
    Get-ReverseModuleDependency -ModuleName 'MyModule' -ModuleVersion '1.2.0' -AsTree

    This example retrieves reverse dependency information for modules that depend on 'MyModule' version
    1.2.0 and displays a visual dependency tree.

.OUTPUTS
    PSCustomObject with properties:
        - Module: Name of the module that requires the target module.
        - ModulePath: The file path of the module.
        - Dependency: The dependency module name (should equal ModuleName).
        - DependencyVersion: The declared dependency version (if any).

.NOTES
    This cmdlet supports the -ListAvailable featureset. If no pipeline input is provided, it will automatically
    query all available modules via Get-Module -ListAvailable.
#>
function Get-ReverseModuleDependency {
    [CmdletBinding(DefaultParameterSetName = 'Default')]
    [OutputType([pscustomobject])]
    param(
        [Parameter(
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = "Module objects (PSModuleInfo) from Get-Module -ListAvailable."
        )]
        [System.Management.Automation.PSModuleInfo[]]$InputObject,

        [Parameter(
            Mandatory = $true,
            Position = 0,
            HelpMessage = "The name of the module to search for as a dependency."
        )]
        [string]$ModuleName,

        [Parameter(
            Mandatory = $false,
            HelpMessage = "Optional. The version of the module dependency to match."
        )]
        [string]$ModuleVersion,

        [Parameter(
            Mandatory = $false,
            HelpMessage = "Switch to display a visual reverse dependency tree."
        )]
        [switch]$AsTree
    )

    begin {
        # Prepare a collection to store pipelined module objects.
        $inputModules = @()
    }
    process {
        if ($_ -is [System.Management.Automation.PSModuleInfo]) {
            $inputModules += $_
        }
    }
    end {
        # If no modules were piped in, retrieve all available modules.
        if ($inputModules.Count -eq 0) {
            try {
                $inputModules = Get-Module -ListAvailable -ErrorAction Stop
            }
            catch {
                Write-Error "Failed to retrieve available modules: $_"
                return
            }
        }

        $results = @()

        # Examine each module's manifest for a dependency on the target module.
        foreach ($mod in $inputModules) {
            if ($mod.RequiredModules) {
                foreach ($req in $mod.RequiredModules) {
                    # A dependency can be a string (just the module name) or a hashtable (with more details).
                    $reqName    = if ($req -is [string])   { $req }
                                  elseif ($req -is [hashtable]) { $req.ModuleName }
                                  else { continue }
                    $reqVersion = if ($req -is [hashtable]) { $req.ModuleVersion } else { $null }

                    if ($reqName -eq $ModuleName) {
                        if ($ModuleVersion) {
                            if ($reqVersion -eq $ModuleVersion) {
                                $results += [pscustomobject]@{
                                    Module            = $mod.Name
                                    ModulePath        = $mod.Path
                                    Dependency        = $reqName
                                    DependencyVersion = $reqVersion
                                }
                            }
                        }
                        else {
                            $results += [pscustomobject]@{
                                Module            = $mod.Name
                                ModulePath        = $mod.Path
                                Dependency        = $reqName
                                DependencyVersion = $reqVersion
                            }
                        }
                    }
                }
            }
        }

        if ($AsTree) {
            # Build a reverse dependency lookup table from all installed modules.
            try {
                $allModules = Get-Module -ListAvailable -ErrorAction Stop
            }
            catch {
                Write-Error "Failed to retrieve modules for tree display: $_"
                return
            }

            $reverseLookup = @{}
            foreach ($m in $allModules) {
                if ($m.RequiredModules) {
                    foreach ($req in $m.RequiredModules) {
                        $depName = if ($req -is [string])   { $req }
                                   elseif ($req -is [hashtable]) { $req.ModuleName }
                                   else { continue }
                        if (-not $reverseLookup.ContainsKey($depName)) {
                            $reverseLookup[$depName] = @()
                        }
                        $reverseLookup[$depName] += $m.Name
                    }
                }
            }

            # Nested helper function to recursively write the dependency tree.
            function Write-Tree {
                param(
                    [string]$CurrentModule,
                    [string]$Prefix = ''
                )
                Write-Host "$Prefix$CurrentModule" -ForegroundColor Cyan
                if ($reverseLookup.ContainsKey($CurrentModule)) {
                    $children  = $reverseLookup[$CurrentModule] | Sort-Object
                    $lastIndex = $children.Count - 1
                    for ($i = 0; $i -lt $children.Count; $i++) {
                        $child  = $children[$i]
                        $isLast = ($i -eq $lastIndex)
                        $branch = if ($isLast) { "└─" } else { "├─" }
                        Write-Host "$Prefix$branch $child" -ForegroundColor Green
                        if ($reverseLookup.ContainsKey($child)) {
                            $childPrefix = $Prefix + (if ($isLast) { "   " } else { "│  " })
                            Write-Tree -CurrentModule $child -Prefix $childPrefix
                        }
                    }
                }
            }

            Write-Host ""
            Write-Host "Reverse Dependency Tree for module '$ModuleName':" -ForegroundColor Yellow
            Write-Tree -CurrentModule $ModuleName
            Write-Host ""
        }

        # Output the flat collection (sorted by module name) so that further pipelining is possible.
        $results | Sort-Object Module | Write-Output
    }
}
