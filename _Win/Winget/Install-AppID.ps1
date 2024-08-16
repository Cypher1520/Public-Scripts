<#
.AUTHOR
    Chris Rockwell
    Email: chris@r-is.tech | chris.rockwell@insight.com

.DESCRIPTION
    Installs applications from Winget
    Use "Winget search 'appname' to find the app ID's to use when calling install.ps1"

.Example
    Intune install command
        powershell.exe -windowstyle hidden -ExecutionPolicy Bypass -command .\install.ps1 -id <APPID CASE SENSITIVE>
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
        Write-Host Relaunching as 64-bit Powershell -ForegroundColor Cyan
        & "$($env:WINDIR)\SysNative\WindowsPowerShell\v1.0\powershell.exe" -ExecutionPolicy bypass -NoProfile -File "$PSCommandPath"
        Exit $lastexitcode
    }
}

# PreInstall
$logDest = "$($env:ProgramData)\AutopilotConfig"
if (!(Test-Path $logDest)) {
    New-Item -Path "$($env:ProgramData)" -Name "AutopilotConfig" -ItemType Directory
}
Start-Transcript "$logDest\Transcripts\$ID-install.log" -Append
# resolve winget_exe
$winget_exe = Resolve-Path "C:\Program Files\WindowsApps\Microsoft.DesktopAppInstaller_*_*__8wekyb3d8bbwe\winget.exe"
if ($winget_exe.count -gt 1) {
    $winget_exe = $winget_exe[-1].Path
}

# Install
if (!$winget_exe) { 
    $wgeterror = "Winget not installed" 
    Write-Error $wgeterror 
}
else {
$result = (winget install --exact --id $ID --silent --accept-package-agreements --accept-source-agreements --scope=machine).split("\")[-1]
}

# PostInstall
#creates tag file, detects if the tag file is there for testing scenarios, not necessary when a new install
if (!$wgeterror) {
    if (!(Test-Path "$logDest\$($ID).tag")) {
        Write-Host Creating Tag file. -ForegroundColor Cyan
        New-Item -Path "$($logDest)" -Name "$($ID).tag" -ItemType File -Value "Tag"
        Write-Host "Install complete, Result: $($result)" -ForegroundColor Green
    }
    else {
        Write-Host "Install not complete, Result: $($result)" -ForegroundColor Red
    }
}

# Quit
Stop-Transcript
Exit $result