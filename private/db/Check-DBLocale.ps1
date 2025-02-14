function Check-DBLocale {
    param($Connection)

    <# https://www.litedb.org/docs/pragmas/
    UTC_DATE	no	bool	If false, dates are converted to local time on retrieval. Storage format is not affected (always in UTC).	default = false
    #>

    $UTC_Date_Pragma = [bool]((Find-LiteDBDocument -Collection '$database' -Sql "select pragmas from `$database" -Connection $dbConnection).pragmas).UTC_Date
    if(-not $UTC_Date_Pragma) {
        #ensuring backend consisetently stores and delivers UTC.  Locale time conversion should happen elsewhere
        Write-PodeHost "UTC_Date Pragma set to '$UTC_Date_Pragma' which can lead to inconsitencies. fixing."
        Find-LiteDBDocument -Collection '$database' -Sql "pragma UTC_Date = true" -Connection $dbConnection
        Write-PodeHost "UTC_Date Pragma now: $(((Find-LiteDBDocument -Collection '$database' -Sql "select pragmas from `$database" -Connection $dbConnection).pragmas).UTC_Date)"
    }
}