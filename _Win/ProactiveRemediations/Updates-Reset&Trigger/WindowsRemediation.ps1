<#
.SYNOPSIS
Removes Windows Update configuration blocks that could interfere with Windows Update for Business (WUfB) and runs Windows updates.
.DESCRIPTION
This script removes registry locations that may be blocking Windows updates from policy-based configurations (GPO, SCCM, or other MDM solutions), resets Windows Update services, and then installs available updates using the PSWindowsUpdate module.
.EXAMPLE
.\WindowsRemediation.ps1
#>

# If we are running as a 32-bit process on an x64 system, re-launch as a 64-bit process
if ("$env:PROCESSOR_ARCHITEW6432" -ne "ARM64") {
    if (Test-Path "$($env:WINDIR)\SysNative\WindowsPowerShell\v1.0\powershell.exe") {
        & "$($env:WINDIR)\SysNative\WindowsPowerShell\v1.0\powershell.exe" -ExecutionPolicy bypass -NoProfile -File "$PSCommandPath"
        Exit $lastexitcode
    }
}

#region Functions
function Reset-WindowsUpdateConfig {
    Write-Host "Resetting Windows Update registry configuration..." -ForegroundColor Cyan
    
    # Define registry keys that may block Windows Updates
    $regkeys = @(
        # Basic Windows Update blocking settings
        @{ Name = "DoNotConnectToWindowsUpdateInternetLocations"; Path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\" }
        @{ Name = "DisableWindowsUpdateAccess"; Path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\" }
        @{ Name = "NoAutoUpdate"; Path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU\" }
        @{ Name = "WUServer"; Path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\" }
        @{ Name = "WUStatusServer"; Path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\" }
        @{ Name = "UseWUServer"; Path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU\" }
        
        # Feature update and version targeting settings
        @{ Name = "DisableOSUpgrade"; Path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\" }
        @{ Name = "TargetReleaseVersion"; Path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\" }
        @{ Name = "TargetReleaseVersionInfo"; Path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\" }
        
        # Update deferral settings
        @{ Name = "DeferFeatureUpdates"; Path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\" }
        @{ Name = "DeferQualityUpdates"; Path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\" }
        @{ Name = "DeferFeatureUpdatesPeriodInDays"; Path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\" }
        @{ Name = "DeferQualityUpdatesPeriodInDays"; Path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\" }
        
        # Delivery optimization settings that might block updates
        @{ Name = "DODownloadMode"; Path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization\" }
    )

    foreach ($reg in $regkeys) {
        Write-Host "Checking for $($reg.Name)..." -ForegroundColor Yellow
        
        # Check if the registry path exists first
        if (Test-Path $reg.Path) {
            if ((Get-Item $reg.Path -ErrorAction SilentlyContinue).Property -contains $reg.Name) {
                Write-Host "✅ Removing $($reg.Name) from registry." -ForegroundColor Green
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

    # Restart Windows Update services
    $services = @("wuauserv", "bits", "cryptsvc")
    foreach ($serviceName in $services) {
        $service = Get-Service -Name $serviceName -ErrorAction SilentlyContinue
        if ($service) {
            Restart-Service -Name $serviceName -Force -ErrorAction SilentlyContinue
            Write-Host "🔄 Restarted $serviceName service." -ForegroundColor Green
        }
    }
}

function Install-WindowsUpdates {
    Write-Host "Installing Windows Updates..." -ForegroundColor Cyan

    try {
        # Import Module - Install if necessary
        if (-not (Get-Module -ListAvailable -Name PSWindowsUpdate)) {
            Write-Host "Installing PSWindowsUpdate module..." -ForegroundColor Yellow
            [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
            Install-PackageProvider -Name NuGet -Force -ErrorAction SilentlyContinue
            Install-Module PSWindowsUpdate -Force -ErrorAction SilentlyContinue
        }
        Import-Module PSWindowsUpdate

        Write-Host "✅ PSWindowsUpdate module loaded successfully." -ForegroundColor Green

        # Install all available updates
        Write-Host "Searching for and installing available updates..." -ForegroundColor Yellow
        $updateResults = Get-WindowsUpdate -Install -IgnoreUserInput -AcceptAll -WindowsUpdate -IgnoreReboot | Select Title, KB, Result

        if ($updateResults) {
            Write-Host "✅ Updates installed:" -ForegroundColor Green
            $updateResults | Format-Table
        }
        else {
            Write-Host "ℹ️ No updates were available or installed." -ForegroundColor Gray
        }

        # Check reboot status
        $needReboot = (Get-WURebootStatus -Silent).RebootRequired
        return $needReboot
    }
    catch {
        Write-Host "❌ Error during Windows Update process: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}
#endregion

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
    # Reset Windows Update registry settings
    Reset-WindowsUpdateConfig

    # Install available Windows Updates
    $needReboot = Install-WindowsUpdates

    if ($needReboot) {
        Write-Host "Windows Update indicated that a reboot is needed."
        #shutdown /r /t 600
        Stop-Transcript
        Exit 3010  # Reboot required
    }
    else {
        Write-Host "Windows Update indicated that no reboot is required."
        Stop-Transcript
        Exit 0     # Success
    }
#endregion