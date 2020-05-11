
#Requires -Version 2.0  

        <#
        https://zabbix.org/mw/images/0/03/Install-RemoteZabbixAgent.ps1
        .SYNOPSIS
         Install, Delete and modyfy Zabbix Agent on a Remote Computer
         For examples type:
             Get-Help Install-RemoteZabbixAgent -examples
        .DESCRIPTION
         Remote installation of Zabbix agent from central location with credential input.
		
		 before you can use the Script, you must run this commands on the remote Server:
		######################################################################################
		
			Set-ExecutionPolicy RemoteSigned -force
 			Start-Service WinRM
 			Set-ItemProperty –Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System –Name LocalAccountTokenFilterPolicy –Value 1 -Type DWord
			Enable-PSRemoting -force
			Configure-SMRemoting.ps1 -force -enable -ErrorAction SilentlyContinue
			Set-Item WSMan:\localhost\Client\TrustedHosts –Value mgmt01.domain.dom -Force 
			restart-service winrm
			
		######################################################################################
		
		 The Zabbix source folder is a folder containing subfolder corresponding to the
		 different agent versions. These subfolders contain the win32 and win64 subfolders 
		 along with the Subfolder conf that include the zabbix_agentd.win.conf configuration file.
		
		 You must have administrative privileges on the remote computer you will specify
		 in the computerName parameter. You can either use the following format:
        .EXAMPLE
         .\Install-RemoteZabbixAgent.ps1 -ComputerName server1,server2,server3
 		 .\Install-RemoteZabbixAgent.ps1 -ComputerName pops.domain.dom -Version 2.0.10
		 .\Install-RemoteZabbixAgent.ps1 -ComputerName patho-S001.sub.domain.dom -Version 2.2.1
		 .\Install-RemoteZabbixAgent.ps1 -File "W:\zabbix\PC.txt" -Version 2.2.1
         
       	 Additionally, you have the following parameters you can optionally define:

			-Version 			#Version of the agent to be installed(points to subfolder)
								 Defaults to "2.0.9"
			-ZabbixPath			#Folder where the agent installation resides on the central
								 server. This is the folder that will be copied over to the
								 remote locations.
								 Defaults to "\\MGMT01.Domain.com\Zabbix$"   
			-File				#List of Computer with Credential Information "<PATH>\PC.txt
								 Servername FQDN [TAB] Domain\Username [TAB] Password
			-force				#force the installation (e.g. update, corecture installation)
								 
		.NOTES
			About the zabbix structure: on my installation, this folder holds 2 subfolders:

			\\MGMT01.domain.dom\Zabbix$
													 \1.8.15
													 \2.0.4
													 \2.0.9
													 \2.2.0
													 		\conf
															\bin
																\win32
																\win64
													 \uninstall.bat
													 \zabbix_fqdn.vbs
													 \zabbix_script
													 			 \check-multipath.ps1
																 \VersConfig.conf
																 
													 		

			$ZabbixPath and $Version will be assembled in a new variable named
			$Zabbix Source, look for it for a better understanding.

		
		
        .NOTES
         NAME......:  Install-RemoteZabbixAgent.ps1
		 REQUIREMENTS...:  PowerShell v2.0
         AUTHOR....:  Thomas Garnreiter, Medical University of Vienna
         LAST EDIT.:  2014-01-13
         CREATED...:  2013-11-28
        .LINK
		
		.DISCLAIMER

		Copyright (c) 2014, Thomas Garnreiter

		All rights reserved.

		Redistribution and use in source and binary forms, with or without modification,
		are permitted provided that the following conditions are met:

		* Redistributions of source code must retain the above copyright notice, this
		list of conditions and the following disclaimer.
		* Redistributions in binary form must reproduce the above copyright notice,
		this list of conditions and the following disclaimer in the documentation
		and/or other materials provided with the distribution.
		* Neither the name of the Medical University of Vienna nor the names of its contributors
		may be used to endorse or promote products derived from this software
		without specific prior written permission.

		THIS SOFTWARE IS PROVIDED BY THE REGENTS AND CONTRIBUTORS ''AS IS'' AND ANY
		EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
		WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
		DISCLAIMED. IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE FOR ANY
		DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
		(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
		LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
		ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
		(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
		SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
        
        #>
# ===========================================================================================
# Parameters
# ===========================================================================================
param( 
    [array]$computerName,
    [string]$ZabbixPath = "\\MGMT01.domain.dom\Zabbix$",
    [string]$Version = "2.2.1",
    [string]$file,
    [switch]$force
    ) #end param
    
# ===========================================================================================
# Initialization
# ===========================================================================================
    $ZabbixService = "Zabbix Agent"
    $ZabbixSource = "$ZabbixPath\$Version"
    [string]$zabbixDestinationPath
    $instOk
    $instBad
    # $DOM = for Windows AD Domains (DOM\Administrator)
    [Array]$DOM = @("DOM1","DOM2,DOM3")
# ===========================================================================================
# Functions
# ===========================================================================================
function FreeDriveLetter {
##--------------------------------------------------------------------------
##  FUNCTION.......:  FreeDriveLetter
##  PURPOSE........:  Look for a free Drive Letter on the local Machine
##  REQUIREMENTS...:  PowerShell v2.0
##  NOTES..........:  
##--------------------------------------------------------------------------
for($j=67;gdr($d=[char]++$j)2>0){}$d
}
#============================================================================================
function Run-RemoteCMD { 
##--------------------------------------------------------------------------
##  FUNCTION.......:  Run-RemoteCMD
##  PURPOSE........:  Runs commandline programs on remote computers. Any
##                    valid CMD.EXE command can be used, but be aware that
##                    the command will execute on the remote computer(s).
##  REQUIREMENTS...:  PowerShell v2.0
##  NOTES..........:  
##--------------------------------------------------------------------------
    param( 
    [Parameter(Mandatory=$true,valuefrompipeline=$true)] 
    [string]$HostName,
    [string]$command,
    $Credential ) 
    begin { 
        
        [string]$cmd = "CMD.EXE /C " +$command 
    } 
    process { 
        $newproc = Invoke-WmiMethod -class Win32_process -name Create `
            -ArgumentList ($cmd) -ComputerName $HostName -Credential $Credential
       # if ($newproc.ReturnValue -eq 0 ) { Write-Output " Command $($command) Install run Sucessfully on $($HostName)" } 
        return $newproc.ReturnValue
                ##----------------------------------------------------------
                ##  if the command is sucessfully invoked it doesn't mean 
                ##  that it did what its supposed to do, it means that the 
                ##  command only sucessfully ran on the cmd.exe of the
                ##  server. Syntax errors, etc.
                ##----------------------------------------------------------                     
    } 
    End{} 
}#end function Run-RemoteCMD
# ===========================================================================================
function Run-RemotePScommand { 
##--------------------------------------------------------------------------
##  FUNCTION.......:  Run-RemoteCMD
##  PURPOSE........:  Runs commandline programs on remote computers. Any
##                    valid CMD.EXE command can be used, but be aware that
##                    the command will execute on the remote computer(s).
##  REQUIREMENTS...:  PowerShell v2.0
##  NOTES..........:  
##--------------------------------------------------------------------------
    param( 
    [Parameter(Mandatory=$true,valuefrompipeline=$true)] 
    [string]$HostName,
    [string]$command,
    $Credential ) 
    begin { 
        
        [string]$cmd = "Powershell.EXE -command { $command }"
    } 
    process { 
        $newproc = Invoke-WmiMethod -class Win32_process -name Create `
            -ArgumentList ($cmd) -ComputerName $HostName -Credential $Credential
       # if ($newproc.ReturnValue -eq 0 ) { Write-Output " Command $($command) Install run Sucessfully on $($HostName)" } 
        return $newproc.ReturnValue
                ##----------------------------------------------------------
                ##  if the command is sucessfully invoked it doesn't mean 
                ##  that it did what its supposed to do, it means that the 
                ##  command only sucessfully ran on the cmd.exe of the
                ##  server. Syntax errors, etc.
                ##----------------------------------------------------------                     
    } 
    End{} 
}#end function Run-RemoteCMD
# ===========================================================================================
function global:Get-OSArchitecture {

#Requires -Version 2.0
[CmdletBinding()]
Param 
(
[Parameter(Mandatory=$false,
           Position=1,
           ValueFromPipeline=$true,
           ValueFromPipelineByPropertyName=$true)]
[String[]]$ComputerName = $env:COMPUTERNAME      
)#End Param 

Begin
{
Write-Verbose "Retrieving Computer Info . . ."
}
Process
{
$ComputerName | foreach { 
$ErrorActionPreference = 0
$Computer = $_
$Windir,$OSArchitecture,$OSVersion = Get-WmiObject -class Win32_OperatingSystem -ComputerName $_ | 
foreach {$_.WindowsDirectory,$_.OSArchitecture,$_.Version}
$SysDrive = ($Windir -split ":")[0] + "$"
# $OSVersion[0]
# $OSArchitecture is only suppored on OSVersion -ge 6
# I was going to test for that, however now I just test if $OSArchitecture -eq $True
Write-Verbose "Operating System version on $Computer is: $OSVersion"
if ($OSArchitecture)
{
    New-Object PSObject -Property @{ 
    Hostname=$Computer
    OSArchitecture=$OSArchitecture
    SysDrive=$SysDrive
    OSVersion=$OSVersion
    WinDir=$WinDir
    }
}
else
{
    # check the program files directory
    write-verbose "System Drive on $Computer is: $SysDrive"
    $x64 =  "\\$Computer\" + $SysDrive + "\Program Files (x86)"
    if (test-path ("\\$Computer\" + $SysDrive))
        {
            if (test-path $x64)
                {
                    New-Object PSObject -Property @{ 
                    Hostname=$Computer
                    OSArchitecture="64-bit"
                    SysDrive=$SysDrive
                    OSVersion=$OSVersion
                    WinDir=$WinDir
                    }
                }
            elseif (!(test-path $x64))
                {
                    New-Object PSObject -Property @{ 
                    Hostname=$Computer
                    OSArchitecture="32-bit"
                    SysDrive=$SysDrive
                    OSVersion=$OSVersion
                    WinDir=$WinDir
                    }
                }
        }
    else {"Something wrong determining the System Drive"} 
}
} | select Hostname,OSArchitecture,SysDrive,WinDir,OSVersion

}#Process            
End            
{   

}#End 


}#Get-Architecture
# ===========================================================================================
function global:Check-OpenPort {

param (
$port 
)

$open = 0
$fw = New-Object -ComObject HNetCfg.FWPolicy2 
$FWports = ($fw.Rules | Where {$_.LocalPorts -like $port})
If (!($FWports -eq $null)) {

                $open = 0
#                    "$port is Open"
                } 
                else {
                $open = 1
              #  "$port is Close"
                }


return $open
}
# ===========================================================================================
function Test-RegistryValue($path, $name){
$key = Get-Item -LiteralPath $path -ErrorAction SilentlyContinue
$key -and $null -ne $key.GetValue($name, $null)
}
# ===========================================================================================
# Gets the specified registry value or $null if it is missing
function Get-RegistryValue($path, $name){
$key = Get-Item -LiteralPath $path -ErrorAction SilentlyContinue
if ($key) {
    $key.GetValue($name, $null)
}
}
# ===========================================================================================
function CheckOpenPort {
        param ($port)
        $open = "close"
        $fw = New-Object -ComObject HNetCfg.FWPolicy2 
        $FWports = ($fw.Rules | Where {$_.LocalPorts -like $port})
        
        If (!($FWports -eq $null)) {$open = "open"} 
        else {$open = "close"}
        return $open
        }# end CheckOpenPort function
# ===========================================================================================

# ===========================================================================================
# Welcome message
# ===========================================================================================
    Write-Host "================================================================================"
    Write-Host " Welcome!" 
    Write-Host " This script requires administrative privileges on all implicated servers!"  
    Write-Host "================================================================================"
# ===========================================================================================
# Verifying the source installation folder
# ===========================================================================================
    Write-Host "================================================================================"
    Write-Host " Zabbix source installation folder:" $ZabbixSource 

    if (!(Test-Path $ZabbixSource)){
        Write-Host " "
        Write-Host "#################################################"
        Write-Host "# Error! - Zabbix Source Folder does not exist! #"
        Write-Host "#################################################"
        Write-Host " "
        exit
    }# end if(!(Test-Path $ZabbixSource))
    Write-Host "================================================================================"

# ===========================================================================================
# Check Free DriveLetter
# ===========================================================================================
#		$FDL = FreeDriveLetter
# ===========================================================================================
# set input about file or direct
# ===========================================================================================
    if ($file) {
        [Array]$arrPCliste = Get-Content -Path $file 
    }#end if ($file)
    else{
         $arrPCliste = $computerName 
    }#end if ($file)else
# ===========================================================================================
# doing on every Computer in list
# ===========================================================================================		
    
foreach($PCs in $arrPCliste) {
#$FDL = FreeDriveLetter
$FDL = "P"

    $cred = $null
If ($file){
    [array]$PC = $PCs -split "	"
    $computer = $PC[0]
    }#end If ($file)
else {
$computer =	$PCs
}#end If ($file)else

$ComputerIP0 = ([System.Net.Dns]::GetHostAddresses($computer)).IPAddressToString
$type = ($ComputerIP0.GetType()).BaseType.Name
If ($type -eq "Array") {
    $ComputerIP1 = $ComputerIP0 | Where { $_ -notlike "*:*"}
    #$ComputerIP2 = ($ComputerIP1 -Split(" "))  
    $ComputerIP = $ComputerIP1
    }else{
    $ComputerIP = $ComputerIP0
    }
$FQND = ([System.Net.Dns]::GetHostByName($computer)).Hostname
$FQND = $FQND.ToLower()
[array]$computerDoms = $computer.Split(".")
$ComputerDestination = "\\$FQND\C$"
$zabbixDestination = "\Zabbix"
$Zabbixroot = $ComputerDestination + $zabbixDestination
$ZabbixServiceState = $false
Write-Host "################################################################################"
Write-Host "#==============================================================================#"
Write-Host "# Start installation ... $FQND"
Write-Host "#==============================================================================#"
Write-Host "################################################################################"

# ===========================================================================================
# prepare Credential management
# ===========================================================================================	


if ($file) {
    $UserName1 = $PC[1]
    $Password1 = convertto-securestring $PC[2] -asplaintext -force 
    $cred = New-Object System.Management.Automation.PSCredential ( $UserName1 , $Password1 )
    }#end if ($file) 
else {

        If ($dom -contains $computerDoms[1] ) {$computerDom = $computerDoms[1]}
        else { $computerDom = $computerDoms[0]    }
        
        }
        $cred = Get-Credential  "$computerDom\Administrator" 
        
    }#end if ($file) else

Start-Sleep -Seconds 5

# ===========================================================================================
# Testing if Computer ist available
# ===========================================================================================	
If (Test-Connection $computer -quiet -count 1)	{
    # Server pings!
    Write-Host "================================================================================"
    Write-Host $computer "is available"
    Write-Host "================================================================================"
    # Verify if service is present...
    # Negative response may be caused by the absence of service (good!) or lack of priviledges (bad!)
    }#end If (Test-Connection $computer -quiet -count 1)
    else {
    Write-Host "================================================================================"
    Write-Host " SCRIPT FINISHED!"
    Write-Host " Unsuccessful installations: $Computer did not response"
    Write-Host "================================================================================"
    Write-Host " "
    Write-Host " Press any key!"
    $HOST.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown") | OUT-NULL
    $HOST.UI.RawUI.Flushinputbuffer()
    exit 0
    }#end If (Test-Connection $computer -quiet -count 1)else	
# ===========================================================================================
# Verifying if the destination folder exist 
# ===========================================================================================
    $TPA =  invoke-command {Test-Path -Path "HKLM:\System\CurrentControlSet\Services\Zabbix Agent"} -computer $computer -Credential $cred
    if ($TPA -eq $true) {
    $key = invoke-command {(Get-ItemProperty -Path "HKLM:\System\CurrentControlSet\Services\Zabbix Agent" -Name ImagePath).ImagePath} -computer $computer -Credential $cred
   #$key = (Get-ItemProperty -Path "HKLM:\System\CurrentControlSet\Services\Zabbix Agent" -Name ImagePath).ImagePath
    $keysplit = $key.Split( '--')
    [STRING]$keypfad = $keysplit[0]
    $keypfa = $keypfad.Replace('"', '')
    $Vers = invoke-command {[system.diagnostics.fileversioninfo]::GetVersionInfo($Using:keypfa)} -computer $computer -Credential $cred
    $laenge = ($Vers.ProductVersion).length
    $insta = ($Vers.ProductVersion).Substring(0,$laenge)
    Write-Host "================================================================================"
    Write-Host " Zabbix installation Version detected: $insta"
    Write-Host "================================================================================"
    }
    else { $insta = "1.0.0"}
    
    
    If ((($insta -eq $Version) -and ( $force -eq $true ))-or ($insta -ne $Version)){ 

    Write-Host "================================================================================"
    If (($insta -eq $Version) -and ( $force -eq $true )){
            Write-Host " Zabbix Installation does exist! Update initialized    "
            }
    elseif ($insta -ne $Version) {
            Write-Host " Zabbix Installation does not exist! Installation initialized   "
    }
    Write-Host "================================================================================"
    
    

# ===========================================================================================
# Start remotePS session 
# ===========================================================================================
$RemotePSSession = New-PSSession -Computername $computer -Credential $cred
# ===========================================================================================
# uninstall services remote
# ===========================================================================================
$Status = Invoke-Command -Session $RemotePSSession -ScriptBlock { 
If (get-service $Using:ZabbixService -ErrorAction SilentlyContinue) {
$Stat = get-service $Using:ZabbixService | where {$_.status -eq 'Running'}| Stop-Service
}
else {$Stat = "Service not exist"}
}# end 	Invoke-Command -Session $RemotePSSession
 
     Invoke-Command -Session $RemotePSSession -ScriptBlock {$h = Get-Service $Using:ZabbixService -ErrorAction SilentlyContinue}
    $Status = Invoke-Command -Session $RemotePSSession -ScriptBlock {($h).Status }

If (!($Status.Status -eq "Running"))	{
    # Server pings!
    Write-Host "================================================================================"
    Write-Host "The Service $ZabbixService is Stopped "
    Write-Host "================================================================================"
    # Verify if service is present...
    }#end If (!($Status.Status -eq "Running"))
    else {
    Write-Host "================================================================================"
    Write-Host " SCRIPT UNFINISHED!"
    Write-Host " Unsuccessful installations: $Computer  the $ZabbixService Service did not response"
    Write-Host "================================================================================"
    Write-Host " "
    Write-Host " Press any key!"
    $HOST.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown") | OUT-NULL
    $HOST.UI.RawUI.Flushinputbuffer()
    exit 0
    }#end If (!($Status.Status -eq "Running"))else	
    

# ===========================================================================================
# prepare to copy files
# ===========================================================================================		
$FDLE = [String]$FDL + ":\"
If (!( Test-Path $FDLE )){ 

        $LW = New-PSDrive -Name $FDL -PSProvider FileSystem -Root $ComputerDestination -Credential $cred -ErrorAction Stop	
        $LWE = [String]$LW + ':' 
         
        $zabbixDestinationPath = $LWE + "$zabbixDestination"
        }#end If ( Test-Path $FDLE )
        else {
        Write-Host "================================================================================"
        Write-Host " SCRIPT UNFINISHED!"
        Write-Host " Unsuccessful installations: $Computer  the copy missmatch"
        Write-Host "================================================================================"
        Write-Host " "
        Write-Host " Press any key!"
        $HOST.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown") | OUT-NULL
        $HOST.UI.RawUI.Flushinputbuffer()
        exit 0
        }
    

# ===========================================================================================
# Copy Zabbix Data to destination
# ===========================================================================================
        Write-Host "================================================================================"
        Write-Host " Copying folder start..."
        Write-Host "================================================================================"
        if (!(Test-Path "$zabbixDestinationPath\zabbix_script")){New-Item -Name zabbix_script -Path $zabbixDestinationPath -ItemType Directory } 
        Copy-Item -Recurse $ZabbixSource $zabbixDestinationPath -Force -ErrorAction Stop
        Copy-Item -Recurse "$ZabbixPath\zabbix_script\zabbix_fqdn.vbs" "$zabbixDestinationPath\zabbix_script\" -Force -ErrorAction Stop
        Copy-Item -Recurse "$ZabbixPath\zabbix_script\uninstall.bat" "$zabbixDestinationPath\zabbix_script\" -Force -ErrorAction Stop
        Copy-Item -Recurse "$ZabbixPath\zabbix_script\*.ps1" "$zabbixDestinationPath\zabbix_script\" -Force -ErrorAction Stop
        $UBLock = gci -Recurse $zabbixDestinationPath -Exclude *.log 
        Unblock-File $UBLock
# ===========================================================================================
# Conf personalisieren
# ===========================================================================================				
        $ConfFile = "$zabbixDestinationPath\$Version\conf\zabbix_agentd.win.conf"
        $hn = "Hostname=" + $FQND
        (Get-Content $ConfFile) | Foreach-Object {$_ -creplace "Hostname=", $hn} | Set-Content $ConfFile
# ===========================================================================================
# Config log
# ===========================================================================================	
        
        if (!(Test-Path "$zabbixDestinationPath\log")){New-Item -Name log -Path $zabbixDestinationPath -ItemType Directory } 
        if (Test-Path "$zabbixDestinationPath\log\VersConfig.conf"){remove-Item "$zabbixDestinationPath\log\VersConfig.conf" } 
        New-Item -Name "VersConfig.conf" -Path "$zabbixDestinationPath\log" -ItemType file -Value "ZabbixVersion:$Version"

        Write-Host "================================================================================"
        Write-Host " Folder successfully copied!"		# No catch triggered, so far so good...
        Write-Host "================================================================================"
# ===========================================================================================
# Check OS version 
# ===========================================================================================			
    #################################################################################################################################
    # At this point, the service state has been determined and the folder has been copied to, rights should not be an issue...
    # Let's install...
    #################################################################################################################################
    
    ### Get architecture x86 or x64...
    
    try
    {
    $os = Get-WMIObject -Class win32_operatingsystem -ComputerName $computer -Credential $cred -ErrorAction Stop
    }
    catch
    {
        Write-Host "================================================================================"
        Write-Host " $computer - Zabbix agent could not be installed!"
        Write-Host " -- Make sure you have administrative rights!"
        Write-Host " -- Make sure no firewall is blocking communications!"
        Write-Host " Error!" $_
        Write-Host "================================================================================"
        $instBad += $computer + " "
        continue
    }
    if($os.OSArchitecture -ne $null)		{
        # Architecture can be determined by $os.OSArchitecture...
        if ($os.OSArchitecture -eq "64-bit")			{
            Write-Host " 64bit system detected!"
            $osArch = "win64"
        }
        elseif($os.OSArchitecture -eq "32-bit")			{
            Write-Host " 32bit system detected!"
            $osArch = "win32"
        }
        else			{
            Write-Host "================================================================================"
            Write-Host " Unknown architecture! Operation Canceled..."
            Write-Host $osArch
            Write-Host "================================================================================"
            $instBad += $computer + " "
            continue
        }
    }
    else		{
        Write-Host " Windows Pre-2008"
        # Here have to analyze $os.Caption to determine architecture...
        if($os.Caption  -match "x64")			{
            Write-Host " 64bit system detected!"
            $osArch = "win64"
        }
        else			{
            Write-Host " 32bit system detected!"
            $osArch = "win32"
        }
    }
    ### Architecture detection ended.
# ===========================================================================================
# Uninstall Zabbix
# ===========================================================================================
    ### Begin installation...
    try	{
        # Create uninstall string
         $rootKey = 'HKLM:\SYSTEM\CurrentControlSet\Services\Zabbix Agent'

        $RegKeyString = Invoke-Command -Session $RemotePSSession -ScriptBlock {
            $reg = Get-ItemProperty $Using:rootKey -ErrorAction SilentlyContinue
            ($reg).DisplayName
        }
                                      
        if ($RegKeyString -eq $ZabbixService){
            Write-Host "================================================================================"
            Write-Host " Create uninstall string..."
            Write-Host "================================================================================"
                
                $TESTFILE = Test-Path ("$Zabbixroot\zabbix_agentd.exe") -ErrorAction SilentlyContinue
                If ($TESTFILE -eq $true) 	{
                $exec = "c:\zabbix\zabbix_agentd.exe -c c:\zabbix\zabbix_agentd.win.conf -d"
                   }
                else {
                $exec = "c:\zabbix\$Version\bin\$osArch\zabbix_agentd.exe -c c:\zabbix\$Version\conf\zabbix_agentd.win.conf -d"
                }
        # Execute uninstall string
        Write-Host "================================================================================"
        Write-Host " Execute uninstall string..."
        Write-Host "================================================================================"
        $remoteWMI = Run-RemoteCMD -command $exec -Credential $cred -HostName $computer
        Start-Sleep -Second 5 
        if (!($remoteWMI -eq 0))   {
            # Oops...
            Write-Host "================================================================================"
            Write-Host " Problem while uninstalling previous zabbix agent! Cancelling..."
            Write-Host " Error:" $remoteWMI
            Write-Host " 0 Successful Completion"
            Write-Host " 3 Insufficient Privilege"
            Write-Host " 8 Unknown Failure"
            Write-Host " 9 Path Not Found"
            Write-Host " 21 Invalid Parameter"
            Write-Host "================================================================================"
            $instBad += $computer + " "
                }
        else{
            
            Write-Host " Zabbix is uninstalled ..."
               Write-Host "================================================================================"
                     }
        Write-Host "================================================================================"
        Write-Host " Delete last old Files..."
        Write-Host "================================================================================"
        
        Invoke-Command -Session $RemotePSSession -ScriptBlock {Get-ChildItem 'C:\Zabbix' -Exclude *.bat ,*.ps1, *.vbs  -Force | where {$_.Attributes -notmatch 'Directory'} | Remove-Item -Force}
        
            }
    }
    catch{
        Write-Host "================================================================================"
        Write-Host " Problem while uninstalling previous zabbix agent! Cancelling..."
        Write-Host $_
        Write-Host "================================================================================"
        $instBad += $computer + " "
        continue
    }
# ===========================================================================================
# Install Zabbix
# ===========================================================================================
        try		{
        # Create install string
        Write-Host "================================================================================"
        Write-Host " Create install string..."
        Write-Host "================================================================================"
        #$UBLock = gci -Recurse $zabbixDestinationPath -Exclude *.log 
        #Unblock-File $UBLock
        $exec = "c:\zabbix\$Version\bin\$osArch\zabbix_agentd.exe -c c:\zabbix\$Version\conf\zabbix_agentd.win.conf -i"
        # Execute install string
        Write-Host "================================================================================"
        Write-Host " Execute install string..."
        Write-Host "================================================================================"
        $remoteWMI = Run-RemoteCMD -command $exec -Credential $cred -HostName $computer
        Start-Sleep -Second 5
            if (!($remoteWMI -eq 0))			{
            # Oops...
            Write-Host "================================================================================"
            Write-Host " Problem while installing new agent! Cancelling..."
            Write-Host " Error: " $remoteWMI
            Write-Host " 0 Successful Completion"
            Write-Host " 3 Insufficient Privilege"
            Write-Host " 8 Unknown Failure"
            Write-Host " 9 Path Not Found"
            Write-Host " 21 Invalid Parameter"
            Write-Host "================================================================================"
            $instBad += $computer + " "
            continue
        }
    }
    catch
    {
        Write-Host "================================================================================"
        Write-Host " Problem while installing new agent! Cancelling..."
        Write-Host $_
        Write-Host "================================================================================"
        $instBad += $computer + " "
        continue
    }
# ===========================================================================================
# Open Firewall ports in local Firewall
# ===========================================================================================
    try		{
        # Open Firewall port
        $FwRule1 = "close"
        $FwRule2 = "close"
        $text = "open"
        if($os.OSArchitecture -ne $null){
        #$FWinfo = Invoke-Command -Computername pops.UVW.meduniwien.ac.at -Credential UVW\Administrator -ScriptBlock ${function:CheckOpenPort} -ArgumentList 10051
        $FwRule1 = Invoke-Command -Session $RemotePSSession -ScriptBlock ${function:CheckOpenPort} -argumentlist 10050
        $FwRule2 = Invoke-Command -Session $RemotePSSession -ScriptBlock ${function:CheckOpenPort} -argumentlist 10051
        }else {
        $FWw2k3 = Invoke-Command -Session $RemotePSSession -ScriptBlock {netsh firewall show portopening}
        $FWw2k350 = $FWw2k3 -match 10050
        $FWw2k351 = $FWw2k3 -match 10051
        if ($FWw2k350 -ne "") {$FwRule1 = "open"}
        if ($FWw2k351 -ne "") {$FwRule2 = "open"}
        }

if (!($FwRule1 -contains $text))   { 
        Write-Host "================================================================================"
        Write-Host " Opening Firewall Port 10050..."
        Write-Host "================================================================================"
    if($os.OSArchitecture -ne $null){
        $remoteWMI1 = Invoke-Command -Session $RemotePSSession -ScriptBlock {netsh advfirewall firewall add rule name=10050in dir=in action=allow enable=yes profile=any localport=10050 protocol=tcp}
    }else {
        $remoteWMI1 = Invoke-Command -Session $RemotePSSession -ScriptBlock {netsh firewall add portopening protocol = TCP port = 10050 name = 10050TCP}
    }
        Start-Sleep -Second 5		
        If (!($remoteWMI1 -match "Ok.")) {$remoteWMI50 = 8}
        else {$remoteWMI50 = 0}}
else {
        Write-Host "================================================================================"
        Write-Host " Firewall Port 10050 is open"
        Write-Host "================================================================================"
        $remoteWMI50 = 0}

if (!($FwRule2 -contains $text)) {
        Write-Host "================================================================================"
        Write-Host " Opening Firewall Port 10051..."
        Write-Host "================================================================================"
    if($os.OSArchitecture -ne $null){
        $remoteWMI2 = Invoke-Command -Session $RemotePSSession -ScriptBlock {netsh advfirewall firewall add rule name=10051out dir=out action=allow enable=yes profile=any localport=10051 protocol=tcp}
    }else {
        $remoteWMI2 = Invoke-Command -Session $RemotePSSession -ScriptBlock {netsh firewall add portopening protocol = TCP port = 10051 name = 10051TCP}
    }
        
        
        
        
        Start-Sleep -Second 5
        If (!($remoteWMI2 -match "Ok.")) {$remoteWMI51 = 8}
        else {$remoteWMI51 = 0}}


else {
        Write-Host "================================================================================"
        Write-Host " Firewall Port 10051 is open"
        Write-Host "================================================================================"
        $remoteWMI51 = 0}
if (!($remoteWMI50 -eq 0)-and (!($remoteWMI51 -eq 0)))	{$remoteWMI = 8}
else {$remoteWMI = 0}
            if (!($remoteWMI -eq 0))			{
            # Problems...
            Write-Host "================================================================================"
            Write-Host " Problem while opening the Firewall Ports! Cancelling..."
            Write-Host " Error: " $remoteWMI
            Write-Host " 0 Successful Completion"
            Write-Host " 3 Insufficient Privilege"
            Write-Host " 8 Unknown Failure"
            Write-Host " 9 Path Not Found"
            Write-Host " 21 Invalid Parameter"
            Write-Host "================================================================================"
            $instBad += $computer + " "
            continue
        }
    }
    catch		{
        Write-Host "================================================================================"
        Write-Host " Problem while opening FirewallPorts! Cancelling..."
        Write-Host $_
        Write-Host "================================================================================"
        $instBad += $computer + " "
        continue
    }
    ### Installation end...
# ===========================================================================================
# Start Zabbix Agent
# ===========================================================================================
    try		{
        # Create run string
        Write-Host "================================================================================"
        Write-Host " Create run string..."
        Write-Host "================================================================================"
            $exec = "c:\zabbix\$Version\bin\$osArch\zabbix_agentd.exe -c c:\zabbix\$Version\conf\zabbix_agentd.win.conf -s"
        # Execute run string
        Write-Host " Execute run string..."
        $remoteWMI = Run-RemoteCMD -command $exec -Credential $cred -HostName $computer
        Start-Sleep -Second 5
            if (!($remoteWMI -eq 0))			{
            # Problems...
            Write-Host "================================================================================"
            Write-Host " Problem while starting the agent! Cancelling..."
            Write-Host " Error: " $remoteWMI
            Write-Host " 0 Successful Completion"
            Write-Host " 3 Insufficient Privilege"
            Write-Host " 8 Unknown Failure"
            Write-Host " 9 Path Not Found"
            Write-Host " 21 Invalid Parameter"
            Write-Host "================================================================================"
            $instBad += $computer + " "
            continue
        }
    }
    catch		{
        Write-Host "================================================================================"
        Write-Host " Problem while starting the agent! Cancelling..."
        Write-Host $_
        Write-Host "================================================================================"
        $instBad += $computer + " "
        continue
    }
    ### Installation end...
# ===========================================================================================
# verify Zabbix installation
# ===========================================================================================

    ### Start verification
    try		{
        $InstallStatus = Invoke-Command -Session $RemotePSSession -ScriptBlock {Get-Service $Using:ZabbixService -ErrorAction SilentlyContinue}
    }
    catch		{
        Write-Host "================================================================================"
        Write-Host " Problem while verifying service!"
        Write-Host " Error! " $_
        Write-Host "================================================================================"
        $instBad += $computer + " "
        continue
    }
    if ($InstallStatus.Status -eq "Running")		{
        Write-Host "================================================================================"
        Write-Host " Service installed and started!"
        Write-Host "================================================================================"
    }
    else		{
        Write-Host "================================================================================"
        Write-Host " Service installed but not started!"
        Write-Host " Service state: " $InstallStatus.Status
        Write-Host "================================================================================"
    }
    $instOk += $computer + " "
    [String]$LWB = $LW
    $LW1 = $LWB +':\'
    If (Test-Path $LW1) {Remove-PSDrive $LW1 -Force -ErrorAction SilentlyContinue}
    Net use * /delete /y
    Remove-PSSession -Session $RemotePSSession

# Next server
$instOk += $computer + " "
    Continue
    
    }	# end if(!(Test-Path $Zabbixdestination))
    else {
            Write-Host " "
    Write-Host "#####################################################"
    Write-Host "# Zabbix Destination Folder does exist! continued   #"
    Write-Host "#####################################################"
    Write-Host " "
$instOk += $computer + " "
continue
}
    
}#end foreach($PCs in $arrPCliste)}

    

Write-Host "================================================================================"
Write-Host " SCRIPT FINISHED!"
Write-Host " Successful installations: " $instOk
Write-Host " Unsuccessful installations: " $instBad
Write-Host "================================================================================"
Write-Host " "
Write-Host " Press any key!"
$HOST.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown") | OUT-NULL
$HOST.UI.RawUI.Flushinputbuffer()
exit 0	
    
