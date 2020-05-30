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

## Specifies the URL of the RAW Public Gist
$profileUri = 'https://gist.githubusercontent.com/OdiWanKenobi/5170bd6ca6a6543a35ee68adeba211a6/raw/230dfa5ab0e062be874a402fe63ca809084916dc/Microsoft.PowerShell_profile.ps1'

## Downloads the contents of the RAW Public Gist
$profileDownload = Invoke-WebRequest -Uri $profileUri
## Stores the contents of the PowerShell profile
$profileContent = $profileDownload.Content

## Replaces the contents of $PROFILE with $profileContent
Add-Content -Path $profile -Value $profileContent -Verbose