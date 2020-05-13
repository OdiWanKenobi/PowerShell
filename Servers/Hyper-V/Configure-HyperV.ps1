## Rename
$NewHostName = Read-Host -Prompt 'Enter new computer name'
Rename-Computer -NewName $NewHostName -Force

## Timezone
Set-TimeZone -Name "Eastern Standard Time"

## PowerShell Remoting
Write-Host "Enabling PowerShell Remoting"
Enable-PSRemoting -Force -ErrorAction 0
Set-WSManQuickConfig -Force -ErrorAction 0

## Remote Desktop
(Get-WmiObject Win32_TerminalServiceSetting -Namespace root\cimv2\TerminalServices).SetAllowTsConnections(1,1) | Out-Null
(Get-WmiObject -Class "Win32_TSGeneralSetting" -Namespace root\cimv2\TerminalServices -Filter "TerminalName='RDP-tcp'").SetUserAuthenticationRequired(0) | Out-Null
Get-NetFirewallRule -DisplayName "Remote Desktop*" | Set-NetFirewallRule -enabled true

## Security
Set-SmbServerConfiguration -EnableSMB1Protocol $false -Force
Disable-WindowsOptionalFeature -Online -FeatureName SMB1Protocol -NoRestart
Disable-WindowsOptionalFeature -Online -FeatureName "MicrosoftWindowsPowerShellV2Root"
Disable-WindowsOptionalFeature -Online -FeatureName "MicrosoftWindowsPowerShellV2"

## Service(s)
Get-Service -DisplayName "Function Discovery Resource Publication" | Start-Service
Get-Service -DisplayName "DNS Client"  | Start-Service
Get-Service -DisplayName "SSDP Discovery"  | Start-Service
Get-Service -DisplayName "UPnP Device Host" | Start-Service

## Firewall Rule(s)
Get-NetFirewallRule -DisplayGroup "File and Printer Sharing" | Set-NetFirewallRule -Action Allow 
Get-NetFirewallRule -DisplayGroup "File and Printer Sharing" | Enable-NetFirewallRule
Get-NetFirewallRule -DisplayGroup "Network Discovery" | Set-NetFirewallRule -Action Allow
Get-NetFirewallRule -DisplayGroup "Network Discovery" | Enable-NetFirewallRule

## Role
Install-WindowsFeature -Name Hyper-V -IncludeAllSubFeature -IncludeManagementTools -Verbose

## Virtual Switch
$NIC = Get-NetAdapter | Where-Object {$_.Status -eq 'Up'}
New-VMSwitch -Name "External Virtual Switch" -NetAdapterName $NIC.Name -AllowManagementOS $True
New-VMSwitch -Name "Internal Virtual Switch" -NetAdapterName

## ISO Folder
New-Item -Path "C:\ISOs" -ItemType Directory