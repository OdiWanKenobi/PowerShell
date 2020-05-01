Function Set-ConsoleConfig

{

 if(-not (Test-IsAdministrator))

  {$Host.ui.RawUI.WindowTitle = "Non-Elevated PowerShell"}

 else {$Host.ui.RawUI.WindowTitle = " Elevated PowerShell"}

} #end function set-consoleconfig