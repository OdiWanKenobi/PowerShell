<#
    TITLE.
        "Bind-Computer.ps1"
    PURPOSE.
        Takes the serial number, and uses the last 6 digits to generate a new hostname.
#>

## Using Serial Number to Create New Host Name
$sn = Get-WmiObject Win32_Bios | Select-Object -ExpandProperty SerialNumber
$snHostName = "UESFL2CP" + $sn.Substring(1,4)

## Domain-Join Credentials and Array
$creds = Get-Credential -Prompt "Enter domain credentials"
$args = @{
    NewName = $snHostName
    Server = "UESFL2DC01"
    Domain = "sysadmin.lan"
    Restart = $true
    Confirm = $false
    Force = $true
}

## Binding to Domain
Add-Computer @args