#prereqs
$script = Get-InstalledScript | where { $_.Name -eq "Get-WindowsAutoPilotInfo" }
$nuget = Get-PackageProvider | where { $_.Name -eq "NuGet" }
if ($null -eq $script) {
    if ($null -eq $nuget) {
        Install-PackageProvider -Name NuGet -Force -Confirm:$false
    }
    Install-Script -Name Get-WindowsAutopilotInfo -Force -Confirm:$false
}

#write to networkshare and append each day into single file, log device hostname to log file for record of devices.
else {
    $date = get-date -Format "yyyyMMdd"
    Get-WindowsAutoPilotInfo.ps1 -OutputFile "$location\$date-HWIDs.csv" -Append
    $name = HOSTNAME.EXE
    $name >> "$location\$date-Devices.log"
}