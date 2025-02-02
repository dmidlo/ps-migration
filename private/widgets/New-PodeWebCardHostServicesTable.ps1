function New-PodeWebCardHostServicesTable {
    New-PodeWebCard -Content @(
        New-PodeWebTable -Name "Host Services" -NoRefresh -ScriptBlock {
            Wait-GetHostServicesStatusTask
        }
    )
}