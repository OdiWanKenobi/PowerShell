$CredentialGuard = ‘CredentialGuard' -match ((Get-ComputerInfo).DeviceGuardSecurityServicesConfigured)

if ($CredentialGuard = $True)
{
    Write-Host "Credential Guard is ENABLED." -ForegroundColor Green
}
else
{
    Write-Host "Credential Guard is DISABLED." -ForegroundColor Yellow
}