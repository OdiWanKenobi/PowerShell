<#
    .TITLE
        "Removing   -Applications.ps1"
    .SOURCE
        https://docs.microsoft.com/en-us/powershell/scripting/samples/working-with-software-installations?view=powershell-7
#>

Get-CimInstance -Class Win32_Product -Filter "Name='ILMerge'" | Invoke-CimMethod -MethodName Uninstall