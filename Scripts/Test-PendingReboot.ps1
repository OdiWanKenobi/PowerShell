<#
    TITLE.
        "Test-PendingReboot.ps1"
    AUTHOR.
        Alex Labrosse
    DESCRIPTION.
        Tests for "Pending Reboot" status.
        If $True, notifies user that the host will reboot.
        If $False, confirms no pending reboot and exits script.
#>

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
    Write-Host " "
 }