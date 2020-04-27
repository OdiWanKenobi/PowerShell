<#
    TITLE.
        "Windows-Updates.ps1"
    PREREQUISITE(S).
        Chocolatey & Boxstarter.
    PURPOSE.
        Downloads Windows Updates from Microsoft, accepts the EULA, and suppresses reboots.
#>

## Modules
Import-Module $ChocolateyProfile
Import-Module Boxstarter.Winconfig

## Enabling Windows Updates
Enable-MicrosoftUpdate

## Installing Updates
Install-WindowsUpdate -getUpdatesFromMS -acceptEula -SuppressReboots

## If / Else
$Reboot = Test-PendingReboot -ComputerName localhost
if ($Reboot = $True)
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