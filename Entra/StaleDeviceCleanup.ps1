#connect to graph
Connect-MgGraph -NoWelcome

#Set time frame to search for devices
$dt = (Get-Date).AddDays(-5)

#export entra devices to csv
Get-MgDevice -All | Where { $_.ApproximateLastSignInDateTime -le $dt } | select-object -Property DeviceId, ID, AccountEnabled, OperatingSystem, OperatingSystemVersion, DisplayName, TrustType, ApproximateLastSignInDateTime | export-csv C:\Temp\RemovalList.csv -NoTypeInformation

#export list of autopilot devices
Get-MgDeviceManagementWindowsAutopilotDeviceIdentity | Select -Property AzureActiveDirectoryDeviceId, DisplayName, EnrollmentState, ID, LastContactedDateTime, SerialNumber | Export-Csv C:\Temp\AutopilotDeviceList.csv -NoTypeInformation

Read-Host CSVs exported, remove autopilot devices from removallist.csv and save. `nPress enter to continue

#import csv with devices to remove after removing autopilot devices from entra device csv.
$removeDevices = Import-Csv C:\Temp\RemovalList.csv

#confirmation to proceed with removal
$confirm = Read-Host "Enter 'Y' to confirm removal of devices in RemovalList.csv"

if ($confirm -eq "Y") {
    #remove target devices
    foreach ($Device in $removeDevices) {
        Remove-MgDevice -DeviceId $Device.Id
    }
}
else {
    Write-Host "No confirmation, no actions taken" -ForegroundColor Red
}