<#
    .TITLE
        'Update-Profile.ps1'
    .AUTHOR
        Alex Labrosse
    .DATE
        19 May 2020
    .DESCRIPTION
        Using a public GitHub Gist, pulls down the latest custom PowerShell profile and updates the local $PROFILE.
#>

## 
$profileUri = https://gist.githubusercontent.com/OdiWanKenobi/5170bd6ca6a6543a35ee68adeba211a6/raw/f2ddbc0e81981e45a6f604f482840f50c9076d64/Microsoft.PowerShell_profile.ps1
$profileDownload = Invoke-WebRequest -Uri $profileUri
$profileContent = $profileDownload.Content

##
$fileName = Microsoft.PowerShell_profile.ps1