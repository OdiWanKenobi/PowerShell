# PowerShell 7 Installation

## ExecutionPolicy
Set-ExecutionPolicy RemoteSigned -Force

## Timezone
Set-TimeZone -Name "Eastern Standard Time"

## Download
$url = "https://github.com/PowerShell/PowerShell/releases/download/v7.0.0/PowerShell-7.0.0-win-x64.msi"
$output = "$env:USERPROFILE\Downloads\PowerShell-7-x64.msi"
Invoke-WebRequest -Uri $url -OutFile $output

## Install
.\$output

## Profile
Test-Path $PROFILE
if Test-Path $PROFILE -eq $false
New-item –Type File -Force $PROFILE

## Chocolatey
. { iwr -useb https://boxstarter.org/bootstrapper.ps1 } | iex; Get-Boxstarter -Force
choco feature enable -n=allowGlobalConfirmation

## GUI
choco install chocolateygui

## Bloatware
Get-AppxPackage -AllUsers | Where-Object { $_.name –notlike "*Microsoft.WindowsStore*" } | Where-Object { $_.packagename -notlike "*Microsoft.WindowsCalculator*" } | Remove-AppxPackage -ErrorAction SilentlyContinue

## Applications
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
choco install google-chrome-for-enterprise
choco install adblockpluschrome
choco install google-drive-file-stream
choco install onedrive
choco install box-drive
choco install rsat
choco install microsoft-windows-terminal
choco install vscode
choco install vscode-intellicode
choco install vscode-powershell
choco install vscode-settingssync
choco install vscode-azurerm-tools
choco install vscode.template
choco install git
choco install github-desktop
choco install azure-cli
choco install office365proplus

## Updates
Enable-MicrosoftUpdate
Install-WindowsUpdate -getUpdatesFromMS -acceptEula -SuppressReboots
Disable-MicrosoftUpdate

## Restart
Restart-Computer -Confirm
