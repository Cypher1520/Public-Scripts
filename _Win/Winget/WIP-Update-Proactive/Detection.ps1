<#
Software Detection Script to see if software needs an update
Author: Chris Rockwell | chris@r-is.tech | chris.rockwell@insight.com
#>

#Help System to find winget.exe
$WinGetResolve = Resolve-Path "C:\Program Files\WindowsApps\Microsoft.DesktopAppInstaller_*_x64__8wekyb3d8bbwe\winget.exe"
$WinGetPathExe = $WinGetResolve[-1].Path

$WinGetPath = Split-Path -Path $WinGetPathExe -Parent
set-location $WinGetPath

#Variables

#Check locally installed software version
$LocalInstalledSoftware = winget.exe update --include-unknown 

$Available = (-split $LocalInstalledSoftware[-3])[-2]

#Check if needs update
if ($Available -eq 'Available') {
    write-host "Updates availabe"
    exit 1
}

else {
    exit 0
}
