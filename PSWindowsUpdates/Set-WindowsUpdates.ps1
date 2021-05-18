# Add NuGet Package Provider
Install-PackageProvider -Name NuGet -Force

# PSGallery as Trusted Repository
Set-PSRepository -Name 'PSGallery' -InstallationPolicy Trusted

# Install PSWindowsUpdate Module
Install-Module PSWindowsUpdate

# Register MS Update Service; Windows + addititional Microsoft product updates
Add-WUServiceManager -MicrosoftUpdate -Confirm:$false

# Update Local Computer
Install-WindowsUpdate -MicrosoftUpdate -AcceptAll -AutoReboot
