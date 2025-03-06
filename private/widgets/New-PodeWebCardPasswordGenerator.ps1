function New-PodeWebCardPasswordGenerator {
    New-PodeWebCard -DisplayName "Password Generator" -Content @(
        New-PodeWebForm -Name "passwordform" -SubmitText "Generate Password" -ShowReset -ResetText "Reset" -Content @(
            New-PodeWebRange -Name "length" -Min 12 -Max 100 -ShowValue -Value 16
            New-PodeWebCheckbox -Name "options" `
                -Options @("upper", "lower", "numeric", "special") `
                -DisplayOptions @("A-Z","a-z","0-9","&^@") `
                -Checked
            New-PodeWebTextbox -Name "secret" -DisplayName "Password"

        ) -ScriptBlock {
            # $WebEvent.Data | Out-Default

            if (-not $WebEvent.Data.Options) {
                Show-PodeWebToast -Message "You must select at least one character set." -Title "Error" -Icon "alert-rhombus"
            } else {
                $newPassword = (New-RandomPassword -PasswordOptions $WebEvent.Data)
                Update-PodeWebTextBox -Value $newPassword -Name "secret"
            }
        }
    )
}