############################################################################################################
#                                         Initial Setup                                                    #
#                                                                                                          #
############################################################################################################
param (
    [string[]]$customwhitelist
)

##Elevate if needed

If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]'Administrator')) {
    Write-Host "You didn't run this script as an Administrator. This script will self elevate to run as an Administrator and continue."
    Start-Sleep 1
    Write-Host "                                               3"
    Start-Sleep 1
    Write-Host "                                               2"
    Start-Sleep 1
    Write-Host "                                               1"
    Start-Sleep 1
    Start-Process powershell.exe -ArgumentList ("-NoProfile -ExecutionPolicy Bypass -File `"{0}`" -WhitelistApps {1}" -f $PSCommandPath, ($WhitelistApps -join ',')) -Verb RunAs
    Exit
}

#no errors throughout
$ErrorActionPreference = 'silentlycontinue'


#Create Folder
$DebloatFolder = "C:\ProgramData\Debloat"
If (Test-Path $DebloatFolder) {
    Write-Output "$DebloatFolder exists. Skipping."
}
Else {
    Write-Output "The folder '$DebloatFolder' doesn't exist. This folder will be used for storing logs created after the script runs. Creating now."
    Start-Sleep 1
    New-Item -Path "$DebloatFolder" -ItemType Directory
    Write-Output "The folder $DebloatFolder was successfully created."
}

Start-Transcript -Path "C:\ProgramData\Debloat\Debloat.log"

############################################################################################################
#                                        Remove AppX Packages                                              #
#                                                                                                          #
############################################################################################################

#Removes AppxPackages
$WhitelistedApps = 'Microsoft.WindowsNotepad|Microsoft.CompanyPortal|Microsoft.ScreenSketch|Microsoft.Paint3D|Microsoft.WindowsCalculator|Microsoft.WindowsStore|Microsoft.Windows.Photos|CanonicalGroupLimited.UbuntuonWindows|`
    |Microsoft.MicrosoftStickyNotes|Microsoft.MSPaint|Microsoft.WindowsCamera|.NET|Framework|`
    Microsoft.HEIFImageExtension|Microsoft.ScreenSketch|Microsoft.StorePurchaseApp|Microsoft.VP9VideoExtensions|Microsoft.WebMediaExtensions|Microsoft.WebpImageExtension|Microsoft.DesktopAppInstaller|WindSynthBerry|MIDIBerry|Slack'
##If $customwhitelist is set, split on the comma and add to whitelist
if ($customwhitelist) {
    $customWhitelistApps = $customwhitelist -split ","
    $WhitelistedApps += "|"
    $WhitelistedApps += $customWhitelistApps -join "|"
}
    
#NonRemovable Apps that where getting attempted and the system would reject the uninstall, speeds up debloat and prevents 'initalizing' overlay when removing apps
$NonRemovable = '1527c705-839a-4832-9118-54d4Bd6a0c89|c5e2524a-ea46-4f67-841f-6a9465d9d515|E2A4F912-2574-4A75-9BB0-0D023378592B|F46D4000-FD22-4DB4-AC8E-4E1DDDE828FE|InputApp|Microsoft.AAD.BrokerPlugin|Microsoft.AccountsControl|`
    Microsoft.BioEnrollment|Microsoft.CredDialogHost|Microsoft.ECApp|Microsoft.LockApp|Microsoft.MicrosoftEdgeDevToolsClient|Microsoft.MicrosoftEdge|Microsoft.PPIProjection|Microsoft.Win32WebViewHost|Microsoft.Windows.Apprep.ChxApp|`
    Microsoft.Windows.AssignedAccessLockApp|Microsoft.Windows.CapturePicker|Microsoft.Windows.CloudExperienceHost|Microsoft.Windows.ContentDeliveryManager|Microsoft.Windows.Cortana|Microsoft.Windows.NarratorQuickStart|`
    Microsoft.Windows.ParentalControls|Microsoft.Windows.PeopleExperienceHost|Microsoft.Windows.PinningConfirmationDialog|Microsoft.Windows.SecHealthUI|Microsoft.Windows.SecureAssessmentBrowser|Microsoft.Windows.ShellExperienceHost|`
    Microsoft.Windows.XGpuEjectDialog|Microsoft.XboxGameCallableUI|Windows.CBSPreview|windows.immersivecontrolpanel|Windows.PrintDialog|Microsoft.XboxGameCallableUI|Microsoft.VCLibs.140.00|Microsoft.Services.Store.Engagement|Microsoft.UI.Xaml.2.0|*Nvidia*'
Get-AppxPackage -AllUsers | Where-Object { $_.Name -NotMatch $WhitelistedApps -and $_.Name -NotMatch $NonRemovable } | Remove-AppxPackage
Get-AppxPackage -allusers | Where-Object { $_.Name -NotMatch $WhitelistedApps -and $_.Name -NotMatch $NonRemovable } | Remove-AppxPackage
Get-AppxProvisionedPackage -Online | Where-Object { $_.PackageName -NotMatch $WhitelistedApps -and $_.PackageName -NotMatch $NonRemovable } | Remove-AppxProvisionedPackage -Online


##Remove bloat
$Bloatware = @(
    #Unnecessary Windows 10/11 AppX Apps
    "Microsoft.549981C3F5F10"
    "Microsoft.BingNews"
    "Microsoft.GetHelp"
    "Microsoft.Getstarted"
    "Microsoft.Messaging"
    "Microsoft.Microsoft3DViewer"
    "Microsoft.MicrosoftOfficeHub"
    "Microsoft.MicrosoftSolitaireCollection"
    "Microsoft.NetworkSpeedTest"
    "Microsoft.MixedReality.Portal"
    "Microsoft.News"
    "Microsoft.Office.Lens"
    "Microsoft.Office.OneNote"
    "Microsoft.Office.Sway"
    "Microsoft.OneConnect"
    "Microsoft.People"
    "Microsoft.Print3D"
    "Microsoft.RemoteDesktop"
    "Microsoft.SkypeApp"
    "Microsoft.StorePurchaseApp"
    "Microsoft.Office.Todo.List"
    "Microsoft.Whiteboard"
    "Microsoft.WindowsAlarms"
    #"Microsoft.WindowsCamera"
    "microsoft.windowscommunicationsapps"
    "Microsoft.WindowsFeedbackHub"
    "Microsoft.WindowsMaps"
    "Microsoft.WindowsSoundRecorder"
    "Microsoft.Xbox.TCUI"
    "Microsoft.XboxApp"
    "Microsoft.XboxGameOverlay"
    "Microsoft.XboxIdentityProvider"
    "Microsoft.XboxSpeechToTextOverlay"
    "Microsoft.ZuneMusic"
    "Microsoft.ZuneVideo"
    "MicrosoftTeams"
    "MSTeams"
    "Microsoft.YourPhone"
    "Microsoft.XboxGamingOverlay_5.721.10202.0_neutral_~_8wekyb3d8bbwe"
    "Microsoft.GamingApp"
    "Microsoft.Todos"
    "Microsoft.PowerAutomateDesktop"
    "SpotifyAB.SpotifyMusic"
    "Microsoft.MicrosoftJournal"
    "Disney.37853FC22B2CE"
    "*EclipseManager*"
    "*ActiproSoftwareLLC*"
    "*AdobeSystemsIncorporated.AdobePhotoshopExpress*"
    "*Duolingo-LearnLanguagesforFree*"
    "*PandoraMediaInc*"
    "*CandyCrush*"
    "*BubbleWitch3Saga*"
    "*Wunderlist*"
    "*Flipboard*"
    "*Twitter*"
    "*Facebook*"
    "*Spotify*"
    "*Minecraft*"
    "*Royal Revolt*"
    "*Sway*"
    "*Speed Test*"
    "*Dolby*"
    "*Office*"
    "*Disney*"
    "clipchamp.clipchamp"
    "*gaming*"
    "MicrosoftCorporationII.MicrosoftFamily"
    "C27EB4BA.DropboxOEM*"
    "*DevHome*"
    #Optional: Typically not removed but you can if you need to for some reason
    #"*Microsoft.Advertising.Xaml_10.1712.5.0_x64__8wekyb3d8bbwe*"
    #"*Microsoft.Advertising.Xaml_10.1712.5.0_x86__8wekyb3d8bbwe*"
    #"*Microsoft.BingWeather*"
    #"*Microsoft.MSPaint*"
    #"*Microsoft.MicrosoftStickyNotes*"
    #"*Microsoft.Windows.Photos*"
    #"*Microsoft.WindowsCalculator*"
    #"*Microsoft.WindowsStore*"
)
##If custom whitelist specified, remove from array
if ($customwhitelist) {
    $customWhitelistApps = $customwhitelist -split ","
    $Bloatware = $Bloatware | Where-Object { $customWhitelistApps -notcontains $_ }
}


foreach ($Bloat in $Bloatware) {
    if (Get-AppxPackage -Name $Bloat -ErrorAction SilentlyContinue) {
        Get-AppxPackage -AllUsers -Name $Bloat | Remove-AppxPackage -AllUsers
        Write-Host "Removed $Bloat." -ForegroundColor Green
    }
    else {
        Write-Host "$Bloat not found."
    }
        
    if (Get-AppxProvisionedPackage -Online | Where-Object DisplayName -like $Bloat -ErrorAction SilentlyContinue) {
        Get-AppxProvisionedPackage -Online | Where-Object DisplayName -like $Bloat | Remove-AppxProvisionedPackage -AllUsers -Online
        Write-Host "Removed provisioned package for $Bloat." -ForegroundColor Green
    }
    else {
        Write-Host "Provisioned package for $Bloat not found."
    }
}
############################################################################################################
#                                        Remove Registry Keys                                              #
#                                                                                                          #
############################################################################################################

##We need to grab all SIDs to remove at user level
$UserSIDs = Get-ChildItem "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList" | Select-Object -ExpandProperty PSChildName

    
#These are the registry keys that it will delete.
            
$Keys = @(
            
    #Remove Background Tasks
    "HKCR:\Extensions\ContractId\Windows.BackgroundTasks\PackageId\46928bounde.EclipseManager_2.2.4.51_neutral__a5h4egax66k6y"
    "HKCR:\Extensions\ContractId\Windows.BackgroundTasks\PackageId\ActiproSoftwareLLC.562882FEEB491_2.6.18.18_neutral__24pqs290vpjk0"
    "HKCR:\Extensions\ContractId\Windows.BackgroundTasks\PackageId\Microsoft.MicrosoftOfficeHub_17.7909.7600.0_x64__8wekyb3d8bbwe"
    "HKCR:\Extensions\ContractId\Windows.BackgroundTasks\PackageId\Microsoft.PPIProjection_10.0.15063.0_neutral_neutral_cw5n1h2txyewy"
    "HKCR:\Extensions\ContractId\Windows.BackgroundTasks\PackageId\Microsoft.XboxGameCallableUI_1000.15063.0.0_neutral_neutral_cw5n1h2txyewy"
    "HKCR:\Extensions\ContractId\Windows.BackgroundTasks\PackageId\Microsoft.XboxGameCallableUI_1000.16299.15.0_neutral_neutral_cw5n1h2txyewy"
            
    #Windows File
    "HKCR:\Extensions\ContractId\Windows.File\PackageId\ActiproSoftwareLLC.562882FEEB491_2.6.18.18_neutral__24pqs290vpjk0"
            
    #Registry keys to delete if they aren't uninstalled by RemoveAppXPackage/RemoveAppXProvisionedPackage
    "HKCR:\Extensions\ContractId\Windows.Launch\PackageId\46928bounde.EclipseManager_2.2.4.51_neutral__a5h4egax66k6y"
    "HKCR:\Extensions\ContractId\Windows.Launch\PackageId\ActiproSoftwareLLC.562882FEEB491_2.6.18.18_neutral__24pqs290vpjk0"
    "HKCR:\Extensions\ContractId\Windows.Launch\PackageId\Microsoft.PPIProjection_10.0.15063.0_neutral_neutral_cw5n1h2txyewy"
    "HKCR:\Extensions\ContractId\Windows.Launch\PackageId\Microsoft.XboxGameCallableUI_1000.15063.0.0_neutral_neutral_cw5n1h2txyewy"
    "HKCR:\Extensions\ContractId\Windows.Launch\PackageId\Microsoft.XboxGameCallableUI_1000.16299.15.0_neutral_neutral_cw5n1h2txyewy"
            
    #Scheduled Tasks to delete
    "HKCR:\Extensions\ContractId\Windows.PreInstalledConfigTask\PackageId\Microsoft.MicrosoftOfficeHub_17.7909.7600.0_x64__8wekyb3d8bbwe"
            
    #Windows Protocol Keys
    "HKCR:\Extensions\ContractId\Windows.Protocol\PackageId\ActiproSoftwareLLC.562882FEEB491_2.6.18.18_neutral__24pqs290vpjk0"
    "HKCR:\Extensions\ContractId\Windows.Protocol\PackageId\Microsoft.PPIProjection_10.0.15063.0_neutral_neutral_cw5n1h2txyewy"
    "HKCR:\Extensions\ContractId\Windows.Protocol\PackageId\Microsoft.XboxGameCallableUI_1000.15063.0.0_neutral_neutral_cw5n1h2txyewy"
    "HKCR:\Extensions\ContractId\Windows.Protocol\PackageId\Microsoft.XboxGameCallableUI_1000.16299.15.0_neutral_neutral_cw5n1h2txyewy"
               
    #Windows Share Target
    "HKCR:\Extensions\ContractId\Windows.ShareTarget\PackageId\ActiproSoftwareLLC.562882FEEB491_2.6.18.18_neutral__24pqs290vpjk0"
)
        
#This writes the output of each key it is removing and also removes the keys listed above.
ForEach ($Key in $Keys) {
    Write-Host "Removing $Key from registry"
    Remove-Item $Key -Recurse
}


#Disables Windows Feedback Experience
Write-Host "Disabling Windows Feedback Experience program"
$Advertising = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo"
If (!(Test-Path $Advertising)) {
    New-Item $Advertising
}
If (Test-Path $Advertising) {
    Set-ItemProperty $Advertising Enabled -Value 0 
}
            
#Stops Cortana from being used as part of your Windows Search Function
Write-Host "Stopping Cortana from being used as part of your Windows Search Function"
$Search = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search"
If (!(Test-Path $Search)) {
    New-Item $Search
}
If (Test-Path $Search) {
    Set-ItemProperty $Search AllowCortana -Value 0 
}

#Disables Web Search in Start Menu
Write-Host "Disabling Bing Search in Start Menu"
$WebSearch = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search"
If (!(Test-Path $WebSearch)) {
    New-Item $WebSearch
}
Set-ItemProperty $WebSearch DisableWebSearch -Value 1 
##Loop through all user SIDs in the registry and disable Bing Search
foreach ($sid in $UserSIDs) {
    $WebSearch = "Registry::HKU\$sid\SOFTWARE\Microsoft\Windows\CurrentVersion\Search"
    If (!(Test-Path $WebSearch)) {
        New-Item $WebSearch
    }
    Set-ItemProperty $WebSearch BingSearchEnabled -Value 0
}
    
Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" BingSearchEnabled -Value 0 

            
#Stops the Windows Feedback Experience from sending anonymous data
Write-Host "Stopping the Windows Feedback Experience program"
$Period = "HKCU:\Software\Microsoft\Siuf\Rules"
If (!(Test-Path $Period)) { 
    New-Item $Period
}
Set-ItemProperty $Period PeriodInNanoSeconds -Value 0 

##Loop and do the same
foreach ($sid in $UserSIDs) {
    $Period = "Registry::HKU\$sid\Software\Microsoft\Siuf\Rules"
    If (!(Test-Path $Period)) { 
        New-Item $Period
    }
    Set-ItemProperty $Period PeriodInNanoSeconds -Value 0 
}

#Prevents bloatware applications from returning and removes Start Menu suggestions               
Write-Host "Adding Registry key to prevent bloatware apps from returning"
$registryPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent"
$registryOEM = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"
If (!(Test-Path $registryPath)) { 
    New-Item $registryPath
}
Set-ItemProperty $registryPath DisableWindowsConsumerFeatures -Value 1 

If (!(Test-Path $registryOEM)) {
    New-Item $registryOEM
}
Set-ItemProperty $registryOEM  ContentDeliveryAllowed -Value 0 
Set-ItemProperty $registryOEM  OemPreInstalledAppsEnabled -Value 0 
Set-ItemProperty $registryOEM  PreInstalledAppsEnabled -Value 0 
Set-ItemProperty $registryOEM  PreInstalledAppsEverEnabled -Value 0 
Set-ItemProperty $registryOEM  SilentInstalledAppsEnabled -Value 0 
Set-ItemProperty $registryOEM  SystemPaneSuggestionsEnabled -Value 0  
    
##Loop through users and do the same
foreach ($sid in $UserSIDs) {
    $registryOEM = "Registry::HKU\$sid\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"
    If (!(Test-Path $registryOEM)) {
        New-Item $registryOEM
    }
    Set-ItemProperty $registryOEM  ContentDeliveryAllowed -Value 0 
    Set-ItemProperty $registryOEM  OemPreInstalledAppsEnabled -Value 0 
    Set-ItemProperty $registryOEM  PreInstalledAppsEnabled -Value 0 
    Set-ItemProperty $registryOEM  PreInstalledAppsEverEnabled -Value 0 
    Set-ItemProperty $registryOEM  SilentInstalledAppsEnabled -Value 0 
    Set-ItemProperty $registryOEM  SystemPaneSuggestionsEnabled -Value 0 
}
 
#Preping mixed Reality Portal for removal    
Write-Host "Setting Mixed Reality Portal value to 0 so that you can uninstall it in Settings"
$Holo = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Holographic"    
If (Test-Path $Holo) {
    Set-ItemProperty $Holo  FirstRunSucceeded -Value 0 
}

##Loop through users and do the same
foreach ($sid in $UserSIDs) {
    $Holo = "Registry::HKU\$sid\Software\Microsoft\Windows\CurrentVersion\Holographic"    
    If (Test-Path $Holo) {
        Set-ItemProperty $Holo  FirstRunSucceeded -Value 0 
    }
}

#Disables Wi-fi Sense
Write-Host "Disabling Wi-Fi Sense"
$WifiSense1 = "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\WiFi\AllowWiFiHotSpotReporting"
$WifiSense2 = "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\WiFi\AllowAutoConnectToWiFiSenseHotspots"
$WifiSense3 = "HKLM:\SOFTWARE\Microsoft\WcmSvc\wifinetworkmanager\config"
If (!(Test-Path $WifiSense1)) {
    New-Item $WifiSense1
}
Set-ItemProperty $WifiSense1  Value -Value 0 
If (!(Test-Path $WifiSense2)) {
    New-Item $WifiSense2
}
Set-ItemProperty $WifiSense2  Value -Value 0 
Set-ItemProperty $WifiSense3  AutoConnectAllowedOEM -Value 0 

#Disables People icon on Taskbar
Write-Host "Disabling People icon on Taskbar"
$People = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People'
If (Test-Path $People) {
    Set-ItemProperty $People -Name PeopleBand -Value 0
}

##Loop through users and do the same
foreach ($sid in $UserSIDs) {
    $People = "Registry::HKU\$sid\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People"
    If (Test-Path $People) {
        Set-ItemProperty $People -Name PeopleBand -Value 0
    }
}

Write-Host "Disabling Cortana"
$Cortana1 = "HKCU:\SOFTWARE\Microsoft\Personalization\Settings"
$Cortana2 = "HKCU:\SOFTWARE\Microsoft\InputPersonalization"
$Cortana3 = "HKCU:\SOFTWARE\Microsoft\InputPersonalization\TrainedDataStore"
If (!(Test-Path $Cortana1)) {
    New-Item $Cortana1
}
Set-ItemProperty $Cortana1 AcceptedPrivacyPolicy -Value 0 
If (!(Test-Path $Cortana2)) {
    New-Item $Cortana2
}
Set-ItemProperty $Cortana2 RestrictImplicitTextCollection -Value 1 
Set-ItemProperty $Cortana2 RestrictImplicitInkCollection -Value 1 
If (!(Test-Path $Cortana3)) {
    New-Item $Cortana3
}
Set-ItemProperty $Cortana3 HarvestContacts -Value 0

##Loop through users and do the same
foreach ($sid in $UserSIDs) {
    $Cortana1 = "Registry::HKU\$sid\SOFTWARE\Microsoft\Personalization\Settings"
    $Cortana2 = "Registry::HKU\$sid\SOFTWARE\Microsoft\InputPersonalization"
    $Cortana3 = "Registry::HKU\$sid\SOFTWARE\Microsoft\InputPersonalization\TrainedDataStore"
    If (!(Test-Path $Cortana1)) {
        New-Item $Cortana1
    }
    Set-ItemProperty $Cortana1 AcceptedPrivacyPolicy -Value 0 
    If (!(Test-Path $Cortana2)) {
        New-Item $Cortana2
    }
    Set-ItemProperty $Cortana2 RestrictImplicitTextCollection -Value 1 
    Set-ItemProperty $Cortana2 RestrictImplicitInkCollection -Value 1 
    If (!(Test-Path $Cortana3)) {
        New-Item $Cortana3
    }
    Set-ItemProperty $Cortana3 HarvestContacts -Value 0
}


#Removes 3D Objects from the 'My Computer' submenu in explorer
Write-Host "Removing 3D Objects from explorer 'My Computer' submenu"
$Objects32 = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{0DB7E03F-FC29-4DC6-9020-FF41B59E513A}"
$Objects64 = "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{0DB7E03F-FC29-4DC6-9020-FF41B59E513A}"
If (Test-Path $Objects32) {
    Remove-Item $Objects32 -Recurse 
}
If (Test-Path $Objects64) {
    Remove-Item $Objects64 -Recurse 
}

##Kill Cortana again
Get-AppxPackage - allusers Microsoft.549981C3F5F10 | Remove AppxPackage

############################################################################################################
#                                        Remove Scheduled Tasks                                            #
#                                                                                                          #
############################################################################################################

#Disables scheduled tasks that are considered unnecessary 
Write-Host "Disabling scheduled tasks"
$task1 = Get-ScheduledTask -TaskName XblGameSaveTaskLogon -ErrorAction SilentlyContinue
if ($null -ne $task1) {
    Get-ScheduledTask  XblGameSaveTaskLogon | Disable-ScheduledTask -ErrorAction SilentlyContinue
}
$task2 = Get-ScheduledTask -TaskName XblGameSaveTask -ErrorAction SilentlyContinue
if ($null -ne $task2) {
    Get-ScheduledTask  XblGameSaveTask | Disable-ScheduledTask -ErrorAction SilentlyContinue
}
$task3 = Get-ScheduledTask -TaskName Consolidator -ErrorAction SilentlyContinue
if ($null -ne $task3) {
    Get-ScheduledTask  Consolidator | Disable-ScheduledTask -ErrorAction SilentlyContinue
}
$task4 = Get-ScheduledTask -TaskName UsbCeip -ErrorAction SilentlyContinue
if ($null -ne $task4) {
    Get-ScheduledTask  UsbCeip | Disable-ScheduledTask -ErrorAction SilentlyContinue
}
$task5 = Get-ScheduledTask -TaskName DmClient -ErrorAction SilentlyContinue
if ($null -ne $task5) {
    Get-ScheduledTask  DmClient | Disable-ScheduledTask -ErrorAction SilentlyContinue
}
$task6 = Get-ScheduledTask -TaskName DmClientOnScenarioDownload -ErrorAction SilentlyContinue
if ($null -ne $task6) {
    Get-ScheduledTask  DmClientOnScenarioDownload | Disable-ScheduledTask -ErrorAction SilentlyContinue
}

############################################################################################################
#                                        Windows 11 Specific                                               #
#                                                                                                          #
############################################################################################################
#Windows 11 Customisations
write-host "Removing Windows 11 Customisations"
#Remove XBox Game Bar
    
$packages = @(
    "Microsoft.XboxGamingOverlay",
    "Microsoft.XboxGameCallableUI",
    "Microsoft.549981C3F5F10",
    "*getstarted*",
    "Microsoft.Windows.ParentalControls"
)
##If custom whitelist specified, remove from array
if ($customwhitelist) {
    $customWhitelistApps = $customwhitelist -split ","
    $packages = $packages | Where-Object { $customWhitelistApps -notcontains $_ }
}
    

foreach ($package in $packages) {
    $appPackage = Get-AppxPackage -allusers $package -ErrorAction SilentlyContinue
    if ($appPackage) {
        Remove-AppxPackage -Package $appPackage.PackageFullName -AllUsers
        Write-Host "Removed $package"
    }
}

#Remove Teams Chat
$MSTeams = "MicrosoftTeams"

$WinPackage = Get-AppxPackage -allusers | Where-Object { $_.Name -eq $MSTeams }
$ProvisionedPackage = Get-AppxProvisionedPackage -Online | Where-Object { $_.DisplayName -eq $WinPackage }
If ($null -ne $WinPackage) {
    Remove-AppxPackage  -Package $WinPackage.PackageFullName -AllUsers
} 

If ($null -ne $ProvisionedPackage) {
    Remove-AppxProvisionedPackage -online -Packagename $ProvisionedPackage.Packagename -AllUsers
}

##Tweak reg permissions
invoke-webrequest -uri "https://github.com/andrew-s-taylor/public/raw/main/De-Bloat/SetACL.exe" -outfile "C:\Windows\Temp\SetACL.exe"
C:\Windows\Temp\SetACL.exe -on "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Communications" -ot reg -actn setowner -ownr "n:$everyone"
C:\Windows\Temp\SetACL.exe -on "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Communications" -ot reg -actn ace -ace "n:$everyone;p:full"


##Stop it coming back
$registryPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Communications"
If (!(Test-Path $registryPath)) { 
    New-Item $registryPath
}
Set-ItemProperty $registryPath ConfigureChatAutoInstall -Value 0


##Unpin it
$registryPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Chat"
If (!(Test-Path $registryPath)) { 
    New-Item $registryPath
}
Set-ItemProperty $registryPath "ChatIcon" -Value 2
write-host "Removed Teams Chat"

############################################################################################################
#                                           Windows Backup App                                             #
#                                                                                                          #
############################################################################################################
$version = Get-CimInstance Win32_OperatingSystem | Select-Object -ExpandProperty Caption
if ($version -like "*Windows 10*") {
    write-host "Removing Windows Backup"
    $filepath = "C:\Windows\SystemApps\MicrosoftWindows.Client.CBS_cw5n1h2txyewy\WindowsBackup\Assets"
    if (Test-Path $filepath) {
        Remove-WindowsPackage -Online -PackageName "Microsoft-Windows-UserExperience-Desktop-Package~31bf3856ad364e35~amd64~~10.0.19041.3393"

        ##Add back snipping tool functionality
        write-host "Adding Windows Shell Components"
        DISM /Online /Add-Capability /CapabilityName:Windows.Client.ShellComponents~~~~0.0.1.0
        write-host "Components Added"
    }
    write-host "Removed"
}

############################################################################################################
#                                           Windows CoPilot                                                #
#                                                                                                          #
############################################################################################################
$version = Get-CimInstance Win32_OperatingSystem | Select-Object -ExpandProperty Caption
if ($version -like "*Windows 11*") {
    write-host "Removing Windows Copilot"
    # Define the registry key and value
    $registryPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot"
    $propertyName = "TurnOffWindowsCopilot"
    $propertyValue = 1

    # Check if the registry key exists
    if (!(Test-Path $registryPath)) {
        # If the registry key doesn't exist, create it
        New-Item -Path $registryPath -Force | Out-Null
    }

    # Get the property value
    $currentValue = Get-ItemProperty -Path $registryPath -Name $propertyName -ErrorAction SilentlyContinue

    # Check if the property exists and if its value is different from the desired value
    if ($null -eq $currentValue -or $currentValue.$propertyName -ne $propertyValue) {
        # If the property doesn't exist or its value is different, set the property value
        Set-ItemProperty -Path $registryPath -Name $propertyName -Value $propertyValue
    }


    ##Grab the default user as well
    $registryPath = "HKEY_USERS\.DEFAULT\Software\Policies\Microsoft\Windows\WindowsCopilot"
    $propertyName = "TurnOffWindowsCopilot"
    $propertyValue = 1

    # Check if the registry key exists
    if (!(Test-Path $registryPath)) {
        # If the registry key doesn't exist, create it
        New-Item -Path $registryPath -Force | Out-Null
    }

    # Get the property value
    $currentValue = Get-ItemProperty -Path $registryPath -Name $propertyName -ErrorAction SilentlyContinue

    # Check if the property exists and if its value is different from the desired value
    if ($null -eq $currentValue -or $currentValue.$propertyName -ne $propertyValue) {
        # If the property doesn't exist or its value is different, set the property value
        Set-ItemProperty -Path $registryPath -Name $propertyName -Value $propertyValue
    }


    ##Load the default hive from c:\users\Default\NTUSER.dat
    reg load HKU\temphive "c:\users\default\ntuser.dat"
    $registryPath = "registry::hku\temphive\Software\Policies\Microsoft\Windows\WindowsCopilot"
    $propertyName = "TurnOffWindowsCopilot"
    $propertyValue = 1

    # Check if the registry key exists
    if (!(Test-Path $registryPath)) {
        # If the registry key doesn't exist, create it
        [Microsoft.Win32.RegistryKey]$HKUCoPilot = [Microsoft.Win32.Registry]::Users.CreateSubKey("temphive\Software\Policies\Microsoft\Windows\WindowsCopilot", [Microsoft.Win32.RegistryKeyPermissionCheck]::ReadWriteSubTree)
        $HKUCoPilot.SetValue("TurnOffWindowsCopilot", 0x1, [Microsoft.Win32.RegistryValueKind]::DWord)
    }

        



    $HKUCoPilot.Flush()
    $HKUCoPilot.Close()
    [gc]::Collect()
    [gc]::WaitForPendingFinalizers()
    reg unload HKU\temphive


    write-host "Removed"


    foreach ($sid in $UserSIDs) {
        $registryPath = "Registry::HKU\$sid\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot"
        $propertyName = "TurnOffWindowsCopilot"
        $propertyValue = 1
    
        # Check if the registry key exists
        if (!(Test-Path $registryPath)) {
            # If the registry key doesn't exist, create it
            New-Item -Path $registryPath -Force | Out-Null
        }
    
        # Get the property value
        $currentValue = Get-ItemProperty -Path $registryPath -Name $propertyName -ErrorAction SilentlyContinue
    
        # Check if the property exists and if its value is different from the desired value
        if ($null -eq $currentValue -or $currentValue.$propertyName -ne $propertyValue) {
            # If the property doesn't exist or its value is different, set the property value
            Set-ItemProperty -Path $registryPath -Name $propertyName -Value $propertyValue
        }
    }
}

############################################################################################################
#                                              Remove Xbox Gaming                                          #
#                                                                                                          #
############################################################################################################

New-ItemProperty -Path "HKLM:\System\CurrentControlSet\Services\xbgm" -Name "Start" -PropertyType DWORD -Value 4 -Force
Set-Service -Name XblAuthManager -StartupType Disabled
Set-Service -Name XblGameSave -StartupType Disabled
Set-Service -Name XboxGipSvc -StartupType Disabled
Set-Service -Name XboxNetApiSvc -StartupType Disabled
$task = Get-ScheduledTask -TaskName "Microsoft\XblGameSave\XblGameSaveTask" -ErrorAction SilentlyContinue
if ($null -ne $task) {
    Set-ScheduledTask -TaskPath $task.TaskPath -Enabled $false
}

##Check if GamePresenceWriter.exe exists
if (Test-Path "$env:WinDir\System32\GameBarPresenceWriter.exe") {
    write-host "GamePresenceWriter.exe exists"
    C:\Windows\Temp\SetACL.exe -on  "$env:WinDir\System32\GameBarPresenceWriter.exe" -ot file -actn setowner -ownr "n:$everyone"
    C:\Windows\Temp\SetACL.exe -on  "$env:WinDir\System32\GameBarPresenceWriter.exe" -ot file -actn ace -ace "n:$everyone;p:full"

    #Take-Ownership -Path "$env:WinDir\System32\GameBarPresenceWriter.exe"
    $NewAcl = Get-Acl -Path "$env:WinDir\System32\GameBarPresenceWriter.exe"
    # Set properties
    $identity = "$builtin\Administrators"
    $fileSystemRights = "FullControl"
    $type = "Allow"
    # Create new rule
    $fileSystemAccessRuleArgumentList = $identity, $fileSystemRights, $type
    $fileSystemAccessRule = New-Object -TypeName System.Security.AccessControl.FileSystemAccessRule -ArgumentList $fileSystemAccessRuleArgumentList
    # Apply new rule
    $NewAcl.SetAccessRule($fileSystemAccessRule)
    Set-Acl -Path "$env:WinDir\System32\GameBarPresenceWriter.exe" -AclObject $NewAcl
    Stop-Process -Name "GameBarPresenceWriter.exe" -Force
    Remove-Item "$env:WinDir\System32\GameBarPresenceWriter.exe" -Force -Confirm:$false

}
else {
    write-host "GamePresenceWriter.exe does not exist"
}

New-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\GameDVR" -Name "AllowgameDVR" -PropertyType DWORD -Value 0 -Force
New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name "SettingsPageVisibility" -PropertyType String -Value "hide:gaming-gamebar;gaming-gamedvr;gaming-broadcasting;gaming-gamemode;gaming-xboxnetworking" -Force
Remove-Item C:\Windows\Temp\SetACL.exe -recurse

############################################################################################################
#                                        Disable Edge Surf Game                                            #
#                                                                                                          #
############################################################################################################
$surf = "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Edge"
If (!(Test-Path $surf)) {
    New-Item $surf
}
New-ItemProperty -Path $surf -Name 'AllowSurfGame' -Value 0 -PropertyType DWord

############################################################################################################
#                                       Grab all Uninstall Strings                                         #
#                                                                                                          #
############################################################################################################


write-host "Checking 32-bit System Registry"
##Search for 32-bit versions and list them
$allstring = @()
$path1 = "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall"
#Loop Through the apps if name has Adobe and NOT reader
$32apps = Get-ChildItem -Path $path1 | Get-ItemProperty | Select-Object -Property DisplayName, UninstallString

foreach ($32app in $32apps) {
    #Get uninstall string
    $string1 = $32app.uninstallstring
    #Check if it's an MSI install
    if ($string1 -match "^msiexec*") {
        #MSI install, replace the I with an X and make it quiet
        $string2 = $string1 + " /quiet /norestart"
        $string2 = $string2 -replace "/I", "/X "
        #Create custom object with name and string
        $allstring += New-Object -TypeName PSObject -Property @{
            Name   = $32app.DisplayName
            String = $string2
        }
    }
    else {
        #Exe installer, run straight path
        $string2 = $string1
        $allstring += New-Object -TypeName PSObject -Property @{
            Name   = $32app.DisplayName
            String = $string2
        }
    }

}
write-host "32-bit check complete"
write-host "Checking 64-bit System registry"
##Search for 64-bit versions and list them

$path2 = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall"
#Loop Through the apps if name has Adobe and NOT reader
$64apps = Get-ChildItem -Path $path2 | Get-ItemProperty | Select-Object -Property DisplayName, UninstallString

foreach ($64app in $64apps) {
    #Get uninstall string
    $string1 = $64app.uninstallstring
    #Check if it's an MSI install
    if ($string1 -match "^msiexec*") {
        #MSI install, replace the I with an X and make it quiet
        $string2 = $string1 + " /quiet /norestart"
        $string2 = $string2 -replace "/I", "/X "
        #Uninstall with string2 params
        $allstring += New-Object -TypeName PSObject -Property @{
            Name   = $64app.DisplayName
            String = $string2
        }
    }
    else {
        #Exe installer, run straight path
        $string2 = $string1
        $allstring += New-Object -TypeName PSObject -Property @{
            Name   = $64app.DisplayName
            String = $string2
        }
    }

}

write-host "64-bit checks complete"

##USER
write-host "Checking 32-bit User Registry"
##Search for 32-bit versions and list them
$path1 = "HKCU:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall"
##Check if path exists
if (Test-Path $path1) {
    #Loop Through the apps if name has Adobe and NOT reader
    $32apps = Get-ChildItem -Path $path1 | Get-ItemProperty | Select-Object -Property DisplayName, UninstallString

    foreach ($32app in $32apps) {
        #Get uninstall string
        $string1 = $32app.uninstallstring
        #Check if it's an MSI install
        if ($string1 -match "^msiexec*") {
            #MSI install, replace the I with an X and make it quiet
            $string2 = $string1 + " /quiet /norestart"
            $string2 = $string2 -replace "/I", "/X "
            #Create custom object with name and string
            $allstring += New-Object -TypeName PSObject -Property @{
                Name   = $32app.DisplayName
                String = $string2
            }
        }
        else {
            #Exe installer, run straight path
            $string2 = $string1
            $allstring += New-Object -TypeName PSObject -Property @{
                Name   = $32app.DisplayName
                String = $string2
            }
        }
    }
}
write-host "32-bit check complete"
write-host "Checking 64-bit User registry"
##Search for 64-bit versions and list them

$path2 = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall"
#Loop Through the apps if name has Adobe and NOT reader
$64apps = Get-ChildItem -Path $path2 | Get-ItemProperty | Select-Object -Property DisplayName, UninstallString

foreach ($64app in $64apps) {
    #Get uninstall string
    $string1 = $64app.uninstallstring
    #Check if it's an MSI install
    if ($string1 -match "^msiexec*") {
        #MSI install, replace the I with an X and make it quiet
        $string2 = $string1 + " /quiet /norestart"
        $string2 = $string2 -replace "/I", "/X "
        #Uninstall with string2 params
        $allstring += New-Object -TypeName PSObject -Property @{
            Name   = $64app.DisplayName
            String = $string2
        }
    }
    else {
        #Exe installer, run straight path
        $string2 = $string1
        $allstring += New-Object -TypeName PSObject -Property @{
            Name   = $64app.DisplayName
            String = $string2
        }
    }

}

Stop-Transcript

if (Test-Path "C:\ProgramData\AutopilotConfig") {
    New-Item -Path "C:\ProgramData\AutopilotConfig" -Name "DeBloat.tag" -ItemType File -Value "Tag"
}
else {
    New-Item -Path "C:\ProgramData" -Name "AutopilotConfig" -ItemType Directory
    New-Item -Path "C:\ProgramData\AutopilotConfig" -Name "DeBloat.tag" -ItemType File -Value "Tag"
}

return 0
exit 0