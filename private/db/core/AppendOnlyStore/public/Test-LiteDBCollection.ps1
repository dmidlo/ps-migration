function Test-LiteDBCollection {
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
    Tests if a LiteDB collection has the expected indexes.

    .DESCRIPTION
    - Queries `$indexes` to retrieve actual index definitions.
    - Compares against expected indexes.
    - Checks that `Unique` indexes have a valid expression.
    - Outputs mismatches if any.

    .PARAMETER Database
    The LiteDB database instance.

    .PARAMETER CollectionName
    The name of the collection.

    .PARAMETER Indexes
    An array of expected index definitions with:
      - `Field` (string) - Required field name.
      - `Unique` (bool) - Optional uniqueness constraint.
      - `Expression` (string) - Optional expression-based indexing.

    .EXAMPLE
    Test-LiteDBCollection -Database $db -CollectionName 'Temp' -Indexes @(
        [PSCustomObject]@{ Field='VersionId'; Unique=$true },
        [PSCustomObject]@{ Field='Guid'; Unique=$false }
    )
    #>

    # 1) Query the database for existing indexes
    $Query = 'SELECT $ FROM $indexes WHERE collection = @CollectionName'
    $IndexData = Invoke-LiteCommand -Database $Database -Command $Query -Parameters @{ CollectionName = $CollectionName }

    if (-not $IndexData) {
        Write-Error "No indexes found for collection '$CollectionName'."
        return $false
    }

    $Passed = $true
    $ActualIndexes = @{}

    # Convert result to a hashtable for easy comparison
    foreach ($index in $IndexData) {
        $ActualIndexes[$index.name] = @{
            Expression = $index.expression
            Unique = [bool]$index.unique
        }
    }

    # 2) Compare expected indexes with actual database state
    foreach ($idx in $Indexes) {
        if (-not $idx.Field) {
            Write-Error "Index definition must contain a 'Field' property."
            throw 
        }

        $Field = $idx.Field
        $ExpectedUnique = $false
        if ($idx.PSObject.Properties.Name -contains 'Unique') {
            $ExpectedUnique = [bool]$idx.Unique
        }

        $ExpectedExpression = if ($idx.PSObject.Properties.Name -contains 'Expression') {
            $idx.Expression
        }
        elseif ($ExpectedUnique) {
            # Default expression for unique indexes without explicit expressions
            "LOWER($." + $Field + ")"
        }
        else {
            "$." + $Field  # Standard field reference
        }

        if ($ActualIndexes.ContainsKey($Field)) {
            $ActualExpression = $ActualIndexes[$Field].Expression
            $ActualUnique = $ActualIndexes[$Field].Unique

            if ($ActualExpression -ne $ExpectedExpression) {
                Write-Warning "Mismatch on index '$Field': Expected expression '$ExpectedExpression', but found '$ActualExpression'"
                $Passed = $false
            }
            if ($ActualUnique -ne $ExpectedUnique) {
                Write-Warning "Mismatch on index '$Field': Expected Unique=$ExpectedUnique, but found Unique=$ActualUnique"
                $Passed = $false
            }
        }
        else {
            Write-Warning "Missing index '$Field' in collection '$CollectionName'."
            $Passed = $false
        }
    }

    # 3) Output final result
    if ($Passed) {
        Write-Host "All indexes are correctly configured for '$CollectionName'." -ForegroundColor Green
    }
    else {
        Write-Host "Some indexes are missing or incorrect in '$CollectionName'." -ForegroundColor Red
    }

    return $Passed
}
