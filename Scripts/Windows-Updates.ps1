<#
    TITLE.
        "Windows-Updates.ps1"
    PREREQUISITE(S).
        Chocolatey & Boxstarter.
    PURPOSE.
        Downloads Windows Updates from Microsoft, accepts the EULA, and suppresses reboots.
#>

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