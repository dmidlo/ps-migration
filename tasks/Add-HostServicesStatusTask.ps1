function Add-HostServicesStatusTask {
    Add-PodeTask -Name "Get-HostServicesStatusTask" -ScriptBlock {
        foreach ($svc in (Get-Service)) {
            [ordered]@{
                Name   = $svc.Name
                Status = "$($svc.Status)"
            }
        }
    }
}

function Invoke-GetHostServicesStatusTask {
    $task = Invoke-PodeTask -Name "Get-HostServicesStatusTask"
    return $task
}

function Wait-GetHostServicesStatusTask {
    $hostServicesStatus = Invoke-GetHostServicesStatusTask | Wait-PodeTask
    return $hostServicesStatus
}