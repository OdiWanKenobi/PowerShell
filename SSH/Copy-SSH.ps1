<#
    .TITLE
        'Copy-SSH.ps1'
    .AUTHOR
        Alex Labrosse
    .DESCRIPTION
        The OpenSSH tools include the SCP and SFTP utilities to make transferring keys completely secure.
        In order to properly configure a Windows client for authenticating via SSH keys, the public key (.PUB) file must be transferred to the client device's .ssh directory and stored in the authorized_keys text file.
    .NOTES
#>

#Requires -RunAsAdministrator

## Create the .ssh directory within the user's profile folder
ssh username@domain.com mkdir C:\Users\username\.ssh

## Securely copy the public key from the server to the client device
scp C:\Users\username\.ssh\id_rsa.pub
username@domain.com:C:\Users\username\.ssh\authorized_keys

## Modify the ACL on the authorized_keys file on the server
ssh --% username@domain.com powershell -c $ConfirmPreference = 'None'; Repair-AuthorizedKeyPermission C:\Users\username\.ssh\authorized_keys