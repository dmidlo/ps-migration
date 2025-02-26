function Get-DbDocumentById {
    <#
    .SYNOPSIS
    Retrieves a single LiteDB document by its _id.

    .PARAMETER Connection
    Active LiteDB.LiteDatabase object.

    .PARAMETER CollectionName
    The target LiteDB collection name.

    .PARAMETER Id
    The LiteDB _id value to look up. Adjust type if needed 
    (e.g., [String], [int], or [LiteDB.ObjectId]).

    .EXAMPLE
    Get-DbDocumentById -Connection $db -CollectionName 'Domains' -Id 123
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [LiteDB.LiteDatabase] $Database,

        [Parameter(Mandatory)]
        $Collection,

        [Parameter(Mandatory, ValueFromPipeline)]
        [Object] $Id,

        [switch]$ResolveRefs
    )

    process {
        $result = Get-LiteData -Collection $collection -ById $Id -As PS
        
        if (-not $result) {
            return $null
        }

        # If multiple found (unexpected for an _id), return first + warning
        if ($result.Count -gt 1) {
            Write-Warning "Multiple documents found for Hash '$Hash'. Returning the first match."
            if ($ResolveRefs) {
                $resolved = $result | ForEach-Object {
                    if ($_.PSObject.Properties.Name -contains '$Ref') {
                        $_ | Get-DbHashRef -Database $Database -Collection $Collection
                    }
                    else {
                        $_
                    }
                }
            }
            Write-Output ($resolved | Select-Object -First 1)
        }

        if ($ResolveRefs) {
            Write-Output ($result | Get-DbHashRef -Database $Database -Collection $Collection)
        }
        else {
            Write-Output $result
        }
    }
}
