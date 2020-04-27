<#
    SOURCE.
        https://lazyadmin.nl/powershell/powershell-gui-howto-get-started/
#>

## PowerShell GUI
Add-Type -AssemblyName System.Windows.Forms

## Create NewForm
$Forms = New-Object system.Windows.Forms.Form

## Define the size, title and background color
$Forms.ClientSize = 
$Forms.text = 
$Forms.BackColor = 

## Display the form
[void]$Forms()