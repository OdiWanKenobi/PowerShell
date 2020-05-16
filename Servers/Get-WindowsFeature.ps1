<#
    .TITLE
        'Get-WindowsFeature.ps1'
    .AUTHOR
        Alex Labrosse
    .DESCRIPTION
        Provides a list of available and/or installed Windows Server roles and features.
#>

## All Roles & Features
$WindowsFeature = Get-WindowsFeature -Name *

## Available Roles & Features
$WindowsFeatureAvailable = Get-WindowsFeature -Name * | Where-Object {$_.InstallState -contains 'Available'}

## Installed Roles & Features
$WindowsFeatureInstalled = Get-WindowsFeature -Name * | Where-Object {$_.InstallState -contains 'Installed'}