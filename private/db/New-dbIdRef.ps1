function New-DbIdRef {
    param(
        [Parameter(Mandatory)]
        $DbDocument,

        [Parameter(Mandatory)]
        $Collection
    )

    $out = [PSCustomObject]@{
        "`$Id"  = $DbDocument._id
        "`$Ref" = $Collection.Name
    }
    
    return $out
}
