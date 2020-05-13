function Get-CredSspClientRole {
    <#
    
    .SYNOPSIS
    Gets the CredSSP enabled state on this computer as client role to the other computer.
    
    .DESCRIPTION
    Gets the CredSSP enabled state on this computer as client role to the other computer.
    
    .ROLE
    Administrators
    
    .PARAMETER serverNames
    The names of the server to which this gateway can forward credentials.
    
    .LINK
    https://portal.msrc.microsoft.com/en-us/security-guidance/advisory/CVE-2018-0886
    
    .LINK
    https://aka.ms/CredSSP-Updates
    
    #>
    
    param (
        [Parameter(Mandatory=$True)]
        [string[]]$serverNames
    )
    
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
    Are the servers already configure to delegate fresh credentials?
    
    .DESCRIPTION
    Are the servers already configure to delegate fresh credentials?
    
    #>
    
    function getServersDelegated([string[]] $serverNames) {
        $valuesFound = 0
    
        foreach ($serverName in $serverNames) {
            $newValue = "{0}/{1}" -f $WsManApplication, $serverName
    
            # Check if any registry-value nodes values of registry-key node have certain value.
            $key = Get-ChildItem $CredentialsDelegationPolicyPath | ? PSChildName -eq $AllowFreshCredentialsPropertyName
            $valueNames = $key.GetValueNames()
    
            foreach ($valueName in $valueNames) {
                $value = $key.GetValue($valueName)
    
                if ($value -eq $newValue) {
                    $valuesFound++
                    break
                }
            }
        }
    
        return $valuesFound -eq $serverNames.Length
    }
    
    <#
    
    .SYNOPSIS
    Detemines if the required CredentialsDelegation containers are in the registry.
    
    .DESCRIPTION
    Get the CredentialsDelegation container from the registry.  If the container
    does not exist then we can return false since CredSSP is not configured on this
    client (gateway).
    
    #>
    
    function areCredentialsDelegationItemsPresent() {
        $credentialDelegationItem = Get-Item  $CredentialsDelegationPolicyPath -ErrorAction SilentlyContinue
        if ($credentialDelegationItem) {
            $key = Get-ChildItem $CredentialsDelegationPolicyPath | ? PSChildName -eq $AllowFreshCredentialsPropertyName
    
            if ($key) {
                $valueNames = $key.GetValueNames()
                if ($valueNames) {
                    return $true
                }
            }
        }
    
        return $false
    }
    
    <#
    
    .SYNOPSIS
    Main function of this script.
    
    .DESCRIPTION
    Return true if the gateway is already configured as a CredSSP client, and all of the servers provided
    have already been configured to allow fresh credential delegation.
    
    #>
    
    function main([string[]] $serverNames) {
        setupScriptEnv
    
        $serversDelegated = $false
    
        $clientEnabled = getCredSSPClientEnabled
        
        if (areCredentialsDelegationItemsPresent) {
            $serversDelegated = getServersDelegated $serverNames
        }
    
        cleanupScriptEnv
    
        return $clientEnabled -and $serversDelegated
    }
    
    ###############################################################################
    # Script execution starts here
    ###############################################################################
    
    return main $serverNames
    
    }
    ## [END] Get-CredSspClientRole ##