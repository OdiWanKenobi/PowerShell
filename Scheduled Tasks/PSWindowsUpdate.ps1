# Determine if 'Install-WindowsUpdate' cmdlet is available. If not, stops execution.
$windowsUpdateCmd = Get-Command -Name 'Install-WindowsUpdate' -ErrorAction SilentlyContinue -WarningAction SilentlyContinue | Select-Object -ExpandProperty Source
if ($windowsUpdateCmd -eq $null) { break}

# Settings - Scheduled Task
$taskAction = New-ScheduledTaskAction –Execute $windowsUpdateCmd -Argument '-MicrosoftUpdate -AcceptAll -AutoReboot'
$taskTrigger = New-ScheduledTaskTrigger -AtLogon
$taskUserPrincipal = New-ScheduledTaskPrincipal -UserId 'SYSTEM'
$taskSettings = New-ScheduledTaskSettingsSet -Compatibility Win8
$task = New-ScheduledTask -Action $taskAction -Principal $taskUserPrincipal -Trigger $taskTrigger -Settings $taskSettings

# Register Scheduled Task
Register-ScheduledTask -TaskName 'Run Windows Update At Logon' -InputObject $task -Force
