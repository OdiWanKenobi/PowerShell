<<<<<<< HEAD
<#
    .TITLE
        "Removing   -Applications.ps1"
    .SOURCE
        https://docs.microsoft.com/en-us/powershell/scripting/samples/working-with-software-installations?view=powershell-7
#>

=======
<#
    .TITLE
        "Removing   -Applications.ps1"
    .SOURCE
        https://docs.microsoft.com/en-us/powershell/scripting/samples/working-with-software-installations?view=powershell-7
#>

>>>>>>> 6b1553c2a7b7bdcf3ea4f59acf5fb2c427b35a33
Get-CimInstance -Class Win32_Product -Filter "Name='ILMerge'" | Invoke-CimMethod -MethodName Uninstall