function New-PodeWebCardKnownHostsTable {
    New-PodeWebCard -Content @(
        New-PodeWebTable -Name "Known Hosts" -NoRefresh -ScriptBlock {
            Wait-GetKnownHostsTask
        }
    )
}