<#
    TITLE.
        "Better-Laptop.ps1"
    PURPOSE.
        Configures device in one script.
    AUTHOR.
        Alex Labrosse
    NOTES.
        Install Chocolatey & Boxstarter.
        Removes Windows bloatware.
        Installs tools and productivity software.
        Runs Windows Updates.
        Renames hostname.
        Binds to Active Directory domain.
        Reboots.
#>

## Variables
$ADDS = "Replace with AD DS FQDN Here"

## Chocolatey
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iwr https://chocolatey.org/install.ps1 -UseBasicParsing | iex

## Chocolatey Settings
choco feature enable -n allowGlobalConfirmation
choco feature enable -n useRememberedArgumentsForUpgrades

## Boxstarter
. { iwr -useb https://boxstarter.org/bootstrapper.ps1 } | iex; Get-Boxstarter -Forceiex "& { $(irm https://aka.ms/install-powershell.ps1) } -UseMSI"

## Boxstarter.Winconfig
Disable-BingSearch
Disable-GameBarTips

## Timezone
Set-TimeZone -Name "Eastern Standard Time"

## Feature(s)
Disable-WindowsOptionalFeature -Online -FeatureName SMB1Protocol

## Remoting
Enable-PSRemoting -Force -ErrorAction 0
Set-WSManQuickConfig -Force -ErrorAction 0

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

## Repositories
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted

## Module(s)
Install-Module -Name PackageManagement -Force
Install-Module -Name PowerShellGet -Force

## SCript(s)
Install-Script Test-PendingReboot -Force

# Bloatware
Get-AppxPackage -AllUsers | Where-Object { $_.name –notlike "*Microsoft.WindowsStore*" } | Where-Object { $_.packagename -notlike "*Microsoft.WindowsCalculator*" } | Remove-AppxPackage -ErrorAction SilentlyContinue

# General
choco install 7zip
choco install adobereader
choco install notepadplusplus
choco install vlc
choco install teamviewer.host
choco install slack
choco install zoom

# G Suite
choco install google-chrome-for-enterprise
choco install adblockpluschrome
choco install google-drive-file-stream

# Office 365
choco install office365proplus

# Hostname
$SerialNumber = Get-WmiObject Win32_Bios | Select-Object -ExpandProperty SerialNumber
$NewHostName = "NY" + $SerialNumber.Substring(1, 6)
Rename-Computer -NewName $NewHostName -ErrorAction 0

# Updates
Enable-MicrosoftUpdate
Install-WindowsUpdate -getUpdatesFromMS -acceptEula -SuppressReboots

# Bind
Add-Computer -NewName $NewHostName -DomainName $ADDS -Verbose

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
