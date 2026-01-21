# VMware Replication - Template Zabbix

**Compatibilidade:** Zabbix 6.2 ou superior

## Instalação

### 1. PowerShell + PowerCLI
Instale o PowerShell e o módulo PowerCLI globalmente:
```bash
sudo pwsh -Command "Install-Module -Name VMware.PowerCLI -Scope AllUsers -AllowClobber -Force"
```

### 2. Ambiente e Permissões
Crie os diretórios necessários e ajuste as permissões:
```bash
mkdir -p /var/lib/zabbix/.{config,local/share}/powershell
mkdir -p /var/lib/zabbix/.config/VMware/PowerCLI
chown -R zabbix:zabbix /var/lib/zabbix
```

### 3. Configuração do PowerCLI
Configure o PowerCLI para o usuário Zabbix:
```bash
sudo -u zabbix -H pwsh -Command "Set-PowerCLIConfiguration -ParticipateInCEIP \$false -InvalidCertificateAction Ignore -DisplayDeprecationWarnings \$false -Confirm:\$false"
```

### 4. Scripts
Copie os scripts para a pasta de externalscripts do Zabbix:
```bash
cp check_vmware_replication.sh /usr/lib/zabbix/externalscripts/
chmod +x /usr/lib/zabbix/externalscripts/check_vmware_replication.sh
```

## Configuração

### Macros
Configure as seguintes macros no host/template:
- `{$REPLICATIONIP}` - IP do VMware Replication Server
- `{$FQDN}` - FQDN do vCenter
- `{$VMWAREUSER}` - Usuário do vCenter
- `{$VMWAREPASS}` - Senha do vCenter

### Teste
Valide a execução do script:
```bash
sudo -u zabbix -H /usr/lib/zabbix/externalscripts/check_vmware_replication.sh vcenter user pass vr_ip
```

## Template

### Item
- **Vmware Replication Raw Data**  
  `check_vmware_replication.sh["{$FQDN}","{$VMWAREUSER}","{$VMWAREPASS}","{$REPLICATIONIP}"]`

### Discovery Rule
- **Vmware Replication Raw Data: Replications Discovery**

### Item Prototypes
- **Replication {#VM_NAME}: RPO Violation**
- **Replication {#VM_NAME}: Status**

### Trigger Prototypes
- **Replication {#VM_NAME} failed**
- **Replication {#VM_NAME} RPO violated**