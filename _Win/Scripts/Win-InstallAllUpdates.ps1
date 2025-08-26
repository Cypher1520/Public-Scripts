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

[CmdletBinding()]

# set $HardReboot = true for the whole script
Param(
    [Parameter(Mandatory=$False)] [Switch] $HardReboot = $true
)

Process
{

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
# Create a tag file just so Intune knows this was installed
# ---------------------------------------------------------
if (-not (Test-Path "$($env:ProgramData)\TS_Logs"))
{
    Mkdir "$($env:ProgramData)\TS_Logs"
}

# ---------------------------------------------------------
# Start logging
# ---------------------------------------------------------
Start-Transcript "$($env:ProgramData)\TS_Logs\UpdateOS.log"


# ---------------------------------------------------------
# Main logic
# ---------------------------------------------------------
$needReboot = $false
Write-Host "Installing updates with HardReboot = $HardReboot."
# exit


# ---------------------------------------------------------
# Load module from PowerShell Gallery
# ---------------------------------------------------------
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Install-PackageProvider -Name NuGet -Force
Install-Module PSWindowsUpdate -Force
Import-Module PSWindowsUpdate


# ---------------------------------------------
# Prevent Specified KB's
# ---------------------------------------------
<#
write-host "Excluding v22H2 update KBs ..."
write-host "-KB5015684"
Hide-WindowsUpdate -KBArticleID KB5015684 -IgnoreUserInput -AcceptAll

write-host "-KB5022834"
Hide-WindowsUpdate -KBArticleID KB5022834 -IgnoreUserInput -AcceptAll
write-host "Done."
#>

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
    shutdown /r /t 600
}
else
{
    Write-Host "Windows Update indicated that no reboot is required."
}

# ---------------------------------------------------------
# For whatever reason, the reboot needed flag is not always being properly set.  So we always want to force a reboot.
# If this script (as an app) is being used as a dependent app, then a hard reboot is needed to get the "main" app to
# install.
# ---------------------------------------------------------
# Needs section needs validation - IS THIS STILL TRUE?
# ---------------------------------------------------------
if ($HardReboot)
{
    Write-Host "Exiting with return code 1641 to indicate a hard reboot is needed."
    Stop-Transcript
    Set-Content -Path "$($env:ProgramData)\TS_Logs\UpdateOS.ps1.tag" -Value "Installed"
    Exit 1641
}
else
{
    Write-Host "Exiting with return code 3010 to indicate a soft reboot is needed."
    Stop-Transcript
    Set-Content -Path "$($env:ProgramData)\TS_Logs\UpdateOS.ps1.tag" -Value "Installed"
    Exit 3010
}
    Set-Content -Path "$($env:ProgramData)\TS_Logs\UpdateOS.ps1.tag" -Value "Installed"
    Stop-Transcript
}