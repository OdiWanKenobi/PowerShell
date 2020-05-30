## Defining Menu Options
## Creating 'New-Menu' Function
using namespace System.Management.Automation.Host

function New-Menu {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Title,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Question
    )

    $Y = New-Object System.Management.Automation.Host.ChoiceDescription '&Yes', 'Update hostname: Yes'
    $N = New-Object System.Management.Automation.Host.ChoiceDescription '&Nes', 'Update hostname: No'
    $Options = [System.Management.Automation.Host.ChoiceDescription[]]($Y, $N)

    $Result = $host.ui.PromptForChoice($Title, $Question, $Options, 1)

    switch ($Result)
    {
        0 { "You chose 'YES' to update hostname."}
        1 { "You chose 'NO' to not update hostname."}
    }

    if ($Result -eq '0')
    {
        $newHostname = Read-Host -Prompt "Enter the desired hostname."
        Rename-Computer -NewName $newHostname -Force -Verbose
        Write-Host "To finish the renaming of this host, this host needs to restart." -ForegroundColor Yellow
        Pause
        Restart-Computer -Force
    }
    else
    {
        $domainName = "sysadmin.lan"
        $server = "UESFL2DC01.sysadmin.lan"
        $credentials = Get-Credential -Message "Enter credentials to bind this host.`nUse the 'DOMAIN\username' format." -Title "Enter AD Credentials"
        Add-Computer -DomainName $domainName -Credential $credentials -Server $server -Verbose
        Write-Host "To finish binding to the domain, this host needs to restart." -ForegroundColor Yellow
        Pause
        Restart-Computer -Force
    }

}

$Title = "Confirm Local Computer Name"
$Question = "Current hostname is $hostname. Do you which to update?"

New-Menu -Title $Title -Question $Question