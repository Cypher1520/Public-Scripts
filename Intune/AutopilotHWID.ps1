#------------------------------------
#Factory Reset
systemreset -factoryreset

#Load HWID direct to online

#PowerShell.exe -ExecutionPolicy Bypass
    PowerShell.exe -ExecutionPolicy Bypass
    Install-Script -name Get-WindowsAutopilotInfo -Force
    Install-Module WindowsAutoPilotIntune
    Set-ExecutionPolicy -Scope Process -ExecutionPolicy RemoteSigned
    Import-Module WindowsAutoPilotIntune
    Get-WindowsAutoPilotInfo -Online -GroupTag "AAD-S"

#Create HWID CSV
    PowerShell.exe -ExecutionPolicy Bypass
    New-Item -Type Directory -Path "E:\HWID"
    Set-Location -Path "E:\HWID"
    $env:Path += ";E:\Program Files\WindowsPowerShell\Scripts"
    Set-ExecutionPolicy -Scope Process -ExecutionPolicy RemoteSigned
    Install-Script -Name Get-WindowsAutoPilotInfo
    Get-WindowsAutoPilotInfo -OutputFile HWIDCucm.csv

#New Online
    PowerShell.exe -ExecutionPolicy Bypass
    Install-Script -name Get-WindowsAutopilotInfo -Force
    Set-ExecutionPolicy -Scope Process -ExecutionPolicy RemoteSigned
    Get-WindowsAutopilotInfo -Online -GroupTag "MTL-DEV"