<#

    TITLE.
        "Install-AzureCLI.ps1"

    PURPOSE.
        Downloads and install the AzureCLI MSI.

    NOTES.
        If you've disabled module autoloading, manually import the module with Import-Module Az.
        Because of the wsay the module is structured, this can take a few seconds.

#>

## Variable(s)
$downloads = "$Env:USERPROFILE\Downloads"

Invoke-WebRequest -Uri https://aka.ms/installazurecliwindows -OutFile .\AzureCLI.msi; Start-Process msiexec.exe -Wait -ArgumentList '/I AzureCLI.msi /quiet'; rm .\AzureCLI.msi