function Initialize-LiteDbDatabase {
    param($connectionString)

    try {
        $database = New-LiteDatabase -ConnectionString $connectionString

        Invoke-LiteCommand 'pragma UTC_DATE = true;' -Database $database
        Invoke-LiteCommand 'select pragmas from $database;' -Database $database
        
        return $database
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