<#
    TITLE.
        "Install-HyperV.ps1"
    PURPOSE.
        On Windows server, installs the Hyper-V role as well as the necessary management tools.
#>

## Hyper-V
Install-WindowsFeature -Name Hyper-V -IncludeManagementTools -Restart 