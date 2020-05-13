do
 {
     Show-Menu
     $selection = Read-Host "Please make a selection"
     switch ($selection)
     {
         '1' {
             'Get-Module -All'
         } '2' {
             'Get-Module -ListAvailable'
         }
     }
     pause
 }
 until ($selection -eq 'q')