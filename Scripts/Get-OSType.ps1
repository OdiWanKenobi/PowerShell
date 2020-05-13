<#
    TITLE.
        'Get-OSType.ps1'
    AUTHOR.
        Alex Labrosse
    DESCRIPTION.
        Determines whether the OS is client (desktop) or server.
    ADDITIONAL.
        '1' - Desktop
        '2' - Domain Controller
        '3' - Server
#>

## Determine OS Type
$osType = Get-CimInstance -ClassName Win32_OperatingSystem
$osType.ProductType | Out-Null

## Write Output to Shell
if ($osType.ProductType -eq 1) {
    Write-Host "This is a DESKTOP" -ForegroundColor Yellow
} elseif ($osType.ProductType -eq 2) {
    Write-Host "This is a DOMAIN CONTROLLER" -ForegroundColor Yellow
} else {
    Write-Host "This is a SERVER" -ForegroundColor Yellow
}