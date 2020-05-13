<#
    TITLE.
        "Rename-Computer.ps1"
    PURPOSE.
        Takes the serial number, and uses the last 6 digits to generate a new hostname.
#>

## Capture desired hostname
$NewHostName = Read-Host -Prompt "Enter the desired hostname."

## Renaming host
Rename-Computer -NewName $NewHostName -Force

## Restart notice
Write-Host "In order to finish the renaming process" -ForegroundColor Yellow
Write-Host "Windows must RESTART." -ForegroundColor Yellow

## Pause
Pause

## Restart
Restart-Computer -Force