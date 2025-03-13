function Get-DbDocumentByContentMark {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [LiteDB.LiteDatabase] $Database,

        [Parameter(Mandatory)]
        $Collection,

        [Parameter(Mandatory, ValueFromPipeline)]
        [string] $ContentMark,

        [switch]$ResolveRefs
    )

    process {
        # Perform a direct lookup by ContentMark using existing helper
        ($result = Get-LiteData -Collection $Collection -Where 'ContentMark = @ContentMark', @{ContentMark = $ContentMark} -As PS) | Out-Null
        if (-not $result) {
            # Return null if nothing is found
            return $null
        }

        # If multiple records somehow matched
        $out = [System.Collections.Generic.List[psobject]]::New()
        if ($result.Count -gt 1) {
            Write-Warning "Multiple documents found for ContentMark '$ContentMark'."
            if ($ResolveRefs) {
                foreach ($_ in $result) {
                    if ($_.PSObject.Properties.Name -contains '$Ref') {
                        ($version = $_ | Get-DbVersionRef -Database $Database -Collection $Collection) | Out-Null
                        $out.Add($version)
                    }
                    else {
                        $out.Add($_)
                    }
                }
                return $out
            }
            else {
                foreach ($_ in $result) {
                    $out.Add($_)
                }
                return $out
            }
        }

        if ($ResolveRefs) {
            $out.Add(($result | Get-DbVersionRef -Database $Database -Collection $Collection))
            return $out
        }
        else {
            $out.Add($result)
            return @(,$out)
        }
    }

}
