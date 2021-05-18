function Get-CredSspManagedServer {
    <#
    
    .SYNOPSIS
    Gets the CredSSP server role on this server.
    
    .DESCRIPTION
    Gets the CredSSP server role on this server.
    
    .ROLE
    Administrators
    
    .Notes
    The feature(s) that use this script are still in development and should be considered as being "In Preview".
    Therefore, those feature(s) and/or this script may change at any time.
    
    #>
    
    Set-StrictMode -Version 5.0
    Import-Module  Microsoft.WSMan.Management -ErrorAction SilentlyContinue
    
    <#
    
    .SYNOPSIS
    Setup all necessary global variables, constants, etc.
    
    .DESCRIPTION
    Setup all necessary global variables, constants, etc.
    
    #>
    
    function setupScriptEnv() {
        Set-Variable -Name WsManApplication -Option ReadOnly -Scope Script -Value "wsman"
        Set-Variable -Name CredSSPServiceAuthPath -Option ReadOnly -Scope Script -Value "localhost\Service\Auth\CredSSP"
    }
    
    <#
    
    .SYNOPSIS
    Clean up all added global variables, constants, etc.
    
    .DESCRIPTION
    Clean up all added global variables, constants, etc.
    
    #>
    
    function cleanupScriptEnv() {
        Remove-Variable -Name WsManApplication -Scope Script -Force
        Remove-Variable -Name CredSSPServiceAuthPath -Scope Script -Force
    }
    
    <#
    
    .SYNOPSIS
    Is CredSSP server role enabled on this server.
    
    .DESCRIPTION
    When the CredSSP server role is enabled on this server then return $true.
    
    #>
    
    function getCredSSPServerEnabled() {
        $path = "{0}:\{1}" -f $WsManApplication, $CredSSPServiceAuthPath
    
        $credSSPServerEnabled = $false;
    
        $credSSPServerService = Get-Item $path -ErrorAction SilentlyContinue
        if ($credSSPServerService) {
            $credSSPServerEnabled = [System.Convert]::ToBoolean($credSSPServerService.Value)
        }
    
        return $credSSPServerEnabled
    }
    
    <#
    
    .SYNOPSIS
    Main function.
    
    .DESCRIPTION
    Main function.
    
    #>
    
    function main() {
        setupScriptEnv
    
        $result = getCredSSPServerEnabled
    
        cleanupScriptEnv
    
        return $result
    }
    
    ###############################################################################
    # Script execution starts here...
    ###############################################################################
    
    if (-not ($env:pester)) {
        return main
    }
    
    }
    ## [END] Get-CredSspManagedServer ##