# Variables
$oldGroup = 'Old Group'
$newGroup = 'New Group'

# Migrate Users to New Group
Add-ADGroupMember -Identity $newGroup -Members (Get-ADGroupMember -Identity $oldGroup -Recursive)
