<# Factory Reset from CMD - "systemreset -factoryreset" #>
#prereqs
$script = Get-InstalledScript | where { $_.Name -eq "Get-WindowsAutoPilotInfo" }
$nuget = Get-PackageProvider | where { $_.Name -eq "NuGet" }
if ($null -eq $script) {
    if ($null -eq $nuget) {
        Install-PackageProvider -Name NuGet -Force -Confirm:$false
    }
    Install-Script -Name Get-WindowsAutopilotInfo -Force -Confirm:$false
}

Write-Host HWID Capture Options -ForegroundColor Yellow
Write-Host "------------"
Write-Host "1 - Online"
Write-Host "2 - CSV"
Write-Host "------------"
$option = Read-Host Select Option

#Online HWID
if ($option -eq 1) {
    $module = Get-Module | where { $_.Name -eq "WindowsAutoPilotIntune" }
    if ($null -eq $module) {
        Install-Module WindowsAutoPilotIntune -Force -Confirm:$false
    }
    Set-ExecutionPolicy -Scope Process -ExecutionPolicy RemoteSigned
    Import-Module WindowsAutoPilotIntune
    $groupTag = Read-Host "Group Tag: if none hit Enter"
    if ($null -ne $groupTag) {
        Get-WindowsAutopilotInfo -Online -GroupTag $groupTag
    }
    else {
        Get-WindowsAutopilotInfo -Online
    } 
}

#Create HWID CSV
elseif ($option -eq 2) {
    $companyName = Read-Host Company Name
    $env:Path += ";C:\Program Files\WindowsPowerShell\Scripts"
    Set-ExecutionPolicy -Scope Process -ExecutionPolicy RemoteSigned
    Get-WindowsAutopilotInfo -OutputFile ".\HWID-$companyName.csv" -Append
}