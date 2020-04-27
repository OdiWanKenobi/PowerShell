<#
    .TITLE
        "Install-Boxstarter.ps1"
    .PURPOSE
        Install Chocolatey and Boxstarter for configuration, timezone, basic applications installation, and updates.
#>

Set-ExecutionPolicy Bypass -Scope Process -Force; . { iwr -useb https://boxstarter.org/bootstrapper.ps1 } | iex; Get-Boxstarter -Force

choco feature enable -n=allowGlobalConfirmation