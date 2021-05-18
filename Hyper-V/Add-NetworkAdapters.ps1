<#
    TITLE.
        "Add-NetworkAdapters.ps1"
    AUTHOR.
        Alex Labrosse
#>

## Variables
$VMName = 
$SwitchName = 
$Name = 

## Add Network Adapter
Add-VMNetworkAdapter -VMName $VMName
                     -SwitchName $SwitchName
                     -Name $Name