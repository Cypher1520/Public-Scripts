<#
.AUTHOR
    Chris Rockwell
    Email: chris@r-is.tech | chris.rockwell@insight.com

.DESCRIPTION
    ---------------------------------------
    References
    ---------------------------------------
        Start-Process "$uninstallFile" -Verb RunAs -ArgumentList $argumentList -Wait
        $products = Get-WmiObject win32_product | where { $_.name -eq "<App1>" -or $_.name -eq "<App2>"}
        foreach ($product in $products) {
            Write-Host Uninstalling $product.Name -ForegroundColor Green
            Start-Process "C:\Windows\System32\msiexec.exe" -ArgumentList "/x $($product.IdentifyingNumber) /qn /norestart" -Wait
            }
        Remove-Item -Path "HKLM:\REGISTRYKEY" -Confirm:$false -Recurse

    Get installed win32_products
        get-wmiobject Win32_Product | Sort-Object -Property Name | Format-Table IdentifyingNumber, Name, Version -AutoSize
        get-wmiobject Win32_Product | Sort-Object -Property Name | Format-Table Name, Version -AutoSize

.Example
    Intune uninstall command
        powershell.exe -windowstyle hidden -ExecutionPolicy Bypass -command .\uninstall.ps1
#>

Param
(
    [parameter(Mandatory = $true)]
    [String[]]
    $ID
)

# Make sure 64-bit PowerShell - Relaunch if not
if ("$env:PROCESSOR_ARCHITEW6432" -ne "ARM64") {
    if (Test-Path "$($env:WINDIR)\SysNative\WindowsPowerShell\v1.0\powershell.exe") {
        Write-Host Relaunching as 64-bit Powershell -ForegroundColor Yellow
        & "$($env:WINDIR)\SysNative\WindowsPowerShell\v1.0\powershell.exe" -ExecutionPolicy bypass -NoProfile -File "$PSCommandPath"
        Exit $lastexitcode
    }
}

#PreUninstall
$logDest = "$($env:ProgramData)\AutopilotConfig"
if (!(Test-Path $logDest)) {
    New-Item -Path "$($env:ProgramData)" -Name "AutopilotConfig" -ItemType Directory
}
Start-Transcript "$logDest\Transcripts\$ID-Uninstall.log" -Append
# resolve winget_exe
$winget_exe = Resolve-Path "C:\Program Files\WindowsApps\Microsoft.DesktopAppInstaller_*_*__8wekyb3d8bbwe\winget.exe"
if ($winget_exe.count -gt 1) {
    $winget_exe = $winget_exe[-1].Path
}

# Uninstall
if (!$winget_exe) { 
    $wgeterror = "Winget not installed" 
    Write-Error $wgeterror 
}
else {
    $result = (winget uninstall --exact --id $ID --silent --scope=machine).split("\")[-1]
}

# PostUninstall
if(!$wgeterror) {    
    if (Test-Path "$($logDest)\$($ID).tag") {
    Write-Host Removing $ID tag file -ForegroundColor Green
    Remove-Item -Path "$($logDest)\$($ID).tag"
    }
}

# Quit
Stop-Transcript
Exit $result