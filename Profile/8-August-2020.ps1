<#
	.TITLE
		'Microsoft.PowerShell_profile.ps1'
	.DATE
		9 August 2020
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

<#
    .CHANGELOG
        [06-02-2020]
            Added "Updates" function - runs the "Windows-Updates.ps1" script as a function.
            Added "Start-PSAdmin" function - runs a new elevated (administrator) PowerShell session.
            Added "Update-PSHelp" function - downloads and updates PowerShell help articles.
            Added "Profile" function - changes working directory to $env:USERPROFILE\OneDrive\Documents\GitHub\alabrosse\PowerShell\Profile.
            Added "Functions" function - changes working directory to $env:USERPROFILE\OneDrive\Documents\GitHub\alabrosse\PowerShell\Functions.
            Updated "Scripts" function - changes working directory to $env:USERPROFILE\OneDrive\Documents\GitHub\alabrosse\PowerShell\Scripts.
            Updated ".URI" to point to the new public Gist URI.
        [07-01-2020]
			Added "Update-Pwsh" function to update to most recent stable PowerShell Core version.
		[08-09-2020]
			Added "Code" function; opens VS Code .lnk file. This ensures that new sessions of VS Code are elevated.
#>

#Requires -RunAsAdministrator

Set-Location C:\

## FUNCTIONS
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
#function global:Update-Profile { 
#	$profileUri = 'https://gist.githubusercontent.com/OdiWanKenobi/5170bd6ca6a6543a35ee68adeba211a6/raw/6ea1f4c6047ce4f368fb2fc08bb8ceaeee5f43e0/Microsoft.PowerShell_profile.ps1'
#	$profileDownload = Invoke-WebRequest -Uri $profileUri
#	$profileContent = $profileDownload.Content
#	Add-Content -Path $profile -Value $profileContent -Verbose
#	Write-Host "Updated local PowerShell profile from gist.github.com" -ForegroundColor Green
#}
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
function global:Update-PSHelp { Update-Help -Force -ErrorAction 0 }
function global:Update-Pwsh { iex "& { $(irm https://aka.ms/install-powershell.ps1) } -UseMSI" }
function global:Code { & 'C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Visual Studio Code\Visual Studio Code.lnk' }

## ALIASES
Set-Alias -Name:"gh" -Value:"Get-Help" -Description:"" -Option:"None"
Set-Alias -Name:"note" -Value:"notepad++.exe" -Description:"Opens Notepad++"

## CHOCOLATEY
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
	Import-Module "$ChocolateyProfile"
}

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
Start-Transcript -Path $LogPath
