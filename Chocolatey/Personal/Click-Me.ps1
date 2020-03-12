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

# General
choco install 7zip
choco install adobereader
choco install notepadplusplus
choco install vlc
choco install filezilla
choco install teamviewer
choco install slack
choco install zoom
choco install lastpass
choco install dashlane
choco install whatsapp
choco install f.lux

# Google
choco install google-chrome-for-enterprise
choco install adblockpluschrome
choco install googledrive
choco install google-calendar-chrome

# File Sync
choco install google-drive-file-stream
choco install onedrive
choco install box-drive

# Servers
choco install rsat

# Troubleshooting
choco install logparser.lizardgui

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
$NewHostName = "UESFL2CP" + $SerialNumber.Substring(1, 6)
Rename-Computer -NewName $NewHostName -ErrorAction 0

# Updates
Enable-MicrosoftUpdate
Install-WindowsUpdate -getUpdatesFromMS -acceptEula -SuppressReboots

# Restart
Restart-Computer -Force -Verbose
