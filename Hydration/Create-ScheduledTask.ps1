<#
    .TITLE
        'Create-ScheduledTask.ps1'
    .AUTHOR
        Alex Labrosse
    .DESCRIPTION
        Creates the corresponding Scheduled Task for the 'Stay-Hydrated.ps1' script so that it runs hourly when logged in.
#>

## Module
Import-Module TaskScheduler

## Variables
$task = New-Task
$task.Settings.Hidden = $true
$ps = "C:\Windows\system32\WindowsPowerShell\v1.0\powershell.exe"

## Adding Scheduled Task to Run 'Stay-Hydrated.ps1' Script
Add-TaskAction -Task $task -Path $ps –Arguments “-File C:\Users\labrossea\OneDrive\Documents\GitHub\alabrosse\PowerShell\Hydration\Stay-Hydrated.ps1"
Add-TaskTrigger -Task $task -Once -At "10:00"
Register-ScheduledJob -Name "Drink Water Reminder" -Task $task