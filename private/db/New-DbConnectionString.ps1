function New-DbConnectionString {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipelineByPropertyName)]
        [switch]$ReadOnly,

        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$Culture = "en-US",

        [Parameter(ValueFromPipelineByPropertyName)]
        [switch]$IgnoreCase,

        [Parameter(ValueFromPipelineByPropertyName)]
        [switch]$IgnoreNonSpace,

        [Parameter(ValueFromPipelineByPropertyName)]
        [switch]$IgnoreSymbols,

        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateSet("Shared", "Direct")]
        [string]$ConnectionType = "Direct",

        [Parameter(ValueFromPipelineByPropertyName)]
        [switch]$AutoRebuild,

        [Parameter(ValueFromPipelineByPropertyName)]
        [switch]$AutoUpgrade,

        [Parameter(ValueFromPipelineByPropertyName)]
        [long]$InitialSize,

        [Parameter(ValueFromPipelineByPropertyName)]
        [pscredential]$Password,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string]$FilePath
    )

    process {
        # Create LiteDB connection string object
        $connectionString = [LiteDB.ConnectionString]::New()

        # Set AutoRebuild
        if ($AutoRebuild) {
            $connectionString.set_AutoRebuild($true)
        }

        # Set Collation
        $LocaleId = [System.Globalization.CultureInfo]::GetCultureInfo($Culture)
        $CompareOptions = 0

        if ($IgnoreCase) { $CompareOptions = $CompareOptions -bor [System.Globalization.CompareOptions]::IgnoreCase }
        if ($IgnoreNonSpace) { $CompareOptions = $CompareOptions -bor [System.Globalization.CompareOptions]::IgnoreNonSpace }
        if ($IgnoreSymbols) { $CompareOptions = $CompareOptions -bor [System.Globalization.CompareOptions]::IgnoreSymbols }

        if ($Password) {
            $connectionString.set_Password($Password.GetNetworkCredential().Password)
        }

        if ($InitialSize) {
            $connectionString.set_InitialSize($InitialSize)
        }

        if ($AutoUpgrade) {
            $connectionString.set_Upgrade($AutoUpgrade)
        }
        
        if ($ReadOnly) {
            $connectionString.set_ReadOnly($ReadOnly)
        }

        $connectionString.set_Collation([LiteDB.Collation]::New($LocaleId.LCID, $CompareOptions))

        # Set Connection Type
        $connectionString.set_Connection([LiteDB.ConnectionType]::$ConnectionType)

        # Set Database Filename
        $connectionString.set_Filename($FilePath)

        # Output Connection String
        return $connectionString
    }
}
