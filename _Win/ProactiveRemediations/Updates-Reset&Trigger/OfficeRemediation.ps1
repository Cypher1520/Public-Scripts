<#
.SYNOPSIS
Removes Office update configuration blocks that could interfere with default Office update channels.
.DESCRIPTION
This script removes registry locations that may be blocking or redirecting Office updates from policy-based configurations (GPO, SCCM, or other MDM solutions) and resets Office to use default Microsoft update channels.
.EXAMPLE
.\OfficeRemediation.ps1
#>

# If we are running as a 32-bit process on an x64 system, re-launch as a 64-bit process
if ("$env:PROCESSOR_ARCHITEW6432" -ne "ARM64") {
    if (Test-Path "$($env:WINDIR)\SysNative\WindowsPowerShell\v1.0\powershell.exe") {
        & "$($env:WINDIR)\SysNative\WindowsPowerShell\v1.0\powershell.exe" -ExecutionPolicy bypass -NoProfile -File "$PSCommandPath"
        Exit $lastexitcode
    }
}

function Reset-OfficeUpdateConfig {
    Write-Host "Resetting Office Click-to-Run update configuration..." -ForegroundColor Cyan

    # Define Office registry keys that may block or redirect Office updates
    $regkeys = @(
        # Office 2016/2019/365 Policy settings
        @{ Name = "UpdatePath"; Path = "HKLM:\SOFTWARE\Policies\Microsoft\Office\16.0\Common\OfficeUpdate\" }
        @{ Name = "UpdateBranch"; Path = "HKLM:\SOFTWARE\Policies\Microsoft\Office\16.0\Common\OfficeUpdate\" }
        @{ Name = "UpdateChannel"; Path = "HKLM:\SOFTWARE\Policies\Microsoft\Office\16.0\Common\OfficeUpdate\" }
        @{ Name = "OfficeMgmtCOM"; Path = "HKLM:\SOFTWARE\Policies\Microsoft\Office\16.0\Common\OfficeUpdate\" }
        
        # Office 2013 Policy settings
        @{ Name = "UpdatePath"; Path = "HKLM:\SOFTWARE\Policies\Microsoft\Office\15.0\Common\OfficeUpdate\" }
        @{ Name = "UpdateBranch"; Path = "HKLM:\SOFTWARE\Policies\Microsoft\Office\15.0\Common\OfficeUpdate\" }
        @{ Name = "UpdateChannel"; Path = "HKLM:\SOFTWARE\Policies\Microsoft\Office\15.0\Common\OfficeUpdate\" }
        @{ Name = "OfficeMgmtCOM"; Path = "HKLM:\SOFTWARE\Policies\Microsoft\Office\15.0\Common\OfficeUpdate\" }
        
        # Click-to-Run configuration settings
        @{ Name = "CDNBaseUrl"; Path = "HKLM:\SOFTWARE\Microsoft\Office\ClickToRun\Configuration\" }
        @{ Name = "UpdateChannel"; Path = "HKLM:\SOFTWARE\Microsoft\Office\ClickToRun\Configuration\" }
        @{ Name = "UpdatePath"; Path = "HKLM:\SOFTWARE\Microsoft\Office\ClickToRun\Configuration\" }
        @{ Name = "UpdateUrl"; Path = "HKLM:\SOFTWARE\Microsoft\Office\ClickToRun\Configuration\" }
        @{ Name = "UpdateBranch"; Path = "HKLM:\SOFTWARE\Microsoft\Office\ClickToRun\Configuration\" }
    )

    foreach ($reg in $regkeys) {
        Write-Host "Checking for $($reg.Name) in Office configuration..." -ForegroundColor Yellow
        
        # Check if the registry path exists first
        if (Test-Path $reg.Path) {
            if ((Get-Item $reg.Path -ErrorAction SilentlyContinue).Property -contains $reg.Name) {
                Write-Host "✅ Removing $($reg.Name) from Office registry." -ForegroundColor Green
                try {
                    Remove-ItemProperty -Path $reg.Path -Name $reg.Name -Force
                    Write-Host "✅ Successfully removed $($reg.Name)." -ForegroundColor Green
                }
                catch {
                    Write-Host "❌ Failed to remove $($reg.Name): $($_.Exception.Message)" -ForegroundColor Red
                }
            }
            else {
                Write-Host "ℹ️ $($reg.Name) was not found in registry." -ForegroundColor Gray
            }
        }
        else {
            Write-Host "ℹ️ Registry path $($reg.Path) does not exist." -ForegroundColor Gray
        }
    }

    # Restart Office ClickToRun service
    $service = Get-Service -Name "ClickToRunSvc" -ErrorAction SilentlyContinue
    if ($service) {
        Restart-Service -Name "ClickToRunSvc" -Force
        Write-Host "🔄 Restarted ClickToRun service." -ForegroundColor Green
    }

    # Trigger an Office update
    $updateExe = "$env:ProgramFiles\Common Files\Microsoft Shared\ClickToRun\OfficeC2RClient.exe"
    if (Test-Path $updateExe) {
        Start-Process -FilePath $updateExe -ArgumentList "/update user" -Wait -ErrorAction SilentlyContinue
        Write-Host "🔧 Office update check triggered." -ForegroundColor Green
    }
}

#region Logging
    if (-not (Test-Path "$($env:ProgramData)\AutopilotConfig")) {
        Mkdir "$($env:ProgramData)\AutopilotConfig"
    }

    # stopping orphaned transcripts
    try {
        stop-transcript | out-null
    }
    catch [System.InvalidOperationException] {
        # No transcript running, continue
    }

    Start-Transcript "$($env:ProgramData)\AutopilotConfig\UpdateOS.log" -Append
#endregion

#region Execution
    # Reset Office update configuration
    Reset-OfficeUpdateConfig

    Write-Host "Office update configuration reset completed." -ForegroundColor Green
    Stop-Transcript
#endregion