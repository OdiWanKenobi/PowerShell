## Chocolatey
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iwr https://chocolatey.org/install.ps1 -UseBasicParsing | iex

## Chocolatey Settings
choco feature enable -n allowGlobalConfirmation

## System Settings
Get-WindowsCapability -Name RSAT* -Online | Add-WindowsCapability –Online
Set-TimeZone -Name "Eastern Standard Time"

## Boxstarter
. { iwr -useb https://boxstarter.org/bootstrapper.ps1 } | iex; Get-Boxstarter -Forceiex "& { $(irm https://aka.ms/install-powershell.ps1) } -UseMSI"

## PowerShell 7
iex "& { $(irm https://aka.ms/install-powershell.ps1) } -UseMSI"

## Microsoft
choco install intellitype
choco install program-install-and-uninstall-troubleshooter
choco install msoid-cli
choco install selenium-all-drivers
choco install microsoft-message-analyzer
choco install microsoftmathematics
choco install azurepowershell
choco install windows-defender-browser-protection-chrome
choco install configuration.powershell

## Software
choco install microsoft-edge
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