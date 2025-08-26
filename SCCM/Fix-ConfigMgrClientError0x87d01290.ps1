<#
.SYNOPSIS
    Script to resolve Configuration Manager Client (Enforcement) Error 0x87d01290 when processing
    App-V packages.
 
.DESCRIPTION
Intended Use
 
    To resolve an issue with Enforcement Error 0x87d01290 on App-V clients, where software is
    being delivered by SCCM. This is a work around and does not solve the root case of the issue.
    
    This script is to be used with a dynamic collection, this will allow resolved clients to 'fall'
    out of the collection when the issue is resolved. 
    In regards restarting the App-V client service, we have found in almost all cases a reboot will
    be required due to the fact that the Get-AppvClientPackage cmdlet is broken, thus we can't check 
    for running App-V packages.
    If you don't understand WQL Query for the SCCM dynamic collection in the article, then take 
    care as you can easily break the SQL server SCCM utilises.
    A thank you to...
  * Mal Lagden for provding the other half of the solution from the ConfigMgr driving App-V 
    persepctive. https://www.linkedin.com/in/mallagden
  * Colin Millins for discovering the malformed Manifests.xml's, which breaks the processing 
    of App-V packages.
Code Snippet Credits
  * https://community.spiceworks.com/topic/2023962-how-to-create-a-task-scheduler-using-powershell?
Version History
    1.05 14/02/2019
    Added Scheduled Task to add SCCM Detection registry key again, due to SCCM PowerShell detection
    method not working correctly - see article for more details. Added detection for missing 
    content in the Package Store, which causes AppEnforce 0x87d0128f errors, which in turn causes 
    0x87d01290 errors. Added invoking of SCCM client actions.
    
    1.04 20/10/2018
    Added conditional big fix approach if no malformed XMLs found. Fixed bug with SCCM not 
    recognising exit codes.
    
    1.03 15/10/2018
    Added date and time to log. Fixed bug, it will now only exit with 3010 if fix was applied.
    1.02 27/09/2018
    Refined fix from the big bang to targeted approach. Fix needed to be applied in two areas, the
    SOFTWARE\Microsoft\AppV\Client\Packages and 
    SOFTWARE\Microsoft\SMS\Mobile Client\Software Distribution\VirtualAppPackages\AppV5XPackages
    registry keys. Removed Scheduled Task, Mal advised simpler approach where the machine will fall
    out of the collection when fixed.
    1.01 26/09/2018
    Following bug fixes. Changed Scheduled Task Trigger from test to production values (minutes to 
    days). Added variable for days in future to remove SCCM Detection registry key. Removed 
    ScheduledTaskSettingsSet Compatibility V1 switch to allow task to run as soon as possible on 
    reboot/missed trigger. Adjusted task to expire in one year from date of creation, this will 
    allow task to run on boot if task was missed due client being powered off. Forgot to add the 
    actual fix to the script!
    
    1.00 25/09/2018
    Initial script written.
 
 
Copyright & Intellectual Property
    Feel to copy, modify and redistribute, but please pay credit where it is due.
    Feed back is welcome, please contact me on LinkedIn. 
 
 
.LINK
Author:.......https://www.linkedin.com/in/rileylim
 Co-author:...https://www.linkedin.com/in/mallagden
 Source Code:..https://gist.github.com/rileyz/93cd70d245ab99fd353a1e39f82f6708
 Article:......https://www.itninja.com/blog/view/app-v-0x87d01290-error-sccm-an-error-occurred-when-querying-the-app-v-wmi-provider
#>



