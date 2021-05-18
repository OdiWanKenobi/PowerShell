function Get-CimWin32PhysicalMemory {
    <#
    
    .SYNOPSIS
    Gets Win32_PhysicalMemory object.
    
    .DESCRIPTION
    Gets Win32_PhysicalMemory object.
    
    .ROLE
    Readers
    
    #>
    ##SkipCheck=true##
    
    
    import-module CimCmdlets
    
    Get-CimInstance -Namespace root/cimv2 -ClassName Win32_PhysicalMemory
    
    }
    ## [END] Get-CimWin32PhysicalMemory ##