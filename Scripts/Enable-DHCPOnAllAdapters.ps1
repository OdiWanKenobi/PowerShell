Get-CimInstance -ClassName Win32_NetworkAdapterConfiguration -Filter IPEnabled=$true |
ForEach-Object -Process {$_.EnableDHCP()}