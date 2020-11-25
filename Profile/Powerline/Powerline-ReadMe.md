# [Tutorial: Set up Powerline in Windows Terminal](https://docs.microsoft.com/en-us/windows/terminal/tutorials/powerline-setup)

## Set up Powerline in PowerShell

### Install 'Posh-Git' and 'Oh-My-Posh'

Install-Module posh-git -Scope CurrentUser
Install-Module oh-my-posh -Scope CurrentUser

### Install 'PSReadline'

Install-Module -Name PSReadLine -Scope CurrentUser -Force -SkipPublisherCheck

## Update Profile

### Customize your PowerShell prompt

notepad.exe $profile

In your PowerShell profile, add the following to the end of the file:

Import-Module posh-git
Import-Module oh-my-posh
Set-Theme Paradox