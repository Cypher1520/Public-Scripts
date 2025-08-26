#------------------------------------------------------------------------------
#
# Copyright © 2013 Microsoft Corporation.  All rights reserved.
#
# THIS CODE AND ANY ASSOCIATED INFORMATION ARE PROVIDED “AS IS” WITHOUT
# WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT
# LIMITED TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS
# FOR A PARTICULAR PURPOSE. THE ENTIRE RISK OF USE, INABILITY TO USE, OR 
# RESULTS FROM THE USE OF THIS CODE REMAINS WITH THE USER.
#
#------------------------------------------------------------------------------
#
# PowerShell Source Code
#
# NAME:
#    O365-Fed-MetaData-Update-Task-Installation.ps1
#
# VERSION:
#    1.3
#
#------------------------------------------------------------------------------

$ErrorActionPreference = "silentlycontinue"
$StartDate = Get-Date
Write-Host "`n Microsoft Office 365 Federation Metadata Update Automation Installation Tool" -ForegroundColor Yellow
Write-Host "`n`n Items required to execute this tool successfully:"
Write-Host "`t1. Functioning AD FS 2.0 Federation Service"
Write-Host "`t2. Access to Global Administrator credentials for your Office 365 tenant (referred to as 'MSOL credentials')"
Write-Host "`t3. At least one verified domain in the Office 365 tenant must be of type 'Federated'"
Write-Host "`t4. This tool must be executed directly on a internal, writable Federation Server"
Write-Host "`t5. The local administrator domain credentials you provide must equal the currently logged on user"
Write-Host "`t6. The Windows Azure Active Directory Module for Windows PowerShell must be installed on the AD FS server"

#Check to make sure this is an AD FS server
$IsADFS = Get-Service ADFSSRV
If (!$IsADFS)
{
	Write-Host "`n`tThe AD FS 2.0 Windows service was not found on this machine. Exiting...`n" -ForegroundColor Red
	Exit
}

#CredMan stuff
$sig = @"
[DllImport("Advapi32.dll", SetLastError=true, EntryPoint="CredWriteW", CharSet=CharSet.Unicode)]
public static extern bool CredWrite([In] ref Credential userCredential, [In] UInt32 flags);
[StructLayout(LayoutKind.Sequential, CharSet=CharSet.Unicode)]
public struct Credential
{
   public UInt32 flags;
   public UInt32 type;
   public IntPtr targetName;
   public IntPtr comment;
   public System.Runtime.InteropServices.ComTypes.FILETIME lastWritten;
   public UInt32 credentialBlobSize;
   public IntPtr credentialBlob;
   public UInt32 persist;
   public UInt32 attributeCount;
   public IntPtr Attributes;
   public IntPtr targetAlias;
   public IntPtr userName;
}
"@
Add-Type -MemberDefinition $sig -Namespace "ADVAPI32" -Name 'Util'
$cred = New-Object ADVAPI32.Util+Credential
$cred.flags = 0
$cred.type = 1

#Get Federated domain - deprecated feature
#While (!$FederatedDomain) {$FederatedDomain = (Read-Host "`n Federated domain (contoso.com)").ToUpper()}
#While (!$ConfirmFederatedDomain) {$ConfirmFederatedDomain = (Read-Host "`n Confirm federated domain (contoso.com)").ToUpper()}
#If ($FederatedDomain -ne $ConfirmFederatedDomain)
#{
	#Write-Host "`n`tFederated domains do not match. Exiting...`n" -ForegroundColor Red
	#Exit
#}

#Get MSOL creds
While (!$UserName) {$UserName = (Read-Host "`n MSOL username (user`@domain)").ToUpper()}

#Set the name of the CredMan credentials
$TargetName = "Microsoft-Office365-Update-MSOLFederatedDomain"
$cred.targetName = [System.Runtime.InteropServices.Marshal]::StringToCoTaskMemUni($TargetName)
$cred.userName = [System.Runtime.InteropServices.Marshal]::StringToCoTaskMemUni($UserName)
$cred.attributeCount = 0
$cred.persist = 2
While (!$Password) {$Password = Read-Host -assecurestring "`n MSOL password"}
$objCreds = New-Object Management.Automation.PSCredential $UserName, $Password
$Password = $objCreds.GetNetworkCredential().Password

#Validating MSOL creds
Write-Host "`n Validating MSOL credentials"
Import-Module MSOnline
Connect-MsolService -Credential $objCreds
If ($?)
{
	Write-Host "`n`tSuccess"  -ForegroundColor Green
}
Else
{
	Write-Host "`n`tFailed MSOL credential validation. Exiting...`n" -ForegroundColor Red
	Exit
}


