<#
    .TITLE
        'New-Popup.ps1'
    .AUTHOR
        Alex Labrosse
    .DESCRIPTION
        Invokes a basic pop-up message, with title, message, and Yes/No answer returns.
    .SYNTAX
        Popup(<Text>,<SecondsToWait>,<Title>,<Type>)
    .REFERENCES
        http://woshub.com/popup-notification-powershell/
#>

$wshell = New-Object -ComObject Wscript.Shell
$Output = $wshell.Popup("Remember to stay hydradated.`nHave you drunk water recently?",0,"Hydrate!",4+32)