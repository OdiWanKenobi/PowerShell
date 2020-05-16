<#

    TITLE.
        "Get-AzContext.ps1"
    
    PURPOSE.
        Get Azure contexts in current session

    NOTES.
        The available Azure contexts aren't always your available subscriptions. 
        Azure contexts only represent locally-stored information. 
        You can get your subscriptions with the Get-AzSubscription cmdlet.

#>

Get-AzContext -ListAvailable