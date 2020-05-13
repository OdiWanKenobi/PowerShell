## Chocolatey
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iwr https://chocolatey.org/install.ps1 -UseBasicParsing | iex

## Chocolatey Settings
choco feature enable -n allowGlobalConfirmation
choco feature enable -n useRememberedArgumentsForUpgrades

## Boxstarter
. { iwr -useb https://boxstarter.org/bootstrapper.ps1 } | iex; Get-Boxstarter -Forceiex "& { $(irm https://aka.ms/install-powershell.ps1) } -UseMSI"

## Timezone
Set-TimeZone -Name "Eastern Standard Time"

## SMBv1
Disable-WindowsOptionalFeature -Online -FeatureName smb1protocol

## Remoting
Enable-PSRemoting -Force -ErrorAction 0
Set-WSManQuickConfig -Force -ErrorAction 0

## Script(s)
Install-Script Test-PendingReboot -Force

## PowerShell 7
iex "& { $(irm https://aka.ms/install-powershell.ps1) } -UseMSI"

## Software
choco install notepadplusplus
choco install googlechrome
choco install chocolateygui
choco install 7zip

## VS Code
choco install vscode
choco install vscode-powershell
choco install vscode-intellicode

## Updates
Enable-MicrosoftUpdate
Install-WindowsUpdate -getUpdatesFromMS -acceptEula -SuppressReboots

## Determine OS Type - RDP
$osType = Get-CimInstance -ClassName Win32_OperatingSystem
$osType.ProductType | Out-Null

## Write Output to Shell - RDP
if ($osType.ProductType -eq 1) {
    Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -name "fDenyTSConnections" -value 0
    Enable-NetFirewallRule -DisplayGroup "Remote Desktop"
    Write-Host "Enabling RDP for Desktop OS." -ForegroundColor Yellow
} elseif ($osType.ProductType -eq 2) {
    (Get-WmiObject Win32_TerminalServiceSetting -Namespace root\cimv2\TerminalServices).SetAllowTsConnections(1,1) | Out-Null
    (Get-WmiObject -Class "Win32_TSGeneralSetting" -Namespace root\cimv2\TerminalServices -Filter "TerminalName='RDP-tcp'").SetUserAuthenticationRequired(0) | Out-Null
    Get-NetFirewallRule -DisplayName "Remote Desktop*" | Set-NetFirewallRule -enabled true
    Write-Host "Enabling RDP for Domain Controller." -ForegroundColor Yellow
} else {
    (Get-WmiObject Win32_TerminalServiceSetting -Namespace root\cimv2\TerminalServices).SetAllowTsConnections(1,1) | Out-Null
    (Get-WmiObject -Class "Win32_TSGeneralSetting" -Namespace root\cimv2\TerminalServices -Filter "TerminalName='RDP-tcp'").SetUserAuthenticationRequired(0) | Out-Null
    Get-NetFirewallRule -DisplayName "Remote Desktop*" | Set-NetFirewallRule -enabled true
    Write-Host "Enabling RDP for Server OS." -ForegroundColor Yellow
}