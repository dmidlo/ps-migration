function Get-DbDocumentVersion {
    <#
    .SYNOPSIS
    Returns the Next, Previous, Latest, or Original version for a given document (by Hash).

    .DESCRIPTION
    1. Retrieves the current doc by Hash (which yields its Guid + epoch).
    2. Depending on the switch:
       * `-Next`     : Returns the *immediately* next version (lowest epoch above current).
       * `-Previous` : Returns the *immediately* previous version (highest epoch below current).
       * `-Latest`   : Returns the absolute newest version (highest epoch) for the Guid.
       * `-Original` : Returns the absolute oldest version (lowest epoch) for the Guid.
    3. Returns `$null` if no match is found in some cases (e.g., `-Next` but no higher epoch doc exists).

    .PARAMETER Connection
    LiteDB.LiteDatabase object.

    .PARAMETER CollectionName
    The collection name.

    .PARAMETER Hash
    Unique hash of the current version doc.

    .PARAMETER Next
    Switch param. Returns the next version by epoch.

    .PARAMETER Previous
    Switch param. Returns the previous version by epoch.

    .PARAMETER Latest
    Switch param. Returns the absolute newest version for the Guid.

    .PARAMETER Original
    Switch param. Returns the absolute oldest version for the Guid.

    .EXAMPLE
    # Next version after a certain doc's Hash:
    $nextVer = Get-DbDocumentVersion -Connection $db -CollectionName 'Domains' -Hash $myHash -Next

    .EXAMPLE
    # The earliest (original) version for a doc's Guid:
    $originalVer = Get-DbDocumentVersion -Connection $db -CollectionName 'Domains' -Hash $myHash -Original
    #>
    [CmdletBinding(DefaultParameterSetName='Latest')]
    param(
        [Parameter(Mandatory)]
        [LiteDB.LiteDatabase] $Connection,

        [Parameter(Mandatory)]
        [string] $CollectionName,

        [Parameter(Mandatory, ValueFromPipeline)]
        [string] $Hash,

        [Parameter(Mandatory=$true, ParameterSetName='Next')]
        [switch] $Next,

        [Parameter(Mandatory=$true, ParameterSetName='Previous')]
        [switch] $Previous,

        [Parameter(Mandatory=$true, ParameterSetName='Latest')]
        [switch] $Latest,

        [Parameter(Mandatory=$true, ParameterSetName='Original')]
        [switch] $Original
    )

    process {
        # 1) Retrieve the "current" document by Hash
        $currentDoc = Get-DbDocumentByHash -Connection $Connection -CollectionName $CollectionName -Hash $Hash
        if (-not $currentDoc) {
            throw "Document with Hash '$Hash' not found in collection '$CollectionName'."
        }

        $Versions = $currentDoc.Guid | Get-DbDocumentVersionsByGuid -Connection $Connection -CollectionName $CollectionName
        
        if ($Versions -is [PSCustomObject]) {
            $Versions = @($Versions)
        }
        
        $currentVersion = $Versions | Where-Object { $_.Hash -eq $Hash}
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


        Write-Output (Normalize-Data -InputObject $out -IgnoreFields @('none'))
    }
}
