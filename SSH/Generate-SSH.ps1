<#
    .TITLE
        'Generate-SSH.ps1'
    .AUTHOR
        Alex Labrosse
    .DESCRIPTION
        Generates SSH user key pair.
    .NOTES
        You will be prompted to provide a directory where the key pair will be stored, or you may press enter to choose the default location provided.
        You'll be prompted to choose a passphrase to encrypt the key pair with.
        While providing a passphrase is optional, it is highly advised to enter one as it serves the secondary purpose of acting as a form of two-factor authentication when utilizing the key pair to establish remote connections.
        Once the process is completed, two files will be generated alongside the SHA256 fingerprint, and the key's random art image will be displayed on-screen.
#>

#Requires -RunAsAdministrator

## Change directory to where SSH keys are stored
Set-Location %HOMEDRIVE%\ProgramData\ssh

## Generate the SSH key pair
ssh-keygen

##