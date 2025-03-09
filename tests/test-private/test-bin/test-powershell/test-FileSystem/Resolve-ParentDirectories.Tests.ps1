Describe "Resolve-ParentDirectories" {
    
    BeforeEach {
        # Define a test file path within the TestDrive
        $testFilePath = "TestDrive:\subfolder\testfile.txt"
        $testDirPath  = [System.IO.Path]::GetDirectoryName($testFilePath)
    }

    It "creates parent directories when they do not exist" -Tag 'bin','powershell','FileSystem','ResolveParentDirectories','active' {
        # Ensure the directory doesn't exist before running the function
        Test-Path -Path $testDirPath | Should -Be $false 

        # Call the function
        Resolve-ParentDirectories -filePath $testFilePath

        # Verify that the directory was created
        Test-Path -Path $testDirPath | Should -Be $true
    }

    # It "does not modify existing directories" {
    #     # Pre-create the directory
    #     New-Item -Path $testDirPath -ItemType Directory -Force | Out-Null

    #     # Capture last write time before function call
    #     $lastWriteTimeBefore = (Get-Item $testDirPath).LastWriteTime

    #     # Call the function
    #     Resolve-ParentDirectories -filePath $testFilePath

    #     # Capture last write time after function call
    #     $lastWriteTimeAfter = (Get-Item $testDirPath).LastWriteTime

    #     # Ensure the directory still exists
    #     Test-Path -Path $testDirPath | Should -Be $true

    #     # Ensure last write time did not change (no unnecessary modification)
    #     $lastWriteTimeBefore | Should -BeExactly $lastWriteTimeAfter
    # }

    # It "throws an error if a file exists at the directory path" {
    #     # Create a file where the directory should be
    #     New-Item -Path $testDirPath -ItemType File -Force | Out-Null

    #     # Ensure the path exists and is a file
    #     (Get-Item $testDirPath).PSIsContainer | Should -Be $false

    #     # Call the function and verify it throws an error
    #     { Resolve-ParentDirectories -filePath $testFilePath } | Should -Throw
    # }
}
