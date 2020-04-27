<#
    TITLE.
        "Remove-Bloatware.ps1"

    PURPOSE.
        Remove Windows 10 Professional "bloatware" applications.
        Keeps the "Store" and "Calculator" apps.
#>

Get-AppxPackage -AllUsers | Where-Object { $_.name –notlike "*Microsoft.WindowsStore*" } | Where-Object { $_.packagename -notlike "*Microsoft.WindowsCalculator*" } | Remove-AppxPackage -ErrorAction SilentlyContinue