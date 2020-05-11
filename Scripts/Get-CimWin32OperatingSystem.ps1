function Get-CimWin32OperatingSystem {
    <#
    
    .SYNOPSIS
    Gets Win32_OperatingSystem object.
    
    .DESCRIPTION
    Gets Win32_OperatingSystem object.
    
    .ROLE
    Readers
    
    #>
    ##SkipCheck=true##
    
    
    import-module CimCmdlets
    
    Get-CimInstance -Namespace root/cimv2 -ClassName Win32_OperatingSystem
    
    }
    ## [END] Get-CimWin32OperatingSystem ##