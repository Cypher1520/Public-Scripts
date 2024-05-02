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
        powershell.exe -ExecutionPolicy Bypass .\uninstall.ps1
#>

# Variables - Remove comments for the alternate uninstall methods if needed
$fileName = "<FILENAME.msi>"
#$uninstallFile = "<FILEPATH>.exe"

<#$argumentList = @(
    "/x "
    $uninstallFile
    "/qb! "
    "/norestart "
)#>

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
Start-Transcript "$logDest\Transcripts\$fileName-uninstall.log" -Append

# Uninstall
Write-Host Uninstalling $fileName...
#Use this when program exists in the win32_products list, if not remove and replace with appropriate uninstall string, see references in description.
$products = Get-WmiObject win32_product | where { $_.name -like "*<App1>*" } #add ' -or $_.name -like "*<App2>*" ' to remove multiple products
foreach ($product in $products) {
    Write-Host Uninstalling $product.Name -ForegroundColor Cyan
    Start-Process "C:\Windows\System32\msiexec.exe" -ArgumentList "/x $($product.IdentifyingNumber) /qn /norestart" -Wait
    }

# PostUninstall
if (Test-Path "$($logDest)\$($fileName).tag") {
    Write-Host Removing $fileName tag file -ForegroundColor Green
    Remove-Item -Path "$($logDest)\$($fileName).tag"
}
$logFile = "$logDest\$fileName.log"
if (Test-Path $logFile) {
    Write-Host Removing $logFile -ForegroundColor Green
    Remove-Item -Path $logFile
}

# Quit
Stop-Transcript
Exit $lastexitcode