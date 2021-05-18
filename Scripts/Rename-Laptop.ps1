<<<<<<< HEAD
<#
    TITLE.
        "Rename-Laptop.ps1"
=======
<<<<<<< HEAD:Scripts/Rename-Computer.ps1
<#
    TITLE.
        "Rename-Computer.ps1"
>>>>>>> 6b1553c2a7b7bdcf3ea4f59acf5fb2c427b35a33
    PURPOSE.
        Takes the serial number, and uses the last 6 digits to generate a new hostname.
#>

##------ Variables ------##
$SerialNumber = Get-WmiObject Win32_Bios | Select-Object -ExpandProperty SerialNumber
<<<<<<< HEAD
$NewHostName = "UESFL2LP" + $SerialNumber.Substring(1, 4)
=======
$NewHostName = "UESFL2CP" + $SerialNumber.Substring(1, 4)
>>>>>>> 6b1553c2a7b7bdcf3ea4f59acf5fb2c427b35a33

##------ Renaming ------##
Rename-Computer -NewName $NewHostName

##------ Pause ------##
Pause

##------ Reboot ------##
<<<<<<< HEAD
=======
=======
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
>>>>>>> 6b1553c2a7b7bdcf3ea4f59acf5fb2c427b35a33:Scripts/Rename-Laptop.ps1
>>>>>>> 6b1553c2a7b7bdcf3ea4f59acf5fb2c427b35a33
Restart-Computer -Force