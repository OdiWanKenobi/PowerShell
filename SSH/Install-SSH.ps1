<#
    .TITLE
        'Install-SSH.ps1'
    .AUTHOR
        Alex Labrosse
    .DESCRIPTION
        Installs the OpenSSH module for PowerShell, which allows the generation of public/private SSH keys.
    .NOTES
        By default, the OpenSSH Server app in not installed, so it must first be installed.
        The ssh-agent service is set to Disabled and must be changed before the cmdlets below will work.
        Host keys are stored at the %HOMEDRIVE%\ProgramData\ssh directory.
#>

#Requires -RunAsAdministrator

## Installing the OpenSSH Module
Install-Module -Force OpenSSHUtils

## Start the ssh-agent service for securely storing privately generated SSH keys
Start-Service ssh-agent

## Start the sshd service, which will generate the first pair of host keys automatically
Start-Service sshd