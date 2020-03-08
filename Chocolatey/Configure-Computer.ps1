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

# Chocolatey & Boxstater
. { Invoke-WebRequest -useb https://boxstarter.org/bootstrapper.ps1 } | Invoke-Expression; Get-Boxstarter -Force
choco feature enable -n=allowGlobalConfirmation

# Timezone
Set-TimeZone -Name "Eastern Standard Time"

# Bloatware
Get-AppxPackage -AllUsers | Where-Object { $_.name –notlike "*Microsoft.WindowsStore*" } | Where-Object { $_.packagename -notlike "*Microsoft.WindowsCalculator*" } | Remove-AppxPackage -ErrorAction SilentlyContinue

# GUI
choco install chocolateygui

# Lenovo
choco install lenovo-thinkvantage-system-update
choco install unifying

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
choco install azurepowershell
choco install microsoftazurestorageexplorer
choco install AzurePowerShell
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