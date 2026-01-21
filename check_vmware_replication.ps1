#Script criado por Nathan Schiavon 01/2026
#Monitoramento do Vsphere Replication via PowerCLI - PowerShell

param(
    [Parameter(Mandatory=$true, Position=0)] [string]$vcenter_server,
    [Parameter(Mandatory=$true, Position=1)] [string]$vcenter_user,
    [Parameter(Mandatory=$true, Position=2)] [string]$vcenter_pass,
    [Parameter(Mandatory=$true, Position=3)] [string]$vr_appliance_server,
    [Parameter(Mandatory=$false, Position=4)] [string]$remote_vcenter
)

$ErrorActionPreference = "Stop"
Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -DisplayDeprecationWarnings $false -Confirm:$false | Out-Null

$data = @()

try {
    $vcenterConn = Connect-VIServer -Server $vcenter_server -User $vcenter_user -Password $vcenter_pass
    $vrConn = Connect-VrServer -Server $vr_appliance_server -User $vcenter_user -Password $vcenter_pass

    $allPairings = (Invoke-VrGetVrPairings).List

    $Pairing = $allPairings | Where-Object {
        ($_.LocalVcServer.Name -match $vcenter_server -or $_.LocalVcServer.Address -match $vcenter_server) -and
        ( -not $remote_vcenter -or ($_.RemoteVcServer.Name -match $remote_vcenter -or $_.RemoteVcServer.Address -match $remote_vcenter) )
    } | Select-Object -First 1 

    if (-not $Pairing) { throw "PairingID nao encontrado para $vcenter_server -> $remote_vcenter" }

    $PairingID = $Pairing.PairingId.GUID
    $VCGuid = (Invoke-VrGetVrInfo).VCGuid.guid

    $replications = (Invoke-VrGetAllReplications -PairingId $PairingID -SourceVcGuid $VCGuid -ExtendedInfo $true).List

    foreach ($rep in $replications) {
        $obj = [PSCustomObject]@{
            vm_name      = $rep.Name
            status       = $rep.status.status
            rpo_violated = [bool]$rep.status.rpoviolation
            rpo_config   = $rep.RPO
            pairing_info = "$($Pairing.LocalVcServer.Name) to $($Pairing.RemoteVcServer.Name)"
        }
        $data += $obj
    }

    Write-Output ($data | ConvertTo-Json -Compress)
}
catch {
    $errorObj = @{
        error   = $true
        message = $_.Exception.Message
    }
    Write-Output ($errorObj | ConvertTo-Json -Compress)
}
finally {
    if ($null -ne $vrConn) { Disconnect-VrServer -Server $vr_appliance_server -ErrorAction SilentlyContinue }
    if ($null -ne $vcenterConn) { Disconnect-VIServer -Server $vcenter_server -Confirm:$false -ErrorAction SilentlyContinue }
}
