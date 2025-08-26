$location = "SHARELOCATION"

#prereqs
$script = Get-InstalledScript | where { $_.Name -eq "Get-WindowsAutoPilotInfo" }
$nuget = Get-PackageProvider | where { $_.Name -eq "NuGet" }
if ($null -eq $script) {
    if ($null -eq $nuget) {
        Install-PackageProvider -Name NuGet -Force -Confirm:$false
    }
    Install-Script -Name Get-WindowsAutopilotInfo -Force -Confirm:$false
}

#Write to C:\Temp if location not accessible
if (!(Test-Path $location)) {
    Write-Host Network location not accessible, writing HWID to C:\Temp -ForegroundColor Red
    $name = HOSTNAME.EXE
    Get-WindowsAutoPilotInfo.ps1 -OutputFile .\$name-HWID.csv
}

#write to networkshare and append each day into single file, log device hostname to log file for record of devices.
else {
    $date = get-date -Format "yyyyMMdd"
    Get-WindowsAutoPilotInfo.ps1 -OutputFile "$location\$date-HWIDs.csv" -Append
    $name = HOSTNAME.EXE
    $name >> "$location\$date-Devices.log"
}