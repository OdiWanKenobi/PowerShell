Get-Service | Where-Object {$_.Status -eq 'Running'} | Select-Object DisplayName,Name