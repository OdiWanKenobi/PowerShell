<#
    .TITLE
        'Install-IcingaAgent.ps1'
    .AUTHOR
        Alex Labrosse
    .SOURCE
        https://icinga.com/docs/windows/latest/doc/installation/01-Kickstart-Script/
#>

[Net.ServicePointManager]::SecurityProtocol = "tls12, tls11";
$ProgressPreference = "SilentlyContinue";

$global:IcingaFrameworkKickstartSource = 'https://raw.githubusercontent.com/Icinga/icinga-powershell-kickstart/master/script/icinga-powershell-kickstart.ps1';

$Script = (Invoke-WebRequest -UseBasicParsing -Uri $global:IcingaFrameworkKickstartSource).Content;
$Script += "`r`n`r`n Start-IcingaFrameworkWizard;";

Invoke-Command -ScriptBlock ([Scriptblock]::Create($Script));