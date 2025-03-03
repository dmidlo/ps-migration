function Get-DbDocumentAll {
    <#
    .SYNOPSIS
    Returns all documents in the specified LiteDB collection.

    .PARAMETER Connection
    Active LiteDB.LiteDatabase object.

    .PARAMETER CollectionName
    The target LiteDB collection name.

    .EXAMPLE
    Get-DbDocumentAll -Connection $db -CollectionName 'Domains'
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [LiteDB.LiteDatabase] $Database,

        [Parameter(Mandatory, ValueFromPipeline)]
        $Collection,
        
        [switch]$ResolveRefs
    )

    process {
        $result = Get-LiteData -Collection $Collection -As PS

        if ($ResolveRefs) {
            $resolved = $result | ForEach-Object {
                if ($_.PSObject.Properties.Name -contains '$Ref') {
                    $_ | Get-DbHashRef -Database $Database -Collection $Collection
                }
                else {
                    $_
                }
            }
            Write-Output $resolved
        }
        else {
            # If none found, returns empty array
            Write-Output $result
        }
    }
}
