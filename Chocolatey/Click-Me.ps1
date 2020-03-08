# Chocolatey & Boxstater
. { Invoke-WebRequest -useb https://boxstarter.org/bootstrapper.ps1 } | Invoke-Expression; Get-Boxstarter -Force
choco feature enable -n=allowGlobalConfirmation

# Timezone
Set-TimeZone -Name "Eastern Standard Time"

# Bloatware
Get-AppxPackage -AllUsers | Where-Object { $_.name –notlike "*Microsoft.WindowsStore*" } | Where-Object { $_.packagename -notlike "*Microsoft.WindowsCalculator*" } | Remove-AppxPackage -ErrorAction SilentlyContinue

# GUI
choco install chocolateygui