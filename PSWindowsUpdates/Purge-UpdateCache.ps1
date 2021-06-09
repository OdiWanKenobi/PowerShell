# Stopping Windows Update Services
Get-Service *wuauserv* | Stop-Service -Force -Confirm:$false
Get-Service *crypSvc* | Stop-Service -Force -Confirm:$false
Get-Service *bits* | Stop-Service -Force -Confirm:$false
Get-Service *msiserver* | Stop-Service -Force -Confirm:$false

# Deleting Windows Update Cache Folders in "SoftwareDistribution"
# "C:\Windows\SoftwareDistribution\Download"
Get-ChildItem "C:\Windows\SoftwareDistribution\Download" -Force | Remove-Item -Recurse -Confirm:$false

# "C:\Windows\SoftwareDistribution\DataStore"
Get-ChildItem "C:\Windows\SoftwareDistribution\DataStore" -Force | Remove-Item -Recurse -Confirm:$false

# "C:\Windows\SoftwareDistribution\PostRebootEventCache.V2"
Get-ChildItem "C:\Windows\SoftwareDistribution\PostRebootEventCache.V2" -Force | Remove-Item -Recurse -Confirm:$false

# Starting Windows Update Services
Get-Service *wuauserv* | Start-Service
Get-Service *crypSvc* | Start-Service
Get-Service *bits* | Start-Service
Get-Service *msiserver* | Start-Service