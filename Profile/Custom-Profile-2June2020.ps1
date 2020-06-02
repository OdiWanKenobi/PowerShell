<#
	.TITLE
		'Microsoft.PowerShell_profile.ps1'
	.DATE
		28 May 2020
	.AUTHOR
		Alex Labrosse
	.SYNOPSIS
		Customized PowerShell $profile.
	.NOTES
		Loads commonly used modules.
		Sets shell start location to local working directory.
		Defines commonly used functions.
		Configures shell to dynamically update functions repository.
	.URI
		https://gist.githubusercontent.com/OdiWanKenobi/5170bd6ca6a6543a35ee68adeba211a6/raw/030c841498d24d95c2c53b7fe38df3d25b2d1cc2/Microsoft.PowerShell_profile.ps1
#>

<#
    .CHANGELOG
        [06-02-2020]:\
            Added "Updates" function - runs the "Windows-Updates.ps1" script as a function.
            Added "Start-PSAdmin" function - runs a new elevated (administrator) PowerShell session.
            Added "Update-PSHelp" function - downloads and updates PowerShell help articles.
            Added "Profile" function - changes working directory to $env:USERPROFILE\OneDrive\Documents\GitHub\alabrosse\PowerShell\Profile.
            Added "Functions" function - changes working directory to $env:USERPROFILE\OneDrive\Documents\GitHub\alabrosse\PowerShell\Functions.
            Updated "Scripts" function - changes working directory to $env:USERPROFILE\OneDrive\Documents\GitHub\alabrosse\PowerShell\Scripts.
            Updated ".URI" to point to the new public Gist URI.
#>

#Requires -RunAsAdministrator

Write-Host " "
Write-Host "######################################################################################################" -ForegroundColor Yellow
Write-Host "################################# LOADING CUSTOM POWERSHELL PROFILE ##################################" -ForegroundColor Yellow
Write-Host "######################################################################################################" -ForegroundColor Yellow

Set-Location C:\

## FUNCTIONS
Write-Host " "
Write-Host "######################################################################################################" -ForegroundColor Yellow
Write-Host "######################################## IMPORTING FUNCTIONS #########################################" -ForegroundColor Yellow
Write-Host "######################################################################################################" -ForegroundColor Yellow
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
	$profileUri = 'https://gist.githubusercontent.com/OdiWanKenobi/5170bd6ca6a6543a35ee68adeba211a6/raw/6ea1f4c6047ce4f368fb2fc08bb8ceaeee5f43e0/Microsoft.PowerShell_profile.ps1'
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
function global:Scripts { Set-Location -Path $env:USERPROFILE\OneDrive\Documents\GitHub\alabrosse\PowerShell\Scripts }
function global:Functions { Set-Location -Path $env:USERPROFILE\OneDrive\Documents\GitHub\alabrosse\PowerShell\Functions }
function global:Profile { Set-Location -Path $env:USERPROFILE\OneDrive\Documents\GitHub\alabrosse\PowerShell\Profile }
function global:Updates 
{
    ## Import Modules
    Import-Module $ChocolateyProfile
    Import-Module Boxstarter.Winconfig

    ## Enable Updates
    Enable-MicrosoftUpdate

    ## Install Updates
    Install-WindowsUpdate -getUpdatesFromMS -acceptEula -SuppressReboots

    ## Check for Pending Reboot
    $Reboot = Test-PendingReboot -ComputerName localhost

    ## If $TRUE, force reboot.
    ## Else $FALSE, exit message.
    if ($Reboot -eq $True)
        {
            Write-Host " "
            Write-Host "Pending reboot detected." -ForegroundColor Yellow
            Write-Host "Press any button to continue with reboot." -ForegroundColor Yellow
            Write-Host " "
            Pause
            Restart-Computer -Force
        }
    else
        {
            Write-Host " "
            Write-Host "No pending reboot detected." -ForegroundColor Yellow
            Write-Host "Updates installed successfully." -ForegroundColor Green
            Write-Host " "
        }
}
function global:Start-PSAdmin { Start-Process PowerShell -Verb RunAs }
function global:Update-PSHelp { Update-Help -Force -ErrorAction SilentlyContinue }


## ALIASES
Write-Host " "
Write-Host "######################################################################################################" -ForegroundColor Yellow
Write-Host "########################################### IMPORT ALIASES ###########################################" -ForegroundColor Yellow
Write-Host "######################################################################################################" -ForegroundColor Yellow

Set-Alias -Name:"gh" -Value:"Get-Help" -Description:"" -Option:"None"
Set-Alias -Name:"note" -Value:"notepad++.exe" -Description:"Opens Notepad++"

## CHOCOLATEY
Write-Host " "
Write-Host "######################################################################################################" -ForegroundColor Yellow
Write-Host "######################################### IMPORTING CHOCOLATEY #######################################" -ForegroundColor Yellow
Write-Host "######################################################################################################" -ForegroundColor Yellow
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
	Import-Module "$ChocolateyProfile"
}

