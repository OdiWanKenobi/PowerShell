## Script introducton
Write-Host "Review the list of Windows desktop optional features." -ForegroundColor Yellow

## Gets all Windows client OS optional features
## Shows the display name (human-readable), feature name (used to enable / disable), and state (enabled / disabled)
Get-WindowsOptionalFeature -Online -FeatureName * | Select-Object DisplayName,FeatureName,State | Format-Table -AutoSize

## Prompt user for selection
Write-Host "Enter the 'FeatureName' of the feature you would like to install."  -ForegroundColor Yellow
$FeatureName = Read-Host -Prompt "Provide a FeatureName to enable"

## Install optional feature
Enable-WindowsOptionalFeature -Online -FeatureName $FeatureName -NoRestart