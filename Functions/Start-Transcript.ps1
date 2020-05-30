<#
    .TITLE
        'Start-Transcript.ps1'
    .AUTHOR
        Alex Labrosse
    .DESCRIPTION
        Intended to be added to a PowerShell profile.
        Starts a transcript fo each PowerShell session, using 'Get-Date -Format o' to generate a unique filename for each recorded session.
#>

## Converting the DateTime object to a string using 'Get-Date -Format o'
## Using this unique string to generate filenames for PowerShell transcripts
$TranscriptFileName = Get-Date -Format o

##
$LogPath = "C:\Transcripts\" + "$TranscriptFileName" + ".txt"
Start-Transcript -Path $LogPath -Verbose