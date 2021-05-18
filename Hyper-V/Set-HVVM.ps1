<#
    TITLE.
        "Set-HVVM.ps1"
    AUTHOR.
        Alex Labrosse
    DESCRIPTION.
        "Deeply" configure a new Hyper-V VM after using tge "New-HVVM.ps1" script.
#>

## Variables
$ProcessorCount = Read-Host "Enter the number of vCPU's"
$DynamicMemory = Read-Host "Enable Dynamic Memory? Y / N"
# Set the minimum memory value
$MemoryMinimumBytes
# Set the startup memory value
$MemoryStartupBytes = 
# Set the maximum memory value
$MemoryMaximumBytes = 
# Nothing, Start, StartIfRunning
$AutomaticStartAction = 
# Number of seconds to wait before the automatic start action is run
$AutomaticStartDelay = 
# Save, Shutdown, TurnOff - Action which is run when the Hyper-V service is stopping
$AutomaticStopAction = 

## Configure Hyper-V VM
Set-VM -Name <VM Name>
        -ProcessorCount <number of vCPU>
        -DynamicMemory
        -MemoryMinimumBytes <Minimum Memory>
        -MemoryStartupBytes <Startup Memory>
        -MemoryMaximumBytes <Maximum Memory>
        -AutomaticStartAction <automatic Start Action>
        -AutomaticStartDelay <Automatic Start Delay in second>
        -AutomaticStopAction <Automatic stop action> 