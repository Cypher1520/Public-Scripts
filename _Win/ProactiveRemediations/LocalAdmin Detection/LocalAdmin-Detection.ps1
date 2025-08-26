<#
==================================================

Script Name:        localAdminDetection.ps1
Description:        Checks for what accounts are in the local admin group (minus the specified one - line 28) and returns them.
Notes:              This is deployed in Intune as a remediation, but only as a detection. Next time the device checks in it'll list all local admin accounts. 
                    Pair this with a LAPS policy and a LUG policy to ensure there is only one local admin account on computers, and you control/rotate the password.

==================================================
#>

# Specify the path to the Administrators group using the WinNT provider
$administratorsGroupPath = "WinNT://./Administrators,group"

# Create an object representing the Administrators group
$administratorsGroup = [ADSI]$administratorsGroupPath

# Get members of the Administrators group
$administratorsMembers = $administratorsGroup.Invoke("Members") | ForEach-Object {
    [PSCustomObject]@{
        Name    = $_.GetType().InvokeMember("Name", 'GetProperty', $null, $_, $null)
        ADSPath = $_.GetType().InvokeMember("ADsPath", 'GetProperty', $null, $_, $null)
    }
}

# Display the names of the members    
$array = @($administratorsMembers)
$itemToRemove = 'LAPSAdmin'
$array = $array | Where-Object { $_.Name -ne $itemToRemove }

if ($array.count -gt 0) {
    Write-Host "Local Administrators:" ($array.name -join ", ")
    exit 1
}

else {
    exit 0
}

