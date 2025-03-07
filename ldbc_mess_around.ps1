Clear-Host
. ".\build.ps1"
Import-Module '.\ps-migration.psd1' -Force
# PS C:\Users\AVT.ASA\Documents\PowerShell\Modules\ps-migration> get-command -module ldbc
# CommandType     Name                                               Version    Source
# -----------     ----                                               -------    ------
# Cmdlet          Invoke-LiteCommand                                 0.8.11     ldbc
# Cmdlet          Register-LiteType                                  0.8.11     ldbc
# Cmdlet          Remove-LiteData                                    0.8.11     ldbc
# Cmdlet          Set-LiteData                                       0.8.11     ldbc
# Cmdlet          Test-LiteData                                      0.8.11     ldbc
# Cmdlet          Update-LiteData                                    0.8.11     ldbc
# Cmdlet          Get-LiteData                                       0.8.11     ldbc
# Cmdlet          Add-LiteData                                       0.8.11     ldbc
# Cmdlet          Get-LiteCollection                                 0.8.11     ldbc

# $Database = New-LiteDatabase :memory:
# try {
#     Use-LiteTransaction {
#         $Database
#     }
# }
# finally {
#     $Database.Dispose()
# }

# [LiteDB.Collation].GetMethods() | Select-Object Name, IsStatic
# [LiteDB.Collation] | Get-Member -MemberType Method -Force

# $connectionString = [LiteDB.ConnectionString]::New()
# $connectionString | Get-Member -MemberType Method -Force
# $connectionString.set_AutoRebuild($true)
# $connectionString.get_AutoRebuild() 
# [LiteDB.Collation].GetConstructors()
# [LiteDB.Collation].GetConstructors() | ForEach-Object { $_.GetParameters() }
# [LiteDB.Collation].GetConstructors() | ForEach-Object { 
#     "Constructor: " + $_.ToString()
# }

# $LocaleId = [System.Globalization.CultureInfo]::GetCultureInfo("en-US")
# $IgnoreCase = [System.Globalization.CompareOptions]::IgnoreCase
# $IgnoreNonSpace = [System.Globalization.CompareOptions]::IgnoreNonSpace
# $IgnoreSymbols = [System.Globalization.CompareOptions]::IgnoreSymbols
# $connectionString.set_Collation([LiteDB.Collation]::New($LocaleId.LCID, ($IgnoreCase -bor $IgnoreNonSpace -bor $IgnoreSymbols)))


# [LiteDB.ConnectionType]::Shared
# [LiteDB.ConnectionType]::Direct
# $connectionString.set_Connection([LiteDB.ConnectionType]::Shared)
# $connectionString.set_Filename(".\StoredObjects\ps-migration.db")

# $Database = New-LiteDatabase -ConnectionString $connectionString
# try {
#     Use-LiteTransaction {
#         $Database
#     }
# }
# finally {
#     $Database.Dispose()
# }

# Write-Host $connectionString.GetType()

# Use-LiteDatabase -ConnectionString $connectionString {
#         # $connectionString
#         # Invoke-LiteCommand 'pragma UTC_DATE = true;'
#         $pragmas = (Invoke-LiteCommand 'select pragmas from $database;' -As PS).pragmas
#         $pragmas | Get-Member
# }

# $dbPassword = Get-StoredCredential -FileName "dbPassword" -Path ".\StoredObjects\Credentials\"

# PS C:\Users\AVT.ASA\Documents\PowerShell\Modules\ps-migration> get-help Get-LiteCollection -Full 

# NAME
#     Get-LiteCollection

# SYNOPSIS
#     Gets the collection instance.


# SYNTAX
#     Get-LiteCollection [-CollectionName] <String> [[-AutoId] <BsonAutoId>] [-Database <ILiteDatabase>] [<CommonParameters>]


# DESCRIPTION
#     The cmdlet gets the collection instance by its name from the specified or default database.


# PARAMETERS
#     -CollectionName
#         The collection name, case insensitive.

#         Required?                    true
#         Position?                    0
#         Default value
#         Accept pipeline input?
#         Aliases
#         Accept wildcard characters?

#     -AutoId
#         The automatic identifier data type.

#         Values : Int32, Int64, ObjectId, Guid

#         Required?                    false
#         Position?                    1
#         Default value
#         Accept pipeline input?
#         Aliases
#         Accept wildcard characters?

#     -Database
#         The database instance. If it is omitted then the variable $Database is expected. Use New-LiteDatabase or Use-LiteDatabase in order to get the database instance.

#         Required?                    false
#         Position?                    named
#         Default value
#         Accept pipeline input?
#         Aliases
#         Accept wildcard characters?

#     <CommonParameters>
#         This cmdlet supports the common parameters: Verbose, Debug,
#         ErrorAction, ErrorVariable, WarningAction, WarningVariable,
#         OutBuffer, PipelineVariable, and OutVariable. For more information, see
#         about_CommonParameters (https://go.microsoft.com/fwlink/?LinkID=113216).

# INPUTS

# OUTPUTS
#     LiteDB.ILiteCollection[LiteDB.BsonDocument]
#         The collection instance.


#     -------------------------- EXAMPLE 1 --------------------------

#     Use-LiteDatabase :memory: {
#         # get the collection
#         $MyCollection = Get-LiteCollection MyCollection

#         # use it...
#         $MyCollection
#     }


# RELATED LINKS
#     New-LiteDatabase
#     Use-LiteDatabase
$dbConnectionString = New-DbConnectionString -Culture "en-US" -IgnoreCase -IgnoreNonSpace -IgnoreSymbols -ConnectionType Shared -AutoRebuild -FilePath "$env:TEMP\temp.db" -Upgrade
$db = Initialize-DB -ConnectionString $dbConnectionString
# $db = New-LiteDatabase -ConnectionString $connectionString
# $db | Get-Member -MemberType Method -Force | ft
# Invoke-LiteCommand 'select pragmas from $database;' -Database $db
# Confirm-LiteDBCollection -Database $db -CollectionName 'Temp' -Indexes @(
#         [PSCustomObject]@{ Field='VersionId'; Unique=$true }
# )


# $CollectionName = "Temp"
# $Collection = Get-LiteCollection -CollectionName $CollectionName -AutoId ObjectId -Database $db
# $docs = $Collection | Get-Member -MemberType Method -Force 
# $docs
# $Collection.get_AutoId()
# EnsureIndex(string name, LiteDB.BsonExpression expression, bool unique = False)
# $TempId = [LiteDB.ObjectId]::NewObjectId()
# $TempDoc = @{ _id = $TempId; TempField = 'Temp' }
# Add-LiteData -Collection $Collection -InputObject $TempDoc
# Confirm-LiteDBCollection -Database $db -CollectionName $CollectionName -Indexes @(
#         [PSCustomObject]@{ Field='VersionId'; Unique=$true },
#         [PSCustomObject]@{ Field='Guid'; Unique=$false}
# )

# Test-LiteDBCollection -Database $db -CollectionName $CollectionName -Indexes @(
#         [PSCustomObject]@{ Field='VersionId'; Unique=$true},
#         [PSCustomObject]@{ Field='Guid'; Unique=$false}
# )
# Initialize-Collections -Database $db | Out-Null
# $docs = $Collection | Get-Member -MemberType Method -Force 
# $docs | ft
# remove-item "$env:TEMP\temp.db"
# $connectionString | Get-Member -MemberType Method -Force | ft
# [LiteDB.ConnectionString].GetMethods() | ft