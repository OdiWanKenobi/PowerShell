## Script must contain FQDN path to .ps1 file
$Script = ""
$CommandLine = "-noexit & $script"
$Credential = Get-Credential
Start-Process powershell.exe -Credential $Credential -ArgumentList $Commandline