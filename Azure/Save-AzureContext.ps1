<#

    TITLE.
        "Save-AzContext.ps1"

    PURPOSE.
        Save Azure contexts across PowerShell sessions

    NOTES.
        If you've disabled module autoloading, manually import the module with Import-Module Az.
        Because of the wsay the module is structured, this can take a few seconds.

#>

# Save the current context
Save-AzContext -Path $env:USERPROFILE\OneDrive\Documents\GitHub\alabrosse\PowerShell\Azure\current-context.json

# Save a context object
Save-AzContext -Profile $profileObject -Path $env:USERPROFILE\OneDrive\Documents\GitHub\alabrosse\PowerShell\Azure\other-context.json
