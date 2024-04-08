<#
    ---------------------------------------
    Application Uninstall Wrapper
    Chris Rockwell - Insight Canada
    chris.rockwell@insight.com
    ---------------------------------------
    Get installed apps
    ---------------------------------------
        you need to find and replace the GUID between the {} in the uninstall commands below
        to do that run following through Powershell
            get-wmiobject Win32_Product | Sort-Object -Property Name | Format-Table IdentifyingNumber, Name, Version -AutoSize
    ---------------------------------------
    References/Examples
    ---------------------------------------
        Start-Process "$uninstallFile" -Verb RunAs -ArgumentList $argumentList -Wait
        if exist "FOLDER" rd "FOLDER" /S /Q
        if exist "FILE" del /f "FILE"
        $products = Get-WmiObject win32_product | where { $_.name -eq "<App1>" -or $_.name -eq "<App2>"}
        foreach ($product in $products) {
            Write-Host Uninstalling $product.Name -ForegroundColor Green
            Start-Process "C:\Windows\System32\msiexec.exe" -ArgumentList "/x $($product.IdentifyingNumber) /qn /norestart" -Wait
            }
        Remove-Item -Path "HKLM:\REGISTRYKEY" -Confirm:$false -Recurse
    ---------------------------------------
    Intune uninstall command
    ---------------------------------------
        powershell.exe -ExecutionPolicy Bypass -NoLogo -NonInteractive -NoProfile -Command .\uninstall.ps1
#>

#---------------------------------------
# Variables
#---------------------------------------
$logDest = "$($env:ProgramData)\AutopilotConfig"
$fileName = "<FILENAME.msi>"
$logFile = "$logDest\$fileName.log"
$uninstallFile = "<FILEPATH>"

$argumentList = @(
    "/x "
    $uninstallFile
    "/qb! "
    "/norestart "
)

#---------------------------------------
# Make sure 64-bit PowerShell - Relaunch if not
#---------------------------------------
if ("$env:PROCESSOR_ARCHITEW6432" -ne "ARM64") {
    if (Test-Path "$($env:WINDIR)\SysNative\WindowsPowerShell\v1.0\powershell.exe") {
        Write-Host Relaunching as 64-bit Powershell -ForegroundColor Yellow
        & "$($env:WINDIR)\SysNative\WindowsPowerShell\v1.0\powershell.exe" -ExecutionPolicy bypass -NoProfile -File "$PSCommandPath"
        Exit $lastexitcode
    }
}

#---------------------------------------
# PreUninstall
#---------------------------------------
Start-Transcript "$logDest\Transcripts\$fileName-uninstall.log" -Append

if (!(Test-Path $logDest)) {
    New-Item -Path "$($env:ProgramData)" -Name "AutopilotConfig" -ItemType Directory
}

#---------------------------------------
# Uninstall
#---------------------------------------
Write-Host Uninstalling $fileName...
$products = Get-WmiObject win32_product | where { $_.name -like "*<App1>*" -or $_.name -like "*<App2>*"}
foreach ($product in $products) {
    Write-Host Uninstalling $product.Name -ForegroundColor Cyan
    Start-Process "C:\Windows\System32\msiexec.exe" -ArgumentList "/x $($product.IdentifyingNumber) /qn /norestart" -Wait
    }

#---------------------------------------
# PostUninstall
#---------------------------------------
if (Test-Path "$($logDest)\$($fileName).tag") {
    Write-Host Removing $fileName tag file -ForegroundColor Green
    Remove-Item -Path "$($logDest)\$($fileName).tag"
}
if (Test-Path $logFile) {
    Write-Host Removing $logFile -ForegroundColor Green
    Remove-Item -Path $logFile
}

#---------------------------------------
# Quit
#---------------------------------------
Stop-Transcript
Exit $lastexitcode