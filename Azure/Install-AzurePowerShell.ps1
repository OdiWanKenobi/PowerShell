## Set 'PSGallery' repository as Trusted
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted

## Install the 'Azure PowerShell' module from PSGallery
Install-Module -Name Az -Repository PSGallery -Force