$cred.credentialBlobSize = [System.Text.Encoding]::Unicode.GetBytes($Password).length
$cred.credentialBlob = [System.Runtime.InteropServices.Marshal]::StringToCoTaskMemUni($Password)

#Store the MSOL creds in CredMan
$CredWrite = [ADVAPI32.Util]::CredWrite([ref]$cred,0)
If ($CredWrite)
{
	Write-Host "`n`tAdded MSOL credentials to the local Credential Manager" -ForegroundColor Green
}
Else
{
	Write-Host "`n`tFailed adding MSOL credentials to the local Credential Manager. Exiting...`n" -ForegroundColor Red
	Exit
}

#Get local admin creds
$LocalUserName = (WhoAmI.exe).ToUpper()
While (!$LocalPassword) {$LocalPassword = Read-Host -assecurestring "`n $LocalUserName password"}
$objCreds = New-Object Management.Automation.PSCredential $LocalUserName, $LocalPassword
$LocalPassword = $objCreds.GetNetworkCredential().Password

# Validating domain credentials
Write-Host "`n Validating local admin domain credentials"
$Domain = "LDAP://" + ([ADSI]"").distinguishedName
$DomainObject = New-Object System.DirectoryServices.DirectoryEntry($Domain,$LocalUserName,$LocalPassword)
`$DomainObject.Name = `$DomainObject.Name
If ($DomainObject.Name -eq $null)
{
	Write-Host "`n`tFailed local admin domain credential validation. Exiting...`n" -ForegroundColor Red
	Exit
}
Else
{
	Write-Host "`n`tSuccess" -ForegroundColor Green
}

#Create the script file using their federated domain name
Write-Host "`n Writing Power Shell script to C:\Office365-Scripts\"
If (!(Test-Path "C:\Office365-Scripts")) { New-Item "C:\Office365-Scripts" -type directory | Out-Null }
$ScriptPath = "C:\Office365-Scripts\Microsoft-Office365-Update-MSOLFederatedDomain"+".ps1"
If (!(Test-Path $ScriptPath)) { New-Item $ScriptPath -type file | Out-Null }
If (!(Test-Path "C:\Office365-Scripts"))
{
	Write-Host "`n`tFailed creating C:\Office365-Scripts\ directory. Exiting...`n" -ForegroundColor Red
	Exit
}
If (!(Test-Path $ScriptPath))
{
	Write-Host "`n`tFailed creating $ScriptPath file. Exiting...`n" -ForegroundColor Red
	Exit
}

$LogPath = "C:\Office365-Scripts\History.log"
"#################################################################" | Out-File $LogPath -Append
"$StartDate INSTALLATION" | Out-File $LogPath -Append
"   -MSOL Username:    $UserName" | Out-File $LogPath -Append
"   -Logged on user:   $LocalUserName" | Out-File $LogPath -Append
"#################################################################" | Out-File $LogPath -Append


