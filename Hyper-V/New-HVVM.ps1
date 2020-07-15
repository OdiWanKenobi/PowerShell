<#
    TITLE.
        "New-HVVM.ps1"
    AUTHOR.
        Alex Labrosse
    DESCRIPTION.
        Deploy a new Hyper-V Gen1/2 virtual machine.
#>

## Variables
$Name = Read-Host "Enter the desired VM Hostname"
$Path = \\fileserver.domain\share\path.ISO
$NewVHDPath = \\hyperv-server.domain\VHD\Path
$NewVHDSizeBytes = Read-Host "In GB, how large should the VHD be?"
$Generation = Read-Host "Generation 1 or 2? Enter only '1' or '2'"
$MemoryStartupBytes = Read-Host "In GB, how much memory should be allocated for the new VM?"
$SwitchName = 

## Math
$NewVHDPath * 1024
$MemoryStartupBytes * 1024

## Deploy new VM
New-VM -Name $Name
       -Path $Path
       -NewVHDPath $NewVHDPath
       -NewVHDSizeBytes $NewVHDSizeBytes
       -Generation $Generation
       -MemoryStartupBytes $MemoryStartupBytes
       -SwitchName $SwitchName