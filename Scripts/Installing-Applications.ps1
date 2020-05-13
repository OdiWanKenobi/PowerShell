<#
    .TITLE
        "Installing-Applications.ps1"
    .SOURCE
        https://docs.microsoft.com/en-us/powershell/scripting/samples/working-with-software-installations?view=powershell-7
#>

Invoke-CimMethod -ClassName Win32_Product -MethodName Install -Arguments @{PackageLocation='\\AppSrv\dsp\NewPackage.msi'}