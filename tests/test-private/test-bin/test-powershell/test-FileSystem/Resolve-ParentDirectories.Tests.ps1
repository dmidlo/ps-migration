Describe "Resolve-ParentDirectories" {
    
    BeforeEach {
        # Define a test file path within the TestDrive
        $testFilePath = "TestDrive:\subfolder\testfile.txt"
        $testDirPath  = [System.IO.Path]::GetDirectoryName($testFilePath)
    }

    AfterEach {
        # Cleanup TestDrive for consecutive tests
        if (Test-Path -Path $testDirPath) {
            Remove-Item -Path $testDirPath -Recurse -Force -ErrorAction SilentlyContinue
        }
    }

    It "Resolve-ParentDirectories TC01: creates parent directories when they do not exist" -Tag 'bin','powershell','FileSystem','ResolveParentDirectories','active' {
        # Ensure the directory doesn't exist before running the function
        Test-Path -Path $testDirPath | Should -Be $false 

        # Call the function
        Resolve-ParentDirectories -filePath $testFilePath

        # Verify that the directory was created
        Test-Path -Path $testDirPath | Should -Be $true
    }

    It "Resolve-ParentDirectories TC02: does not modify existing directories" -Tag 'bin','powershell','FileSystem','ResolveParentDirectories','active' {
        # Pre-create the directory
        $null = New-Item -Path $testDirPath -ItemType Directory -Force

        # Capture last write time before function call
        $lastWriteTimeBefore = (Get-Item $testDirPath).LastWriteTime

        # Call the function
        Resolve-ParentDirectories -filePath $testFilePath

        # Capture last write time after function call
        $lastWriteTimeAfter = (Get-Item $testDirPath).LastWriteTime

        # Ensure the directory still exists
        Test-Path -Path $testDirPath | Should -Be $true

        # Ensure last write time did not change (no unnecessary modification)
        $lastWriteTimeBefore | Should -BeExactly $lastWriteTimeAfter
    }

    It "Resolve-ParentDirectories TC03: throws an error if a file exists at the directory path" -Tag 'bin','powershell','FileSystem','ResolveParentDirectories','active' {
        # Create a file where the directory should be
        $null = New-Item -Path $testDirPath -ItemType File -Force

        # Ensure the path exists and is a file
        (Get-Item $testDirPath).PSIsContainer | Should -Be $false

        # Call the function and verify it throws an error
        { Resolve-ParentDirectories -filePath $testFilePath } | Should -Throw
    }
}
