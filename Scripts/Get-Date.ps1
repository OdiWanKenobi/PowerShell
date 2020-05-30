<#
    .TITLE
        'Get-Date.ps1'
    .AUTHOR
        Alex Labrosse
    .DESCRIPTION
        Stores the date as a variable that can be used to create unique log and/or file names.
#>

Get-Date -Format 'dd-MMMM-yyyy-HH-mm-ss'