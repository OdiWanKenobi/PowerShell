<#
    .TITLE
        'Join-SysadminLan.ps1'
    .AUTHOR
        Alex Labrosse
    .DESCRIPTION
        Binds a Windows-host to the Active Directory (non-routable) domain 'sysadmin.lan'
#>

## Variables
$credentials = Get-Credential -Message "Enter credentials to bind this host.`nUse the 'DOMAIN\username' format."
Import-Module ActiveDirectory -Force
 
if ($Credentials -eq $null)
    { 
        Write-Host "You have not entered the credentials necessary to proceed.`nWhen you are ready, please ENTER to continue and enter your AD credentials." -BackgroundColor Yellow -ForegroundColor Red
        Pause
        $domainName = "sysadmin.lan"
        $server = "UESFL2DC01.sysadmin.lan"
        $hostName = HOSTNAME.EXE
        $credentials = Get-Credential -Message "Enter credentials to bind this host.`nUse the 'DOMAIN\username' format."
        Import-Module 
        $bindingOutputVariable = Add-Computer -DomainName $domainName -Credential $credentials -Server $server -Verbose | Out-String
        Write-Host "To finish binding to the domain, this host needs to restart." -ForegroundColor Yellow
        Pause
        Restart-Computer -Force
    }
else
    {
        Write-Host "Ready to proceed with AD binding." -ForegroundColor Blue -BackgroundColor White
        $domainName = "sysadmin.lan"
        $server = "UESFL2DC01.sysadmin.lan"
        $hostName = HOSTNAME.EXE
        $bindingOutputVariable = Add-Computer -DomainName $domainName -Credential $credentials -Server $server -Verbose | Out-String
        Write-Host "To finish binding to the domain, this host needs to restart." -ForegroundColor Yellow
        Pause
        Restart-Computer -Force
    }
exit