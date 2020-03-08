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
#--- WORKING DIRECTORY ---#
#-------------------------#
Write-Host "CONFIGURING START DIRECTORY..." -ForegroundColor Yellow
Set-Location $ENV:USERPROFILE\Documents\WindowsPowerShell
Set-Variable -Name WORKINGDIRECTORY -Value "$ENV:USERPROFILE\Documents\WindowsPowerShell"

#-----------------#
#--- FUNCTIONS ---#
#-----------------#
Write-Host "IMPORTING FUNCTIONS..." -ForegroundColor Yellow
function global:Time {Get-Date -UFormat "%A, %B %e, %Y %r"}
function global:Bypass
	{
		Set-ExecutionPolicy RemoteSigned -Force -Confirm:$false;
		Set-Executionpolicy -Scope CurrentUser -ExecutionPolicy UnRestricted -Force -Confirm:$false
	}
function global:Reload {& $profile}
function global:ShowWorkDir {Get-ChildItem $WORKINGDIRECTORY -Directory}
function global:Connect-Az {.\$WORKINGDIRECTORY\Azure\Connect-AzAccount.ps1}
function global:Update-Alias
	{
	Export-Alias -Path "$WORKINGDIRECTORY\alias.ps1" -As Script
	Add-Content -Path $Profile -Value (Get-Content $WORKINGDIRECTORY\Aliases\alias.ps1)
	}
function global:Terminal { Invoke-Item "C:\Users\Odi\Desktop\Windows Terminal.lnk" }
function global:Edit-PSProfile { notepad++.exe $profile.CurrentUserCurrentHost }
function global:GetServices { Get-Service | sort Status | fw -GroupBy Status -AutoSize }
function global:GetRunningServices { Get-Service | Where-Object {$_.status -eq 'running'} | Select-Object DisplayName,Name }
function global:GetStoppedServices { Get-Service | Where-Object {$_.status -eq 'stopped'} | Select-Object DisplayName,Name }
function global:Choco-Up { choco upgrade all --verbose }

#---------------#
#--- MODULES ---#
#---------------#
Write-Host "IMPORTING MODULES..." -ForegroundColor Yellow
Import-Module -Name ActiveDirectory, PSReadline, MSOnline, VMware.PowerCLI, Az, PowerShellGet -ErrorAction SilentlyContinue

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
Write-Host "UPDATING CHOCOLATEY PACKAGES..." -ForegroundColor Yellow
choco upgrade all --verbose

#-------------#
#--- AZURE ---#
#-------------#
Write-Host "IMPORTING AZURE..." -ForegroundColor Yellow
$AzureContext = Import-AzContext -Path $WORKINGDIRECTORY\Azure\other-context.json -ErrorAction SilentlyContinue

#----------------#
#--- COMMENTS ---#
#----------------#
Write-Host "LOADING CUSTOM POWERSHELL PROFILE - DONE!" -ForegroundColor Green
