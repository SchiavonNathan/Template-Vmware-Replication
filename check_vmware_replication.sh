#!/bin/bash
#Script criado por Nathan Schiavon 01/2026 - Trade Technology
#Monitoramento do Vmware Replication via PowerShell

#Este e o Wrapper para utilizar External Scripts no Zabbix

export HOME=/var/lib/zabbix

/usr/bin/pwsh -NoLogo -NoProfile -NonInteractive -File /usr/lib/zabbix/externalscripts/check_vmware_replication.ps1 "$1" "$2" "$3" "$4"
