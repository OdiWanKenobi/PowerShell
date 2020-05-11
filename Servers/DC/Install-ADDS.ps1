## Install AD DS Role
Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools

## Creating new domain (has to also be a forest)
Install-ADDSForest -DomainName $DomainName

## Prompt for "SafeModeAdministratorPassword"
$SafeModeAdminPW = "UM1r1nBr0?"

## Check AD DS-related Services
Get-Service adws,kdc,netlogon,dns

## Check Event Viewer for AD DS-related Log Entries
Get-Eventlog "Directory Service" | Select-Object entrytype, source, eventid, message
Get-Eventlog "Active Directory Web Services" | Select-Object entrytype, source, eventid, message