<#
    TITLE.
        "Bind-Computer.ps1"
    PURPOSE.
        Takes the serial number, and uses the last 6 digits to generate a new hostname.
#>

## Variables
$SerialNumber = Get-WmiObject Win32_Bios | Select-Object -ExpandProperty SerialNumber
$NewHostName = "NY" + $SerialNumber.Substring(1,6)
$DomainName = Read-Host "Enter the AD domain name"
Add-Computer -NewName $NewHostName -DomainName $DomainName


