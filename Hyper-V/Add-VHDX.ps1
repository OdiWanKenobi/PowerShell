<#
    TITLE.
        "Add-VHDX.ps1"
    AUTHOR.
        Alex Labrosse
#>

## Variables
$Path =  
$SizeBytes = 
# -Dynamic or -Fixed

## Add VHD(X)
New-VHD -Path $Path
        -SizeBytes $SizeBytes
        -Dynamic or -Fixed