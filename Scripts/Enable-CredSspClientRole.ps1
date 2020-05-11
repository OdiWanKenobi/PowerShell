function Enable-CredSSPClientRole {
    <#
    
    .SYNOPSIS
    Enables CredSSP on this computer as client role to the other computer.
    
    .DESCRIPTION
    Enables CredSSP on this computer as client role to the other computer.
    
    .ROLE
    Administrators
    
    .PARAMETER serverNames
    The names of the server to which this gateway can forward credentials.
    
    .LINK
    https://portal.msrc.microsoft.com/en-us/security-guidance/advisory/CVE-2018-0886
    
    .LINK
    https://aka.ms/CredSSP-Updates
    
    #>
    
    param (
        [Parameter(Mandatory=$True)]
        [string[]]$serverNames
    )
    
    Set-StrictMode -Version 5.0
    Import-Module  Microsoft.WSMan.Management -ErrorAction SilentlyContinue
    
    <#
    
    .SYNOPSIS
    Setup all necessary global variables, constants, etc.
    
    .DESCRIPTION
    Setup all necessary global variables, constants, etc.
    
    #>
    
    function setupScriptEnv() {
        Set-Variable -Name WsManApplication -Option ReadOnly -Scope Script -Value "wsman"
        Set-Variable -Name CredSSPClientAuthPath -Option ReadOnly -Scope Script -Value "localhost\Client\Auth\CredSSP"
        Set-Variable -Name CredentialsDelegationPolicyPath -Option ReadOnly -Scope Script -Value "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CredentialsDelegation"
        Set-Variable -Name AllowFreshCredentialsPath -Option ReadOnly -Scope Script -Value "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CredentialsDelegation\AllowFreshCredentials"
        Set-Variable -Name AllowFreshCredentialsPropertyName -Option ReadOnly -Scope Script -Value "AllowFreshCredentials"
        Set-Variable -Name TypeAlreadyExistsHResult -Option ReadOnly -Scope Script -Value -2146233088
        Set-Variable -Name NativeCode -Option ReadOnly -Scope Script -Value @"
        using Microsoft.Win32;
        using System;
        using System.Collections.Generic;
        using System.Globalization;
        using System.Linq;
        using System.Runtime.InteropServices;
        using System.Text;
        using System.Threading;
        
        namespace SME
        {
            public static class LocalGroupPolicy
            {
                [Guid("EA502722-A23D-11d1-A7D3-0000F87571E3")]
                [ComImport]
                [ClassInterface(ClassInterfaceType.None)]
                public class GPClass
                {
                }
        
                [ComImport, Guid("EA502723-A23D-11d1-A7D3-0000F87571E3"),
                InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
                public interface IGroupPolicyObject
                {
                    void New(
                        [MarshalAs(UnmanagedType.LPWStr)] string pszDomainName,
                        [MarshalAs(UnmanagedType.LPWStr)] string pszDisplayName,
                        uint dwFlags);
        
                    void OpenDSGPO(
                        [MarshalAs(UnmanagedType.LPWStr)] string pszPath,
                        uint dwFlags);
        
                    void OpenLocalMachineGPO(uint dwFlags);
        
                    void OpenRemoteMachineGPO(
                        [MarshalAs(UnmanagedType.LPWStr)] string pszComputerName,
                        uint dwFlags);
        
                    void Save(
                        [MarshalAs(UnmanagedType.Bool)] bool bMachine,
                        [MarshalAs(UnmanagedType.Bool)] bool bAdd,
                        [MarshalAs(UnmanagedType.LPStruct)] Guid pGuidExtension,
                        [MarshalAs(UnmanagedType.LPStruct)] Guid pGuid);
        
                    void Delete();
        
                    void GetName(
                        [MarshalAs(UnmanagedType.LPWStr)] StringBuilder pszName,
                        int cchMaxLength);
        
                    void GetDisplayName(
                        [MarshalAs(UnmanagedType.LPWStr)] StringBuilder pszName,
                        int cchMaxLength);
        
                    void SetDisplayName(
                        [MarshalAs(UnmanagedType.LPWStr)] string pszName);
        
                    void GetPath(
                        [MarshalAs(UnmanagedType.LPWStr)] StringBuilder pszPath,
                        int cchMaxPath);
        
                    void GetDSPath(
                        uint dwSection,
                        [MarshalAs(UnmanagedType.LPWStr)] StringBuilder pszPath,
                        int cchMaxPath);
        
                    void GetFileSysPath(
                        uint dwSection,
                        [MarshalAs(UnmanagedType.LPWStr)] StringBuilder pszPath,
                        int cchMaxPath);
        
                    IntPtr GetRegistryKey(uint dwSection);
        
                    uint GetOptions();
        
                    void SetOptions(uint dwOptions, uint dwMask);
        
                    void GetMachineName(
                        [MarshalAs(UnmanagedType.LPWStr)] StringBuilder pszName,
                        int cchMaxLength);
        
                    uint GetPropertySheetPages(out IntPtr hPages);
                }
        
                private const int GPO_OPEN_LOAD_REGISTRY = 1;
                private const int GPO_SECTION_MACHINE = 2;
                private const string ApplicationName = @"wsman";
                private const string AllowFreshCredentials = @"AllowFreshCredentials";
                private const string ConcatenateDefaultsAllowFresh = @"ConcatenateDefaults_AllowFresh";
                private const string PathCredentialsDelegationPath = @"SOFTWARE\Policies\Microsoft\Windows";
                private const string GPOpath = @"SOFTWARE\Microsoft\Windows\CurrentVersion\Group Policy Objects";
                private const string Machine = @"Machine";
                private const string CredentialsDelegation = @"\CredentialsDelegation";
                private const string PoliciesPath = @"Software\Policies\Microsoft\Windows";
                private const string BackSlash = @"\";
        
                public static string EnableAllowFreshCredentialsPolicy(string[] serverNames)
                {
                    if (Thread.CurrentThread.GetApartmentState() == ApartmentState.STA)
                    {
                        return EnableAllowFreshCredentialsPolicyImpl(serverNames);
                    }
                    else
                    {
                        string value = null;
        
                        var thread = new Thread(() =>
                        {
                            value = EnableAllowFreshCredentialsPolicyImpl(serverNames);
                        });
        
                        thread.SetApartmentState(ApartmentState.STA);
                        thread.Start();
                        thread.Join();
        
                        return value;
                    }
                }
        
                public static string RemoveServersFromAllowFreshCredentialsPolicy(string[] serverNames)
                {
                    if (Thread.CurrentThread.GetApartmentState() == ApartmentState.STA)
                    {
                        return RemoveServersFromAllowFreshCredentialsPolicyImpl(serverNames);
                    }
                    else
                    {
                        string value = null;
        
                        var thread = new Thread(() =>
                        {
                            value = RemoveServersFromAllowFreshCredentialsPolicyImpl(serverNames);
                        });
        
                        thread.SetApartmentState(ApartmentState.STA);
                        thread.Start();
                        thread.Join();
        
                        return value;
                    }
                }
        
                private static string EnableAllowFreshCredentialsPolicyImpl(string[] serverNames)
                {
                    IGroupPolicyObject gpo = (IGroupPolicyObject)new GPClass();
                    gpo.OpenLocalMachineGPO(GPO_OPEN_LOAD_REGISTRY);
        
                    var KeyHandle = gpo.GetRegistryKey(GPO_SECTION_MACHINE);
        
                    try
                    {
                        var rootKey = Registry.CurrentUser;
        
                        using (RegistryKey GPOKey = rootKey.OpenSubKey(GPOpath, true))
                        {
                            foreach (var keyName in GPOKey.GetSubKeyNames())
                            {
                                if (keyName.EndsWith(Machine, StringComparison.OrdinalIgnoreCase))
                                {
                                    var key = GPOpath + BackSlash + keyName + BackSlash + PoliciesPath;
        
                                    UpdateGpoRegistrySettingsAllowFreshCredentials(ApplicationName, serverNames, Registry.CurrentUser, key);
                                }
                            }
                        }
        
                        //saving gpo settings
                        gpo.Save(true, true, new Guid("35378EAC-683F-11D2-A89A-00C04FBBCFA2"), new Guid("7A9206BD-33AF-47af-B832-D4128730E990"));
                    }
                    catch (Exception ex)
                    {
                        return ex.Message;
                    }
                    finally
                    {
                        KeyHandle = IntPtr.Zero;
                    }
        
                    return null;
                }
        
                private static string RemoveServersFromAllowFreshCredentialsPolicyImpl(string[] serverNames)
                {
                    IGroupPolicyObject gpo = (IGroupPolicyObject)new GPClass();
                    gpo.OpenLocalMachineGPO(GPO_OPEN_LOAD_REGISTRY);
        
                    var KeyHandle = gpo.GetRegistryKey(GPO_SECTION_MACHINE);
        
                    try
                    {
                        var rootKey = Registry.CurrentUser;
        
                        using (RegistryKey GPOKey = rootKey.OpenSubKey(GPOpath, true))
                        {
                            foreach (var keyName in GPOKey.GetSubKeyNames())
                            {
                                if (keyName.EndsWith(Machine, StringComparison.OrdinalIgnoreCase))
                                {
                                    var key = GPOpath + BackSlash + keyName + BackSlash + PoliciesPath;
        
                                    UpdateGpoRegistrySettingsRemoveServersFromFreshCredentials(ApplicationName, serverNames, Registry.CurrentUser, key);
                                }
                            }
                        }
        
                        //saving gpo settings
                        gpo.Save(true, true, new Guid("35378EAC-683F-11D2-A89A-00C04FBBCFA2"), new Guid("7A9206BD-33AF-47af-B832-D4128730E990"));
                    }
                    catch (Exception ex)
                    {
                        return ex.Message;
                    }
                    finally
                    {
                        KeyHandle = IntPtr.Zero;
                    }
        
                    return null;
                }
        
                private static void UpdateGpoRegistrySettingsAllowFreshCredentials(string applicationName, string[] serverNames, RegistryKey rootKey, string registryPath)
                {
                    var registryPathCredentialsDelegation = registryPath + CredentialsDelegation;
                    var credentialDelegationKey = rootKey.OpenSubKey(registryPathCredentialsDelegation, true);
        
                    try
                    {
                        if (credentialDelegationKey == null)
                        {
                            credentialDelegationKey = rootKey.CreateSubKey(registryPathCredentialsDelegation, RegistryKeyPermissionCheck.ReadWriteSubTree);
                        }
        
                        credentialDelegationKey.SetValue(AllowFreshCredentials, 1, RegistryValueKind.DWord);
                        credentialDelegationKey.SetValue(ConcatenateDefaultsAllowFresh, 1, RegistryValueKind.DWord);
                    }
                    finally
                    {
                        credentialDelegationKey.Dispose();
                        credentialDelegationKey = null;
                    }
        
                    var allowFreshCredentialKey = rootKey.OpenSubKey(registryPathCredentialsDelegation + BackSlash + AllowFreshCredentials, true);
        
                    try
                    {
    
                        if (allowFreshCredentialKey == null)
                        {
                            allowFreshCredentialKey = rootKey.CreateSubKey(registryPathCredentialsDelegation + BackSlash + AllowFreshCredentials, RegistryKeyPermissionCheck.ReadWriteSubTree);
                        }
    
                        if (allowFreshCredentialKey != null)
                        {
                            var values = allowFreshCredentialKey.ValueCount;
                            var valuesToAdd = serverNames.ToDictionary(key => string.Format(CultureInfo.InvariantCulture, @"{0}/{1}", applicationName, key), value => value);
                            var valueNames = allowFreshCredentialKey.GetValueNames();
                            var existingValues = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
        
                            foreach (var valueName in valueNames)
                            {
                                var value = allowFreshCredentialKey.GetValue(valueName).ToString();
        
                                if (!existingValues.ContainsKey(value))
                                {
                                    existingValues.Add(value, value);
                                }
                            }
        
                            foreach (var key in valuesToAdd.Keys)
                            {
                                if (!existingValues.ContainsKey(key))
                                {
                                    allowFreshCredentialKey.SetValue(Convert.ToString(values + 1, CultureInfo.InvariantCulture), key, RegistryValueKind.String);
                                    values++;
                                }
                            }
                        }
                    }
                    finally
                    {
                        allowFreshCredentialKey.Dispose();
                        allowFreshCredentialKey = null;
                    }
                }
        
                private static void UpdateGpoRegistrySettingsRemoveServersFromFreshCredentials(string applicationName, string[] serverNames, RegistryKey rootKey, string registryPath)
                {
                    var registryPathCredentialsDelegation = registryPath + CredentialsDelegation;
        
                    using (var allowFreshCredentialKey = rootKey.OpenSubKey(registryPathCredentialsDelegation + BackSlash + AllowFreshCredentials, true))
                    {
                        if (allowFreshCredentialKey != null)
                        {
                            var valuesToRemove = serverNames.ToDictionary(key => string.Format(CultureInfo.InvariantCulture, @"{0}/{1}", applicationName, key), value => value);
                            var valueNames = allowFreshCredentialKey.GetValueNames();
        
                            foreach (var valueName in valueNames)
                            {
                                var value = allowFreshCredentialKey.GetValue(valueName).ToString();
                                
                                if (valuesToRemove.ContainsKey(value))
                                {
                                    allowFreshCredentialKey.DeleteValue(valueName);
                                }
                            }
                        }
                    }
                }
            }
        }
    "@  # Cannot have leading whitespace on this line!
    }
    
    <#
    
    .SYNOPSIS
    Clean up all added global variables, constants, etc.
    
    .DESCRIPTION
    Clean up all added global variables, constants, etc.
    
    #>
    
    function cleanupScriptEnv() {
        Remove-Variable -Name WsManApplication -Scope Script -Force
        Remove-Variable -Name CredSSPClientAuthPath -Scope Script -Force
        Remove-Variable -Name CredentialsDelegationPolicyPath -Scope Script -Force
        Remove-Variable -Name AllowFreshCredentialsPath -Scope Script -Force
        Remove-Variable -Name AllowFreshCredentialsPropertyName -Scope Script -Force
        Remove-Variable -Name TypeAlreadyExistsHResult -Scope Script -Force
        Remove-Variable -Name NativeCode -Scope Script -Force
    }
    
    <#
    
    .SYNOPSIS
    Enable CredSSP client role on this computer.
    
    .DESCRIPTION
    Enable the CredSSP client role on this computer.  This computer should be a 
    Windows Admin Center gateway, desktop or service mode.
    
    #>
    
    function enableCredSSPClient() {
        $path = "{0}:\{1}" -f $WsManApplication, $CredSSPClientAuthPath
    
        Set-Item -Path $path True -Force -ErrorAction SilentlyContinue -ErrorVariable +err
    }
    
    <#
    
    .SYNOPSIS
    Get the CredentialsDelegation container from the registry.
    
    .DESCRIPTION
    Get the CredentialsDelegation container from the registry.  If the container
    does not exist then a new one will be created.
    
    #>
    
    function getCredentialsDelegationItem() {
        $credentialDelegationItem = Get-Item  $CredentialsDelegationPolicyPath -ErrorAction SilentlyContinue
        if (-not ($credentialDelegationItem)) {
            $credentialDelegationItem = New-Item  $CredentialsDelegationPolicyPath
        }
    
        return $credentialDelegationItem
    }
    
    <#
    
    .SYNOPSIS
    Creates the CredentialsDelegation\AllowFreshCredentials container from the registry.
    
    .DESCRIPTION
    Create the CredentialsDelegation\AllowFreshCredentials container from the registry.  If the container
    does not exist then a new one will be created.
    
    #>
    
    function createAllowFreshCredentialsItem() {
        $allowFreshCredentialsItem = Get-Item $AllowFreshCredentialsPath -ErrorAction SilentlyContinue
        if (-not ($allowFreshCredentialsItem)) {
            New-Item $AllowFreshCredentialsPath
        }
    }
    
    <#
    
    .SYNOPSIS
    Set the AllowFreshCredentials property value in the CredentialsDelegation container.
    
    .DESCRIPTION
    Set the AllowFreshCredentials property value in the CredentialsDelegation container.
    If the value exists then it is not changed.
    
    #>
    
    function setAllowFreshCredentialsProperty($credentialDelegationItem) {
        $credentialDelegationItem | New-ItemProperty -Name $AllowFreshCredentialsPropertyName -Value 1 -Type DWord -Force
    }
    
    <#
    
    .SYNOPSIS
    Add the passed in server(s) to the AllowFreshCredentials key/container.
    
    .DESCRIPTION
    Add the passed in server(s) to the AllowFreshCredentials key/container. 
    If a given server is already present then do not add it again.
    
    #>
    
    function addServersToAllowFreshCredentials([string[]]$serverNames) {
        $valuesAdded = 0
    
        foreach ($serverName in $serverNames) {
            $newValue = "{0}/{1}" -f $WsManApplication, $serverName
    
            # Check if any registry-value nodes values of registry-key node have certain value.
            $key = Get-ChildItem $CredentialsDelegationPolicyPath | ? PSChildName -eq $AllowFreshCredentialsPropertyName
            $hasValue = $false
            $valueNames = $key.GetValueNames()
    
            foreach ($valueName in $valueNames) {
                $value = $key.GetValue($valueName)
    
                if ($value -eq $newValue) {
                    $hasValue = $true
                    break
                }
            }
    
            if (-not ($hasValue)) {
                New-ItemProperty $AllowFreshCredentialsPath -Name ($valueNames.Length + 1) -Value $newValue -Force
                $valuesAdded++
            }
        }
    
        return $valuesAdded -gt 0
    }
    
    <#
    
    .SYNOPSIS
    Add the passed in server(s) to the delegation list in the registry.
    
    .DESCRIPTION
    Add the passed in server(s) to the delegation list in the registry.
    
    #>
    
    function addServersToDelegation([string[]] $serverNames) {
        # Default to true because not adding entries is not a failure
        $result = $true
    
        # Get the CredentialsDelegation key/container
        $credentialDelegationItem = getCredentialsDelegationItem
    
        # Test, and create if needed, the AllowFreshCredentials property value
        setAllowFreshCredentialsProperty $credentialDelegationItem
    
        # Create the AllowFreshCredentials key/container
        createAllowFreshCredentialsItem
        
        # Add the servers to the AllowFreshCredentials key/container, if not already present
        $updateGroupPolicy = addServersToAllowFreshCredentials $serverNames
    
        if ($updateGroupPolicy) {
            $result = setLocalGroupPolicy $serverNames
        }
    
        return $result
    }
    
    <#
    
    .SYNOPSIS
    Set the local group policy to match the settings that have already been made.
    
    .DESCRIPTION
    Local Group Policy must match the settings that were made by this script to
    ensure that an older Local GP setting does not overwrite the thos settings.
    
    #>
    
    function setLocalGroupPolicy([string[]] $serverNames) {
        try {
            Add-Type -TypeDefinition $NativeCode
        } catch {
            if ($_.Exception.HResult -ne $TypeAlreadyExistsHResult) {
                Write-Error $_.Exception.Message
    
                return $false
            }
        }
    
        $errorMessage = [SME.LocalGroupPolicy]::EnableAllowFreshCredentialsPolicy($serverNames)
    
        if ($errorMessage) {
            Write-Error $errorMessage
    
            return $false
        }
    
        return $true
    }
    
    <#
    
    .SYNOPSIS
    Main function of this script.
    
    .DESCRIPTION
    Enable CredSSP client role and add the passed in servers to the list
    of servers to which this client can delegate credentials.
    
    #>
    function main([string[]] $serverNames) {
        setupScriptEnv
    
        enableCredSSPClient
        $result = addServersToDelegation $serverNames
    
        cleanupScriptEnv
    
        return $result
    }
    
    ###############################################################################
    # Script execution starts here
    ###############################################################################
    
    return main $serverNames
    
    }
    ## [END] Enable-CredSSPClientRole ##