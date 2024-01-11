#=============================================================================================================================
#
# Script Name:     Detect-BitlockerPin.ps1
# Description:     Detect if Bitlocker Startup Pin is set.
# Notes:           Detects the bitlocker startup pins existance to avoid duplicate pin creations
#
#=============================================================================================================================

# Define Variables
$blkey = (Get-BitLockerVolume -MountPoint C).KeyProtector | where { $_.KeyProtectorType -eq "TpmPin" }
$blstate = (Get-BitLockerVolume -MountPoint C).VolumeStatus

if ($blkey) {
    write-host "Startup key exists, exiting"
    exit 0
}

if ($blstate -eq "FullyEncrypted") {
    Write-Host "Bitlocker Enabled"
    exit 1
}

else {
    write-host "No pin or not Bitlocker"
    exit 1
}