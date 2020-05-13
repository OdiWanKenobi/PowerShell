function Get-ServerInventory {
    <#
    
    .SYNOPSIS
    Retrieves the inventory data for a server.
    
    .DESCRIPTION
    Retrieves the inventory data for a server.
    
    .ROLE
    Readers
    
    #>
    
    Set-StrictMode -Version 5.0
    
    Import-Module CimCmdlets
    
    <#
    
    .SYNOPSIS
    Converts an arbitrary version string into just 'Major.Minor'
    
    .DESCRIPTION
    To make OS version comparisons we only want to compare the major and
    minor version.  Build number and/os CSD are not interesting.
    
    #>
    
    function convertOsVersion([string]$osVersion) {
      [Ref]$parsedVersion = $null
      if (![Version]::TryParse($osVersion, $parsedVersion)) {
        return $null
      }
    
      $version = [Version]$parsedVersion.Value
      return New-Object Version -ArgumentList $version.Major, $version.Minor
    }
    
    <#
    
    .SYNOPSIS
    Determines if CredSSP is enabled for the current server or client.
    
    .DESCRIPTION
    Check the registry value for the CredSSP enabled state.
    
    #>
    
    function isCredSSPEnabled() {
      Set-Variable credSSPServicePath -Option Constant -Value "WSMan:\localhost\Service\Auth\CredSSP"
      Set-Variable credSSPClientPath -Option Constant -Value "WSMan:\localhost\Client\Auth\CredSSP"
    
      $credSSPServerEnabled = $false;
      $credSSPClientEnabled = $false;
    
      $credSSPServerService = Get-Item $credSSPServicePath -ErrorAction SilentlyContinue
      if ($credSSPServerService) {
        $credSSPServerEnabled = [System.Convert]::ToBoolean($credSSPServerService.Value)
      }
    
      $credSSPClientService = Get-Item $credSSPClientPath -ErrorAction SilentlyContinue
      if ($credSSPClientService) {
        $credSSPClientEnabled = [System.Convert]::ToBoolean($credSSPClientService.Value)
      }
    
      return ($credSSPServerEnabled -or $credSSPClientEnabled)
    }
    
    <#
    
    .SYNOPSIS
    Determines if the Hyper-V role is installed for the current server or client.
    
    .DESCRIPTION
    The Hyper-V role is installed when the VMMS service is available.  This is much
    faster then checking Get-WindowsFeature and works on Windows Client SKUs.
    
    #>
    
    function isHyperVRoleInstalled() {
      $vmmsService = Get-Service -Name "VMMS" -ErrorAction SilentlyContinue
    
      return $vmmsService -and $vmmsService.Name -eq "VMMS"
    }
    
    <#
    
    .SYNOPSIS
    Determines if the Hyper-V PowerShell support module is installed for the current server or client.
    
    .DESCRIPTION
    The Hyper-V PowerShell support module is installed when the modules cmdlets are available.  This is much
    faster then checking Get-WindowsFeature and works on Windows Client SKUs.
    
    #>
    function isHyperVPowerShellSupportInstalled() {
      # quicker way to find the module existence. it doesn't load the module.
      return !!(Get-Module -ListAvailable Hyper-V -ErrorAction SilentlyContinue)
    }
    
    <#
    
    .SYNOPSIS
    Determines if Windows Management Framework (WMF) 5.0, or higher, is installed for the current server or client.
    
    .DESCRIPTION
    Windows Admin Center requires WMF 5 so check the registey for WMF version on Windows versions that are less than
    Windows Server 2016.
    
    #>
    function isWMF5Installed([string] $operatingSystemVersion) {
      Set-Variable Server2016 -Option Constant -Value (New-Object Version '10.0')   # And Windows 10 client SKUs
      Set-Variable Server2012 -Option Constant -Value (New-Object Version '6.2')
    
      $version = convertOsVersion $operatingSystemVersion
      if (-not $version) {
        # Since the OS version string is not properly formatted we cannot know the true installed state.
        return $false
      }
    
      if ($version -ge $Server2016) {
        # It's okay to assume that 2016 and up comes with WMF 5 or higher installed
        return $true
      }
      else {
        if ($version -ge $Server2012) {
          # Windows 2012/2012R2 are supported as long as WMF 5 or higher is installed
          $registryKey = 'HKLM:\SOFTWARE\Microsoft\PowerShell\3\PowerShellEngine'
          $registryKeyValue = Get-ItemProperty -Path $registryKey -Name PowerShellVersion -ErrorAction SilentlyContinue
    
          if ($registryKeyValue -and ($registryKeyValue.PowerShellVersion.Length -ne 0)) {
            $installedWmfVersion = [Version]$registryKeyValue.PowerShellVersion
    
            if ($installedWmfVersion -ge [Version]'5.0') {
              return $true
            }
          }
        }
      }
    
      return $false
    }
    
    <#
    
    .SYNOPSIS
    Determines if the current usser is a system administrator of the current server or client.
    
    .DESCRIPTION
    Determines if the current usser is a system administrator of the current server or client.
    
    #>
    function isUserAnAdministrator() {
      return ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
    }
    
    <#
    
    .SYNOPSIS
    Get some basic information about the Failover Cluster that is running on this server.
    
    .DESCRIPTION
    Create a basic inventory of the Failover Cluster that may be running in this server.
    
    #>
    function getClusterInformation() {
      $returnValues = @{ }
    
      $returnValues.IsS2dEnabled = $false
      $returnValues.IsCluster = $false
      $returnValues.ClusterFqdn = $null
      $returnValues.IsBritannicaEnabled = $false
    
      $namespace = Get-CimInstance -Namespace root/MSCluster -ClassName __NAMESPACE -ErrorAction SilentlyContinue
      if ($namespace) {
        $cluster = Get-CimInstance -Namespace root/MSCluster -ClassName MSCluster_Cluster -ErrorAction SilentlyContinue
        if ($cluster) {
          $returnValues.IsCluster = $true
          $returnValues.ClusterFqdn = $cluster.Fqdn
          $returnValues.IsS2dEnabled = !!(Get-Member -InputObject $cluster -Name "S2DEnabled") -and ($cluster.S2DEnabled -gt 0)
          $returnValues.IsBritannicaEnabled = $null -ne (Get-CimInstance -Namespace root/sddc/management -ClassName SDDC_Cluster -ErrorAction SilentlyContinue)
        }
      }
    
      return $returnValues
    }
    
    <#
    
    .SYNOPSIS
    Get the Fully Qaulified Domain (DNS domain) Name (FQDN) of the passed in computer name.
    
    .DESCRIPTION
    Get the Fully Qaulified Domain (DNS domain) Name (FQDN) of the passed in computer name.
    
    #>
    function getComputerFqdnAndAddress($computerName) {
      $hostEntry = [System.Net.Dns]::GetHostEntry($computerName)
      $addressList = @()
      foreach ($item in $hostEntry.AddressList) {
        $address = New-Object PSObject
        $address | Add-Member -MemberType NoteProperty -Name 'IpAddress' -Value $item.ToString()
        $address | Add-Member -MemberType NoteProperty -Name 'AddressFamily' -Value $item.AddressFamily.ToString()
        $addressList += $address
      }
    
      $result = New-Object PSObject
      $result | Add-Member -MemberType NoteProperty -Name 'Fqdn' -Value $hostEntry.HostName
      $result | Add-Member -MemberType NoteProperty -Name 'AddressList' -Value $addressList
      return $result
    }
    
    <#
    
    .SYNOPSIS
    Get the Fully Qaulified Domain (DNS domain) Name (FQDN) of the current server or client.
    
    .DESCRIPTION
    Get the Fully Qaulified Domain (DNS domain) Name (FQDN) of the current server or client.
    
    #>
    function getHostFqdnAndAddress($computerSystem) {
      $computerName = $computerSystem.DNSHostName
      if (!$computerName) {
        $computerName = $computerSystem.Name
      }
    
      return getComputerFqdnAndAddress $computerName
    }
    
    <#
    
    .SYNOPSIS
    Are the needed management CIM interfaces available on the current server or client.
    
    .DESCRIPTION
    Check for the presence of the required server management CIM interfaces.
    
    #>
    function getManagementToolsSupportInformation() {
      $returnValues = @{ }
    
      $returnValues.ManagementToolsAvailable = $false
      $returnValues.ServerManagerAvailable = $false
    
      $namespaces = Get-CimInstance -Namespace root/microsoft/windows -ClassName __NAMESPACE -ErrorAction SilentlyContinue
    
      if ($namespaces) {
        $returnValues.ManagementToolsAvailable = !!($namespaces | Where-Object { $_.Name -ieq "ManagementTools" })
        $returnValues.ServerManagerAvailable = !!($namespaces | Where-Object { $_.Name -ieq "ServerManager" })
      }
    
      return $returnValues
    }
    
    <#
    
    .SYNOPSIS
    Check the remote app enabled or not.
    
    .DESCRIPTION
    Check the remote app enabled or not.
    
    #>
    function isRemoteAppEnabled() {
      Set-Variable key -Option Constant -Value "HKLM:\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\Terminal Server\\TSAppAllowList"
    
      $registryKeyValue = Get-ItemProperty -Path $key -Name fDisabledAllowList -ErrorAction SilentlyContinue
    
      if (-not $registryKeyValue) {
        return $false
      }
      return $registryKeyValue.fDisabledAllowList -eq 1
    }
    
    <#
    
    .SYNOPSIS
    Check the remote app enabled or not.
    
    .DESCRIPTION
    Check the remote app enabled or not.
    
    #>
    
    <#
    c
    .SYNOPSIS
    Get the Win32_OperatingSystem information
    
    .DESCRIPTION
    Get the Win32_OperatingSystem instance and filter the results to just the required properties.
    This filtering will make the response payload much smaller.
    
    #>
    function getOperatingSystemInfo() {
      return Get-CimInstance Win32_OperatingSystem | Microsoft.PowerShell.Utility\Select-Object csName, Caption, OperatingSystemSKU, Version, ProductType
    }
    
    <#
    
    .SYNOPSIS
    Get the Win32_ComputerSystem information
    
    .DESCRIPTION
    Get the Win32_ComputerSystem instance and filter the results to just the required properties.
    This filtering will make the response payload much smaller.
    
    #>
    function getComputerSystemInfo() {
      return Get-CimInstance Win32_ComputerSystem -ErrorAction SilentlyContinue | `
        Microsoft.PowerShell.Utility\Select-Object TotalPhysicalMemory, DomainRole, Manufacturer, Model, NumberOfLogicalProcessors, Domain, Workgroup, DNSHostName, Name, PartOfDomain, SystemFamily, SystemSKUNumber
    }
    
    <#
    
    .SYNOPSIS
    script to query SMBIOS locally from the passed in machineName
    
    
    .DESCRIPTION
    script to query SMBIOS locally from the passed in machine name
    #>
    function getSmbiosData($computerSystem) {
      <#
        Array of chassis types.
        The following list of ChassisTypes is copied from the latest DMTF SMBIOS specification.
        REF: https://www.dmtf.org/sites/default/files/standards/documents/DSP0134_3.1.1.pdf
      #>
      $ChassisTypes =
      @{
        1  = 'Other'
        2  = 'Unknown'
        3  = 'Desktop'
        4  = 'Low Profile Desktop'
        5  = 'Pizza Box'
        6  = 'Mini Tower'
        7  = 'Tower'
        8  = 'Portable'
        9  = 'Laptop'
        10 = 'Notebook'
        11 = 'Hand Held'
        12 = 'Docking Station'
        13 = 'All in One'
        14 = 'Sub Notebook'
        15 = 'Space-Saving'
        16 = 'Lunch Box'
        17 = 'Main System Chassis'
        18 = 'Expansion Chassis'
        19 = 'SubChassis'
        20 = 'Bus Expansion Chassis'
        21 = 'Peripheral Chassis'
        22 = 'Storage Chassis'
        23 = 'Rack Mount Chassis'
        24 = 'Sealed-Case PC'
        25 = 'Multi-system chassis'
        26 = 'Compact PCI'
        27 = 'Advanced TCA'
        28 = 'Blade'
        29 = 'Blade Enclosure'
        30 = 'Tablet'
        31 = 'Convertible'
        32 = 'Detachable'
        33 = 'IoT Gateway'
        34 = 'Embedded PC'
        35 = 'Mini PC'
        36 = 'Stick PC'
      }
    
    
    
      $list = New-Object System.Collections.ArrayList
      $win32_Bios = Get-CimInstance -class Win32_Bios
      $obj = New-Object -Type PSObject | Microsoft.PowerShell.Utility\Select-Object SerialNumber, Manufacturer, UUID, BaseBoardProduct, ChassisTypes, Chassis, SystemFamily, SystemSKUNumber
      $obj.SerialNumber = $win32_Bios.SerialNumber
      $obj.Manufacturer = $win32_Bios.Manufacturer
      $obj.UUID = (Get-CimInstance Win32_ComputerSystemProduct).UUID
      $obj.BaseBoardProduct = (Get-CimInstance Win32_BaseBoard).Product
      $obj.ChassisTypes = Get-CimInstance Win32_SystemEnclosure | Microsoft.PowerShell.Utility\Select-Object -ExpandProperty ChassisTypes
      $obj.Chassis = $ChassisTypes[[int]$obj.ChassisTypes]
      $obj.SystemFamily = $computerSystem.SystemFamily
      $obj.SystemSKUNumber = $computerSystem.SystemSKUNumber
      $list.Add($obj) | Out-Null
    
      return $list
    
    }
    ###########################################################################
    # main()
    ###########################################################################
    
    $operatingSystem = getOperatingSystemInfo
    $computerSystem = getComputerSystemInfo
    $isAdministrator = isUserAnAdministrator
    $fqdnAndAddress = getHostFqdnAndAddress $computerSystem
    $hostname = hostname
    $netbios = $env:ComputerName
    $managementToolsInformation = getManagementToolsSupportInformation
    $isWmfInstalled = isWMF5Installed $operatingSystem.Version
    $clusterInformation = getClusterInformation -ErrorAction SilentlyContinue
    $isHyperVPowershellInstalled = isHyperVPowerShellSupportInstalled
    $isHyperVRoleInstalled = isHyperVRoleInstalled
    $isCredSSPEnabled = isCredSSPEnabled
    $isRemoteAppEnabled = isRemoteAppEnabled
    $smbiosData = getSmbiosData $computerSystem
    
    $result = New-Object PSObject
    $result | Add-Member -MemberType NoteProperty -Name 'IsAdministrator' -Value $isAdministrator
    $result | Add-Member -MemberType NoteProperty -Name 'OperatingSystem' -Value $operatingSystem
    $result | Add-Member -MemberType NoteProperty -Name 'ComputerSystem' -Value $computerSystem
    $result | Add-Member -MemberType NoteProperty -Name 'Fqdn' -Value $fqdnAndAddress.Fqdn
    $result | Add-Member -MemberType NoteProperty -Name 'AddressList' -Value $fqdnAndAddress.AddressList
    $result | Add-Member -MemberType NoteProperty -Name 'Hostname' -Value $hostname
    $result | Add-Member -MemberType NoteProperty -Name 'NetBios' -Value $netbios
    $result | Add-Member -MemberType NoteProperty -Name 'IsManagementToolsAvailable' -Value $managementToolsInformation.ManagementToolsAvailable
    $result | Add-Member -MemberType NoteProperty -Name 'IsServerManagerAvailable' -Value $managementToolsInformation.ServerManagerAvailable
    $result | Add-Member -MemberType NoteProperty -Name 'IsWmfInstalled' -Value $isWmfInstalled
    $result | Add-Member -MemberType NoteProperty -Name 'IsCluster' -Value $clusterInformation.IsCluster
    $result | Add-Member -MemberType NoteProperty -Name 'ClusterFqdn' -Value $clusterInformation.ClusterFqdn
    $result | Add-Member -MemberType NoteProperty -Name 'IsS2dEnabled' -Value $clusterInformation.IsS2dEnabled
    $result | Add-Member -MemberType NoteProperty -Name 'IsBritannicaEnabled' -Value $clusterInformation.IsBritannicaEnabled
    $result | Add-Member -MemberType NoteProperty -Name 'IsHyperVRoleInstalled' -Value $isHyperVRoleInstalled
    $result | Add-Member -MemberType NoteProperty -Name 'IsHyperVPowershellInstalled' -Value $isHyperVPowershellInstalled
    $result | Add-Member -MemberType NoteProperty -Name 'IsCredSSPEnabled' -Value $isCredSSPEnabled
    $result | Add-Member -MemberType NoteProperty -Name 'IsRemoteAppEnabled' -Value $isRemoteAppEnabled
    $result | Add-Member -MemberType NoteProperty -Name 'SmbiosData' -Value $smbiosData
    
    $result
    
    }
    ## [END] Get-ServerInventory ##