# Function List ###################################################################################
Function Write-Registry {
    Param ([Parameter(Mandatory=$true)][String]$RegistryKey,
           [Parameter(Mandatory=$true)][String]$RegistryValueName,
                                       [String]$RegistryValueData,
           [Parameter(Mandatory=$true)][String]$RegistryValueType,
                                       [Switch]$EnableReflectiontoWOW3264Node)
    #Need to add logic to write to WOW3264Node if in 64bit system via switch.
    
    Try   {Switch ((Get-ItemProperty -Path $RegistryKey -Name $RegistryValueName -ErrorAction SilentlyContinue).$RegistryValueName.gettype().name)
                   {'String'    {$RegistryValueTypeCheck = 'String'}
                    'Int32'     {$RegistryValueTypeCheck = 'DWord'}
                    'Int64'     {$RegistryValueTypeCheck = 'QWord'}
                    'String[]'  {$RegistryValueTypeCheck = 'MultiString'}
                    'Byte[]'    {$RegistryValueTypeCheck = 'Binary'}
                    Default     {Return 'Unable to discover registry type for overwrite check'}}}
    Catch {$RegistryValueTypeCheck = $null}

    If ($RegistryValueTypeCheck -ne $null)
            {If ($RegistryValueTypeCheck -ne $RegistryValueType)
                    {Return 'Registry type mismatch'}}
    
    #Force create the registry path.
    If (((Test-Path $RegistryKey) -replace "`n|`r") -eq 'False')
            {$null = New-Item -Path $RegistryKey -Force}

    Switch ($RegistryValueTypeCheck)
        {MultiString   {#Writing registry MultiString value.
                        $MultiStringArray = Get-ItemProperty -Path $RegistryKey | Select-Object -ExpandProperty $RegistryValueName
                        $MultiStringArray = @($MultiStringArray | where {$_ -ne $RegistryValueData})
             
                        If ($MultiStringArray -notcontains $RegistryValueData) 
                                {$MultiStringArray += $RegistryValueData}
                                 
                        #Not in use yet, needs coded into params.
                        If ($Remove -eq $true)
                                {$MultiStringArray = @($MultiStringArray | where { $_ -ne $RegistryValueData })}

                        Set-ItemProperty -Path $RegistryKey -type $RegistryValueTypeCheck -Name $RegistryValueName -Value $MultiStringArray
                                 
                        Try   {$RegistryWriteCheck = Get-ItemProperty -Path $RegistryKey | Select-Object -ExpandProperty $RegistryValueName
                               If ($RegistryWriteCheck -contains $RegistryValueData)
                                       {$RegistryWriteCheck = $null
                                        Return '0'}
                                   Else{Return 'Unexpected value on validation'}}
                        Catch {Return 'Error'}}

         Default       {#Writing registry String, Dword, Qword, value.
                        $null = New-ItemProperty -Path $RegistryKey -Name $RegistryValueName -Value $RegistryValueData -PropertyType $RegistryValueType -Force

                        Try   {$RegistryWriteCheck = (Get-ItemProperty -Path $RegistryKey | Select-Object -ExpandProperty $RegistryValueName)
                               If ($RegistryWriteCheck -eq $RegistryValueData)
                                       {$RegistryWriteCheck = $null
                                        Return '0'}
                                   Else{Return 'Unexpected value on validation'}}
                        Catch {Return 'Error'}}}

    #https://github.com/rileyz/VMR-Stable/blob/master/Virtual%20Machine%20Runner/Framework/Core_CommonFunctions.ps1

 } #End Function Write-Registry 

Function LogWrite {Param ([String] $LogLine,
                          [Switch] $EndOfLog)
                   If ($EndOfLog -eq $True) {Add-content $LogFile -value 'INFO:   END OF LOGGING'
                                             Add-content $LogFile -value ''}
                                       Else {Write-Verbose $LogLine
                                             Add-content $LogFile -value $LogLine}

                   #https://gist.github.com/rileyz/464175e3bb96f1b67dfc

 } #End Function LogWrite
#<<< End Of Function List >>>



# Setting up housekeeping for variables ###########################################################
$ScriptPath = Split-Path -Parent $MyInvocation.MyCommand.Definition
$VerbosePreference = 'SilentlyContinue' #SilentlyContinue|Continue

$PackageName                 = 'Fix-ConfigMgrClientError0x87d01290'  #Registry value for SCCM detection.
$DetectionStamp              = "HKLM:\SOFTWARE\$PackageName"         #Registry path SCCM detection key.

$RemoveSCCMDetectionTimeUnit = 'Hours'                               #Days|Hours|Minutes
$RemoveSCCMDetection         = '8'                                   #Time unit in future to remove SCCM Detection registry key.

$LogFile = "$env:systemroot\Temp\Fix-ConfigMgrClientError0x87d01290.log" #Log location.
$LogDate = Get-Date -Format 'dd MMMM, yyyy, HH:mm.'
#<<< End of Setting up housekeeping >>>



# Start of script work ############################################################################
$ArrayScriptExitResult = @()
$ArrayAllManifestFiles = @()

LogWrite 'INFO:   ****************************************'
LogWrite 'INFO:   Configuration Manager Client Fix For Error 0x87d01290'
LogWrite 'INFO:   Author: https://www.linkedin.com/in/rileylim'
LogWrite 'INFO:   Co-author: https://www.linkedin.com/in/mallagden'
LogWrite 'INFO:   Source Script: https://gist.github.com/rileyz/93cd70d245ab99fd353a1e39f82f6708'
LogWrite "INFO:   $LogDate"

