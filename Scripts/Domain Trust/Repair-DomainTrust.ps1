<#
    .TITLE
        'Repair-DomainTrust.ps1'
    .AUTHOR
        Alex Labrosse (RAI IT)
    .SUMMARY
        Test's the trust relationship between local host and AD DS
        If the response is $false, attempts to reset the Computer Machine Password
        Next, attempts to repair the trust relationship
        Lastly, if the trust relationship is healthy, writes to the shell to inform operator.
#>

#Requires -RunAsAdministrator

if (Test-ComputerSecureChannel -eq $false) {
    $credential = Get-Credential
    Reset-ComputerMachinePassword -Credential $credential
    Test-ComputerSecureChannel -Credential $credential -Repair
}
else {
    Write-Host "The trust relationship between this workstation and the domain is healthy" -ForegroundColor Green
}