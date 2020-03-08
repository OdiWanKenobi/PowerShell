<#

    TITLE.
        "Rename-Computer.ps1"

    PURPOSE.
        Takes the serial number, and uses the last 6 digits to generate a new hostname.

#>

##------ Variables ------##
$SerialNumber = Get-WmiObject Win32_Bios | Select-Object -ExpandProperty SerialNumber
$NewHostName = "NY" + $SerialNumber.Substring(1, 6)

##------ Renaming ------##
Rename-Computer -NewName $NewHostName -ErrorAction