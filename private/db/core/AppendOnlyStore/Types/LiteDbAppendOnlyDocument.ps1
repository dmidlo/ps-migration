[NoRunspaceAffinity()]
class LiteDbAppendOnlyDocument : LiteDbAppendOnlyCollection {
    # This someday may be helpfully converted to three classes once [Type] `-is` conditionals
    # are backported into supporting code to support additional type safety and project code consistency
    # for now, this will be base class for Standard DB Documents, Temp Db Documents, Recycled DBdocuments, and VersionRef/BundleRef Db Documents
    [LiteDB.ObjectId]$_id
    [Guid]$BundleId
    [string]$Thumbprint
    [string]$VersionId
    [int64]$UTC_Created
    [int64]$UTC_Updated
    [PSCustomObject]$Properties

    LiteDbAppendOnlyDocument($Database, $Collection) : base($Database, $Collection) {}

    LiteDbAppendOnlyDocument($Database, $Collection, [PSCustomObject]$PSCustomObject) : base($Database, $Collection){
        $this.Properties = $PSCustomObject
        $this.FromPS()
    }

    [void] FromPS() {
        $props = $this.Properties.PSObject.Properties.Name
        $classProps = $this.PSObject.Properties.Name
        
        $instanceProps = [PSCustomObject]@{}
        foreach ($prop in $props) {
            if($classProps -contains $prop) {
                $this.$prop = $this.Properties.$prop
            } else {
                $instanceProps = $instanceProps | Add-Member -MemberType NoteProperty -Name $prop -Value $this.Properties.$prop -PassThru
            }
        }
        $this.Properties = $instanceProps
    }

    [PSCustomObject] ToPS() {
        $out = [PSCustomObject]@{}
        $classProps = [System.Collections.ArrayList]($this.PSObject.Properties.Name)

        $classProps.Remove('Database')
        $classProps.Remove('Collection')

        if ($this.BundleId.Guid -like "00000000-0000-0000-0000-000000000000") {
            $classProps.Remove('BundleId')
        }

        if ($this.UTC_Created -eq 0) {
            $classProps.Remove('UTC_Created')
        }

        if ($this.UTC_Updated -eq 0) {
            $classProps.Remove('UTC_Updated')
        }

        if ($this.ObjVer -eq 0) {
            $classProps.Remove('ObjVer')
        }

        if ($this._id -like "") {
            $classProps.Remove('_id')
        }
        
        if ($this.VersionId -like "") {
            $classProps.Remove('VersionId')
        }

        if (($this.Properties | Get-Member -MemberType NoteProperty).Count -eq 0){
            $classProps.Remove('Properties')
        } else {
            $instanceProps = $this.Properties.PSObject.Properties.Name
            foreach ($instanceProp in $instanceProps) {
                $out = $out | Add-Member -MemberType NoteProperty -Name $instanceProp -Value $this.Properties.$instanceProp -PassThru
            }
            $classProps.Remove('Properties')
        }

        foreach ($classProp in $classProps) {
            $out = $out | Add-Member -MemberType NoteProperty -Name $classProp -Value $this.$classProp -PassThru
        }
        return $out
    }

    [PsCustomObject] Stage() {
        $Obj = $this.ToPS()
        $staged = $this.StageDbObjectDocument($Obj)
        $stagedProps = $staged.PSObject.Properties.Name
        if ($stagedProps -contains '$Ref' -and $stagedProps -contains '$VersionId') {
            $Temp = New-LiteDbAppendOnlyCollection -Database $this.Database -Collection 'Temp'
            $staged = $Temp.GetVersionRef($staged)
        }
        $this.Properties = $staged
        $this.FromPS()
        return $staged
    }

    [PSCustomObject] Commit () {
        $commit = $this.CommitTempObjectAsDbDoc($this.BundleId)
        $this.Properties = $commit[0]
        $this.FromPS()
        return $commit
    }
}
