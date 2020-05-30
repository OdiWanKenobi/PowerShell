<#
    .TITLE
        'Install-MicrosoftTeams-02.ps1'
    .AUTHOR
        Alex Labrosse
    .DESCRIPTION
        Installs Microsoft Teams (Machine-Wide installer) using PowerShell.
#>

## Variables
$downloads = "$env:USERPROFILE\Downloads\"
$downloadPath = "$env:USERPROFILE\Downloads\Teams_windows_x64.msi"
$downloadUri = "https://go.microsoft.com/fwlink/p/?linkid=869426&clcid=0x409&culture=en-us&country=us&lm=deeplink&lmsrc=groupchatmarketingpageweb&cmpid=directdownloadwin64"

## Download Microsoft Teams from $downloadUri
Start-BitsTransfer -Source $downloadUri -Destination $downloadPath 

## Change Working Directory to $downloads
Set-Location -Path $downloads

## 
msiexec /i Teams_windows_x64.msi OPTIONS="noAutoStart=true" ALLUSERS=1 /qn /norestart