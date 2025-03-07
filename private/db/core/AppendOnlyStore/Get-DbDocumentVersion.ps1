function Get-DbDocumentVersion {
    [CmdletBinding(DefaultParameterSetName='Latest')]
    param(
        [Parameter(Mandatory)]
        [LiteDB.LiteDatabase]$Database,

        [Parameter(Mandatory)]
        $Collection,

        [Parameter(Mandatory, ValueFromPipeline)]
        [string]$VersionId,

        [Parameter(Mandatory=$true, ParameterSetName='Next')]
        [switch]$Next,

        [Parameter(Mandatory=$true, ParameterSetName='Previous')]
        [switch]$Previous,

        [Parameter(Mandatory=$true, ParameterSetName='Latest')]
        [switch]$Latest,

        [Parameter(Mandatory=$true, ParameterSetName='Original')]
        [switch]$Original,

        [switch]$ResolveRefs
    )

    process {
        # 1) Retrieve the "current" document by VersionId
        $currentDoc = $VersionId | Get-DbDocumentByVersionId -Database $Database -Collection $Collection
        if (-not $currentDoc) {
            throw "Document with VersionId '$VersionId' not found in collection '$CollectionName'."
        }

        $Versions = $currentDoc.BundleId | Get-DbDocumentVersionsByBundle -Database $Database -Collection $Collection
        
        if ($Versions -is [PSCustomObject]) {
            $Versions = @($Versions)
        }
        
        $currentVersion = $Versions | Where-Object { $_.VersionId -eq $VersionId}
        $currentIndex = [Array]::IndexOf($Versions, $currentVersion)

        switch ($PSCmdlet.ParameterSetName) {

            'Next' {
                $nextIndex = $currentIndex - 1
                if ($nextIndex -gt 0) {
                    $out = ($Versions[$nextIndex])
                }
                else {
                    $out = $Versions[0]
                }
            }

            'Previous' {
                $prevIndex = $currentIndex + 1
                if ($prevIndex -lt ($Versions.Count -1)) {
                    $out = ($Versions[$prevIndex])
                }
                else {
                    $out = $Versions[-1]
                }
            }

            'Latest' {
                $out = $Versions[0]
            }

            'Original' {
                $out =  $Versions[-1]
            }
        }

        if ($ResolveRefs -and $out.PSObject.Properties.Name -contains '$Ref') {
            Write-Host $out
            Write-Output ($out | Get-DbVersionRef -Database $Database -Collection $Collection)
        }
        else {
            Write-Output $out
        }
    }
}
