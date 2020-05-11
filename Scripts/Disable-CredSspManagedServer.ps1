function Disable-CredSspManagedServer {
    <#
    
    .SYNOPSIS
    Disables CredSSP on this server.
    
    .DESCRIPTION
    Disables CredSSP on this server.
    
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
    Is CredSSP client role enabled on this server.
    
    .DESCRIPTION
    When the CredSSP client role is enabled on this server then return $true.
    
    #>
    
    function getCredSSPClientEnabled() {
        Set-Variable credSSPClientPath -Option Constant -Value "WSMan:\localhost\Client\Auth\CredSSP" -ErrorAction SilentlyContinue
    
        $credSSPClientEnabled = $false;
    
        $credSSPClientService = Get-Item $credSSPClientPath -ErrorAction SilentlyContinue
        if ($credSSPClientService) {
            $credSSPClientEnabled = [System.Convert]::ToBoolean($credSSPClientService.Value)
        }
    
        return $credSSPClientEnabled
    }
    
    <#
    
    .SYNOPSIS
    Disable CredSSP
    
    .DESCRIPTION
    Attempt to disable the CredSSP Client role and return any error that occurs
    
    #>
    
    function disableCredSSPClientRole() {
        $err = $null
    
        # Catching the result so that we can discard it. Otherwise it get concatinated with $err and we don't want that!
        $result = Disable-WSManCredSSP -Role Client -ErrorAction SilentlyContinue -ErrorVariable +err
    
        return $err
    }
    
    <#
    
    .SYNOPSIS
    Disable the CredSSP client role on this server.
    
    .DESCRIPTION
    Disable the CredSSP client role on this server.
    
    #>
    
    function disableCredSSPClient() {
        # If disabled then we can stop.
        if (-not (getCredSSPClientEnabled)) {
            return $null
        }
    
        $err = disableCredSSPClientRole
    
        # If there is an error and it is not enabled, then success
        if ($err) {
            if (-not (getCredSSPClientEnabled)) {
                return $null
            }
    
            return $err
        }
    
        return $null
    }
    
    <#
    
    .SYNOPSIS
    Is CredSSP server role enabled on this server.
    
    .DESCRIPTION
    When the CredSSP server role is enabled on this server then return $true.
    
    #>
    
    function getCredSSPServerEnabled() {
        Set-Variable credSSPServicePath -Option Constant -Value "WSMan:\localhost\Service\Auth\CredSSP" -ErrorAction SilentlyContinue
    
        $credSSPServerEnabled = $false;
    
        $credSSPServerService = Get-Item $credSSPServicePath -ErrorAction SilentlyContinue
        if ($credSSPServerService) {
            $credSSPServerEnabled = [System.Convert]::ToBoolean($credSSPServerService.Value)
        }
    
        return $credSSPServerEnabled
    }
    
    <#
    
    .SYNOPSIS
    Disable CredSSP
    
    .DESCRIPTION
    Attempt to disable the CredSSP Server role and return any error that occurs
    
    #>
    
    function disableCredSSPServerRole() {
        $err = $null
    
        # Catching the result so that we can discard it. Otherwise it get concatinated with $err and we don't want that!
        $result = Disable-WSManCredSSP -Role Server -ErrorAction SilentlyContinue -ErrorVariable +err
    
        return $err
    }
    
    function disableCredSSPServer() {
        # If not enabled then we can leave
        if (-not (getCredSSPServerEnabled)) {
            return $null
        }
    
        $err = disableCredSSPServerRole
    
        # If there is an error, but the requested functionality completed don't fail the operation.
        if ($err) {
            if (-not (getCredSSPServerEnabled)) {
                return $null
            }
    
            return $err
        }
        
        return $null
    }
    
    <#
    
    .SYNOPSIS
    Main function.
    
    .DESCRIPTION
    Main function.
    
    #>
    
    function main() {
        $err = disableCredSSPServer
        if ($err) {
            throw $err
        }
    
        $err = disableCredSSPClient
        if ($err) {
            throw $err
        }
    
        return $true
    }
    
    ###############################################################################
    # Script execution starts here...
    ###############################################################################
    
    if (-not ($env:pester)) {
        return main
    }
    
    }
    ## [END] Disable-CredSspManagedServer ##