# Finds File Paths Over 200 Characters in Current Folder
(Get-ChildItem -Recurse).FullName | Where-Object Length -GT 220