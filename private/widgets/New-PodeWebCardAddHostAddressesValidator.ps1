Function New-PodeWebCardAddHostAddressesValidator {
    ## No Validation for Chassis Serial Number Needed.

    ## Mac Address Validation
    # Allow for no entry `-gt 0`
    if($WebEvent.Data['MacAddress'].Length -gt 0) {
        $MacAddressValidation, $MacAddressMessage = Validate-MACAddressString -MacAddress $WebEvent.Data['MacAddress']
        if (-not $MacAddressValidation) {
            Out-PodeWebValidation -Name "MacAddress" -Message $MacAddressMessage
        }
    }
}
