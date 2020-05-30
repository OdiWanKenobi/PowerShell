function Show-Menu {
    param (
        [string]$Title = 'My Menu'
    )
    Clear-Host
    Write-Host "================ $Title ================"
    
    Write-Host "1: Press 'Y' for YES."
    Write-Host "2: Press 'N' for NO."
    Write-Host "Q: Press 'Q' to quit."
}

do
{
    Show-Menu
    $Selection = Read-Host "Please make a selection."
    switch ($Selection)
    {
    '1' {
    'You chose option #1'
    } '2' {
    'You chose option #2'
    } '3' {
    'You chose option #3'
    }
    }
    pause
}
until ($Selection -eq 'q')