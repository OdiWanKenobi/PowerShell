# PowerShell 7 Installation

## ExecutionPolicy

Set-ExecutionPolicy RemoteSigned -Force
Get-ExecutionPolicy -List

## Download

$url = "https://github.com/PowerShell/PowerShell/releases/download/v7.0.0/PowerShell-7.0.0-win-x64.msi"
$output = "$env:USERPROFILE\Downloads\PowerShell-7-x64.msi"
Invoke-WebRequest -Uri $url -OutFile $output

## Install

.\$output

## Profile

Test-Path $PROFILE
if Test-Path $PROFILE -eq $false
New-item –Type File -Force $PROFILE
