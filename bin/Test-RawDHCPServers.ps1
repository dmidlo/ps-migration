function Test-RawDHCPServers {
    param (
        [Parameter(Mandatory)]
        [string]$BinaryPath,

        [Int16]$Attempts = 4,

        [Int16]$AttemptTimeout = 5
    )

    $Arguments = @("--query", "--wait", "--timeout", "$AttemptTimeout")
    $results = @()

    $tries = 0
    while ($tries -le $Attempts) {
        # Run the command and capture output
        $output = & $BinaryPath @Arguments

        # Parse the output
        $serverAddressStrings = $output -split " " | Where-Object {$_ -like "*siaddr*"}

        foreach ($serverAddressString in $serverAddressStrings) {
            $IPv4 = ($serverAddressString -split "=")[1]
            
            if($results -contains $IPv4){
                write-host "Already Discovered $IPv4"
            } else {
                write-host $IPv4
                $results += $IPv4
            }
        }

        Start-Sleep -Seconds $AttemptTimeout
        $tries++
    }

    return $results
}