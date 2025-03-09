function Initialize-LiteDBCollection {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [LiteDB.ILiteDatabase]
        $Database,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string]
        $CollectionName,

        [PSCustomObject[]]
        $Indexes = @()
    )

    <#
    .SYNOPSIS
    Ensures that a LiteDB collection exists and applies indexing.

    .DESCRIPTION
    - Retrieves or creates the collection.
    - Ensures indexes using `EnsureIndex()` directly on the LiteCollection object.
    - Automatically sets AutoId to ObjectId.
    - Ensures `Unique` indexes use an expression if needed.

    .PARAMETER Database
    The LiteDB database instance.

    .PARAMETER CollectionName
    The name of the collection.

    .PARAMETER Indexes
    An array of index definitions, each containing:
      - `Field` (string) - Required field name.
      - `Unique` (bool) - Optional uniqueness constraint.
      - `Expression` (string) - Optional expression-based indexing.

    .EXAMPLE
    Initialize-LiteDbCollection -Database $db -CollectionName 'Movies' -Indexes @(
        [PSCustomObject]@{ Field='Title'; Unique=$true },
        [PSCustomObject]@{ Field='Genre'; Expression='LOWER($.Genre)' }
    )
    #>

    # 1) Get the collection (implicitly creates if it doesn’t exist)
    $Collection = Get-LiteCollection -CollectionName $CollectionName -AutoId ObjectId -Database $Database

    # 2) Ensure indexes using the LiteCollection `EnsureIndex` method
    foreach ($idx in $Indexes) {
        if (-not $idx.Field) {
            Write-Error "Index definition must contain a 'Field' property."
            throw 
        }

        # Ignore attempts to manually index `_id`
        if ($idx.Field -eq "_id") {
            Write-Warning "Skipping index creation on '_id' as it is always indexed by default."
            continue
        }

        # Determine if Unique flag is set
        $Unique = $false
        if ($idx.PSObject.Properties.Name -contains 'Unique') {
            $Unique = [bool]$idx.Unique
        }

        try {
            if ($idx.PSObject.Properties.Name -contains 'Expression' -and $idx.Expression) {
                # User explicitly provided an expression
                Write-Verbose "Creating expression-based index on '$($idx.Field)' with expression '$($idx.Expression)'"
                $Collection.EnsureIndex($idx.Field, $idx.Expression, $Unique)
            }
            elseif ($Unique) {
                # Unique index requires an expression—default to LOWER() if none provided
                $DefaultExpression = "LOWER($." + $idx.Field + ")"
                Write-Verbose "Creating unique index on '$($idx.Field)' with default expression '$DefaultExpression'"
                $Collection.EnsureIndex($idx.Field, $DefaultExpression, $Unique)
            }
            else {
                # Standard field-based index
                Write-Verbose "Creating normal index on '$($idx.Field)'"
                $Collection.EnsureIndex($idx.Field)
            }
        }
        catch {
            Write-Warning "Failed to create index on '$($idx.Field)': $($_.Exception.Message)"
        }
    }
}
