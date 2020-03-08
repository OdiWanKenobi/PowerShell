<#
    TITLE.
        "Windows-Updates.ps1"

    PURPOSE.
        Downloads Windows Updates from Microsoft, accepts the EULA, and suppresses reboots.
#>

Enable-MicrosoftUpdate
Install-WindowsUpdate -getUpdatesFromMS -acceptEula -SuppressReboots