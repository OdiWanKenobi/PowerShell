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

#Requires -RunAsAdministrator

Write-Host " " 
Write-Host "LOADING CUSTOM POWERSHELL PROFILE..." -ForegroundColor Yellow
Write-Host " " 

Set-Location C:\

## FUNCTIONS
Write-Host "IMPORTING FUNCTIONS..." -ForegroundColor Yellow
Write-Host " " 
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
function global:Terminal { Invoke-Item "$ENV:USERPROFILE\Desktop\Windows Terminal.lnk" }
function global:Edit-Profile { notepad++.exe $profile.CurrentUserCurrentHost }
function global:GetServices { Get-Service | Sort-Object Status | Format-Wide -GroupBy Status -AutoSize }
function global:GetRunningServices { Get-Service | Where-Object {$_.status -eq 'running'} | Select-Object DisplayName,Name }
function global:GetStoppedServices { Get-Service | Where-Object {$_.status -eq 'stopped'} | Select-Object DisplayName,Name }
function global:ChocoItUp
	{
		Write-Host "UPDATING CHOCOLATEY PACKAGES..." -ForegroundColor Yellow
		choco upgrade all
		Write-Host "SUCCESSFULLY UPDATED CHOCOLATEY PACKAGES!" -ForegroundColor Green
	}
function global:GetFunctions { Get-ChildItem function: }
function global:ExecutionPolicy { Get-ExecutionPolicy -List }

## ALIASES
Write-Host "IMPORT ALIASES..." -ForegroundColor Yellow
Write-Host " " 
Set-Alias -Name:"gh" -Value:"Get-Help" -Description:"" -Option:"None"
Set-Alias -Name:"note" -Value:"notepad++.exe" -Description:"Opens Notepad++"

## CHOCOLATEY
Write-Host "IMPORTING CHOCOLATEY..." -ForegroundColor Yellow
Write-Host " " 
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
	Import-Module "$ChocolateyProfile"
}

## COMMENTS
Write-Host "SUCCESSFULLY LOADED POWERSHELL PROFILE!" -ForegroundColor Green
Write-Host " " -ForegroundColor Cyan
Write-Host "#---# USEFUL FUNCTIONS & ALIASES #---#" -ForegroundColor Cyan
Write-Host " " -ForegroundColor Cyan
Write-Host "[GETFUNCTIONS] Show all functions available." -ForegroundColor Cyan
Write-Host "[CHOCOITUP] Updates all Chocolatey packages." -ForegroundColor Cyan
Write-Host "[EDIT-PROFILE] Edit PowerShell profile in Notepad++" -ForegroundColor Cyan
Write-Host "[RELOAD] Reload PowerShell profile." -ForegroundColor Cyan
Write-Host "[BYPASS] Sets ExecutionPolicy to 'Bypass' for current process." -ForegroundColor Cyan
Write-Host "[TERMINAL] Opens Microsoft Terminal Preview." -ForegroundColor Cyan
Write-Host "[GETSERVICES] Displays all services, grouped by status." -ForegroundColor Cyan
Write-Host "[GETRUNNINGSERVICES] Displays all running services." -ForegroundColor Cyan
Write-Host "[GETSTOPPEDSERVICES] Displays all stopped services." -ForegroundColor Cyan
Write-Host "  " -ForegroundColor Cyan