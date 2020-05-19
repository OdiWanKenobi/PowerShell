<#
    .TITLE
        "Install-Chocolatey.ps1"
    .PURPOSE
        Installs Chocolatey package manager for Windows (chocolatey.org).
#>

Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

choco feature enable -n=allowGlobalConfirmation
choco feature enable -n useRememberedArgumentsForUpgrades