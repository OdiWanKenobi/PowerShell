<#
    .TITLE
        'Install-HyperV.ps1'
    .DESCRIPTION
        Installs the Hyper-V feature on Windows 10.
#>

Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All