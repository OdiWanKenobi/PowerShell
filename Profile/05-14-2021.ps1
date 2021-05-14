<#
.WORKING LOCATION
#>

Set-Location C:\

<#
.FUNCTIONS
#>

function global:Bypass
	{
		Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force
	}

function global:Reload {& $profile}

function global:Update-Alias
	{
	Export-Alias -Path "$ENV:USERPROFILE\Documents\WindowsPowerShell\Aliases\alias.ps1" -As Script
	Add-Content -Path $Profile -Value (Get-Content $ENV:USERPROFILE\Documents\WindowsPowerShell\Aliases\alias.ps1)
	}

function global:Edit-Profile { notepad++.exe $profile.CurrentUserCurrentHost }
 
function global:ChocoItUp
	{
		Write-Host "UPDATING CHOCOLATEY PACKAGES..." -ForegroundColor Yellow
		choco upgrade all
		Write-Host "SUCCESSFULLY UPDATED CHOCOLATEY PACKAGES!" -ForegroundColor Green
	}

function global:GetFunctions { Get-ChildItem function: }

function global:ExecutionPolicy { Get-ExecutionPolicy -List }

function global:Scripts { Set-Location -Path $env:USERPROFILE\OneDrive\Documents\GitHub\alabrosse\PowerShell\Scripts }

function global:Update-PSHelp { Update-Help -Force -ErrorAction 0 }

function global:Update-Pwsh { iex "& { $(irm https://aka.ms/install-powershell.ps1) } -UseMSI" }

function global:AWS { Import-Module AWSPowerShell.NetCore }

function global:ChocoInstalls { choco find --local-only }

function global:ChocoInstallsPlusPrograms { choco find --local-only --include-programs }

function global:Hibernate { $Env:WinDir shutdown.exe /h }

function global:Reboot { $Env:WinDir shutdown.exe /r }

function global:Shutdown { $Env:WinDir shutdown.exe /s }

function global:Logoff { $Env:WinDir shutdown.exe /l }

<#
.ALIASES
#>

Set-Alias -Name:"gh" -Value:"Get-Help" -Description:"" -Option:"None"
Set-Alias -Name:"note" -Value:"notepad++.exe" -Description:"Opens Notepad++"
