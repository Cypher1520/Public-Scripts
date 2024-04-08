# ------------------------------------
<# Factory Reset from CMD
# systemreset -factoryreset
#>

Write-Host HWID Capture Options -ForegroundColor Yellow
Write-Host "------------"
Write-Host "1 - Online"
Write-Host "2 - CSV"
Write-Host "------------"
$option = Read-Host Select Option

if ($option -eq 1) {
    #Online HWID
    Install-Script -name Get-WindowsAutopilotInfo -Force -Confirm:$false
    Install-Module WindowsAutoPilotIntune -Force -Confirm:$false
    Set-ExecutionPolicy -Scope Process -ExecutionPolicy RemoteSigned
    Import-Module WindowsAutoPilotIntune
    $groupTag = Read-Host Group Tag
    Get-WindowsAutopilotInfo -Online -GroupTag "$groupTag" 
}

elseif ($option -eq 2) {
    #Create HWID CSV
    $companyName = Read-Host Company Name
    $env:Path += ";C:\Program Files\WindowsPowerShell\Scripts"
    Set-ExecutionPolicy -Scope Process -ExecutionPolicy RemoteSigned
    Install-Script -Name Get-WindowsAutopilotInfo
    Get-WindowsAutopilotInfo -OutputFile "HWID-$($companyName).csv"
}