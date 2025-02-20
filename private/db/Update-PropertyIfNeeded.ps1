function Update-PropertyIfNeeded {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [hashtable]$Target,

        [Parameter(Mandatory)]
        [string]$Key,

        [Parameter(Mandatory)]
        $Value,

        [Switch]$Force
    )

    if ($Force -or (-not $Target.ContainsKey($Key)) -or ([string]::IsNullOrEmpty("$($Target[$Key])"))) {
        $Target[$Key] = $Value
    }
}