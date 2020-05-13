Get-CimInstance -ClassName Win32_OperatingSystem |
Select-Object -Property BuildNumber,BuildType,OSType,ServicePackMajorVersion,ServicePackMinorVersion