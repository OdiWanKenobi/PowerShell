<#
    .TITLE
        "Elevate-PowerShell.ps1"
    .SUMMARY
        Simply add this snippet at the beginning of a script that requires elevation to run properly. 
        It works by starting a new elevated PowerShell window and then re-executes the script in this new window, if necessary. 
        If User Account Control (UAC) is enabled, you will get a UAC prompt. 
        If the script is already running in an elevated PowerShell session or UAC is disabled, the script will run normally. 
        This code also allows you to right-click the script in File Explorer and select "Run with PowerShell".
#>

Start-Process powershell -Verb runAs