<#
    .TITLE
        "Install-ChocoSimple.ps1"
    .PURPOSE
        Installs Chocolatey package manager for Windows (chocolatey.org).
    .PREREQUISITE(S)
        Run as Administrator.
#>

#RunAs Administrator

## Execution Policy
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force

## Choco Install
Install-Module Chocolatey
Install-ChocolateySoftware

## Choco Setting(s)
choco feature enable -n=allowGlobalConfirmation
choco feature enable -n useRememberedArgumentsForUpgrades