<#
	.AUTHOR
		Alex Labrosse

	.SYNOPSIS
		Customized PowerShell $profile.

	.NOTES
		Loads commonly used modules.
		Sets shell start location to local working directory.
		Defines commonly used functions.
		Configures shell to dynamically update functions repository.
#>

#---------------------------#
#--- RUNAS ADMINISTRATOR ---#
#---------------------------#
#Requires -RunAsAdministrator
Write-Host "LOADING CUSTOM POWERSHELL PROFILE..." -ForegroundColor Yellow

#-------------------------#
#--- DIRECTORIES ---#
#-------------------------#
Write-Host "CONFIGURING START DIRECTORY..." -ForegroundColor Yellow
Set-Location C:\

#-----------------#
#--- FUNCTIONS ---#
#-----------------#
Write-Host "IMPORTING FUNCTIONS..." -ForegroundColor Yellow
function global:Date {Get-Date -UFormat "%A, %B %e, %Y %r"}
function global:Bypass
	{
		Set-ExecutionPolicy -Scope LocalMachine -ExecutionPolicy RemoteSigned -Force -Confirm:$false;
		Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy UnRestricted -Force -Confirm:$false
	}
function global:Reload {& $profile}
function global:Update-Alias
	{
	Export-Alias -Path "$ENV:USERPROFILE\Documents\WindowsPowerShell\Aliases\alias.ps1" -As Script
	Add-Content -Path $Profile -Value (Get-Content $ENV:USERPROFILE\Documents\WindowsPowerShell\Aliases\alias.ps1)
	}
function global:Terminal { Invoke-Item "C:\Users\Odi\Desktop\Windows Terminal.lnk" }
function global:Edit-Profile { notepad++.exe $profile.CurrentUserCurrentHost }
function global:GetServices { Get-Service | Sort-Object Status | Format-Wide -GroupBy Status -AutoSize }
function global:GetRunningServices { Get-Service | Where-Object {$_.status -eq 'running'} | Select-Object DisplayName,Name }
function global:GetStoppedServices { Get-Service | Where-Object {$_.status -eq 'stopped'} | Select-Object DisplayName,Name }
function global:ChocoItUp
	{
		Write-Host "UPDATING CHOCOLATEY PACKAGES..." -ForegroundColor Yellow
		choco upgrade all --verbose
		Write-Host "SUCCESSFULLY UPDATED CHOCOLATEY PACKAGES!" -ForegroundColor Green
	}
function global:GetFunctions { Get-ChildItem function: }
function global:ExecutionPolicy { Get-ExecutionPolicy -List }

#---------------#
#--- ALIASES ---#
#---------------#
Write-Host "IMPORT ALIASES..." -ForegroundColor Yellow
Set-Alias -Name:"gh" -Value:"Get-Help" -Description:"Get-Help"
Set-Alias -Name:"np" -Value:"notepad++.exe" -Description:"Opens Notepad++"

#------------------#
#--- CHOCOLATEY ---#
#------------------#
Write-Host "IMPORTING CHOCOLATEY..." -ForegroundColor Yellow
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
	Import-Module "$ChocolateyProfile"
}

#----------------#
#--- COMMENTS ---#
#----------------#
Write-Host "SUCCESSFULLY LOADED POWERSHELL PROFILE!" -ForegroundColor Green
Write-Host "`n #--- USEFUL FUNCTIONS & ALIASES ---# `n `n [GETFUNCTIONS] Show all functions available. `n [CHOCOITUP] Updates all Chocolatey packages. `n [EDIT-PROFILE] Edit PowerShell profile in Notepad++ `n [RELOAD] Reload PowerShell profile. `n [BYPASS] Sets ExecutionPolicy to 'Bypass' for current process. `n [TERMINAL] Opens Microsoft Terminal Preview. `n [GETSERVICES] Displays all services, grouped by status. `n [GETRUNNINGSERVICES] Displays all running services. `n [GETSTOPPEDSERVICES] Displays all stopped services. `n " -ForegroundColor Cyan
