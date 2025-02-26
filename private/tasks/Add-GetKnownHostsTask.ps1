# Collection           : Hosts
# _id                  : 679ddb80fb11150443065dd8
# UTC_Created      : 1738398592845
# IPAddress            : 10.0.0.10
# CertificateAuthority : {}
# Role                 : DomainController
# Hash                 : B012632535B2C9010B418F3C8BB65A469D16593B814F6F1E3BDF8C80955A6EAB
# SecurityPolicies     : {}
# AD_Roles             : {GlobalCatalog, PrimaryDomainController}
# UTC_Updated      : 1738398592845
# DomainName           : example.local
# FriendlyId           : DC-001
# DNSConfig            : {}
# Guid                 : f58856c3-293f-4d09-a8fc-1e6682370114
# VerInt               : 0
# OSVersion            : Windows Server 2022
# Hostname             : DC01.example.local
# FSMORoles            : {@{RoleName=InfrastructureMaster; FSMOGuid=GUID-InfrastructureMaster; FSMOHash=HASH-InfrastructureMaster}, @{RoleName=PDCEmulator; FSMOGuid=GUID-PDCEmulator;       
#                     FSMOHash=HASH-PDCEmulator}, @{RoleName=RIDMaster; FSMOGuid=GUID-RIDMaster; FSMOHash=HASH-RIDMaster}}

function Add-GetKnownHostsTask {
    Add-PodeTask -Name "Get-GetKnownHostsTask" -ScriptBlock {
        $hosts = Find-LiteDBDocument -Collection 'Hosts' -Connection (Get-PodeState -Name "dbConnection")
        foreach ($known in $hosts) {
            [ordered]@{
                Collection   = $known.Collection
                Added        = $known.UTC_Created
                IPAddress    = $known.IPAddress
                CertificateAuthority = "Add Button Here"
                Roles        = $known.Role
                ADRoles      = "Add Button Here"
                Modified     = $known.UTC_Updated
                DomainName   = $known.DomainName
                Name         = $known.FriendlyId
                DNSConfig    = "Add Button Here"
                RevisionId   = $known.VerInt
                OSVersion    = $known.OSVersion
                Hostname     = $known.Hostname
                FSMORoles    = "Add Button Here"
                Actions      = "Add Button Here"
            }
        }
    }
}

function Invoke-GetKnownHostsTask {
    $task = Invoke-PodeTask -Name "Get-GetKnownHostsTask"
    return $task
}

function Wait-GetKnownHostsTask {
    $hostServicesStatus = Invoke-GetKnownHostsTask | Wait-PodeTask
    return $hostServicesStatus
}