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
Write-Host "LOADING CUSTOM POWERSHELL PROFILE - START!" -ForegroundColor Cyan

#------------------------#
#--- EXECUTION POLICY ---#
#------------------------#
Write-Host "CONFIGURING EXECUTIONPOLICY..." -ForegroundColor Yellow
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process
$ExecutionPolicy = (Get-ExecutionPolicy).ToString()
$env:PSElevated = Test-Elevated

#-------------------------#
#--- DIRECTORIES ---#
#-------------------------#
Write-Host "CONFIGURING START DIRECTORY..." -ForegroundColor Yellow
Set-Location $ENV:USERPROFILE\Documents\WindowsPowerShell

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
function global:Connect-Az {.\$ENV:USERPROFILE\Documents\WindowsPowerShell\Azure\Connect-AzAccount.ps1}
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

#---------------#
#--- MODULES ---#
#---------------#
Write-Host "IMPORTING MODULES..." -ForegroundColor Yellow
Import-Module -Name ActiveDirectory, PSReadline, MSOnline, VMware.PowerCLI, Az, PowerShellGet -ErrorAction SilentlyContinue | Out-Null

#---------------#
#--- ALIASES ---#
#---------------#
Set-Alias -Name:"gh" -Value:"Get-Help" -Description:"" -Option:"None"
Set-Alias -Name:"note" -Value:"notepad++.exe" -Description:"Opens Notepad++"

#------------------#
#--- CHOCOLATEY ---#
#------------------#
Write-Host "IMPORTING CHOCOLATEY..." -ForegroundColor Yellow
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
	Import-Module "$ChocolateyProfile"
}

#-------------#
#--- AZURE ---#
#-------------#
Write-Host "IMPORTING AZURE..." -ForegroundColor Yellow
$AzureContext = Import-AzContext -Path $ENV:USERPROFILE\Documents\GitHub\Azure\other-context.json -ErrorAction SilentlyContinue

#----------------#
#--- COMMENTS ---#
#----------------#
Write-Host "SUCCESSFULLY LOADED CUSTOM POWERSHELL PROFILE!" -ForegroundColor Green
