#Author : Microsoft
#Source : https://learn.microsoft.com/en-us/powershell/module/bitlocker/backuptoaad-bitlockerkeyprotector?view=windowsserver2025-ps

$BLV = Get-BitLockerVolume -MountPoint "C:"
BackupToAAD-BitLockerKeyProtector -MountPoint "C:" -KeyProtectorId $BLV.KeyProtector[1].KeyProtectorId