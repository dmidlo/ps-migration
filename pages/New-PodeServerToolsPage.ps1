function New-PodeServerToolsPage {
    Add-PodeWebPage -Name "Tools" -Icon "tools" -ScriptBlock {
        New-PodeWebTabs -Tabs @(
            New-PodeWebTab -Name "Password Generator" -Layouts @(
                New-PodeWebCardPasswordGenerator
            )
        )
    }
}