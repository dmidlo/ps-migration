@{
    # Script module or binary module file associated with this manifest.
    RootModule        = 'ps-migration.psm1'

    # Version number of this module.
    ModuleVersion     = '1.0.0'

    # ID used to uniquely identify this module
    #GUID              = '00000000-0000-0000-0000-000000000001'

    # Author of this module
    Author            = 'David Midlo'

    # Company or vendor of this module
    #CompanyName       = 'Your Company'

    # Copyright
    #Copyright         = '(c) 2025 Your Name'

    # Description of the functionality provided by this module
    Description       = 'A Pode.Web-based module for migrating users, building custom routes/pages/widgets, etc.'

    # Minimum version of the PowerShell host required by this module
    PowerShellVersion = '7.4.6'

    # Modules that must be installed from the gallery
    RequiredModules   = @(
        @{ ModuleName = 'Pode'; ModuleVersion = '2.9.0' },  # example versions
        @{ ModuleName = 'Pode.Web'; ModuleVersion = '0.8.3' }
    )

    # Functions to export from this module
    FunctionsToExport = '*'
    # Cmdlets to export from this module
    CmdletsToExport   = @()
    # Variables to export from this module
    VariablesToExport = '*'
    # Aliases to export from this module
    AliasesToExport   = '*'

    # Private data to pass to the module
    PrivateData       = @{
        PSData = @{
            Tags       = @('pode','pode.web','migration','ad','dhcp')
            LicenseUri = 'https://opensource.org/licenses/MIT'
            ProjectUri = 'https://github.com/dmidlo/ps-migration'
        }
    }
}
