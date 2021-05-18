<#
    .TITLE
        'Get-AppxPackages.ps1'
    .AUTHOR
        Alex Labrosse
    .DESCRIPTION
        Lists all AppxPackages that can be removed / uninstalled.
#>

$AppxPackages = Get-AppxPackage -AllUsers -Name * | Select-Object Name, PackageFullName, NonRemovable | Where-Object {$_.NonRemovable -eq $false}