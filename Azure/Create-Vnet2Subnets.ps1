<#
    .TITLE
        'Create-Vnet2Subnets.ps1'
    .AUTHOR
        Alex Labrosse
    .DESCRIPTION
        Creates a new Azure Resource Group and deploys two subnets.
    .SOURCE
        https://azure.microsoft.com/en-us/resources/templates/101-vnet-two-subnets/
#>

## Variables
$AzureLocations = Get-AzureRmLocation | Format-Table
$ResourceGroupName = Read-Host -Prompt "Enter new RESOURCE GROUP name."
$ResourceGroupLocation = Read-Host -Prompt "Enter new RESOURCE GROUP location."
$TemplateUri = https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/101-vne

## Create new Resource Group using $ResourceGroupName
## Location for new Azure RG is determined by $ResourceGroupLocation
New-AzResourceGroup -Name $ResourceGroupName -Location $ResourceGroupLocation #use this command when you need to create a new resource group for your deployment

## Using the $TemplateUri, deploys two subnets to $ResourceGroupName
New-AzResourceGroupDeployment -ResourceGroupName $ResourceGroupName -TemplateUri $TemplateUri