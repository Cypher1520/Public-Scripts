<#
---------------------------------
Get the App IDS
By Garth Williams
Insight Canada
---------------------------------
1) open the c:\programdata\microsoft\intunemanagementextensions\logs\intunemanagementextension.log file
1a) c:\programdata is a hidden folder
1b) I suggest using CMTrace from the SCCM Client Utilities
2) Get (copy) the name name of the program you have in the Apps blade of MEM (Apps/Windows)
3) search (paste) for that name in the file you opened in 1)
4) the appid will be on the left or the right of th program name as it appears in many places.
5) replace the app id and the app name in the list below anad SAVE (don't forget to check for proper ' wrapping)
6) save
7) edit "apdiags-custname.cmd"
8) change the reference to apdiags-custname.ps1 to the proper name
9) When the ESP is displayed, press Shift-F10 (you might need to wait a minute for it to appear)
10) You might want to hit Shift-F10 again just in case (the system gets busy)
11) Go to the drive letter this script is on (usinally d:)
12) type apdiags-custname (hit enter)
13) apdiags-custname.cmd will launch apdiags-custname.ps1 and display MEM app install status


---------------------------------
In other news ...
To get the install GUID of a program on a system ...
---------------------------------
1) Open an Admin command prompt
2) Type "powershell" (no quotes) in the window
3) In the powershell window, paste below:
"get-wmiobject Win32_Product | Sort-Object -Property Name | Format-Table IdentifyingNumber, Name, LocalPackage -AutoSize" (no quotes)
4) You will see a list displayed
5) The install GUID is the IdentifyingNumber
6) To uninstall that app type msiexec.exe /x {App ID} from an admin command prompt
---------------------------------
HAVE GOOD DAY
---------------------------------
#>

$GuidApp = @{
    # --------------------------------------------------------------------------------------
    # Common Win32 apps (App IDs show in IntuneManagementExtension.log)
    # --------------------------------------------------------------------------------------
    '025fceaa-d36a-4926-815d-638e50904cf1' = 'AP-SR-00-Apply all Windows updates'
    '0069ec58-86c1-4e84-9ca5-5b0e7c0915be' = 'AP-SR-01-Rapid7 Insight Agent'
    '14a11721-fb03-467d-be06-dc816adfd611' = 'AP-SR-02-AdoptOpenJDK JDK with Hotspot'
    '17f479a1-add2-4de8-b0b7-b596aac55ffb' = 'AP-SR-03-CrowdStrike'
    '0a4435b7-c54a-4b63-92a1-2e34ca2a8859' = 'AP-SR-03-SentinelOne-CA'
    '744d2ff9-25a0-45d3-949f-76e8cd46bea1' = 'AP-SR-04-Equisoft Help Menu V2'
    'a2fd9f1c-b34d-4931-8693-26f655c9b899' = 'AP-SR-05-7-Zip 23.01-x64'
    'c7000bcb-06c4-4c2c-bfcc-dabada5e3209' = 'AP-SR-06-Team Viewer Host'
    '4747bf5c-0ead-472d-9791-8aed5d5efd72' = 'AP-SR-xx-Google Chrome'
    '4d393467-eac7-4750-924e-db6cce0a36ee' = 'AP-SR-xx-Equisoft Branding'
    '2a6b7b9d-439e-49c3-9b8c-23d14139c655' = 'AP-SR-xx-Palo Alto Global Protect'
 
    # --------------------------------------------------------------------------------------
    # Common new MS Store apps (App IDs still show in IntuneManagementExtension.log)
    # --------------------------------------------------------------------------------------
    '16b44745-e3c2-47de-b478-9263d813fe63' = 'AP-SR-Adobe Acrobat Reader'
    '200519d0-3aa7-447a-ad92-e9253b2b4cb1' = 'AP-UR-Slack'
    '47088858-7637-42e8-b5f1-2ee44f84853f' = 'AP-UR-Company Portal New'
 
    # --------------------------------------------------------------------------------------
    # Developer Win32 apps (App IDs still show in IntuneManagementExtension.log)
    # --------------------------------------------------------------------------------------
    '5322a418-3e19-4ff0-ae6a-6a8f1d270c7d' = 'SQL Server Management Studio'
    '9de93b92-18cd-4089-8b8a-cd37faec7733' = 'NotePad Plus Plus v8.5.5 x64'
    'cb114876-313d-433a-aebd-28f84a4f65c4' = 'Git-2.41.0.2-64-bit'
    '159b67e2-9c85-4861-a62c-46dfbafe831e' = 'Putty'
 
}


<#PSScriptInfo

.VERSION 5.6

.GUID 06025137-9010-4807-bd22-53464539dfa3

.AUTHOR Michael Niehaus

. https://oofhours.com/2020/07/12/windows-autopilot-diagnostics-digging-deeper/

.COMPANYNAME Microsoft

.COPYRIGHT 

.TAGS Windows AutoPilot

.LICENSEURI 

.PROJECTURI 

.ICONURI 

.EXTERNALMODULEDEPENDENCIES 

.REQUIREDSCRIPTS 

.EXTERNALSCRIPTDEPENDENCIES 

.RELEASENOTES
Version 5.6:  Fixed parameter handling
Version 5.5:  Added support for a zip file
Version 5.4:  Added additional ESP details
Version 5.3:  Added hardware and OS version details
Version 5.2:  Added device registration events
Version 5.1:  Bug fixes
Version 5.0:  Bug fixes
Version 4.9:  Bug fixes
Version 4.8:  Added Delivery Optimization results (but not when using a CAB file), ensured events are displayed even when no ESP
Version 4.7:  Added ESP settings, fixed bugs
Version 4.6:  Fixed typo
Version 4.5:  Fixed but to properly reported Win32 app status when a Win32 app is installed during user ESP
Version 4.4:  Added more ODJ info
Version 4.3:  Added policy tracking
Version 4.2:  Bug fixes for Windows 10 2004 (event ID changes)
Version 4.1:  Renamed to Get-AutopilotDiagnostics
Version 4.0:  Added sidecar installation info
Version 3.9:  Bug fixes
Version 3.8:  Bug fixes
Version 3.7:  Modified Office logic to ensure it accurately reflected what ESP thinks the status is.  Added ShowPolicies option.
Version 3.2:  Fixed sidecar detection logic
Version 3.1:  Fixed ODJ applied output
Version 3.0:  Added the ability to process logs as well
Version 2.2:  Added new IME MSI guid, new -AllSessions switch
Version 2.0:  Added -online parameter to look up app and policy details
Version 1.0:  Original published version

