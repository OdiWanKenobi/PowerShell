function Get-CimWin32NetworkAdapter {
    <#
    
    .SYNOPSIS
    Gets Win32_NetworkAdapter object.
    
    .DESCRIPTION
    Gets Win32_NetworkAdapter object.
    
    .ROLE
    Readers
    
    #>
    ##SkipCheck=true##
    
    
    import-module CimCmdlets
    
    Get-CimInstance -Namespace root/cimv2 -ClassName Win32_NetworkAdapter
    
    }
    ## [END] Get-CimWin32NetworkAdapter ##