#Script file contents
$ScriptContents = @"
`$ErrorActionPreference `= `"silentlycontinue`"
`$sig `= `@`"
`[StructLayout`(LayoutKind.Sequential, CharSet `= CharSet.Unicode)`]
public struct NativeCredential
`{
    public UInt32 Flags`;
    public CRED_TYPE Type`;
    public IntPtr TargetName`;
    public IntPtr Comment`;
    public System.Runtime.InteropServices.ComTypes.FILETIME LastWritten`;
    public UInt32 CredentialBlobSize`;
    public IntPtr CredentialBlob`;
    public UInt32 Persist`;
    public UInt32 AttributeCount`;
    public IntPtr Attributes`;
    public IntPtr TargetAlias`;
    public IntPtr UserName`;
    internal static NativeCredential GetNativeCredential`(Credential cred`)
    `{
        NativeCredential ncred `= new NativeCredential`(`)`;
        ncred.AttributeCount `= 0`;
        ncred.Attributes `= IntPtr.Zero`;
        ncred.Comment `= IntPtr.Zero`;
        ncred.TargetAlias `= IntPtr.Zero`;
        ncred.Type `= CRED_TYPE.GENERIC`;
        ncred.Persist `= (UInt32)1`;
        ncred.CredentialBlobSize `= `(UInt32`)cred.CredentialBlobSize`;
        ncred.TargetName `= Marshal.StringToCoTaskMemUni`(cred.TargetName`)`;
        ncred.CredentialBlob `= Marshal.StringToCoTaskMemUni`(cred.CredentialBlob`)`;
        ncred.UserName `= Marshal.StringToCoTaskMemUni`(System.Environment.UserName`)`;
        return ncred`;
    `}
`}
`[StructLayout`(LayoutKind.Sequential, CharSet `= CharSet.Unicode`)`]
public struct Credential
`{
    public UInt32 Flags`;
    public CRED_TYPE Type`;
    public string TargetName`;
    public string Comment`;
    public System.Runtime.InteropServices.ComTypes.FILETIME LastWritten`;
    public UInt32 CredentialBlobSize`;
    public string CredentialBlob`;
    public UInt32 Persist`;
    public UInt32 AttributeCount`;
    public IntPtr Attributes`;
    public string TargetAlias`;
    public string UserName`;
`}
public enum CRED_TYPE `: uint
    `{
        GENERIC `= 1,
        DOMAIN_PASSWORD `= 2,
        DOMAIN_CERTIFICATE `= 3,
        DOMAIN_VISIBLE_PASSWORD `= 4,
        GENERIC_CERTIFICATE `= 5,
        DOMAIN_EXTENDED `= 6,
        MAXIMUM `= 7,      `/`/ Maximum supported cred type
        MAXIMUM_EX `= `(MAXIMUM `+ 1000`),  `/`/ Allow new applications to run on old OSes
    `}
public class CriticalCredentialHandle `: Microsoft.Win32.SafeHandles.CriticalHandleZeroOrMinusOneIsInvalid
`{
    public CriticalCredentialHandle`(IntPtr preexistingHandle`)
    `{
        SetHandle`(preexistingHandle`)`;
    `}
    public Credential GetCredential`(`)
    `{
        if `(`!IsInvalid`)
        `{
            NativeCredential ncred `= `(NativeCredential`)Marshal.PtrToStructure`(handle,
                  typeof`(NativeCredential`)`)`;
            Credential cred `= new Credential`(`)`;
            cred.CredentialBlobSize `= ncred.CredentialBlobSize`;
            cred.CredentialBlob `= Marshal.PtrToStringUni`(ncred.CredentialBlob,
                  `(int`)ncred.CredentialBlobSize `/ 2)`;
            cred.UserName `= Marshal.PtrToStringUni`(ncred.UserName`)`;
            cred.TargetName `= Marshal.PtrToStringUni`(ncred.TargetName``);
            cred.TargetAlias `= Marshal.PtrToStringUni`(ncred.TargetAlias`)`;
            cred.Type `= ncred.Type`;
            cred.Flags `= ncred.Flags`;
            cred.Persist `= ncred.Persist`;
            return cred`;
        `}
        else
        `{
            throw new InvalidOperationException`(`"Invalid CriticalHandle`!`"`)`;
        `}
    `}
    override protected bool ReleaseHandle`(`)
    `{
        if `(`!IsInvalid`)
        `{
            CredFree`(handle`)`;
            SetHandleAsInvalid`(`)`;
            return true`;
        `}
        return false`;
    `}
`}
`[DllImport`(`"Advapi32.dll`", EntryPoint `= `"CredReadW`", CharSet `= CharSet.Unicode, SetLastError `= true`)`]
public static extern bool CredRead`(string target, CRED_TYPE type, int reservedFlag, out IntPtr CredentialPtr`)`;
`[DllImport`(`"Advapi32.dll`", EntryPoint `= `"CredFree`", SetLastError `= true`)`]
public static extern bool CredFree`(`[In`] IntPtr cred`)`;
`"`@
Add-Type -MemberDefinition `$sig -Namespace `"ADVAPI32`" -Name `'Util`'
`$targetName `= `"Microsoft-Office365-Update-MSOLFederatedDomain`"
`$nCredPtr`= New-Object IntPtr
`$success `= `[ADVAPI32.Util`]`:`:CredRead`(`$targetName,1,0,`[ref`] `$nCredPtr`)
if`(`$success`)`{
    `$critCred `= New-Object ADVAPI32.Util`+CriticalCredentialHandle `$nCredPtr
    `$cred `= `$critCred.GetCredential`(`)
	`$UserName `= `$cred.UserName`;
    `$Password `= `$cred.CredentialBlob`;
	`$Password `= ConvertTo-SecureString -String `$Password -AsPlainText -Force
	`$objCreds `= New-Object Management.Automation.PSCredential `$UserName, `$Password
`}

`$LogFile `= `"`$pwd`\History.log`"
`"#################################################################`" `| Out-File `$LogFile -Append
Get-Date `| Out-File `$LogFile -Append

`#Validating MSOL creds
Import-Module MSOnline
Connect-MsolService -Credential `$objCreds
`[array`] `$FedDoms `= Get-MsolDomain -Authentication Federated -Status Verified

ForEach `(`$Domain in `$FedDoms`)
`{
	`$FedDom `= `$Domain.Name
	`"#################################################################`" `| Out-File `$LogFile -Append
	`$FedDom.ToUpper`(`) `| Out-File `$LogFile -Append
	Get-MSOLFederationProperty -DomainName `$FedDom `| Out-File `$LogFile -Append
	`#Execute the MSOL work
	Try
	`{
		`"Attempting to update metadata for `$FedDom without SupportMultipleDomain`" `| Out-File `$LogFile -Append
		Update-MSOLFederatedDomain -DomainName `$FedDom -EA Stop 2`>`&1 `| foreach-object `{`$`_.ToString`(`)`} `| Out-File `$LogFile -Append
	`}
	Catch `[Exception`]
	`{
		`$`_.Exception.Message `| Out-File `$LogFile -Append
		`$SMDRequired `= `$true
	`}

	If `(`$SMDRequired`)
	`{
		Try
		`{
			`"Attempting to update metadata for `$FedDom with SupportMultipleDomain`" `| Out-File `$LogFile -Append
			Update-MSOLFederatedDomain -DomainName `$FedDom -SupportMultipleDomain -EA Stop 2`>`&1 `| foreach-object `{`$`_.ToString`(`)`} `| Out-File `$LogFile -Append
		`}
		Catch `[Exception`]
		`{
			`$_.Exception.Message `| Out-File `$LogFile -Append
		`}
	`}
`}
"@
$ScriptContents | Out-File $ScriptPath
Write-Host "`n`tCreated stored script file used by Task Scheduler" -ForegroundColor Green

#Create the scheduled task
$TaskXML = @"
<?xml version="1.0" encoding="UTF-16"?>
<Task version="1.2" xmlns="http://schemas.microsoft.com/windows/2004/02/mit/task">
  <RegistrationInfo>
    <Date>2012-02-02T14:48:49.0352312</Date>
    <Author>Microsoft</Author>
    <Description>This task executes Update-MSOLFederatedDomain -DomainName FederatedDomainName</Description>
  </RegistrationInfo>
  <Triggers>
    <CalendarTrigger>
      <StartBoundary>2012-02-02T00:00:00</StartBoundary>
      <Enabled>true</Enabled>
      <ScheduleByDay>
        <DaysInterval>1</DaysInterval>
      </ScheduleByDay>
    </CalendarTrigger>
  </Triggers>
  <Principals>
   <Principal id="Author">
    <UserId>$LocalUserName</UserId> 
    <LogonType>Password</LogonType> 
    <RunLevel>HighestAvailable</RunLevel> 
   </Principal>
  </Principals>
  <Settings>
    <MultipleInstancesPolicy>IgnoreNew</MultipleInstancesPolicy>
    <DisallowStartIfOnBatteries>true</DisallowStartIfOnBatteries>
    <StopIfGoingOnBatteries>true</StopIfGoingOnBatteries>
    <AllowHardTerminate>true</AllowHardTerminate>
    <StartWhenAvailable>true</StartWhenAvailable>
    <RunOnlyIfNetworkAvailable>false</RunOnlyIfNetworkAvailable>
    <IdleSettings>
      <StopOnIdleEnd>true</StopOnIdleEnd>
      <RestartOnIdle>false</RestartOnIdle>
    </IdleSettings>
    <AllowStartOnDemand>true</AllowStartOnDemand>
    <Enabled>true</Enabled>
    <Hidden>false</Hidden>
    <RunOnlyIfIdle>false</RunOnlyIfIdle>
    <WakeToRun>false</WakeToRun>
    <ExecutionTimeLimit>PT1H</ExecutionTimeLimit>
    <Priority>7</Priority>
  </Settings>
  <Actions Context="Author">
    <Exec>
      <Command>C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe</Command>
	  <Arguments>-command C:\Office365-Scripts\Microsoft-Office365-Update-MSOLFederatedDomain.ps1</Arguments>
	  <WorkingDirectory>C:\Office365-Scripts</WorkingDirectory>
    </Exec>
  </Actions>
</Task>
"@

Write-Host "`n Creating task in Task Scheduler"
$ST = new-object -com("Schedule.Service")
$ST.connect("localhost")
$RootFolder = $ST.getfolder("\")
$TaskDef = $ST.NewTask(0)
$TaskDef.XmlText = $TaskXML
$CreateTask = $Rootfolder.RegisterTaskDefinition("Microsoft-Office365-Update-MSOLFederatedDomain", $TaskDef, 6, $LocalUserName, $LocalPassword, 1, $null)
If ($CreateTask)
{
	Write-Host "`n`tCreated daily scheduled task 'Microsoft-Office365-Update-MSOLFederatedDomain'`n" -ForegroundColor Green
}
Else
{
	Write-Host "`n`tFailed creating task 'Microsoft-Office365-Update-MSOLFederatedDomain'`n" -ForegroundColor Red
}

#Clean up cred vars
$UserName=$null
$Password=$null
$LocalUserName=$null
$LocalPassword=$null
$objCreds=$null