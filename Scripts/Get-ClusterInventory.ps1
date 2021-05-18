function Get-ClusterInventory {
    <#
    
    .SYNOPSIS
    Retrieves the inventory data for a cluster.
    
    .DESCRIPTION
    Retrieves the inventory data for a cluster.
    
    .ROLE
    Readers
    
    #>
    
    import-module CimCmdlets -ErrorAction SilentlyContinue
    
    # JEA code requires to pre-import the module (this is slow on failover cluster environment.)
    import-module FailoverClusters -ErrorAction SilentlyContinue
    
    <#
    
    .SYNOPSIS
    Get the name of this computer.
    
    .DESCRIPTION
    Get the best available name for this computer.  The FQDN is preferred, but when not avaialble
    the NetBIOS name will be used instead.
    
    #>
    
    function getComputerName() {
        $computerSystem = Get-CimInstance Win32_ComputerSystem -ErrorAction SilentlyContinue | Microsoft.PowerShell.Utility\Select-Object Name, DNSHostName
    
        if ($computerSystem) {
            $computerName = $computerSystem.DNSHostName
    
            if ($null -eq $computerName) {
                $computerName = $computerSystem.Name
            }
    
            return $computerName
        }
    
        return $null
    }
    
    <#
    
    .SYNOPSIS
    Are the cluster PowerShell cmdlets installed on this server?
    
    .DESCRIPTION
    Are the cluster PowerShell cmdlets installed on this server?
    
    #>
    
    function getIsClusterCmdletAvailable() {
        $cmdlet = Get-Command "Get-Cluster" -ErrorAction SilentlyContinue
    
        return !!$cmdlet
    }
    
    <#
    
    .SYNOPSIS
    Get the MSCluster Cluster CIM instance from this server.
    
    .DESCRIPTION
    Get the MSCluster Cluster CIM instance from this server.
    
    #>
    function getClusterCimInstance() {
        $namespace = Get-CimInstance -Namespace root/MSCluster -ClassName __NAMESPACE -ErrorAction SilentlyContinue
    
        if ($namespace) {
            return Get-CimInstance -Namespace root/mscluster MSCluster_Cluster -ErrorAction SilentlyContinue | Microsoft.PowerShell.Utility\Select-Object fqdn, S2DEnabled
        }
    
        return $null
    }
    
    
    <#
    
    .SYNOPSIS
    Determines if the current cluster supports Failover Clusters Time Series Database.
    
    .DESCRIPTION
    Use the existance of the path value of cmdlet Get-StorageHealthSetting to determine if TSDB 
    is supported or not.
    
    #>
    function getClusterPerformanceHistoryPath() {
        return $null -ne (Get-StorageSubSystem clus* | Get-StorageHealthSetting -Name "System.PerformanceHistory.Path")
    }
    
    <#
    
    .SYNOPSIS
    Get some basic information about the cluster from the cluster.
    
    .DESCRIPTION
    Get the needed cluster properties from the cluster.
    
    #>
    function getClusterInfo() {
        $returnValues = @{}
    
        $returnValues.Fqdn = $null
        $returnValues.isS2DEnabled = $false
        $returnValues.isTsdbEnabled = $false
    
        $cluster = getClusterCimInstance
        if ($cluster) {
            $returnValues.Fqdn = $cluster.fqdn
            $isS2dEnabled = !!(Get-Member -InputObject $cluster -Name "S2DEnabled") -and ($cluster.S2DEnabled -eq 1)
            $returnValues.isS2DEnabled = $isS2dEnabled
    
            if ($isS2DEnabled) {
                $returnValues.isTsdbEnabled = getClusterPerformanceHistoryPath
            } else {
                $returnValues.isTsdbEnabled = $false
            }
        }
    
        return $returnValues
    }
    
    <#
    
    .SYNOPSIS
    Are the cluster PowerShell Health cmdlets installed on this server?
    
    .DESCRIPTION
    Are the cluster PowerShell Health cmdlets installed on this server?
    
    s#>
    function getisClusterHealthCmdletAvailable() {
        $cmdlet = Get-Command -Name "Get-HealthFault" -ErrorAction SilentlyContinue
    
        return !!$cmdlet
    }
    <#
    
    .SYNOPSIS
    Are the Britannica (sddc management resources) available on the cluster?
    
    .DESCRIPTION
    Are the Britannica (sddc management resources) available on the cluster?
    
    #>
    function getIsBritannicaEnabled() {
        return $null -ne (Get-CimInstance -Namespace root/sddc/management -ClassName SDDC_Cluster -ErrorAction SilentlyContinue)
    }
    
    <#
    
    .SYNOPSIS
    Are the Britannica (sddc management resources) virtual machine available on the cluster?
    
    .DESCRIPTION
    Are the Britannica (sddc management resources) virtual machine available on the cluster?
    
    #>
    function getIsBritannicaVirtualMachineEnabled() {
        return $null -ne (Get-CimInstance -Namespace root/sddc/management -ClassName SDDC_VirtualMachine -ErrorAction SilentlyContinue)
    }
    
    <#
    
    .SYNOPSIS
    Are the Britannica (sddc management resources) virtual switch available on the cluster?
    
    .DESCRIPTION
    Are the Britannica (sddc management resources) virtual switch available on the cluster?
    
    #>
    function getIsBritannicaVirtualSwitchEnabled() {
        return $null -ne (Get-CimInstance -Namespace root/sddc/management -ClassName SDDC_VirtualSwitch -ErrorAction SilentlyContinue)
    }
    
    ###########################################################################
    # main()
    ###########################################################################
    
    $clusterInfo = getClusterInfo
    
    $result = New-Object PSObject
    
    $result | Add-Member -MemberType NoteProperty -Name 'Fqdn' -Value $clusterInfo.Fqdn
    $result | Add-Member -MemberType NoteProperty -Name 'IsS2DEnabled' -Value $clusterInfo.isS2DEnabled
    $result | Add-Member -MemberType NoteProperty -Name 'IsTsdbEnabled' -Value $clusterInfo.isTsdbEnabled
    $result | Add-Member -MemberType NoteProperty -Name 'IsClusterHealthCmdletAvailable' -Value (getIsClusterHealthCmdletAvailable)
    $result | Add-Member -MemberType NoteProperty -Name 'IsBritannicaEnabled' -Value (getIsBritannicaEnabled)
    $result | Add-Member -MemberType NoteProperty -Name 'IsBritannicaVirtualMachineEnabled' -Value (getIsBritannicaVirtualMachineEnabled)
    $result | Add-Member -MemberType NoteProperty -Name 'IsBritannicaVirtualSwitchEnabled' -Value (getIsBritannicaVirtualSwitchEnabled)
    $result | Add-Member -MemberType NoteProperty -Name 'IsClusterCmdletAvailable' -Value (getIsClusterCmdletAvailable)
    $result | Add-Member -MemberType NoteProperty -Name 'CurrentClusterNode' -Value (getComputerName)
    
    $result
    
    }
    ## [END] Get-ClusterInventory ##