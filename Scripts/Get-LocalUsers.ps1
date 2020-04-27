

Get-CimInstance -ClassName Win32_OperatingSystem |
Select-Object -Property NumberOfLicensedUsers,NumberOfUsers,RegisteredUser