function Ensure-LiteDBCollection {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true,
                   ValueFromPipelineByPropertyName = $true)]
        [LiteDB.LiteDatabase]
        $Connection,

        [Parameter(Mandatory = $true,
                   ValueFromPipelineByPropertyName = $true)]
        [string]
        $CollectionName,

        # Each element is a PSCustomObject that can have:
        #   Field      = 'fieldName' (required)
        #   Unique     = $true or $false (optional)
        #   Expression = 'some expression' (optional for expression-based index)
        [PSCustomObject[]]
        $Indexes = @()
    )
    <#
    .SYNOPSIS
    Ensures that the specified LiteDB collection and indexes exist.

    .DESCRIPTION
    This function first ensures that a collection named $CollectionName exists by calling
    New-LiteDBCollection. If it already exists, no error is thrown. Then, it loops over
    each index definition in $Indexes and attempts to create it with New-LiteDBIndex. If
    the index already exists (or if there's another conflict), a warning is written, but
    the function continues.

    .PARAMETER Connection
    The LiteDB.LiteDatabase object (from Open-LiteDBConnection).

    .PARAMETER CollectionName
    The name of the collection to create or ensure exists.

    .PARAMETER Indexes
    An array of PSCustomObject definitions for indexes. Each object must contain at least
    a `Field` property. Optionally, `Unique` (bool) and `Expression` (string) can be included.

    .EXAMPLE
    Ensure-LiteDBCollection -Connection $db -CollectionName 'Movies' -Indexes @(
        [PSCustomObject]@{ Field='Title'; Unique=$true },
        [PSCustomObject]@{ Field='Genre'; Expression='LOWER($.Genre)' }
    )
    #>
    
    # 1) Ensure the collection exists. If it already exists, this is a no-op.
    New-LiteDBCollection -Collection $CollectionName -Connection $Connection

    # 2) Create indexes
    foreach ($idx in $Indexes) {
        if (-not $idx.Field) {
            Write-Error "Index definition must contain a 'Field' property."
            continue
        }

        $unique = $false
        if ($idx.PSObject.Properties.Name -contains 'Unique') {
            $unique = [bool]$idx.Unique
        }

        $expression = $null
        if ($idx.PSObject.Properties.Name -contains 'Expression') {
            $expression = [string]$idx.Expression
        }

        try {
            if ($expression) {
                New-LiteDBIndex -Collection $CollectionName `
                                -Field $idx.Field `
                                -Unique:$unique `
                                -Expression $expression `
                                -Connection $Connection
            }
            else {
                New-LiteDBIndex -Collection $CollectionName `
                                -Field $idx.Field `
                                -Unique:$unique `
                                -Connection $Connection
            }
        }
        catch {
            Write-Warning "Could not create index on field '$($idx.Field)': $($_.Exception.Message)"
        }
    }
}
