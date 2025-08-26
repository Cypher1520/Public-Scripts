<#
# Script Name:     remediate128bitlocker.ps1
# Description:     Decrypts the OS drive if 128bit encrypted
# Notes:           
#>

# Define Variables

#Script Body
    try{
        # Specify the drive letter
        $DriveLetter = "C"
        Disable-BitLocker -MountPoint $DriveLetter

        #Wait for decryption
        do {
            $Status = Get-BitLockerVolume -MountPoint $DriveLetter
            Write-Host "$($Status.VolumeStatus): $($Status.EncryptionPercentage)%"
            Start-Sleep -Seconds 10
        } while ($Status.VolumeStatus -ne "FullyDecrypted")

        # Update registry to enforce 256-bit encryption
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\FVE" -Name "EncryptionMethodWithXtsOs" -Value 7
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\FVE" -Name "EncryptionMethodWithXtsFdv" -Value 7
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\FVE" -Name "EncryptionMethodWithXtsRdv" -Value 7

        Write-Host "Decryption completed for drive $DriveLetter."
        exit 0
    }
    catch{
        $errMsg = $_.Exception.Message
        Write-Error $errMsg
        exit 1
    }