function Get-CimWin32LogicalDisk {
    <#
    
    .SYNOPSIS
    Gets Win32_LogicalDisk object.
    
    .DESCRIPTION
    Gets Win32_LogicalDisk object.
    
    .ROLE
    Readers
    
    #>
    ##SkipCheck=true##
    
    
    import-module CimCmdlets
    
    Get-CimInstance -Namespace root/cimv2 -ClassName Win32_LogicalDisk
    
    }
    ## [END] Get-CimWin32LogicalDisk ##