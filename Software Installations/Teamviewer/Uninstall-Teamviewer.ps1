# Remove all Teamviewer installations
Get-WmiObject -Class Win32_Product -Filter "Vendor LIKE 'TeamViewer' " | Foreach { ($_).uninstall() }