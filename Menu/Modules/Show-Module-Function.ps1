function Show-Module
{
    param (
        [string]$Title = 'PowerShell Module Menu'
    )
    Clear-Host
    Write-Host "================ $Title ================"
    
    Write-Host "1: Press '1' to list imported modules."
    Write-Host "2: Press '2' to list all modules."
    Write-Host "Q: Press 'Q' to quit."
}