Compatibilidade: Zabbix 6.2 ou superior.

VMware PowerCLI no Zabbix
1. Instalação (PowerShell + PowerCLI)
# Instalar o PowerShell
# Instala o PowerCLI Globalmente
sudo pwsh -Command "Install-Module -Name VMware.PowerCLI, VMware.VimAutomation.vSphereReplication -Scope AllUsers -AllowClobber -Force"

2. Ambiente e Permissões
# Cria diretórios de configuração e ajusta dono
mkdir -p /var/lib/zabbix/.{config,local/share}/powershell
mkdir -p /var/lib/zabbix/.config/VMware/PowerCLI
chown -R zabbix:zabbix /var/lib/zabbix

3. Configuração do Usuário Zabbix
# Silencia CEIP e ignora certificados (Comando único)
sudo -u zabbix -H pwsh -Command "Set-PowerCLIConfiguration -ParticipateInCEIP \$false -InvalidCertificateAction Ignore -DisplayDeprecationWarnings \$false -Confirm:\$false"

Scripts devem ser adicionados na pasta de externalscripts

Preencher macros com:
Replication IP
Vcenter FQDN
User Vcenter
Pass Vcenter

Testar `sudo -u zabbix -H /usr/lib/zabbix/externalscripts/seu_script.sh vcenter user pass vr_ip`

Items
Vmware Replication Raw Data		
check_vmware_replication.sh["{$FQDN}","{$VMWAREUSER}","{$VMWAREPASS}","{$REPLICATIONIP}"]

Discovery
Vmware Replication Raw Data: Replications Discovery

Item Prototype
Vmware Replication Raw Data: Replication {#VM_NAME}: RPO Violation	
Vmware Replication Raw Data: Replication {#VM_NAME}: Status

Trigger Prototype
Replication {#VM_NAME} failed
Replication {#VM_NAME} RPO violated