#>

<#
.SYNOPSIS
Displays Windows Autopilot diagnostics information from the current PC or a captured set of logs.

.DESCRIPTION
This script displays diagnostics information from the current PC or a captured set of logs.  This includes details about the Autopilot profile settings; policies, apps, certificate profiles, etc. being tracked via the Enrollment Status Page; and additional information.

This should work with Windows 10 1903 and later (earlier versions have not been validated).  This script will not work on ARM64 systems due to registry redirection from the use of x86 PowerShell.exe.

.PARAMETER Online
Look up the actual policy and app names via the Intune Graph API

.PARAMETER AllSessions
Show all ESP progress instead of just the final details.

.PARAMETER CABFile
Processes the information in the specified CAB file (captured by MDMDiagnosticsTool.exe -area Autopilot -cab filename.cab) instead of from the registry.

.PARAMETER ZIPFile
Processes the information in the specified ZIP file (captured by MDMDiagnosticsTool.exe -area Autopilot -zip filename.zip) instead of from the registry.

.PARAMETER ShowPolicies
Shows the policy details as recorded in the NodeCache registry keys, in the order that the policies were received by the client.

.EXAMPLE
.\Get-AutopilotDiagnostics.ps1

.EXAMPLE
.\Get-AutopilotDiagnostics.ps1 -Online

.EXAMPLE
.\Get-AutopilotESPStatus.ps1 -AllSessions

.EXAMPLE
.\Get-AutopilotDiagnostics.ps1 -CABFile C:\Autopilot.cab -Online -AllSessions

.EXAMPLE
.\Get-AutopilotDiagnostics.ps1 -ZIPFile C:\Autopilot.zip

.EXAMPLE
.\Get-AutopilotDiagnostics.ps1 -ShowPolicies

#>

