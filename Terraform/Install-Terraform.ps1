<#
    .TITLE
        'Install-Terraform.ps1'
    .AUTHOR
        Alex Labrosse
    .DESCRIPTION
        Downloads the Terraform ZIP file, extracts it, and creates the relevant PATH variable.
    .USAGE

    .REFERENCE
        https://docs.microsoft.com/en-us/azure/developer/terraform/overview
#>

## Variables
$terraformPath = "C:\Terraform"
$terraformUri = 'https://releases.hashicorp.com/terraform/0.12.26/terraform_0.12.26_windows_amd64.zip'
$terraformZip = "$terraformPath\terraform_0.12.26_windows_amd64.zip"

## Checking for $terraformDir and creating if it does not exist
if (Test-Path $terraformPath)
    {
        New-Item -Path $terraformPath -ItemType Directory -Force
    }

## Download Terraform Zip
Start-BitsTransfer -Source $terraformUri -Destination $terraformZip

## Expand Terraform Zip
Expand-Archive $terraformZip $terraformPath -Force

## Move to $terraformDir
Get-ChildItem "$($terraformPath)\*\*" | Move-Item -Destination "$($terraformPath)\" -Force

## Cleanup
## Delete Zip and old folder
Remove-Item $terraformZip -Force -Confirm:$false
Get-ChildItem "$($terraformPath)\*" -Directory | ForEach-Object { Remove-Item $_.FullName -Recurse -Force -Confirm:$false }

## Add $terraformPath to the System Path if it does not exist
if ($env:PATH -notcontains $terraformPath)
    {
        $path = ($env:PATH -split ";")
        if (!($path -contains $terraformPath))
        {
            $path += $terraformPath
            $env:PATH = ($path -join ";")
            $env:PATH = $env:PATH -replace '::',';'
        }
        [Environment]::SetEnvironmentVariable("Path", ($env:path), [System.EnvironmentVariableTarget]::Machine)
    }