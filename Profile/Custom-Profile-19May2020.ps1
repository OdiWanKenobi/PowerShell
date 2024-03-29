<#
	.TITLE
		'Microsoft.PowerShell_profile.ps1'
	.DATE
		19 May 2020
	.AUTHOR
		Alex Labrosse
	.SYNOPSIS
		Customized PowerShell $profile.
	.NOTES
		Loads commonly used modules.
		Sets shell start location to local working directory.
		Defines commonly used functions.
		Configures shell to dynamically update functions repository.
	.URL
		https://gist.githubusercontent.com/OdiWanKenobi/5170bd6ca6a6543a35ee68adeba211a6/raw/f2ddbc0e81981e45a6f604f482840f50c9076d64/Microsoft.PowerShell_profile.ps1
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
		Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force
	}
function global:Reload {& $profile}
function global:Update-Alias
	{
	Export-Alias -Path "$ENV:USERPROFILE\Documents\WindowsPowerShell\Aliases\alias.ps1" -As Script
	Add-Content -Path $Profile -Value (Get-Content $ENV:USERPROFILE\Documents\WindowsPowerShell\Aliases\alias.ps1)
	}
function global:Terminal { Invoke-Item "$ENV:USERPROFILE\Desktop\Windows Terminal.lnk" }
function global:Edit-Profile { notepad++.exe $profile.CurrentUserCurrentHost }
function global:Update-Profile { 
	$profileUri = 'https://gist.githubusercontent.com/OdiWanKenobi/5170bd6ca6a6543a35ee68adeba211a6/raw/f2ddbc0e81981e45a6f604f482840f50c9076d64/Microsoft.PowerShell_profile.ps1'
	$profileDownload = Invoke-WebRequest -Uri $profileUri
	$profileContent = $profileDownload.Content
	Add-Content -Path $profile -Value $profileContent -Verbose
	Write-Host "Updated local PowerShell profile from gist.github.com" -ForegroundColor Green
}
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
Write-Host "###################################################" -ForegroundColor Green
Write-Host "##### SUCCESSFULLY LOADED POWERSHELL PROFILE ######" -ForegroundColor Green
Write-Host "###################################################" -ForegroundColor Green
Write-Host " " -ForegroundColor Cyan
Write-Host "###################################################" -ForegroundColor Cyan
Write-Host "########### USEFUL FUNCTIONS & ALIASES ############" -ForegroundColor Cyan
Write-Host "###################################################" -ForegroundColor Cyan
Write-Host " " -ForegroundColor Cyan

Write-Host "###################################################" -ForegroundColor Cyan
Write-Host "################# 'GETFUNCTIONS' ##################" -ForegroundColor Blue
Write-Host "########## Show all functions available ###########" -ForegroundColor Cyan

Write-Host "###################################################" -ForegroundColor Cyan
Write-Host "################### 'CHOCOITUP' ###################" -ForegroundColor Blue
Write-Host "######## Updates all Chocolatey packages ##########" -ForegroundColor Cyan

Write-Host "###################################################" -ForegroundColor Cyan
Write-Host "################# 'EDIT-PROFILE' ##################" -ForegroundColor Blue
Write-Host "###### Edit PowerShell profile in Notepad++ #######" -ForegroundColor Cyan

Write-Host "###################################################" -ForegroundColor Cyan
Write-Host "################ 'UPDATE-PROFILE' #################" -ForegroundColor Blue
Write-Host "###### Update PowerShell profile from Github ######" -ForegroundColor Cyan

Write-Host "###################################################" -ForegroundColor Cyan
Write-Host "#################### 'RELOAD' #####################" -ForegroundColor Blue
Write-Host "############ Reload PowerShell profile ############" -ForegroundColor Cyan

Write-Host "###################################################" -ForegroundColor Cyan
Write-Host "#################### 'BYPASS' #####################" -ForegroundColor Blue
Write-Host "############ Bypasses execution policy ############" -ForegroundColor Cyan

Write-Host "###################################################" -ForegroundColor Cyan
Write-Host "#################### 'TERMINAL' ###################" -ForegroundColor Blue
Write-Host "######## Opens Microsoft Terminal Preview #########" -ForegroundColor Cyan

Write-Host "###################################################" -ForegroundColor Cyan
Write-Host "################## 'GETSERVICES' ##################" -ForegroundColor Blue
Write-Host "#### Displays all services, grouped by status #####" -ForegroundColor Cyan

Write-Host "###################################################" -ForegroundColor Cyan
Write-Host "############## 'GETRUNNINGSERVICES' ###############" -ForegroundColor Blue
Write-Host "########## Displays all running services ##########" -ForegroundColor Cyan

Write-Host "###################################################" -ForegroundColor Cyan
Write-Host "############## 'GETSTOPPEDSERVICES' ###############" -ForegroundColor Blue
Write-Host "########## Displays all stopped services ##########" -ForegroundColor Cyan
Write-Host "  " -ForegroundColor Cyan

## Converting the DateTime object to a string using 'Get-Date -Format o'
## Using this unique string to generate filenames for PowerShell transcripts
$TranscriptFileName = Get-Date -Format o

## Verifies if the directory exists
## If not, creates the necessary folder
$LogFolder = "C:\Transcripts\"
if (!(Test-Path -Path $LogFolder)) {
    New-Item -ItemType Directory -Path $LogFolder -Force
  }

## Creates a new, unique log file for each PowerShell session
$LogPath = "C:\Transcripts\" + "$TranscriptFileName" + ".txt"
Start-Transcript -Path $LogPath -Verbose