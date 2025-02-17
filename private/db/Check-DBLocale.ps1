# function Check-DBLocale {
#     param($Connection)

#     <# https://www.litedb.org/docs/pragmas/
#     UTC_DATE	no	bool	If false, dates are converted to local time on retrieval. Storage format is not affected (always in UTC).	default = false
#     #>

#     $UTC_Date_Pragma = [bool]((Find-LiteDBDocument -Collection '$database' -Sql "select pragmas from `$database" -Connection $Connection).pragmas).UTC_Date
#     if(-not $UTC_Date_Pragma) {
#         #ensuring backend consisetently stores and delivers UTC.  Locale time conversion should happen elsewhere
#         Write-PodeHost "UTC_Date Pragma set to '$UTC_Date_Pragma' which can lead to inconsitencies. fixing."
#         Find-LiteDBDocument -Collection '$database' -Sql "pragma UTC_Date = true" -Connection $Connection
#         Write-PodeHost "UTC_Date Pragma now: $(((Find-LiteDBDocument -Collection '$database' -Sql "select pragmas from `$database" -Connection $Connection).pragmas).UTC_Date)"
#     }
# }
function Check-DBLocale {
    param($Connection)

    <# Ensure UTC_Date pragma is enabled in LiteDB to avoid inconsistencies. #>
    # https://www.litedb.org/docs/pragmas/

    # Retrieve current pragma settings
    $Pragmas = (Find-LiteDBDocument -Collection '$database' -Sql "select pragmas from `$database" -Connection $Connection).pragmas

    # Validate response
    if ($null -eq $Pragmas) {
        throw -ErrorMessage "Failed to retrieve pragmas from LiteDB. Ensure database is accessible."
    }

    $UTC_Date_Pragma = $Pragmas?.UTC_Date -eq $true

    if (-not $UTC_Date_Pragma) {
        Write-Warning "UTC_Date Pragma set to '$UTC_Date_Pragma'. Fixing..."

        # Update UTC_Date pragma
        $SetPragmaResult = Find-LiteDBDocument -Collection '$database' -Sql "pragma UTC_Date = true" -Connection $Connection
        if ($SetPragmaResult -eq $null) {
            Write-Error "Failed to update UTC_Date pragma."
            return
        }

        # Verify update
        $UpdatedPragmas = (Find-LiteDBDocument -Collection '$database' -Sql "select pragmas from `$database" -Connection $Connection).pragmas
        $UpdatedUTC_Date_Pragma = $UpdatedPragmas?.UTC_Date -eq $true

        Write-Host "UTC_Date Pragma now: $UpdatedUTC_Date_Pragma"
    }
}
