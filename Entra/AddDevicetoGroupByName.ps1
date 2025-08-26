Install-Module -Name AzureAD
Import-Module AzureAD

Connect-AzureAD

# Define the group name or ID
$GroupName = "<GROUPNAME>" # Replace with your group name
$DeviceNames = Import-Csv C:\Temp\Devices.csv

# Get the group object
$Group = Get-AzureADGroup -Filter "DisplayName eq '$GroupName'"
if (-not $Group) {
    Write-Host "Group not found!" -ForegroundColor Red
    return
}

# Loop through each device name and add it to the group
foreach ($DeviceName in $DeviceNames) {
    $Device = Get-AzureADDevice -Filter "DisplayName eq '$($DeviceName.Name)'"
    if ($Device) {
        Add-AzureADGroupMember -ObjectId $Group.ObjectId -RefObjectId $Device.ObjectId
        Write-Host "Added $DeviceName to $GroupName" -ForegroundColor Green
    } else {
        Write-Host "Device $DeviceName not found!" -ForegroundColor Yellow
    }
}