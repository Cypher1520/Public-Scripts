if (Test-Path D:) {
    $size = (Get-WmiObject -Class Win32_LogicalDisk | ? { $_. DeviceID -eq "D:" }).DriveType
    if (!($size -eq 2 -or 5)) {
        Get-WmiObject -Class Win32_volume -Filter "DriveLetter = 'd:'" | Set-WmiInstance -Arguments @{DriveLetter = 'Z:'}
    }
    else {
        Label D: "Data"
    }
}
else {
    $NewPartitionSize = 274877906944 #256GB Size
    Resize-Partition -DriveLetter C -Size $NewPartitionSize -Verbose #Resizes to 256GB
    New-Partition -DriveLetter D -UseMaximumSize -DiskNumber 0 #Create the new partition with remainder of the drive
    Format-Volume D
    Label D: "Data"
}