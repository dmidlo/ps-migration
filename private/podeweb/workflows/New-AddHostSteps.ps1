Function New-AddHostSteps {
    New-PodeWebStep -Name "Host Addresses" -Icon "identifier" -Content @(
        New-PodeWebCardAddHostAddresses
    ) -ScriptBlock {
        New-PodeWebCardAddHostAddressesValidator
    }
    New-PodeWebStep -Name "Host Details" -Icon "identifier" -Content @(
        New-PodeWebText -Value "Host Details"
    )
}