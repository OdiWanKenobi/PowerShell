<#
    .TITLE
        'Create-ServicePrincipal.ps1'
    .AUTHOR
        Alex Labrosse
    .DESCRIPTION
        Creates a service principal - an identity for use with applications, hosted services, and automated tools to access Azure resources.
    .SOURCE
        https://docs.microsoft.com/en-us/powershell/azure/create-azure-service-principal-azureps?view=azps-4.1.0
#>

## Imports the PSADPasswordCredential object
Import-Module Az.Resources

## Login to Azure
Connect-AzAccount

## Creates a service principal with a random password
$credentials = New-Object Microsoft.Azure.Commands.ActiveDirectory.PSADPasswordCredential -Property @{ StartDate=Get-Date; EndDate=Get-Date -Year 2024; Password="Asstasticwaffl3s!"}
$sp = New-AzADServicePrincipal -DisplayName TerraformServicePrincipal -PasswordCredential $credentials

## Captures the Tenant ID in which the Service Principal was created above
$tenantId = (Get-AzContext).Tenant.Id

## Prompt for Service Principal credentials
$spCredentials = Get-Credential

## Authenticating with the credentials captured above
## Confirming the abiltiy of the new Service Principal to login
Connect-AzAccount -ServicePrincipal -Credential $spCredentials -Tenant $tenantId

##
$terraformServicePrincipal = Get-AzADServicePrincipal -DisplayName TerraformServicePrincipal
New-AzRoleAssignment -ApplicationId $terraformServicePrincipal.ApplicationId -RoleDefinitionName "Contributor"