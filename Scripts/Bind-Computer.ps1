<#
    TITLE.
        "Bind-Computer.ps1"
    PURPOSE.
        Takes the serial number, and uses the last 6 digits to generate a new hostname.
#>

##------ Variables ------##
$SerialNumber = Get-WmiObject Win32_Bios | Select-Object -ExpandProperty SerialNumber
$NewHostName = "NY" + $SerialNumber.Substring(1,6)
Add-Computer -NewName $NewHostName -DomainName "corp.better.site" -OUPath "OU=Computers,OU=IT,dc=corp,DC=better,DC=site"


