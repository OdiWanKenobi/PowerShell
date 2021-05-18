function Enable-CredSspManagedServer {
    <#
    
    .SYNOPSIS
    Enables CredSSP on this server.
    
    .DESCRIPTION
    Enables CredSSP server role on this server.
    
    .ROLE
    Administrators
    
    .LINK
    https://portal.msrc.microsoft.com/en-us/security-guidance/advisory/CVE-2018-0886
    
    .LINK
    https://aka.ms/CredSSP-Updates
    
    
    #>
    
    Set-StrictMode -Version 5.0
    Import-Module  Microsoft.WSMan.Management -ErrorAction SilentlyContinue
    
    function setupScriptEnv() {
        Set-Variable CredSSPServicePath -Option ReadOnly -Scope Script -Value "WSMan:\localhost\Service\Auth\CredSSP"
    }
    
    function cleanupScriptEnv() {
        Remove-Variable CredSSPServicePath -Scope Script -Force
    }
    
    <#
    
    .SYNOPSIS
    Is CredSSP enabled on this server.
    
    .DESCRIPTION
    Enables CredSSP on this server for server role.
    
    #>
    
    function getCredSSPServerEnabled()
    {
        $credSSPServerEnabled = $false;
    
        $credSSPServerService = Get-Item $CredSSPServicePath -ErrorAction SilentlyContinue
        if ($credSSPServerService) {
            $credSSPServerEnabled = [System.Convert]::ToBoolean($credSSPServerService.Value)
        }
    
        return $credSSPServerEnabled
    }
    
    <#
    
    .SYNOPSIS
    Enables CredSSP on this server.
    
    .DESCRIPTION
    Enables CredSSP on this server for server role.
    
    #>
    
    function enableCredSSP() {
        $err = $null
    
        # Catching the result so that we can discard it. Otherwise it get concatinated with $err and we don't want that!
        $result = Enable-WSManCredSSP -Role Server -Force -ErrorAction SilentlyContinue -ErrorVariable +err
    
        return $err
    }
    
    <#
    
    .SYNOPSIS
    Main function.
    
    .DESCRIPTION
    Main function.
    
    #>
    
    function main() {
        setupScriptEnv
    
        $retVal = $true
        
        # If server role is enabled then return success.
        if (-not (getCredSSPServerEnabled)) {
            # If not enabled try to enable
            $err = enableCredSSP
            if ($err) {
                # If there was an error, and server role is not enabled return error.
                if (-not (getCredSSPServerEnabled)) {
                    $retVal = $false
                    
                    Write-Error $err
                }
            }
        }
    
        cleanupScriptEnv
    
        return $retVal
    }
    
    ###############################################################################
    # Script execution starts here...
    ###############################################################################
    
    return main
    
    }
    ## [END] Enable-CredSspManagedServer ##