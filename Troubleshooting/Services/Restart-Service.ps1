# Generate a GUI menu, allowing you to select a service to restart
Get-Service | Out-GridView -PassThru | Restart-Service