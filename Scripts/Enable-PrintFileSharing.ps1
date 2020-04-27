<#
    .TITLE
        "Enable-PrintFileSharing.ps1"
    .PURPOSE
        Creates a firewall rule allowing file and printer sharing.
#>

# Start required services
Get-Service -DisplayName "Function Discovery Resource Publication" | Start-Service
Get-Service -DisplayName "DNS Client"  | Start-Service
Get-Service -DisplayName "SSDP Discovery"  | Start-Service
Get-Service -DisplayName "UPnP Device Host" | Start-Service

# Set action to allow
Get-NetFirewallRule -DisplayGroup "File and Printer Sharing" | Set-NetFirewallRule -Action Allow 
# Enabling the rule
Get-NetFirewallRule -DisplayGroup "File and Printer Sharing" | Enable-NetFirewallRule