function Get-AutopilotDiagnostics
{

[CmdletBinding()]
param(
    [Parameter(Mandatory=$False)] [String] $CABFile = $null,
    [Parameter(Mandatory=$False)] [String] $ZIPFile = $null,
    [Parameter(Mandatory=$False)] [Switch] $Online = $false,
    [Parameter(Mandatory=$False)] [Switch] $AllSessions = $false,
    [Parameter(Mandatory=$False)] [Switch] $ShowPolicies = $false
)

Begin
{
    # Process log files if needed
    $script:useFile = $false
    if ($CABFile -or $ZIPFile) {

        if (-not (Test-Path "$($env:TEMP)\ESPStatus.tmp")) {
            New-Item -Path "$($env:TEMP)\ESPStatus.tmp" -ItemType "directory" | Out-Null
        }
        Remove-Item -Path "$($env:TEMP)\ESPStatus.tmp\*.*" -Force -Recurse        
        $script:useFile = $true

        # If using a CAB file, extract the needed files from it
        if ($CABFile)
        {
            $fileList = @("MdmDiagReport_RegistryDump.reg","microsoft-windows-devicemanagement-enterprise-diagnostics-provider-admin.evtx",
            "microsoft-windows-user device registration-admin.evtx", "AutopilotDDSZTDFile.json", "*.csv")

            $fileList | % {
                $null = & expand.exe "$CABFile" -F:$_ "$($env:TEMP)\ESPStatus.tmp\" 
                if (-not (Test-Path "$($env:TEMP)\ESPStatus.tmp\$_")) {
                    Write-Error "Unable to extract $_ from $CABFile"
                }
            }
        }
        else {
            # If using a ZIP file, just extract the entire contents (not as easy to do selected files)
            Expand-Archive -Path $ZIPFile -DestinationPath "$($env:TEMP)\ESPStatus.tmp\"
        }

        # Get the hardware hash information
        $csvFile = (Get-ChildItem "$($env:TEMP)\ESPStatus.tmp\*.csv").FullName
        if ($csvFile) {
            $csv = Get-Content $csvFile | ConvertFrom-Csv
            $hash = $csv.'Hardware Hash'
        }

        # Edit the path in the .reg file
        $content = Get-Content -Path "$($env:TEMP)\ESPStatus.tmp\MdmDiagReport_RegistryDump.reg"
        $content = $content -replace "\[HKEY_CURRENT_USER\\", "[HKEY_CURRENT_USER\ESPStatus.tmp\USER\"
        $content = $content -replace "\[HKEY_LOCAL_MACHINE\\", "[HKEY_CURRENT_USER\ESPStatus.tmp\MACHINE\"
        $content = $content -replace '^    "','"'
        $content = $content -replace '^    @','@'
        $content = $content -replace 'DWORD:','dword:'
        "Windows Registry Editor Version 5.00`n" | Set-Content -Path "$($env:TEMP)\ESPStatus.tmp\MdmDiagReport_Edited.reg"
        $content | Add-Content -Path "$($env:TEMP)\ESPStatus.tmp\MdmDiagReport_Edited.reg"

        # Remove the registry info if it exists
        if (Test-Path "HKCU:\ESPStatus.tmp") {
            Remove-Item -Path "HKCU:\ESPStatus.tmp" -Recurse -Force
        }

        # Import the .reg file
        $null = & reg.exe IMPORT "$($env:TEMP)\ESPStatus.tmp\MdmDiagReport_Edited.reg" 2>&1

        # Configure the (not live) constants
        $script:provisioningPath =  "HKCU:\ESPStatus.tmp\MACHINE\software\microsoft\provisioning"
        $script:autopilotDiagPath = "HKCU:\ESPStatus.tmp\MACHINE\software\microsoft\provisioning\Diagnostics\Autopilot"
        $script:omadmPath = "HKCU:\ESPStatus.tmp\MACHINE\software\microsoft\provisioning\OMADM"
        $script:path = "HKCU:\ESPStatus.tmp\MACHINE\Software\Microsoft\Windows\Autopilot\EnrollmentStatusTracking\ESPTrackingInfo\Diagnostics"
        $script:msiPath = "HKCU:\ESPStatus.tmp\MACHINE\Software\Microsoft\EnterpriseDesktopAppManagement"
        $script:officePath = "HKCU:\ESPStatus.tmp\MACHINE\Software\Microsoft\OfficeCSP"
        $script:sidecarPath = "HKCU:\ESPStatus.tmp\MACHINE\Software\Microsoft\IntuneManagementExtension\Win32Apps"
        $script:enrollmentsPath =  "HKCU:\ESPStatus.tmp\MACHINE\software\microsoft\enrollments"
    }
    else {
        # Configure live constants
        $script:provisioningPath =  "HKLM:\software\microsoft\provisioning"
        $script:autopilotDiagPath = "HKLM:\software\microsoft\provisioning\Diagnostics\Autopilot"
        $script:omadmPath = "HKLM:\software\microsoft\provisioning\OMADM"
        $script:path = "HKLM:\Software\Microsoft\Windows\Autopilot\EnrollmentStatusTracking\ESPTrackingInfo\Diagnostics"
        $script:msiPath = "HKLM:\Software\Microsoft\EnterpriseDesktopAppManagement"
        $script:officePath = "HKLM:\Software\Microsoft\OfficeCSP"
        $script:sidecarPath = "HKLM:\Software\Microsoft\IntuneManagementExtension\Win32Apps"
        $script:enrollmentsPath =  "HKLM:\Software\Microsoft\enrollments"

        $hash = (Get-WmiObject -Namespace root/cimv2/mdm/dmmap -Class MDM_DevDetail_Ext01 -Filter "InstanceID='Ext' AND ParentID='./DevDetail'").DeviceHardwareData
    }

    # Configure other constants
    $script:officeStatus = @{"0" = "None"; "10" = "Initialized"; "20" = "Download In Progress"; "25" = "Pending Download Retry";
        "30" = "Download Failed"; "40" = "Download Completed"; "48" = "Pending User Session"; "50" = "Enforcement In Progress"; 
        "55" = "Pending Enforcement Retry"; "60" = "Enforcement Failed"; "70" = "Success / Enforcement Completed"}
    $script:espStatus = @{"1" = "Not Installed"; "2" = "Downloading / Installing"; "3" = "Success / Installed"; "4" = "Error / Failed / Might be a dependent app"}
    $script:policyStatus = @{"0" = "Not Processed"; "1" = "Processed"}

    # Configure any other global variables
    $script:observedTimeline = @()
}

Process
{
    #------------------------
    # Functions
    #------------------------

    Function RecordStatus() {
        param
        (
            [Parameter(Mandatory=$true)] [String] $detail,
            [Parameter(Mandatory=$true)] [String] $status,
            [Parameter(Mandatory=$true)] [String] $color,
            [Parameter(Mandatory=$true)] [datetime] $date
        )

        # See if there is already an entry for this policy and status
        $found = $script:observedTimeline | ? { $_.Detail -eq $detail -and $_.Status -eq $status }
        if (-not $found) {
            $script:observedTimeline += New-Object PSObject -Property @{
                "Date" = $date
                "Detail" = $detail
                "Status" = $status
                "Color" = $color
            }
        }
    }

    Function AddDisplay() {
        param
        (
            [Parameter(Mandatory=$true)] [ref]$items
        )
        $items.Value | % {
            Add-Member -InputObject $_ -NotePropertyName display -NotePropertyValue $AllSessions
        }
        $items.Value[$items.Value.Count - 1].display = $true
    }
    
    Function ProcessApps() {
    param
    (
        [Parameter(Mandatory=$true,ValueFromPipeline=$True)] [Microsoft.Win32.RegistryKey] $currentKey,
        [Parameter(Mandatory=$true)] $currentUser,
        [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$True)] [bool] $display
    )

    Begin {
        if ($display) { Write-Host "Apps:" }
    }

    Process {
        if ($display) { Write-Host "  $(([datetime]$currentKey.PSChildName).ToString('u'))" }
        $currentKey.Property | % {
            if ($_.StartsWith("./Device/Vendor/MSFT/EnterpriseDesktopAppManagement/MSI/")) {
                $msiKey = [URI]::UnescapeDataString(($_.Split("/"))[6])
                $fullPath = "$msiPath\$currentUser\MSI\$msiKey"
                if (Test-Path $fullPath) {
                    $status = (Get-ItemProperty -Path $fullPath).Status
                    $msiFile = (Get-ItemProperty -Path $fullPath).CurrentDownloadUrl
                }
                if ($status -eq "" -or $status -eq $null) {
                    $status = 0
                } 
                if ($msiFile -match "IntuneWindowsAgent.msi") {
                    $msiKey = "Intune Management Extensions ($($msiKey))"
                }
                elseif ($Online) {
                    $found = $apps | ? {$_.ProductCode -contains $msiKey}
                    $msiKey = "$($found.DisplayName) ($($msiKey))"
                }
                if ($status -eq 70) {
                    if ($display) { Write-Host "    MSI $msiKey : $status ($($officeStatus[$status.ToString()]))" -ForegroundColor Green }
                    RecordStatus -detail "MSI $msiKey" -status $officeStatus[$status.ToString()] -color "Green" -date $currentKey.PSChildName
                }
                elseif ($status -eq 60) {
                    if ($display) { Write-Host "    MSI $msiKey : $status ($($officeStatus[$status.ToString()]))" -ForegroundColor Red }
                    RecordStatus -detail "MSI $msiKey" -status $officeStatus[$status.ToString()] -color "Red" -date $currentKey.PSChildName
                }
                else {
                    if ($display) { Write-Host "    MSI $msiKey : $status ($($officeStatus[$status.ToString()]))" -ForegroundColor Yellow }
                    RecordStatus -detail "MSI $msiKey" -status $officeStatus[$status.ToString()] -color "Yellow" -date $currentKey.PSChildName
                }
            }
            elseif ($_.StartsWith("./Vendor/MSFT/Office/Installation/")) {
                # Report the main status based on what ESP is tracking
                $status = Get-ItemPropertyValue -Path $currentKey.PSPath -Name $_

                # Then try to get the detailed Office status
                $officeKey = [URI]::UnescapeDataString(($_.Split("/"))[5])
                $fullPath = "$officepath\$officeKey"
                if (Test-Path $fullPath) {
                    $oStatus = (Get-ItemProperty -Path $fullPath).FinalStatus

                    if ($oStatus -eq $null)
                    {
                        $oStatus = (Get-ItemProperty -Path $fullPath).Status
                        if ($oStatus -eq $null)
                        {
                            $oStatus = "None"
                        }
                    }
                }
                else {
                    $oStatus = "None"
                }
                if ($officeStatus.Keys -contains $oStatus.ToString()) {
                    $officeStatusText = $officeStatus[$oStatus.ToString()]
                }
                else {
                    $officeStatusText = $oStatus
                }
                if ($status -eq 1) {
                    if ($display) { Write-Host "    Office $officeKey : $status ($($policyStatus[$status.ToString()]) / $officeStatusText)" -ForegroundColor Green }
                    RecordStatus -detail "Office $officeKey" -status "$($policyStatus[$status.ToString()]) / $officeStatusText" -color "Green" -date $currentKey.PSChildName
                }
                else {
                    if ($display) { Write-Host "    Office $officeKey : $status ($($policyStatus[$status.ToString()]) / $officeStatusText)" -ForegroundColor Yellow }
                    RecordStatus -detail "Office $officeKey" -status "$($policyStatus[$status.ToString()]) / $officeStatusText" -color "Yellow" -date $currentKey.PSChildName
                }
            }
            else {
                if ($display) { Write-Host "    $_ : Unknown app" }
            }
        }
    }

    }

    Function ProcessModernApps() {
    param
    (
        [Parameter(Mandatory=$true,ValueFromPipeline=$True)] [Microsoft.Win32.RegistryKey] $currentKey,
        [Parameter(Mandatory=$true)] $currentUser,
        [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$True)] [bool] $display
    )

    Begin {
        if ($display) { Write-Host "Modern Apps:" }
    }

    Process {
        if ($display) { Write-Host "  $(([datetime]$currentKey.PSChildName).ToString('u'))" }
        $currentKey.Property | % {
            $status = (Get-ItemPropertyValue -path $currentKey.PSPath -Name $_).ToString()
            if ($_.StartsWith("./User/Vendor/MSFT/EnterpriseModernAppManagement/AppManagement/")) {
                $appID = [URI]::UnescapeDataString(($_.Split("/"))[7])
                $type = "User UWP"
            }
            elseif ($_.StartsWith("./Device/Vendor/MSFT/EnterpriseModernAppManagement/AppManagement/")) {
                $appID = [URI]::UnescapeDataString(($_.Split("/"))[7])
                $type = "Device UWP"
            }
            else {
                $appID = $_
                $type = "Unknown UWP"
            }
            if ($status -eq "1") {
                if ($display) { Write-Host "    $type $appID : $status ($($policyStatus[$status]))" -ForegroundColor Green }
                RecordStatus -detail "UWP $appID" -status $policyStatus[$status] -color "Green" -date $currentKey.PSChildName
            }
            else {
                if ($display) { Write-Host "    $type $appID : $status ($($policyStatus[$status]))" -ForegroundColor Yellow }
            }
        }
    }

    }

    Function ProcessSidecar() {
    param
    (
        [Parameter(Mandatory=$true,ValueFromPipeline=$True)] [Microsoft.Win32.RegistryKey] $currentKey,
        [Parameter(Mandatory=$true)] $currentUser,
        [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$True)] [bool] $display
    )

    Begin {
        if ($display) { Write-Host "Sidecar apps:" }
    }

    Process {
        if ($display) { Write-Host "  $(([datetime]$currentKey.PSChildName).ToString('u'))" }
        $currentKey.Property | % {
            $win32Key = [URI]::UnescapeDataString(($_.Split("/"))[9])
            $status = Get-ItemPropertyValue -path $currentKey.PSPath -Name $_
            if ($Online) {
                $found = $apps | ? {$win32Key -match $_.Id }
                $win32Key = "$($found.DisplayName) ($($win32Key))"
            }
            $appGuid = $win32Key.Substring(9)
            $sidecarApp = "$sidecarPath\$currentUser\$appGuid"
            $exitCode = $null
            if (Test-Path $sidecarApp) {
                $exitCode = (Get-ItemProperty -Path $sidecarApp).ExitCode
            }
            if ($status -eq "3") {
                if ($exitCode -ne $null) {
                    if ($display) { Write-Host "    Win32 $win32Key : $status ($($espStatus[$status.ToString()]), rc = $exitCode)" -ForegroundColor Green }
                }
                else {
                    if ($display) { Write-Host "    Win32 $win32Key : $status ($($espStatus[$status.ToString()]))" -ForegroundColor Green }
                }
                RecordStatus -detail "Win32 $win32Key" -status $espStatus[$status.ToString()] -color "Green" -date $currentKey.PSChildName
            }
            elseif ($status -eq "4") {
                if ($exitCode -ne $null) {
                    if ($display) { Write-Host "    Win32 $win32Key : $status ($($espStatus[$status.ToString()]), rc = $exitCode)" -ForegroundColor Red }
                }
                else {
                    if ($display) { Write-Host "    Win32 $win32Key : $status ($($espStatus[$status.ToString()]))" -ForegroundColor Red }
                }
                RecordStatus -detail "Win32 $win32Key" -status $espStatus[$status.ToString()] -color "Red" -date $currentKey.PSChildName
            }
            else {
                if ($exitCode -ne $null) {
                    if ($display) { Write-Host "    Win32 $win32Key : $status ($($espStatus[$status.ToString()]), rc = $exitCode)" -ForegroundColor Yellow }
                }
                else {
                    if ($display) { Write-Host "    Win32 $win32Key : $status ($($espStatus[$status.ToString()]))" -ForegroundColor Yellow }
                }
                if ($status -ne "1") {
                    RecordStatus -detail "Win32 $win32Key" -status $espStatus[$status.ToString()] -color "Yellow" -date $currentKey.PSChildName
                }
            }
        }
    }

    }

    Function ProcessPolicies() {
    param
    (
        [Parameter(Mandatory=$true,ValueFromPipeline=$True)] [Microsoft.Win32.RegistryKey] $currentKey,
        [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$True)] [bool] $display
    )

    Begin {
        if ($display) { Write-Host "Policies:" }
    }

    Process {
        if ($display) { Write-Host "  $(([datetime]$currentKey.PSChildName).ToString('u'))" }
        $currentKey.Property | % {
            $status = Get-ItemPropertyValue -path $currentKey.PSPath -Name $_
            if ($status -eq "1") {
                if ($display) { Write-Host "    Policy $_ : $status ($($policyStatus[$status.ToString()]))" -ForegroundColor Green }
                RecordStatus -detail "Policy $_" -status $policyStatus[$status.ToString()] -color "Green" -date $currentKey.PSChildName
            }
            else {
                if ($display) { Write-Host "    Policy $_ : $status ($($policyStatus[$status.ToString()]))" -ForegroundColor Yellow }
            }
        }
    }

    }

    Function ProcessCerts() {
    param
    (
        [Parameter(Mandatory=$true,ValueFromPipeline=$True)] [Microsoft.Win32.RegistryKey] $currentKey,
        [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$True)] [bool] $display
    )

    Begin {
        if ($display) { Write-Host "Certificates:" }
    }

    Process {
        if ($display) { Write-Host "  $(([datetime]$currentKey.PSChildName).ToString('u'))" }
        $currentKey.Property | % {
            $certKey = [URI]::UnescapeDataString(($_.Split("/"))[6])
            $status = Get-ItemPropertyValue -path $currentKey.PSPath -Name $_
            if ($Online) {
                $found = $policies | ? { $certKey.Replace("_","-") -match $_.Id }
                $certKey = "$($found.DisplayName) ($($certKey))"
            }
            if ($status -eq "1") {
                if ($display) { Write-Host "    Cert $certKey : $status ($($policyStatus[$status.ToString()]))" -ForegroundColor Green }
                RecordStatus -detail "Cert $certKey" -status $policyStatus[$status.ToString()] -color "Green" -date $currentKey.PSChildName
            }
            else {
                if ($display) { Write-Host "    Cert $certKey : $status ($($policyStatus[$status.ToString()]))" -ForegroundColor Yellow }
            }
        }
    }

    }

    Function ProcessNodeCache() {

    Process {
        $nodeCount = 0
        while ($true) {
            # Get the nodes in order.  This won't work after a while because the older numbers are deleted as new ones are added
            # but it will work out OK shortly after provisioning.  The alternative would be to get all the subkeys and then sort
            # them numerically instead of alphabetically, but that can be saved for later...
            $node = Get-ItemProperty "$provisioningPath\NodeCache\CSP\Device\MS DM Server\Nodes\$nodeCount" -ErrorAction SilentlyContinue
            if ($node -eq $null) {
                break
            }
            $nodeCount += 1
            $node | Select NodeUri, ExpectedValue
        }
    }

    }

    Function ProcessEvents() {

        Process {

            $productCode = 'IME-Not-Yet-Installed'
            if (Test-Path "$msiPath\S-0-0-00-0000000000-0000000000-000000000-000\MSI") {
                Get-ChildItem -path "$msiPath\S-0-0-00-0000000000-0000000000-000000000-000\MSI" | % {
                    $file = (Get-ItemProperty -Path $_.PSPath).CurrentDownloadUrl
                    if ($file -match "IntuneWindowsAgent.msi") {
                        $productCode = Get-ItemPropertyValue -Path $_.PSPath -Name ProductCode
                    }
                }
            }

            # Process device management events
            if ($script:useFile) {
                $events = Get-WinEvent -Path "$($env:TEMP)\ESPStatus.tmp\microsoft-windows-devicemanagement-enterprise-diagnostics-provider-admin.evtx" -Oldest | ? { ($_.Message -match $productCode -and $_.Id -in 1905,1906,1920,1922) -or $_.Id -in (72,100,107,109,110,111) }
            }
            else {
                $events = Get-WinEvent -LogName Microsoft-Windows-DeviceManagement-Enterprise-Diagnostics-Provider/Admin -Oldest | ? { ($_.Message -match $productCode -and $_.Id -in 1905,1906,1920,1922) -or $_.Id -in (72,100,107,109,110,111) }
            }
            $events | % {
                $message = $_.Message
                $detail = "Sidecar (IME)"
                $color = "Yellow"
                $event = $_
                switch ($_.id)
                {
                    {$_ -in (110, 109)} { 
                        $detail = "Offline Domain Join"
                        switch ($event.Properties[0].Value)
                        {
                            0 { $message = "Offline domain join not configured" }
                            1 { $message = "Waiting for ODJ blob" }
                            2 { $message = "Processed ODJ blob" }
                            3 { $message = "Timed out waiting for ODJ blob or connectivity" }
                        }
                    }
                    111 { $detail = "Offline Domain Join"; $message = "Starting wait for ODJ blob"}
                    107 { $detail = "Offline Domain Join"; $message = "Successfully applied ODJ blob"}
                    100 { $detail = "Offline Domain Join"; $message = "Could not establish connectivity"; $color = "Red"}
                    72 { $detail = "MDM Enrollment" }
                    1905 { $message = "Download started" }
                    1906 { $message = "Download finished" }
                    1920 { $message = "Installation started" }
                    1922 { $message = "Installation finished" }
                    {$_ -in (1922, 72)} { $color = "Green" }
                }
                RecordStatus -detail $detail -date $_.TimeCreated -status $message -color $color
            }

            # Process device registration events            
            if ($script:useFile) {
                $events = Get-WinEvent -Path "$($env:TEMP)\ESPStatus.tmp\microsoft-windows-user device registration-admin.evtx" -Oldest | ? { $_.Id -in (306, 101) }
            }
            else {
                $events = Get-WinEvent -LogName 'Microsoft-Windows-User Device Registration/Admin' -Oldest | ? { $_.Id -in (306, 101) }
            }
            $events | % {
                $message = $_.Message
                $detail = "Device Registration"
                $color = "Yellow"
                $event = $_
                switch ($_.id)
                {
                    101 { $detail = "Device Registration"; $message = "SCP discovery successful." }
                    304 { $detail = "Device Registration"; $message = "Hybrid AADJ device registration failed." }
                    306 { $detail = "Device Registration"; $message = "Hybrid AADJ device registration succeeded."; $color = 'Green' }
                }
                RecordStatus -detail $detail -date $_.TimeCreated -status $message -color $color
            }

        }
    
        }
    
    Function GetIntuneObjects() {
        param
        (
            [Parameter(Mandatory=$true)] [String] $uri
        )

        Process {

            Write-Verbose "GET $uri"
            try {
                $response = Invoke-MSGraphRequest -Url $uri -HttpMethod Get

                $objects = $response.value
                $objectsNextLink = $response."@odata.nextLink"
    
                while ($objectsNextLink -ne $null){
                    $response = (Invoke-MSGraphRequest -Url $devicesNextLink -HttpMethod Get)
                    $objectsNextLink = $response."@odata.nextLink"
                    $objects += $response.value
                }

                return $objects
            }
            catch {
                Write-Error $_.Exception
                return $null
                break
            }

        }
    }

    #------------------------
    # Main code
    #------------------------

    # If online, make sure we are able to authenticate
    if ($Online) {

        # Make sure we can connect
        $module = Import-Module Microsoft.Graph.Intune -PassThru -ErrorAction Ignore
        if (-not $module) {
            Write-Host "Installing module Microsoft.Graph.Intune"
            Install-Module Microsoft.Graph.Intune -Force
        }
        Import-Module Microsoft.Graph.Intune
        $graph = Connect-MSGraph
        Write-Host "Connected to tenant $($graph.TenantId)"

        # Get a list of apps
        Write-Host "Getting list of apps"
        $script:apps = GetIntuneObjects("https://graph.microsoft.com/beta/deviceAppManagement/mobileApps")

        # Get a list of policies (for certs)
        Write-Host "Getting list of policies"
        $script:policies = GetIntuneObjects("https://graph.microsoft.com/beta/deviceManagement/deviceConfigurations")
    }

    # Display Autopilot diag details
    Write-Host ""
    Write-Host "AUTOPILOT DIAGNOSTICS" -ForegroundColor Magenta
    Write-Host ""

    $values = Get-ItemProperty "$autopilotDiagPath"
    if (-not $values.CloudAssignedTenantId) {
        Write-Host "This is not an Autopilot device.`n"
        exit 0
    }

    if (-not $script:useFile) {
        $osVersion = (Get-WmiObject win32_operatingsystem).Version
        Write-Host "OS version:               $osVersion"
    }
    Write-Host "Profile:                  $($values.DeploymentProfileName)"
    Write-Host "TenantDomain:             $($values.CloudAssignedTenantDomain)"
    Write-Host "TenantID:                 $($values.CloudAssignedTenantId)"
    $correlations = Get-ItemProperty "$autopilotDiagPath\EstablishedCorrelations"
    Write-Host "ZTDID:                    $($correlations.ZTDRegistrationID)"
    Write-Host "EntDMID:                  $($correlations.EntDMID)"

    Write-Host "OobeConfig:               $($values.CloudAssignedOobeConfig)"

    if (($values.CloudAssignedOobeConfig -band 1024) -gt 0) {
        Write-Host " Skip keyboard:           Yes   1 - - - - - - - - - -"
    }
    else {
        Write-Host " Skip keyboard:           No    0 - - - - - - - - - -"
    }
    if (($values.CloudAssignedOobeConfig -band 512) -gt 0) {
        Write-Host " Enable patch download:   Yes   - 1 - - - - - - - - -"
    }
    else {
        Write-Host " Enable patch download:   No    - 0 - - - - - - - - -"
    }
    if (($values.CloudAssignedOobeConfig -band 256) -gt 0) {
        Write-Host " Skip Windows upgrade UX: Yes   - - 1 - - - - - - - -"
    }
    else {
        Write-Host " Skip Windows upgrade UX: No    - - 0 - - - - - - - -"
    }
    if (($values.CloudAssignedOobeConfig -band 128) -gt 0) {
        Write-Host " AAD TPM Required:        Yes   - - - 1 - - - - - - -"
    }
    else {
        Write-Host " AAD TPM Required:        No    - - - 0 - - - - - - -"
    }
    if (($values.CloudAssignedOobeConfig -band 64) -gt 0) {
        Write-Host " AAD device auth:         Yes   - - - - 1 - - - - - -"
    }
    else {
        Write-Host " AAD device auth:         No    - - - - 0 - - - - - -"
    }
    if (($values.CloudAssignedOobeConfig -band 32) -gt 0) {
        Write-Host " TPM attestation:         Yes   - - - - - 1 - - - - -"
    }
    else {
        Write-Host " TPM attestation:         No    - - - - - 0 - - - - -"
    }
    if (($values.CloudAssignedOobeConfig -band 16) -gt 0) {
        Write-Host " Skip EULA:               Yes   - - - - - - 1 - - - -"
    }
    else {
        Write-Host " Skip EULA:               No    - - - - - - 0 - - - -"
    }
    if (($values.CloudAssignedOobeConfig -band 8) -gt 0) {
        Write-Host " Skip OEM registration:   Yes   - - - - - - - 1 - - -"
    }
    else {
        Write-Host " Skip OEM registration:   No    - - - - - - - 0 - - -"
    }
    if (($values.CloudAssignedOobeConfig -band 4) -gt 0) {
        Write-Host " Skip express settings:   Yes   - - - - - - - - 1 - -"
    }
    else {
        Write-Host " Skip express settings:   No    - - - - - - - - 0 - -"
    }
    if (($values.CloudAssignedOobeConfig -band 2) -gt 0) {
        Write-Host " Disallow admin:          Yes   - - - - - - - - - 1 -"
    }
    else {
        Write-Host " Disallow admin:          No    - - - - - - - - - 0 -"
    }

    # In theory we could read these values from the profile cache registry key, but it's so bungled
    # up in the registry export that it doesn't import without some serious massaging for embedded
    # quotes.  So this is easier.
    if ($script:useFile) {
        $jsonFile = "$($env:TEMP)\ESPStatus.tmp\AutopilotDDSZTDFile.json"
    }
    else {
        $jsonFile = "$($env:WINDIR)\ServiceState\wmansvc\AutopilotDDSZTDFile.json" 
    }
    if (Test-Path $jsonFile) {
        $json = Get-Content $jsonFile | ConvertFrom-Json
        $date = [datetime]$json.PolicyDownloadDate
        RecordStatus -date $date -detail "Autopilot profile" -status "Profile downloaded" -color "Yellow" 
        if ($json.CloudAssignedDomainJoinMethod -eq 1) {
            Write-Host "Scenario:                 Hybrid Azure AD Join"
            if (Test-Path "$omadmPath\SyncML\ODJApplied") {
                Write-Host "ODJ applied:              Yes"
            }
            else {
                Write-Host "ODJ applied:              No"                
            }
            if ($json.HybridJoinSkipDCConnectivityCheck -eq 1) {
                Write-Host "Skip connectivity check:  Yes"
            }
            else {
                Write-Host "Skip connectivity check:  No"
            }

        }
        else {
            Write-Host "Scenario:                 Azure AD Join"
        }
    }
    else {
        Write-Host "Scenario:                 Not available (JSON not found)"
    }

    # Get ESP properties
    Get-ChildItem $enrollmentsPath | ? { Test-Path "$($_.PSPath)\FirstSync" } | % {
        $properties = Get-ItemProperty "$($_.PSPath)\FirstSync"
        Write-Host "Enrollment status page:"
        Write-Host " Device ESP enabled:      $($properties.SkipDeviceStatusPage -eq 0)"
        Write-Host " User ESP enabled:        $($properties.SkipUserStatusPage -eq 0)"
        Write-Host " ESP timeout:             $($properties.SyncFailureTimeout)"
        if ($properties.BlockInStatusPage -eq 0) {
            Write-Host " ESP blocking:            No"
        }
        else {
            Write-Host " ESP blocking:            Yes"
            if ($properties.BlockInStatusPage -band 1) {
                Write-Host " ESP allow reset:         Yes"
            }
            if ($properties.BlockInStatusPage -band 2) {
                Write-Host " ESP allow try again:     Yes"
            }
            if ($properties.BlockInStatusPage -band 4) {
                Write-Host " ESP continue anyway:     Yes"
            }
        }
    }

    # Get Delivery Optimization statistics (when available)
    if (-not $script:useFile) {
        $stats = Get-DeliveryOptimizationPerfSnapThisMonth
        if ($stats.DownloadHttpBytes -ne 0)
        {
            $peerPct = [math]::Round( ($stats.DownloadLanBytes / $stats.DownloadHttpBytes) * 100 )
            $ccPct = [math]::Round( ($stats.DownloadCacheHostBytes / $stats.DownloadHttpBytes) * 100 )
        }
        else {
            $peerPct = 0
            $ccPct = 0
        }
        Write-Host "Delivery Optimization statistics:"
        Write-Host " Total bytes downloaded:  $($stats.DownloadHttpBytes)"
        Write-Host " From peers:              $($peerPct)% ($($stats.DownloadLanBytes))"
        Write-host " From Connected Cache:    $($ccPct)% ($($stats.DownloadCacheHostBytes))"
    }

    # If the ADK is installed, get some key hardware hash info
    $adkPath = Get-ItemPropertyValue "HKLM:\Software\Microsoft\Windows Kits\Installed Roots" -Name KitsRoot10 -ErrorAction SilentlyContinue
    $oa3Tool = "$adkPath\Assessment and Deployment Kit\Deployment Tools\$($env:PROCESSOR_ARCHITECTURE)\Licensing\OA30\oa3tool.exe"
    if ($hash -and (Test-Path $oa3Tool)) {
        $commandLineArgs = "/decodehwhash:$hash"
        $output = & "$oa3Tool" $commandLineArgs
        [xml] $hashXML = $output | Select -skip 8 -First ($output.Count - 12)
        Write-Host "Hardware information:"
        Write-Host " Operating system build: " $hashXML.SelectSingleNode("//p[@n='OsBuild']").v
        Write-Host " Manufacturer:           " $hashXML.SelectSingleNode("//p[@n='SmbiosSystemManufacturer']").v
        Write-Host " Model:                  " $hashXML.SelectSingleNode("//p[@n='SmbiosSystemProductName']").v
        Write-Host " Serial number:          " $hashXML.SelectSingleNode("//p[@n='SmbiosSystemSerialNumber']").v
        Write-Host " TPM version:            " $hashXML.SelectSingleNode("//p[@n='TPMVersion']").v
    }
    
    # Process event log info
    ProcessEvents

    # Display the list of policies
    if ($ShowPolicies) {
        Write-Host " "
        Write-Host "POLICIES PROCESSED" -ForegroundColor Magenta   
        ProcessNodeCache | Format-Table -Wrap
    }
    
    # Make sure the tracking path exists
    if (Test-Path $path) {

        # Process device ESP sessions
        Write-Host " "
        Write-Host "DEVICE ESP:" -ForegroundColor Magenta
        Write-Host " "

        if (Test-Path "$path\ExpectedPolicies") {
            [array]$items = Get-ChildItem "$path\ExpectedPolicies"
            AddDisplay ([ref]$items)
            $items | ProcessPolicies
        }
        if (Test-Path "$path\ExpectedMSIAppPackages") {
            [array]$items = Get-ChildItem "$path\ExpectedMSIAppPackages"
            AddDisplay ([ref]$items)
            $items | ProcessApps -currentUser "S-0-0-00-0000000000-0000000000-000000000-000" 
        }
        if (Test-Path "$path\ExpectedModernAppPackages") {
            [array]$items = Get-ChildItem "$path\ExpectedModernAppPackages"
            AddDisplay ([ref]$items)
            $items | ProcessModernApps -currentUser "S-0-0-00-0000000000-0000000000-000000000-000"
        }
        if (Test-Path "$path\Sidecar") {
            [array]$items = Get-ChildItem "$path\Sidecar" | ? { $_.Property -match "./Device" }
            AddDisplay ([ref]$items)
            $items | ProcessSidecar -currentUser "00000000-0000-0000-0000-000000000000"
        }
        if (Test-Path "$path\ExpectedSCEPCerts") {
            [array]$items = Get-ChildItem "$path\ExpectedSCEPCerts"
            AddDisplay ([ref]$items)
            $items | ProcessCerts
        }

        # Process user ESP sessions
        Get-ChildItem "$path" | ? { $_.PSChildName.StartsWith("S-") } | % {
            $userPath = $_.PSPath
            $userSid = $_.PSChildName
            Write-Host " "
            Write-Host "USER ESP for $($userSid):" -ForegroundColor Magenta
            Write-Host " "
            if (Test-Path "$userPath\ExpectedPolicies") {
                [array]$items = Get-ChildItem "$userPath\ExpectedPolicies"
                AddDisplay ([ref]$items)
                $items | ProcessPolicies
            }
            if (Test-Path "$userPath\ExpectedMSIAppPackages") {
                [array]$items = Get-ChildItem "$userPath\ExpectedMSIAppPackages" 
                AddDisplay ([ref]$items)
                $items | ProcessApps -currentUser $userSid
            }
            if (Test-Path "$userPath\ExpectedModernAppPackages") {
                [array]$items = Get-ChildItem "$userPath\ExpectedModernAppPackages"
                AddDisplay ([ref]$items)
                $items | ProcessModernApps -currentUser $userSid
            }
            if (Test-Path "$userPath\Sidecar") {
                [array]$items = Get-ChildItem "$path\Sidecar" | ? { $_.Property -match "./User" }
                AddDisplay ([ref]$items)
                $items | ProcessSidecar -currentUser $userSid
            }
            if (Test-Path "$userPath\ExpectedSCEPCerts") {
                [array]$items = Get-ChildItem "$userPath\ExpectedSCEPCerts"
                AddDisplay ([ref]$items)
                $items | ProcessCerts
            }
        }
    }
    else {
        Write-Host "ESP diagnostics info does not (yet) exist."
    }

    # Display timeline 
    Write-Host ""
    Write-Host "OBSERVED TIMELINE:" -ForegroundColor Magenta
    Write-Host ""
    $observedTimeline | Sort-Object -Property Date |
        Format-Table @{
            Label = "Date"
            Expression = { $_.Date.ToString("u") } 
        }, 
        @{
            Label = "Status"
            Expression =
            {
                switch ($_.Color)
                {
                    'Red'    { $color = "91"; break }
                    'Yellow' { $color = '93'; break }
                    'Green'  { $color = "92"; break }
                    default { $color = "0" }
                }
                $e = [char]27
                "$e[${color}m$($_.Status)$e[0m"
            }
        },
        
        # start Custom GUIDS:
        @{
            Label = "App Name"
            Expression =
            {
                $match = [Regex]::Match($_.Detail, 'Win32 Win32App_(.*)_.')
                if ($match.Success) {
                    Write-Output $GuidApp[$match.Groups[1].Value]
                }
                else {
                    $_.Detail
                }
            }
        },
        # end Custom GUIDS.
        Detail

    Write-Host ""
}

End {

    # Remove the registry info if it exists
    if (Test-Path "HKCU:\ESPStatus.tmp") {
        Remove-Item -Path "HKCU:\ESPStatus.tmp" -Recurse -Force
    }
}

} 


# Need width.
$host.UI.RawUI.BufferSize = New-Object System.Management.Automation.Host.Size(500,5000)

# Loop it.
while ($true) {

    $data = Get-AutopilotDiagnostics -ErrorAction SilentlyContinue 6>$null
    cls
    $data
    # todo - formatting? Automatic window positioning via pinvoke?
    Start-Sleep -Seconds 60
}