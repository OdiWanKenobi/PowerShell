

Get-CimInstance -ClassName Win32_Processor | Select-Object -ExcludeProperty "CIM*"