$ArrayAllManifestFiles = Get-ChildItem -Path $Env:Programdata\Microsoft\AppV\Client\Catalog\Packages\ -Recurse -Filter Manifest.xml
LogWrite "Event:  Found $($ArrayAllManifestFiles.Count) XML files to check."

Foreach ($ManifestItem in $ArrayAllManifestFiles)
    {$ReadManifestTest = $null
     $ReadManifestTest = Get-Content $ManifestItem.FullName -First 1 -ErrorAction SilentlyContinue
     LogWrite "INFO:   Checking on $($ManifestItem.FullName)"

     $PathString = $ManifestItem.DirectoryName | Out-String
     $AppVGUID = $PathString.Split('\')[$($PathString.Split('\').Count - 2)] -replace '[{}]'
     $AppVVersionGUID = $($PathString.Split('\')[$($PathString.Split('\').Count - 1)] -replace '[{}]|\r|\n') 

     If (($ReadManifestTest -eq $null) -or
         !(Test-Path "$Env:ProgramData\App-V\$AppVGUID\$AppVVersionGUID\AppxManifest.xml") -or
         !(Test-Path "$Env:ProgramData\App-V\$AppVGUID\$AppVVersionGUID\FilesystemMetadata.xml") -or
         !(Test-Path "$Env:ProgramData\App-V\$AppVGUID\$AppVVersionGUID\PackageHistory.xml") -or
         !(Test-Path "$Env:ProgramData\App-V\$AppVGUID\$AppVVersionGUID\Registry.dat") -or
         !(Test-Path "$Env:ProgramData\App-V\$AppVGUID\$AppVVersionGUID\StreamMap.xml"))
         {LogWrite 'INFO:   Found broken XML file or missing content in Package Store, more details to follow.'
          $BrokenXMLCount += 1

          LogWrite "INFO:   App-V GUID is $AppVGUID."

          If (Test-Path "$($ManifestItem.DirectoryName)\DeploymentConfiguration.xml")
              {$RegEx = [RegEx]'DisplayName=".*?"'
	           $WorkingDisplayName = Select-String -Pattern $RegEx -InputObject $(Get-Content "$($ManifestItem.DirectoryName)\DeploymentConfiguration.xml") -AllMatches | foreach {$_.matches}
               $AppVPackageName = $WorkingDisplayName.Value -replace 'DisplayName="|"'
               LogWrite "INFO:   App-V Package Name is $AppVPackageName."}
          
          If ($ReadManifestTest -eq $null) 
              {LogWrite 'INFO:   Confirmed broken XML file.'}
          Else{LogWrite 'INFO:   XML file is OK.'}

          If (Test-Path "$Env:ProgramData\App-V\$AppVGUID")
              {If ((Get-ChildItem "$Env:ProgramData\App-V\$AppVGUID" -Recurse | Measure-Object | %{$_.Count}) -gt 1)
                   {LogWrite "INFO:   Found $(Get-ChildItem "$Env:ProgramData\App-V\$AppVGUID" -Recurse | Measure-Object | %{$_.Count}) files."}
               Else{LogWrite 'INFO:   Package Store missing content.'}}
          Else{LogWrite "INFO:   Path %ProgramData%\App-V\$AppVGUID does not exist, can't check for folder size/missing Package Store content."}

          LogWrite 'INFO:   Applying fix to broken App-V package.'     
          
          If (Test-Path "HKLM:\SOFTWARE\Microsoft\SMS\Mobile Client\Software Distribution\VirtualAppPackages\AppV5XPackages\$AppVGUID")
              {LogWrite 'INFO:   Test Path App-V GUID from Software Distribution\VirtualAppPackages registry entry found.'  
               Remove-Item "HKLM:\SOFTWARE\Microsoft\SMS\Mobile Client\Software Distribution\VirtualAppPackages\AppV5XPackages\$AppVGUID" -Recurse -Force -ErrorAction SilentlyContinue
               If ($?)
                   {LogWrite 'Event:  Removal of App-V GUID from Software Distribution\VirtualAppPackages registry success.'
                    $ArrayScriptExitResult += 0}
               Else{LogWrite 'Event:  Removal of App-V GUID from Software Distribution\VirtualAppPackages registry failure.'
                    $ArrayScriptExitResult += 1}}
          Else{LogWrite 'INFO:   Test Path App-V GUID from Software Distribution\VirtualAppPackages registry entry not found.'}

          If (Test-Path "HKLM:\SOFTWARE\Microsoft\AppV\Client\Packages\$AppVGUID")
              {LogWrite 'INFO:   Test Path App-V GUID from AppV\Client\Packages registry found.'
               Remove-Item "HKLM:\SOFTWARE\Microsoft\AppV\Client\Packages\$AppVGUID" -Recurse -Force -ErrorAction SilentlyContinue
               If ($?)
                   {LogWrite 'Event:  Removal of App-V GUID from AppV\Client\Packages registry success.'
                    $ArrayScriptExitResult += 0}
               Else{LogWrite 'Event:  Removal of App-V GUID from AppV\Client\Packages registry failure.'
                    $ArrayScriptExitResult += 1}}
          Else{LogWrite 'INFO:   Test Path App-V GUID from AppV\Client\Packages registry entry not found.'}}}

If ($BrokenXMLCount -ne $null)
    {LogWrite "INFO:   Total malformed XML files found is $BrokenXMLCount."
     $null = Get-AppvClientPackage -ErrorAction SilentlyContinue 
     If ($?)
         {LogWrite 'INFO:   Commandlet Get-AppvClientPackage is working OK, will try and restart service.'
          If ((Get-Service -Name AppVClient).Status -eq 'Running')
              {LogWrite 'INFO:   AppVClient service is running, checking that no App-V packages are running so we can restart service.'
               If ((Get-AppvClientPackage -All | Where-Object -Property InUse -EQ True).Count -eq 0   )
                   {LogWrite 'Event:  No packages running, restarting AppVClient service.'
                    Restart-Service AppVClient}
               Else{LogWrite 'INFO:   Packages in use, we will just have to wait for a reboot.'
                    $ArrayScriptExitResult += '3010'}}
          Else{LogWrite 'INFO:   AppVClient service is not running, now checking for stopped state.'
               If ((Get-Service -Name AppVClient).Status -ne 'Stopped')
                   {LogWrite 'INFO:   AppVClient service is in a weird state, recommend reboot.'
                    $ArrayScriptExitResult += '3010'}
               Else{LogWrite 'Event:  AppVClient service is in stopped state, starting service.'
                    Start-Service -Name AppVClient
                    If ($?) 
                        {LogWrite 'Event:  AppVClient service started OK.'}
                    Else{LogWrite 'Event:  Error starting AppVClient service.'
                         $ArrayScriptExitResult += '1'}}}}
     Else{LogWrite 'Event:  Commandlet Get-AppvClientPackage did not run correctly, unable to determine if any packages are in use.'
          LogWrite 'Event:  Since we cant detect packages in use, we will just have to wait for a reboot.'
          $ArrayScriptExitResult += '3010'}}
Else{LogWrite 'INFO:   No malformed XML files found, going for big bang fix approach.'
     If((Get-Service -Name AppVClient).Status -eq 'Running') 
         {LogWrite 'INFO:   AppVClient service is running, big bang fix approach not taken.'}
     Else{LogWrite 'INFO:   AppVClient service is not running, able to go for big bang fix approach.'
          
          $TargetPath = "$Env:ProgramData\Microsoft\AppV\Client\Catalog\Packages"
          LogWrite "INFO:   App-V working path for fix is $TargetPath."
          
          LogWrite "Event:  Taking ownership of $TargetPath."
          $Account = New-Object -TypeName System.Security.Principal.NTAccount -ArgumentList 'BUILTIN\Administrators';
          $ItemList = Get-ChildItem -Path $TargetPath -Recurse
          ForEach ($Item in $ItemList) 
              {$Acl = $null                                     
               $Acl = Get-Acl -Path $Item.FullName
               $Acl.SetOwner($Account)
               Set-Acl -Path $Item.FullName -AclObject $Acl} 

               #https://stackoverflow.com/questions/22988384/powershell-change-owner-of-files-and-folders

          LogWrite "Event:  Removing content from $TargetPath."
          Get-ChildItem -Path $TargetPath | Remove-Item -Force -Recurse

          If (Get-ChildItem -Path $TargetPath -Recurse)
              {LogWrite "ERROR:  Removing content failed, contents still exists."
               $ArrayScriptExitResult += '1'}
          Else{LogWrite "INFO:   Removing content Successful."}

          LogWrite 'INFO:   Attempting to start AppVClient service.'
          Start-Service -Name AppVClient
          If ($?) 
              {LogWrite 'Event:  AppVClient service started OK.'}
          Else{LogWrite 'Event:  Error starting AppVClient service.'
                         $ArrayScriptExitResult += '1'}}}

If (Test-Path $DetectionStamp) 
    {LogWrite 'Event:  Found detection key, now removing.'
     Remove-Item $DetectionStamp -Recurse -Force
     $ArrayScriptExitResult += $?}

If (((Get-ScheduledTask -TaskName $PackageName -ErrorAction SilentlyContinue).TaskName).count -eq 1)
    {LogWrite 'Event:  Found Scheduled Task, now removing.'
     Unregister-ScheduledTask -TaskName $PackageName -Confirm:$false
     $ArrayScriptExitResult += $?}

LogWrite 'Event:  Creating Task Scheduler Job.'
$Jobname      = $PackageName
$Script       = "delete $($DetectionStamp -replace ':') /f"
$Action       = New-ScheduledTaskAction –Execute 'reg.exe' -Argument  "$script"

Switch -Wildcard ($RemoveSCCMDetectionTimeUnit)
    {'Days'    {LogWrite 'Event:  Applying Scheduled Task time unit in Days.'
                $Trigger      = New-ScheduledTaskTrigger -Once -At $((Get-date).AddDays($RemoveSCCMDetection))}
     'Hours'   {LogWrite 'Event:  Applying Scheduled Task time unit in Hours.' 
                $Trigger      = New-ScheduledTaskTrigger -Once -At $((Get-date).AddHours($RemoveSCCMDetection))}
     'Minutes' {LogWrite 'Event:  Applying Scheduled Task time unit in Minutes.'
                $Trigger      = New-ScheduledTaskTrigger -Once -At $((Get-date).AddMinutes($RemoveSCCMDetection))}
     Default   {LogWrite 'ERROR:  Unknown Scheduled Task time unit.'}}

$Trigger.EndBoundary = (Get-Date).AddYears(1).ToString('s')
$Description  = 'Fix for Configuration Manager Client Error 0x87d01290, to allow SCCM re-evaluation by removing the SCCM detection key. See this page for initiating script https://gist.github.com/rileyz/93cd70d245ab99fd353a1e39f82f6708.'
$Settings     = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable -DisallowStartOnRemoteAppSession -ExecutionTimeLimit 00:05:00
$Settings.DeleteExpiredTaskAfter = 'PT0S'
Register-ScheduledTask -TaskName $Jobname -Action $Action -Trigger $Trigger -RunLevel Highest -User 'SYSTEM' -Settings $Settings -Description $Description
$ArrayScriptExitResult += $? #Capture success or failure of Register-ScheduledTask.

LogWrite 'Event:  Writing registry detection method for SCCM.'
$ArrayScriptExitResult += Write-Registry -RegistryKey $DetectionStamp -RegistryValueName 'PackageName' -RegistryValueData "$PackageName" -RegistryValueType String

LogWrite "Event:  Invoking three CCM actions."
Invoke-WMIMethod -Namespace root\ccm -Class SMS_CLIENT -Name TriggerSchedule "{00000000-0000-0000-0000-000000000021}" 
$ArrayScriptExitResult += $?
Start-Sleep -Seconds 30
Invoke-WMIMethod -Namespace root\ccm -Class SMS_CLIENT -Name TriggerSchedule "{00000000-0000-0000-0000-000000000022}" 
$ArrayScriptExitResult += $?
Start-Sleep -Seconds 30
Invoke-WMIMethod -Namespace root\ccm -Class SMS_CLIENT -Name TriggerSchedule "{00000000-0000-0000-0000-000000000121}"
$ArrayScriptExitResult += $?
Start-Sleep -Seconds 30

$SuccessCodes = @('Example','0','3010','True')                                                    #List all success codes, including reboots here.
$SuccessButNeedsRebootCodes = @('Example','3010')                                                 #List success but needs reboot code here.
$ScriptError = $ArrayScriptExitResult | Where-Object {$SuccessCodes -notcontains $_}              #Store errors found in this variable
$ScriptReboot = $ArrayScriptExitResult | Where-Object {$SuccessButNeedsRebootCodes -contains $_}  #Store success but needs reboot in this variable

If ($ScriptError -eq $null)                       #If ScriptError is empty, then everything processed ok.
        {If ($ScriptReboot -ne $null)             #If ScriptReboot is not empty, then everything processed ok, but just needs a reboot.
                {$ScriptExitResult = 'Reboot'}
            Else{$ScriptExitResult = '0'}}
    Else{$ScriptExitResult = 'Error'}

LogWrite "Event:  Result is $ScriptExitResult."
LogWrite -EndOfLog

Switch ($ScriptExitResult) 
    {'0'        {[System.Environment]::Exit(0)}
     'Reboot'   {[System.Environment]::Exit(3010)}
     'Error'    {[System.Environment]::Exit(1)}
     Default    {[System.Environment]::Exit(1)}}

#https://github.com/rileyz/VMR-Stable/blob/master/Virtual%20Machine%20Runner/Framework/%5ETemplate.ps1

#<<< End of script work >>>