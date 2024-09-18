<#
.AUTHOR
    Chris Rockwell
    Email: chris@r-is.tech | chris.rockwell@insight.com

.DESCRIPTION
    Uninstalls applications from Winget
    Use "Winget search "appname" to find the app ID's to use when calling uninstall.ps1"

.Example
    Intune uninstall command
        powershell.exe -windowstyle hidden -ExecutionPolicy Bypass -command .\uninstall.ps1 -id <APPID CASE SENSITIVE>
#>

Param
(
    [parameter(Mandatory = $true)]
    [String[]]
    $ID
)

# Make sure 64-bit PowerShell - Relaunch if not
if ("$env:PROCESSOR_ARCHITEW6432" -ne "ARM64") {
    if (Test-Path "$($env:WINDIR)\SysNative\WindowsPowerShell\v1.0\powershell.exe") {
        Write-Host Relaunching as 64-bit Powershell -ForegroundColor Yellow
        & "$($env:WINDIR)\SysNative\WindowsPowerShell\v1.0\powershell.exe" -ExecutionPolicy bypass -NoProfile -File "$PSCommandPath"
        Exit $lastexitcode
    }
}

#PreUninstall
$logDest = "$($env:ProgramData)\_Intune"
New-Item -Path "$($env:ProgramData)" -Name "_Intune" -ItemType Directory -ErrorAction SilentlyContinue

Start-Transcript "$logDest\Transcripts\$ID-Uninstall.log" -Append

# Install winget if not present
$WingetPath = "C:\Program Files\WindowsApps\Microsoft.DesktopAppInstaller_*_8wekyb3d8bbwe\winget.exe"
if (!(Test-Path $WingetPath)) {
    $progressPreference = 'silentlyContinue'
    Write-Information "Downloading WinGet and its dependencies..."
    Invoke-WebRequest -Uri https://aka.ms/getwinget -OutFile Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle
    Invoke-WebRequest -Uri https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx -OutFile Microsoft.VCLibs.x64.14.00.Desktop.appx
    Invoke-WebRequest -Uri https://github.com/microsoft/microsoft-ui-xaml/releases/download/v2.8.6/Microsoft.UI.Xaml.2.8.x64.appx -OutFile Microsoft.UI.Xaml.2.8.x64.appx
    Add-AppxPackage Microsoft.VCLibs.x64.14.00.Desktop.appx
    Add-AppxPackage Microsoft.UI.Xaml.2.8.x64.appx
    Add-AppxPackage Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle4
    if (!(Test-Path $WingetPath)) {
        Write-host "Winget install not successful, exiting"
        Exit 1
    }
} 

# Uninstall
$result = (winget uninstall --exact --id $ID --silent --scope=machine).split("\")[-1]

# PostUninstall
if ($result -eq "Successfully Uninstalled") {    
    if (Test-Path "$($logDest)\$($ID).tag") {
        Write-Host Removing $ID tag file -ForegroundColor Green
        Remove-Item -Path "$($logDest)\$($ID).tag"
        Write-Host "Uninstall complete, Result: $($result)" -ForegroundColor Green

        Stop-Transcript
        Exit 0
    }
    else {
        Write-Host "Uninstall not complete, Result: $result" -ForegroundColor Red
        
        Stop-Transcript 
        Exit 1
    }
}