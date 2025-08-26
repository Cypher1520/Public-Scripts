#=============================================================================================================================
#
# Script Name:     Remediate-BitlockerPin.ps1
# Description:     Set Bitlocker startup pin.
# Notes:           Sets bitlocker startup pin.
#
#=============================================================================================================================

try {
    $SecureString = ConvertTo-SecureString "590454" -AsPlainText -Force
    Add-BitLockerKeyProtector -MountPoint "C:" -Pin $SecureString -TPMandPinProtector -ErrorAction Stop
    exit 0
}

catch {
    $errMsg = $_.Exception.Message
    Write-host $errMsg
    exit 1
}