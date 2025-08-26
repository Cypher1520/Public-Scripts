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
        powershell.exe -ExecutionPolicy Bypass -command .\uninstall.ps1
#>

#-------------------------------------------
#region Variables
$fileName = "setup.exe"
#get product name using "get-wmiobject Win32_Product | Sort-Object -Property Name | Format-Table Name, Version -AutoSize"
$productName = $null #Replace with product name if available

#if app not in the list above, use uninstallFiles variable below, remove comment and fill in path for uninstall file.
$uninstallFile = $null # replace with "<FILEPATH>" if product name not available
$argumentList = @(
    #"SILENTSWITCHES"
)

#endRegion Variables
#-------------------------------------------

#region Functions
function ProductUninstall {    #Use this when program exists in the win32_products list, if not use fileUninstall
    # Uninstall
    Write-Host Uninstalling $fileName...

    $products = Get-WmiObject win32_product | where { $_.name -like "*$productName*" } #add ' -or $_.name -like "*<App2>*" ' to remove multiple products
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
}

function FileUninstall {
    # Uninstall
    Start-Process "$uninstallFile" -Verb RunAs -ArgumentList $argumentList -Wait

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
}
#endregion

#region Execution
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

if ($null -eq $uninstallFile -and $null -ne $productName) {
    ProductUninstall
}
elseif ($null -ne $uninstallFile) {
    FileUninstall
}
else {
    Write-Host "Variables Missing, try again"
}
#endregion