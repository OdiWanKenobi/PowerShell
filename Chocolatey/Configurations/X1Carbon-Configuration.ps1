## Chocolatey
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iwr https://chocolatey.org/install.ps1 -UseBasicParsing | iex

## Chocolatey Settings
choco feature enable -n allowGlobalConfirmation

## Boxstarter
. { iwr -useb https://boxstarter.org/bootstrapper.ps1 } | iex; Get-Boxstarter -Forceiex "& { $(irm https://aka.ms/install-powershell.ps1) } -UseMSI"

## Boxstarter.Winconfig
Disable-BingSearch
Disable-GameBarTips

## Timezone
Set-TimeZone -Name "Eastern Standard Time"

## Feature(s)
Get-WindowsCapability -Name RSAT* -Online | Add-WindowsCapability –Online
Disable-WindowsOptionalFeature -Online -FeatureName SMB1Protocol

## Remoting
Enable-PSRemoting -Force
winrm quickconfig -quiet

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

## Module(s)
Install-Module -Name PackageManagement -Force
Install-Module -Name MSOnline -Force
Install-Module -Name PowerShellGet -Force
Install-Module -Name PSReadline -Force
Install-Module -Name Az -AllowClobber -Force

## Script(s)
Install-Script Test-PendingReboot -Force

## Repositories
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted

## PowerShell 7
iex "& { $(irm https://aka.ms/install-powershell.ps1) } -UseMSI"

## Microsoft
choco install intellitype
choco install msoid-cli
choco install selenium-all-drivers
choco install microsoft-message-analyzer
choco install microsoftmathematics
choco install azurepowershell
choco install windows-defender-browser-protection-chrome
choco install configuration.powershell
choco install microsoft-windows-terminal
choco install microsoft-edge

## Software
choco install notepadplusplus
choco install dashlane
choco install authy
choco install discord
choco install steam
choco install github-desktop
choco install acronis-drive-monitor
choco install lenovo-thinkvantage-system-update
choco install chocolateygui

## Visual Studio
choco install vscode
choco install vscode-powershell
choco install visualstudio-2019-remotetools
choco install vscode-settingssync
choco install vscode-intellicode
choco install openinvscode

# Updates
Enable-MicrosoftUpdate
Install-WindowsUpdate -getUpdatesFromMS -acceptEula -SuppressReboots

## Rename
$NewHostName = Read-Host -Prompt 'Enter new computer name'
Rename-Computer -NewName $NewHostName -Force

## Pending Reboot
$Reboot = Test-PendingReboot -ComputerName localhost
if ($Reboot = $True)
 {
    Write-Host " "
    Write-Host "Pending reboot detected." -ForegroundColor Yellow
    Write-Host "Press any button to continue with reboot." -ForegroundColor Yellow
    Write-Host " "
    Pause
    Restart-Computer -Force
 }
else
 {
    Write-Host " "
    Write-Host "No pending reboot detected." -ForegroundColor Yellow
    Write-Host "Updates installed successfully." -ForegroundColor Green
    Write-Host " "
 }