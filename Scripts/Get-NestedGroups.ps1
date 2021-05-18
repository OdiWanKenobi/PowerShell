<#
    TITLE.
        'Get-NestedGroups.ps1'
    AUTHOR.
        Alex Labrosse
#>

## Find all groups in the 'Rose' OU in 'rose.local'
$SearchBase = "OU=Rose,DC=rose,DC=local"
$Groups = Get-ADGroup -Filter * -SearchBase $SearchBase

## Check members of every group found in previos step
ForEach-Object ($Group -in $Groups) {
    $Partition = "DC=rose,DC=local"
    Write-Host 'Searching for members of $Group'
    $Group | Get-ADGroupMember -Partition $Partition -Recursive
}