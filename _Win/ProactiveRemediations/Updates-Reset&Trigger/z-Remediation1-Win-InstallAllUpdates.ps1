# ---------------------------------------------------------
# Windows Quality update script
# ---------------------------------------------------------
# massacred from M Neihaus UpdateOS script
# ---------------------------------------------------------



<#
.SYNOPSIS
Installs the latest Windows 10 quality updates.
.DESCRIPTION
This script uses the PSWindowsUpdate module to install the latest cumulative update for Windows 10.
.EXAMPLE
.\UpdateOS.ps1
#>


# If we are running as a 32-bit process on an x64 system, re-launch as a 64-bit process
if ("$env:PROCESSOR_ARCHITEW6432" -ne "ARM64")
{
    if (Test-Path "$($env:WINDIR)\SysNative\WindowsPowerShell\v1.0\powershell.exe")
    {
        & "$($env:WINDIR)\SysNative\WindowsPowerShell\v1.0\powershell.exe" -ExecutionPolicy bypass -NoProfile -File "$PSCommandPath"
        Exit $lastexitcode
    }
}

# ---------------------------------------------------------
# Create log dir and starts transcript
# ---------------------------------------------------------
if (-not (Test-Path "$($env:ProgramData)\AutopilotConfig"))
{
    Mkdir "$($env:ProgramData)\AutopilotConfig"
}
Start-Transcript "$($env:ProgramData)\AutopilotConfig\UpdateOS.log"


# ---------------------------------------------------------
# Load module from PowerShell Gallery
# ---------------------------------------------------------
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Install-PackageProvider -Name NuGet -Force
Install-Module PSWindowsUpdate -Force
Import-Module PSWindowsUpdate


# ---------------------------------------------
# Install all available updates
# ---------------------------------------------
Get-WindowsUpdate -Install -IgnoreUserInput -AcceptAll -WindowsUpdate -IgnoreReboot | Select Title, KB, Result | Format-Table
$needReboot = (Get-WURebootStatus -Silent).RebootRequired


# ---------------------------------------------
# Specify return code
# ---------------------------------------------
if ($needReboot)
{
    Write-Host "Windows Update indicated that a reboot is needed."
    #shutdown /r /t 600
    Stop-Transcript
}
else
{
    Write-Host "Windows Update indicated that no reboot is required."
    Stop-Transcript
}