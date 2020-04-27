<#
    TITLE.
        "Click-Me.ps1"

    PURPOSE.
        Configures device in one script.

    NOTES.
        Install Chocolatey & Boxstarter.
        Removes Windows bloatware.
        Installs tools and productivity software.
        Runs Windows Updates.
        Renames hostname.
        Binds to Active Directory domain.
        Reboots.

#>

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

## PowerShell 7
iex "& { $(irm https://aka.ms/install-powershell.ps1) } -UseMSI"

# Bloatware
Get-AppxPackage -AllUsers | Where-Object { $_.name –notlike "*Microsoft.WindowsStore*" } | Where-Object { $_.packagename -notlike "*Microsoft.WindowsCalculator*" } | Remove-AppxPackage -ErrorAction SilentlyContinue

# GUI
choco install chocolateygui

# General
choco install 7zip
choco install adobereader
choco install notepadplusplus
choco install vlc
choco install filezilla
choco install teamviewer
choco install telegram.install
choco install slack
choco install zoom
choco install lastpass
choco install dashlane
choco install whatsapp
choco install f.lux

# Chrome
choco install googlechrome
choco install adblockpluschrome

# Google
choco install google-backup-and-sync
choco install google-drive-file-stream
choco install googledrive
choco install google-chrome-for-enterprise
choco install google-calendar-chrome

# File Sync
choco install onedrive
choco install box-drive
choco install boxsync

# Servers
choco install sql-server-management-studio
choco install rsat

# Troubleshooting
choco install logparser
choco install sysinternals
choco install procexp
choco install procmon
choco install baretail
choco install angryip

# Utilities
choco install treesizefree
choco install rufus

# Editors
choco install microsoft-windows-terminal
choco install vscode
choco install vscode-intellicode
choco install vscode-powershell
choco install vscode-settingssync
choco install vscode-azurerm-tools
choco install vscode.template
choco install git
choco install github-desktop

# Azure
choco install azure-cli
choco install microsoftazurestorageexplorer
choco install fogg

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
Add-Computer -NewName $NewHostName -DomainName "corp.better.site" -OUPath "OU=Computers,OU=IT,dc=corp,DC=better,DC=site" -Verbose

# Restart
Restart-Computer -Force -Verbose
