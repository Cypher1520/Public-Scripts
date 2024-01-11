<#
# Script Name:     BLtoAAD_Remediation.ps1
# Description:     Remediation script for backing up bitlocker key to AAD/Entra ID
# Notes:           
#>

# Define Variables

#Script Body
try {
    $BitlockerVol = Get-BitLockerVolume -MountPoint $env:SystemDrive
    $KPID = ""
    foreach ($KP in $BitlockerVol.KeyProtector) {
        if ($KP.KeyProtectorType -eq "RecoveryPassword") {
            $KPID = $KP.KeyProtectorId
            break;
        }
    }
    $output = BackupToAAD-BitLockerKeyProtector -MountPoint "$($env:SystemDrive)" -KeyProtectorId $KPID
    return $true
}
catch {
    return $false
}