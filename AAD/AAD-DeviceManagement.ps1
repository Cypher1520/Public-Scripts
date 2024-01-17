<# VS Code Shortcuts
Collapse All: Ctrl+K CTRL+0
Expand All: Ctrl+K CTRL+J
#>

#-----------Add a computer to a group-----------#
    #Get device list    
    Get-AzureADDevice -All:$true | select-object -Property AccountEnabled, DeviceId, DeviceOSType, DeviceOSVersion, DisplayName, DeviceTrustType, ApproximateLastLogonTimestamp | export-csv devicelist-summary.csv -NoTypeInformation

        #for many devices filter down by timestamp
        $dt = (Get-Date).AddDays(-180)
        Get-AzureADDevice -All:$true | Where {$_.ApproximateLastLogonTimeStamp -le $dt} | select-object -Property AccountEnabled, DeviceId, DeviceOSType, DeviceOSVersion, DisplayName, DeviceTrustType, ApproximateLastLogonTimestamp | export-csv devicelist-olderthan-180days-summary.csv -NoTypeInformation

    #disable devices
    $dt = (Get-Date).AddDays(-180)
    $Devices = Get-AzureADDevice -All:$true | Where {$_.ApproximateLastLogonTimeStamp -le $dt}
    foreach ($Device in $Devices) {
    Set-AzureADDevice -ObjectId $Device.ObjectId -AccountEnabled $false
    }

    #Delete Devices
    $dt = (Get-Date).AddDays(-180)
    $Devices = Get-AzureADDevice -All:$true | Where {($_.ApproximateLastLogonTimeStamp -le $dt) -and ($_.AccountEnabled -eq $false)}
    foreach ($Device in $Devices) {
    Remove-AzureADDevice -ObjectId $Device.ObjectId
    }