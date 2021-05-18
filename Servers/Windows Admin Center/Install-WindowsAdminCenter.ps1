## Download Windows Admin Center installer
$downloadPath = 'C:\Users\Administrator\Downloads\WAC.msi'
Invoke-WebRequest 'http://aka.ms/WACDownload' -OutFile $downloadPath

## Install Windows Admin Center
## Configure WAC to listen on port 443
## Generate a self-signed SSL certificate
$port = 443
msiexec /i $downloadPath /qn /L*v log.txt SME_PORT=$port SSL_CERTIFICATE_OPTION=generate