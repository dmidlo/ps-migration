function Get-DbDocumentByVersionId {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [LiteDB.LiteDatabase] $Database,

        [Parameter(Mandatory)]
        $Collection,

        [Parameter(Mandatory, ValueFromPipeline)]
        [string] $VersionId,

        [switch]$ResolveRefs
    )

    process {
        # Perform a direct lookup by Version using your existing helper
        ($result = Get-LiteData -Collection $Collection -Where 'VersionId = @VersionId', @{VersionId = $VersionId} -As PS) | Out-Null

        if (-not $result) {
            # Return null if nothing is found
            return $null
        }

        # If multiple records somehow matched, assume the first is the canonical
        if ($result.Count -gt 1) {
            Write-Warning "Multiple documents found for VersionId '$VersionId'. Returning the first match."
            if ($ResolveRefs) {
                $resolved = $result | ForEach-Object {
                    if ($_.PSObject.Properties.Name -contains '$Ref') {
                        ($return = $_ | Get-DbVersionRef -Database $Database -Collection $Collection) | Out-Null
                        $return
                    }
                    else {
                        $_
                    }
                }
            }
            Write-Output ($resolved | Select-Object -First 1)
        }

        if ($ResolveRefs) {
            Write-Output ($result | Get-DbVersionRef -Database $Database -Collection $Collection)
        }
        else {
            Write-Output $result
        }
    }

}
