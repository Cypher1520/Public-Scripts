<#
 Script Name:     detect128bitlocker.ps1
 Description:     Tests if bitlocker has automatically encrypted at 128 bit.
 Notes:           
#>

# Define Variables

#Script Body
try {
    if ((Get-BitLockerVolume -MountPoint "C:" | select *).EncryptionMethod -eq "XtsAes128") { #XtsAes256 or XtsAes128
        #Exit if pass
        Write-Host "Encryption: $((Get-BitLockerVolume -MountPoint "C:" | select *).EncryptionMethod), needs remediation"
        exit 1
    }
    else {
        #Exit if fail
        Write-Host "Pass"        
        exit 0
    }   
}
catch {
    $errMsg = $_.Exception.Message
    Write-Error $errMsg
    exit 1
}