## COMMENTS
Write-Host " "
Write-Host "######################################################################################################" -ForegroundColor Green
Write-Host "############################## SUCCESSFULLY LOADED POWERSHELL PROFILE ################################" -ForegroundColor Green
Write-Host "######################################################################################################" -ForegroundColor Green
Write-Host " "

Write-Host "######################################################################################################" -ForegroundColor Cyan
Write-Host "########################################## 'GETFUNCTIONS' ############################################" -ForegroundColor Cyan
Write-Host "################################### Show all functions available #####################################" -ForegroundColor Cyan

Write-Host "######################################################################################################" -ForegroundColor Cyan
Write-Host "############################################ 'CHOCOITUP' #############################################" -ForegroundColor Cyan
Write-Host "################################# Updates all Chocolatey packages ####################################" -ForegroundColor Cyan

Write-Host "######################################################################################################" -ForegroundColor Cyan
Write-Host "########################################## 'EDIT-PROFILE' ############################################" -ForegroundColor Cyan
Write-Host "############################### Edit PowerShell profile in Notepad++ #################################" -ForegroundColor Cyan

Write-Host "######################################################################################################" -ForegroundColor Cyan
Write-Host "######################################### 'UPDATE-PROFILE' ###########################################" -ForegroundColor Cyan
Write-Host "############################### Update PowerShell profile from Github ################################" -ForegroundColor Cyan

Write-Host "######################################################################################################" -ForegroundColor Cyan
Write-Host "############################################# 'RELOAD' ###############################################" -ForegroundColor Cyan
Write-Host "##################################### Reload PowerShell profile ######################################" -ForegroundColor Cyan

Write-Host "######################################################################################################" -ForegroundColor Cyan
Write-Host "############################################# 'BYPASS' ###############################################" -ForegroundColor Cyan
Write-Host "##################################### Bypasses execution policy ######################################" -ForegroundColor Cyan

Write-Host "######################################################################################################" -ForegroundColor Cyan
Write-Host "############################################# 'TERMINAL' #############################################" -ForegroundColor Cyan
Write-Host "################################# Opens Microsoft Terminal Preview ###################################" -ForegroundColor Cyan

Write-Host "######################################################################################################" -ForegroundColor Cyan
Write-Host "########################################### 'GETSERVICES' ############################################" -ForegroundColor Cyan
Write-Host "############################# Displays all services, grouped by status ###############################" -ForegroundColor Cyan

Write-Host "######################################################################################################" -ForegroundColor Cyan
Write-Host "####################################### 'GETRUNNINGSERVICES' #########################################" -ForegroundColor Cyan
Write-Host "################################### Displays all running services ####################################" -ForegroundColor Cyan

Write-Host "######################################################################################################" -ForegroundColor Cyan
Write-Host "####################################### 'GETSTOPPEDSERVICES' #########################################" -ForegroundColor Cyan
Write-Host "################################### Displays all stopped services ####################################" -ForegroundColor Cyan

Write-Host "######################################################################################################" -ForegroundColor Cyan
Write-Host "############################################## 'DATE' ################################################" -ForegroundColor Cyan
Write-Host "######################################### Displays the date ##########################################" -ForegroundColor Cyan

Write-Host "######################################################################################################" -ForegroundColor Cyan
Write-Host "############################################ 'SCRIPTS' ###############################################" -ForegroundColor Cyan
Write-Host "############################ Changes working directory to Scripts folder #############################" -ForegroundColor Cyan

Write-Host "######################################################################################################" -ForegroundColor Cyan
Write-Host "############################################ 'UPDATES' ###############################################" -ForegroundColor Cyan
Write-Host "############################## Downloads and installs Windows Updates ################################" -ForegroundColor Cyan

Write-Host "######################################################################################################" -ForegroundColor Cyan
Write-Host "######################################### 'START-PSADMIN' ############################################" -ForegroundColor Cyan
Write-Host "################################ Starts PowerShell session as admin ##################################" -ForegroundColor Cyan

Write-Host "######################################################################################################" -ForegroundColor Cyan
Write-Host "######################################### 'UPDATE-PSHELP' ############################################" -ForegroundColor Cyan
Write-Host "########################## Downloads and updates PowerShell help articles ############################" -ForegroundColor Cyan

Write-Host "######################################################################################################" -ForegroundColor Cyan
Write-Host " "

## Converting the DateTime object to a string using 'Get-Date -Format o'
## Using this unique string to generate filenames for PowerShell transcripts
$TranscriptFileName = Get-Date -Format 'dd-MMMM-yyyy-HH-mm-ss'

## Verifies if the directory exists
## If not, creates the necessary folder
$LogFolder = "C:\Transcripts\"
if (!(Test-Path -Path $LogFolder)) {
    New-Item -ItemType Directory -Path $LogFolder -Force
  }

## Creates a new, unique log file for each PowerShell session
$LogPath = "C:\Transcripts\" + "$TranscriptFileName" + ".txt"
Start-Transcript -Path $LogPath -Verbose
