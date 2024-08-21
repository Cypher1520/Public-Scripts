<#
Software Remediation Script to update the software
Author: Chris Rockwell | chris@r-is.tech | chris.rockwell@insight.com
#>

# Help System to find winget.exe
$WinGetResolve = Resolve-Path "C:\Program Files\WindowsApps\Microsoft.DesktopAppInstaller_*_x64__8wekyb3d8bbwe\winget.exe"
$WinGetPathExe = $WinGetResolve[-1].Path

$WinGetPath = Split-Path -Path $WinGetPathExe -Parent
set-location $WinGetPath

#Variables

# Run upgrade of the software
winget.exe upgrade --all --silent --accept-package-agreements --include-unknown --accept-source-agreements