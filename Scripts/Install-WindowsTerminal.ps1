<#
    .TITLE
        "Install-WindowsTerminal.ps1"
    .PURPOSE
        Installs Windows Terminal, and creates a custom shortcut (.lnk) file on the desktop.
        The shortcut will use cmd.exe to open Windows Terminal as an administrator.
        This avoids any issues caused when running scripts and/or cmdlets that require session elevation.
#>

## Installing Windows Terminal
choco install microsoft-windows-terminal --y

## Create Shortcut
$TargetFile = "$env:SystemRoot\System32\cmd.exe /c start /b wt"
$ShortcutFile = "$env:UserProfile\Desktop\Terminal.lnk"
$WScriptShell = New-Object -ComObject WScript.Shell
$Shortcut = $WScriptShell.CreateShortcut($ShortcutFile)
$Shortcut.TargetPath = $TargetFile
$Shortcut.Save()