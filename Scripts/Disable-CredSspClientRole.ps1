function Disable-CredSspClientRole {
    <#
    
    .SYNOPSIS
    Disables CredSSP on this client/gateway.
    
    .DESCRIPTION
    Disables CredSSP on this client/gateway.
    
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
        Set-Variable -Name CredSSPClientAuthPath -Option ReadOnly -Scope Script -Value "localhost\Client\Auth\CredSSP"
        Set-Variable -Name CredentialsDelegationPolicyPath -Option ReadOnly -Scope Script -Value "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CredentialsDelegation"
        Set-Variable -Name AllowFreshCredentialsPath -Option ReadOnly -Scope Script -Value "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CredentialsDelegation\AllowFreshCredentials"
        Set-Variable -Name AllowFreshCredentialsPropertyName -Option ReadOnly -Scope Script -Value "AllowFreshCredentials"
    }
    
    <#
    
    .SYNOPSIS
    Clean up all added global variables, constants, etc.
    
    .DESCRIPTION
    Clean up all added global variables, constants, etc.
    
    #>
    
    function cleanupScriptEnv() {
        Remove-Variable -Name WsManApplication -Scope Script -Force
        Remove-Variable -Name CredSSPClientAuthPath -Scope Script -Force
        Remove-Variable -Name CredentialsDelegationPolicyPath -Scope Script -Force
        Remove-Variable -Name AllowFreshCredentialsPath -Scope Script -Force
        Remove-Variable -Name AllowFreshCredentialsPropertyName -Scope Script -Force
    }
    
    <#
    
    .SYNOPSIS
    Is CredSSP client role enabled on this server.
    
    .DESCRIPTION
    When the CredSSP client role is enabled on this server then return $true.
    
    #>
    
    function getCredSSPClientEnabled() {
        $path = "{0}:\{1}" -f $WsManApplication, $CredSSPClientAuthPath
    
        $credSSPClientEnabled = $false;
    
        $credSSPClientService = Get-Item $path -ErrorAction SilentlyContinue
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
    
    function disableCredSSP() {
        $err = $null
    
        # Catching the result so that we can discard it. Otherwise it get concatinated with $err and we don't want that!
        $result = Disable-WSManCredSSP -Role Client -ErrorAction SilentlyContinue -ErrorVariable +err
    
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
        $results = $null
    
        # If the client role is disabled then we can stop.
        if (-not (getCredSSPClientEnabled)) {
            $results = $true
        } else {
            $err = disableCredSSP
    
            if ($err) {
                # If there is an error and the client role is not enabled return success.
                if (-not (getCredSSPClientEnabled)) {
                    $results = $true
                }
    
                Write-Error @($err)[0]
                $results = $false
            }
        }
    
        cleanupScriptEnv
    
        return $results
    }
    
    ###############################################################################
    # SCcript execution starts here...
    ###############################################################################
    $results = $null
    
    if (-not ($env:pester)) {
        $results = main
    }
    
    
    return $results
        
    }
    ## [END] Disable-CredSspClientRole ##