<#
.SYNOPSIS
    Sets default start menu layout and removes store from taskbar.
.INPUTS
  None
.OUTPUTS
  None
.NOTES
  Version:        1.0
  Author:         Chris Rockwell
  Creation Date:  2023-06-19
  Purpose/Change: Remove Store from taskbar
.EXAMPLE
  .\StartLayout.ps1
  Removes Store from taskbar
  Run as administrator
#>

#Set function for taskbar cleanup
function unpin_taskbar([string]$appname) {
    ((New-Object -Com Shell.Application).NameSpace('shell:::{4234d49b-0245-4df3-b780-3893943456e1}').Items() |
    Where-Object { $_.Name -eq $appname }).Verbs() | Where-Object { $_.Name.replace('&', '') -match 'Unpin from taskbar' } | ForEach-Object { $_.DoIt() }
}

#Test if path for xml exists
if (!(Test-Path "C:\ProgramData\AutopilotConfig\StartLayout")) {
    New-Item -Path "C:\ProgramData\AutopilotConfig" -Name "StartLayout" -ItemType Directory
}

#Create XML file
$File = 'C:\ProgramData\AutopilotConfig\StartLayout\StartLayout.xml'
@"
<?xml version="1.0" encoding="UTF-8"?>
<LayoutModificationTemplate xmlns:defaultlayout="http://schemas.microsoft.com/Start/2014/FullDefaultLayout" xmlns:start="http://schemas.microsoft.com/Start/2014/StartLayout" Version="1" xmlns="http://schemas.microsoft.com/Start/2014/LayoutModification">
  <LayoutOptions StartTileGroupCellWidth="6" />
  <DefaultLayoutOverride>
    <StartLayoutCollection>
      <defaultlayout:StartLayout GroupCellWidth="6">
        <start:Group Name="">
          <start:DesktopApplicationTile Size="2x2" Column="2" Row="2" DesktopApplicationLinkPath="%ALLUSERSPROFILE%\Microsoft\Windows\Start Menu\Programs\OneDrive.lnk" />
          <start:Tile Size="2x2" Column="2" Row="0" AppUserModelID="MSTeams_8wekyb3d8bbwe!MSTeams" />
          <start:DesktopApplicationTile Size="2x2" Column="4" Row="0" DesktopApplicationLinkPath="%ALLUSERSPROFILE%\Microsoft\Windows\Start Menu\Programs\Outlook.lnk" />
          <start:DesktopApplicationTile Size="2x2" Column="4" Row="2" DesktopApplicationLinkPath="%APPDATA%\Microsoft\Windows\Start Menu\Programs\explorer.lnk" />
          <start:DesktopApplicationTile Size="2x2" Column="0" Row="2" DesktopApplicationLinkPath="%ALLUSERSPROFILE%\Microsoft\Windows\Start Menu\Programs\OneNote.lnk" />
          <start:DesktopApplicationTile Size="2x2" Column="0" Row="0" DesktopApplicationLinkPath="%ALLUSERSPROFILE%\Microsoft\Windows\Start Menu\Programs\Microsoft Edge.lnk" />
        </start:Group>
        <start:Group Name="">
          <start:Tile Size="2x2" Column="4" Row="0" AppUserModelID="Microsoft.CompanyPortal_8wekyb3d8bbwe!App" />
          <start:DesktopApplicationTile Size="2x2" Column="2" Row="0" DesktopApplicationLinkPath="%APPDATA%\Microsoft\Windows\Start Menu\Programs\System Tools\Control Panel.lnk" />
          <start:Tile Size="2x2" Column="0" Row="0" AppUserModelID="windows.immersivecontrolpanel_cw5n1h2txyewy!microsoft.windows.immersivecontrolpanel" />
        </start:Group>
      </defaultlayout:StartLayout>
    </StartLayoutCollection>
  </DefaultLayoutOverride>
</LayoutModificationTemplate>
"@ | Set-Content $File -Encoding UTF8

$XML = "XML"
$XML.Trigger

#Set Registry for default start layout
New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer"
New-ItemProperty -Force -Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer -Name LockedStartLayout -PropertyType DWord -Value 0
New-ItemProperty -Force -Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer -Name StartLayoutFile -PropertyType ExpandString -Value $File

#Remove store from taskbar
foreach ($taskbarapp in 'Microsoft Store') {
    Write-Host unpinning $taskbarapp
    unpin_taskbar("$taskbarapp") -Force
}