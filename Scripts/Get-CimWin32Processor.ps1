function Get-CimWin32Processor {
    <#
    
    .SYNOPSIS
    Gets Win32_Processor object.
    
    .DESCRIPTION
    Gets Win32_Processor object.
    
    .ROLE
    Readers
    
    #>
    ##SkipCheck=true##
    
    
    import-module CimCmdlets
    
    Get-CimInstance -Namespace root/cimv2 -ClassName Win32_Processor
    
    }
    ## [END] Get-CimWin32Processor ##
