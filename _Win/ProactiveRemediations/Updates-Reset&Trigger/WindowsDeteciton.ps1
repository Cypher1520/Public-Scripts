<#
.SYNOPSIS
Detection script for Windows updates looking at last update date and registry configurations.
.DESCRIPTION
This script checks if updates have not ran for "x" (variable) days OR if registry keys are blocking Windows updates.
If $maxDays is populated, it uses date-based detection. If $maxDays is empty, it checks registry configurations.
.EXAMPLE
.\WindowsDetection.ps1
#>

$maxDays = $null   # Set to a number (e.g., 45) for date-based detection, or leave as $null for registry-based detection

if ($maxDays -ne $null -and $maxDays -gt 0) {
    # Date-based detection (original logic)
    Write-Output "Using date-based detection with $maxDays day threshold..."
    
    $lastupdate = Get-HotFix | Sort-Object -Property @{Expression = { if ($_.InstalledOn) { [datetime]::Parse($_.InstalledOn) } else { [datetime]::MinValue } } } | Select-Object -Last 1 -ExpandProperty InstalledOn
    $Date = Get-Date
    $diff = New-TimeSpan -Start $lastupdate -end $Date
    $days = $diff.Days

    if ($days -ge $maxDays) {
        Write-Output "Windows Updates ran more than $maxDays days ago ($days days), updates needed"
        exit 1
    }
    else {
        Write-Output "Windows Updates ran less than $maxDays days ago ($days days), no updates needed"
        exit 0
    }
}
else {
    # Registry-based detection
    Write-Output "Using registry-based detection for blocking configurations..."
    
    $blockingFound = $false
    
    # Check for Windows Update policy registry locations that shouldn't exist on unconfigured devices
    $windowsUpdatePolicyPaths = @(
        "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate"
        "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization"
    )
    
    foreach ($policyPath in $windowsUpdatePolicyPaths) {
        if (Test-Path $policyPath) {
            Write-Output "Found Windows Update policy registry location: $policyPath"
            $blockingFound = $true
        }
    }
    
    if ($blockingFound) {
        Write-Output "Blocking registry configurations found - remediation needed"
        exit 1
    }
    else {
        Write-Output "No blocking registry configurations found - no remediation needed"
        exit 0
    }
}