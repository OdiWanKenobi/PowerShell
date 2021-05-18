# Finds all Appx Provisioned Packages
$appx = Get-AppxProvisionedPackage -Online | Select-Object DisplayName,PackageName | Out-GridView

# Where $app = the "PackageName"
Remove-AppxProvisionedPackage -PackageName $app -AllUsers -Online