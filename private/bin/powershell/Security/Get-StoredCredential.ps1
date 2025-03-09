function Get-StoredCredential {
    param (
        [Parameter(Mandatory = $true)]
        [string]$FileName,
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    # Define the path for the .clixml file
    $credentialFile = Join-Path -Path $Path -ChildPath "$FileName.clixml"
    Resolve-ParentDirectories -filePath $credentialFile

    # Check if the credential file exists
    if (Test-Path $credentialFile) {
        # If the file exists, import the credentials from the .clixml file
        try {
            $credential = Import-Clixml -Path $credentialFile
        }
        catch {
            Write-Error "Failed to import credentials from $credentialFile. It may be corrupted."
            return
        }
    } else {
        # If the file doesn't exist, prompt the user for credentials
        $credential = Get-Credential

        # Save the credentials to the .clixml file
        try {
            $credential | Export-Clixml -Path $credentialFile
            Write-Host "Credentials saved to $credentialFile."
        }
        catch {
            Write-Error "Failed to save credentials to $credentialFile."
            return
        }
    }

    # Return the credentials
    return $credential
}
