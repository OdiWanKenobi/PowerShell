<#
    TITLE.
        "Attach-VHDX.ps1"
    AUTHOR.
        Alex Laborsse
#>

## Variables
$VMName = 
$Path = 

## Attach VHD(X)
Add-VMHardDiskDrive -VMName $VMName
                    -Path $Path