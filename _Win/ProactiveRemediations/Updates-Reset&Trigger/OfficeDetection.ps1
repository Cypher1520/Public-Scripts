<#
.SYNOPSIS
Detection script for Office updates looking at update path settings.
.DESCRIPTION
This script checks the update path value to confirm if it's getting updates from Microsoft or a different configured source.
.EXAMPLE
.\OfficeDetection.ps1
#>

$blockingFound = $false

# Check for Office UpdatePath to see if it starts with "http://officecdn.microsoft.com"
$officeUpdatePath = "HKLM:\SOFTWARE\Policies\Microsoft\Office\16.0\Common\OfficeUpdate\"
if (Test-Path $officeUpdatePath) {
    $updatePathValue = Get-ItemProperty -Path $officeUpdatePath -Name "UpdatePath" -ErrorAction SilentlyContinue
    if ($updatePathValue -and $updatePathValue.UpdatePath -and $updatePathValue.UpdatePath -notlike "http://officecdn.microsoft.com*") {
        Write-Output "Found non-default Office UpdatePath: $($updatePathValue.UpdatePath)"
        $blockingFound = $true
    }
}
    
if ($blockingFound) {
    Write-Output "Bad update path found - remediation needed"
    exit 1
}
else {
    Write-Output "Update path is correct - no remediation needed"
    exit 0
}