function New-PodeWebCardAddHost {
    New-PodeWebCard -Name "Add Hosts" -Content @(
        New-PodeWebSteps -Name "Add Host Steps" -Steps @(
            New-PodeWebStep -Name "Host Addresses" -Icon "identifier" -Content @(
                New-PodeWebCardAddHostAddresses
            ) -ScriptBlock {
                New-PodeWebCardAddHostAddressesValidator
            }
            New-PodeWebStep -Name "Host Details" -Icon "identifier" -Content @(
                New-PodeWebText -Value "Host Details"
            )
        ) -ScriptBlock {
            Out-PodeHost $WebEvent.Data
        }
    )

    # New-PodeWebForm -Name 'addHostForm' -SubmitText 'Add Host' -ShowReset -ResetText 'Reset' -Content @(
    #     New-PodeWebTextbox -Name 'MACAddress' -Placeholder 'Enter MAC Address' -ValidateNotEmpty
    #     New-PodeWebTextbox -Name 'IPAddress' -Placeholder 'Enter IP Address'
    #     New-PodeWebTextbox -Name 'HostType' -Placeholder 'Enter Host Type'
    #     New-PodeWebTextbox -Name 'Hostname' -Placeholder 'Enter Hostname'
    #     New-PodeWebTextbox -Name 'FQDN' -Placeholder 'Enter FQDN'
    #     New-PodeWebTextbox -Name 'DomainOrWorkgroup' -Placeholder 'Enter Domain or Workgroup'
    #     New-PodeWebTextbox -Name 'LastUsers' -Placeholder 'Enter Last Users (comma-separated)'
    #     New-PodeWebTextbox -Name 'OS' -Placeholder 'Enter Operating System'
    #     New-PodeWebCheckbox -Name 'VirtualMachine' -DisplayName 'Is Virtual Machine?'
    #     New-PodeWebCheckbox -Name 'ClusterNodeMember' -DisplayName 'Is Cluster Node Member?'
    #     New-PodeWebTextbox -Name 'Role' -Placeholder 'Enter Role'
    #     New-PodeWebTextbox -Name 'AD_Roles' -Placeholder 'Enter AD Roles (comma-separated)'
    #     New-PodeWebTextbox -Name 'FSMORoles' -Placeholder 'Enter FSMO Roles (comma-separated)'
    #     New-PodeWebCheckbox -Name 'Force' -DisplayName 'Force Overwrite'
    #     New-PodeWebCheckbox -Name 'NewProp' -DisplayName 'Add New Properties'
    # ) -ScriptBlock {
    #     param($WebEvent)

    #     # Extract form data
    #     $formData = $WebEvent.Data

    #     # Convert comma-separated fields to arrays
    #     $formData.LastUsers = $formData.LastUsers -split ',\s*'
    #     $formData.AD_Roles = $formData.AD_Roles -split ',\s*'
    #     $formData.FSMORoles = $formData.FSMORoles -split ',\s*'

    #     # Prepare properties hashtable
    #     $properties = @{
    #         IPAddress         = $formData.IPAddress
    #         HostType          = $formData.HostType
    #         Hostname          = $formData.Hostname
    #         FQDN              = $formData.FQDN
    #         DomainOrWorkgroup = $formData.DomainOrWorkgroup
    #         LastUsers         = $formData.LastUsers
    #         OS                = $formData.OS
    #         VirtualMachine    = $formData.VirtualMachine
    #         ClusterNodeMember = $formData.ClusterNodeMember
    #         Role              = $formData.Role
    #         AD_Roles          = $formData.AD_Roles
    #         FSMORoles         = $formData.FSMORoles
    #     }

    #     # Remove empty properties
    #     $properties = $properties.GetEnumerator() | Where-Object { $_.Value } | ForEach-Object {
    #         [PSCustomObject]@{ $_.Key = $_.Value }
    #     }

    #     # Call New-dbHost function
    #     $dbHost = New-dbHost -MACAddress $formData.MACAddress -Properties $properties -Force:$formData.Force -NewProp:$formData.NewProp

    #     # Display the created dbHost object
    #     Show-PodeWebToast -Message "Host created successfully!" -Duration 5000
    #     New-PodeWebCard -Name 'Host Details' -Content @(
    #         New-PodeWebCodeBlock -Value ($dbHost | ConvertTo-Json -Depth 3) -Language 'json'
    #     )
    # }
}
