function Initialize-DB {
    param($DBPath)

    try {
        if (-not (Test-Path $DBPath)) {
            New-LiteDBDatabase -Path $DBPath -Verbose
        }

        $dbConnection = Open-LiteDBConnection -Database $DBPath -Mode Shared -Verbose
        Check-DBLocale -Connection $dbConnection
        return $dbConnection
    }
    catch {
        Write-PodeHost "Caught an error!"
    
        # Basic error message
        Write-PodeHost "Error Message    : $($PSItem.Exception.Message)"
        
        # Detailed call stack in which the error occurred
        Write-PodeHost "Stack Trace      : $($PSItem.Exception.StackTrace)"
        
        # Full .NET exception type
        Write-PodeHost "Exception Type   : $($PSItem.Exception.GetType().FullName)"
        
        # If there's an inner exception, you can also log it
        if ($PSItem.Exception.InnerException) {
            Write-PodeHost "Inner Exception : $($PSItem.Exception.InnerException.Message)"
        }
        
        # Invocation Info includes the script line/position where error occurred
        Write-PodeHost "Invocation Info  : $($PSItem.InvocationInfo.PositionMessage)"
        
        # Optionally rethrow the error if you need to handle it further up the chain
        throw
    }    
}

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


function Ensure-LiteDBCollections {
    param($Connection)

    
}