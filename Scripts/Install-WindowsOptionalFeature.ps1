<#
    TITLE.
        "Install-WindowsOptionalFeature.ps1"
    AUTHOR.
        Alex Labrosse
    PREREQUISITE(S).
        'Test-PendingReboot.ps1' script (Install-Script Test-PendingReboot -Force).
    DESCRIPTION.
        Provides a table-view of all Windows "client" (desktop) optional features.
        Prompts user for a selection.
        Installs said selection.
        Checks for pending reboot. If $True, notifies user that the host will reboot.
#>

## Script introducton
Write-Host "Review the list of Windows desktop optional features." -ForegroundColor Yellow

## Gets all Windows client OS optional features
## Shows the display name (human-readable), feature name (used to enable / disable), and state (enabled / disabled)
Get-WindowsOptionalFeature -Online -FeatureName * | Select-Object DisplayName,FeatureName,State | Format-Table -AutoSize

## Prompt user for selection
Write-Host "Enter the 'FeatureName' of the feature you would like to install."  -ForegroundColor Yellow
$FeatureName = Read-Host -Prompt "Provide a FeatureName to enable"

## Install optional feature
Enable-WindowsOptionalFeature -Online -FeatureName $FeatureName -NoRestart

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