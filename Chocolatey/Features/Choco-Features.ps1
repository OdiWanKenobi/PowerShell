# Use 'choco feature list' to view all available Chocolatey features
choco feature enable -n allowGlobalConfirmation
choco feature enable -n autoUninstaller
choco feature enable -n ignoreInvalidOptionsSwitches
choco feature enable -n usePackageExitCodes
choco feature enable -n useEnhancedExitCodes
choco feature enable -n showNonElevatedWarnings
choco feature enable -n showDownloadProgress
choco feature enable -n useRememberedArgumentsForUpgrades
choco feature enable -n skipPackageUpgradesWhenNotInstalled
choco feature enable -n removePackageInformationOnUninstall
choco feature enable -n logValidationResultsOnWarnings
choco feature enable -n usePackageRepositoryOptimizations
