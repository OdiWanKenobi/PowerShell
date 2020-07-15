<#
    TITLE.

    AUTHOR.
        Alex Labrosse
#>

## Variables
$MacAddressSpoofing = <on / off>
$DHCPGuard = <on / off>
$RouterGuard = <on / off>

## Configure network adatper
Set-VMNetworkAdapter -MacAddressSpoofing $MacAddressSpoofing
                     -DHCPGuard $DHCPGuard
                     -RouterGuard $RouterGuard