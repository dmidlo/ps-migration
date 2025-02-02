function New-PodeServerHostsPage {
    Add-PodeWebPage -Name "Hosts" -Icon "lasso" -ScriptBlock {
        New-PodeWebTabs -Tabs @(
            New-PodeWebTab -Name "Known Hosts" -Layouts @(
                New-PodeWebCardAddHost
                New-PodeWebCardKnownHostsTable
            )
            New-PodeWebTab -Name "Services" -Layouts @(
                New-PodeWebCardHostServicesTable
            )
        )
    }
}