<#
    TITLE.
        "Windows-Updates.ps1"
    PREREQUISITE(S).
        Chocolatey & Boxstarter.
    PURPOSE.
        Downloads Windows Updates from Microsoft, accepts the EULA, and suppresses reboots.
#>


## Enabling Windows Updates
Enable-MicrosoftUpdate

## Installing Updates
Install-WindowsUpdate -getUpdatesFromMS -acceptEula -SuppressReboots

## Pause
Pause

## Reboot
Restart-Computer -Force