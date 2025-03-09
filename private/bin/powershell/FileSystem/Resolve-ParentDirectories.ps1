 function Resolve-ParentDirectories {
    param (
        [string]$filePath   # Full path of the file (including file name)
    )

    # Extract the directory path from the file path
    $directoryPath = [System.IO.Path]::GetDirectoryName($filePath)

    # Check if the directory path exists
    if (Test-Path -Path $directoryPath) {
        # Check if the existing path is a directory, not a file
        if (-not (Get-Item $directoryPath).PSIsContainer) {
            throw "A file exists at '$directoryPath'. Cannot create directories."
        } else {
            Write-Host ""
        }
    } else {
        # Create the parent directory structure if it does not exist
        New-Item -Path $directoryPath -ItemType Directory -Force
        Write-Host "Created directory: $directoryPath"
    }
}