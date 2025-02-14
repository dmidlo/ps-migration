function Initialize-DB {
    param($DBPath)

    try {
        if (-not (Test-Path $DBPath)) {
            New-LiteDBDatabase -Path $DBPath -Verbose
        }

        $dbConnection = Open-LiteDBConnection -Database $DBPath -Mode Shared -Verbose -collation "en-US/IgnoreCase"
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
        
        # rethrow the error
        throw
    }    
}