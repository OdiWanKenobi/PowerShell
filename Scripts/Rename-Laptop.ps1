<#
    TITLE.
        "Rename-Laptop.ps1"
    PURPOSE.
        Takes the serial number, and uses the last 6 digits to generate a new hostname.
#>

##------ Variables ------##
$SerialNumber = Get-WmiObject Win32_Bios | Select-Object -ExpandProperty SerialNumber
$NewHostName = "UESFL2LP" + $SerialNumber.Substring(1, 4)

##------ Renaming ------##
Rename-Computer -NewName $NewHostName

##------ Pause ------##
Pause

##------ Reboot ------##
Restart-Computer -Force