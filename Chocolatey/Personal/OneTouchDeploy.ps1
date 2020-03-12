<#
    TITLE.
        "OneTouchDeploy.ps1"

    PURPOSE.
        Configures device in one script.

    NOTES.
        Install Chocolatey & Boxstarter.
        Removes Windows bloatware.
        Installs tools and productivity software.
        Runs Windows Updates.
        Renames hostname.
        Reboots.
#>

Install-BoxstarterPackage -PackageName https://gist.githubusercontent.com/OdiWanKenobi/a331b404d2be02ea29db4a661f793847/raw/216c712262fb3f0b9be5e67c692a0aab7f1f9c99/Click-Me.ps1 -DisableReboots
