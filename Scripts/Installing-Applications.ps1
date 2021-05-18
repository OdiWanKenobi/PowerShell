<<<<<<< HEAD
<#
    .TITLE
        "Installing-Applications.ps1"
    .SOURCE
        https://docs.microsoft.com/en-us/powershell/scripting/samples/working-with-software-installations?view=powershell-7
#>

=======
<#
    .TITLE
        "Installing-Applications.ps1"
    .SOURCE
        https://docs.microsoft.com/en-us/powershell/scripting/samples/working-with-software-installations?view=powershell-7
#>

>>>>>>> 6b1553c2a7b7bdcf3ea4f59acf5fb2c427b35a33
Invoke-CimMethod -ClassName Win32_Product -MethodName Install -Arguments @{PackageLocation='\\AppSrv\dsp\NewPackage.msi'}