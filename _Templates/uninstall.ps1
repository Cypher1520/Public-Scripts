<#
.AUTHOR
        Chris Rockwell
        Email: chris@r-is.tech | chris.rockwell@insight.com

.SYNOPSIS
        Uninstall helper that supports product-based (Win32_Product/MSI) or
        file-based uninstall flows with logging and clean-up of tag files.

.DESCRIPTION
        This template provides two uninstall approaches:
            - ProductUninstall: locates MSI products via Win32_Product matching
                $productName and uninstalls them using msiexec.
            - FileUninstall: runs a provided uninstall executable ($uninstallFile)
                with silent switches in $argumentList.

        The script captures a transcript to %ProgramData%\IntuneConfig\Transcripts
        and removes tag/log artifacts for the target package after a successful
        uninstall. Adjust $argumentList, $productName, or $uninstallFile to suit
        the application being removed.

.EXAMPLE
        Intune command for uninstallation (copy/paste into intune program page):
                powershell.exe -ExecutionPolicy Bypass -NoProfile -File .\uninstall.ps1

.NOTES
        - Set $fileName and either $productName (preferred) or $uninstallFile
            before running the script.
        - Success exit codes treated as success: 0, 3010, 1641.
        - Caution: querying Win32_Product triggers consistency checks and can be
            slow; consider using registry or Get-Package where possible in
            production environments.
        - Get Installed apps options:
            Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | Select-Object DisplayName, DisplayVersion | Where-Object {$_.DisplayName} | Sort-Object DisplayName | Format-Table -AutoSize
            Get-Package | Select-Object Name, Version | Sort-Object Name | Format-Table -AutoSize
            Get-WmiObject Win32_Product | Sort-Object -Property Name | Format-Table IdentifyingNumber, Name, Version -AutoSize
#>

#-------------------------------------------
#region Variables
$fileName = $null       #Replace with filename
$productName = $null    #Replace with product name if available, use: "Get-Package | Select-Object Name, Version | Sort-Object Name | Format-Table -AutoSize"

#if app not in the list above, use uninstallFiles variable below, remove comment and fill in path for uninstall file.
$uninstallFile = $null  #Replace with "<FILEPATH>" if product name not available
$argumentList = @(
    #"SILENTSWITCHES"
)

#endRegion Variables
#-------------------------------------------

#region Functions
function ProductUninstall {    #Use this when program exists in the win32_products list, if not use fileUninstall
    # Uninstall
    Write-Host (Get-Date) "|" Uninstalling $fileName...

    if ([string]::IsNullOrEmpty($productName)) {
        Write-Host (Get-Date) "|" "Error: productName variable is not set." -ForegroundColor Red
        Stop-Transcript
        Exit 1
    }

    $products = Get-WmiObject win32_product | Where-Object { $_.name -like "*$productName*" } #add ' -or $_.name -like "*<App2>*" ' to remove multiple products
    
    if ($products.Count -eq 0) {
        Write-Host (Get-Date) "|" "No products found matching: $productName" -ForegroundColor Yellow
        Stop-Transcript
        Exit 0
    }

    $exitCode = 0
    foreach ($product in $products) {
        Write-Host (Get-Date) "|" Uninstalling $product.Name -ForegroundColor Cyan
        $proc = Start-Process "C:\Windows\System32\msiexec.exe" -ArgumentList "/x $($product.IdentifyingNumber) /qn /norestart" -PassThru -Wait
        if ($proc.ExitCode -notin @(0, 3010, 1641)) {
            Write-Host (Get-Date) "|" "Uninstall failed for $($product.Name). Exit code: $($proc.ExitCode)" -ForegroundColor Red
            $exitCode = $proc.ExitCode
        }
    }

    # PostUninstall
    # Delete Tag files if present
    if (Test-Path "$($logDest)\$($fileName).tag") {
        Write-Host (Get-Date) "|" Removing $fileName tag file -ForegroundColor Green
        Remove-Item -Path "$($logDest)\$($fileName).tag"
    }

    $logFile = "$logDest\$fileName.log"
    if (Test-Path $logFile) {
        Write-Host (Get-Date) "|" Removing $logFile -ForegroundColor Green
        Remove-Item -Path $logFile
    }

    # Quit
    Write-Host (Get-Date) "|" "Uninstall complete. Exit code: $exitCode" -ForegroundColor Green
    Stop-Transcript
    Exit $exitCode
}

function FileUninstall {
    # Uninstall
    if ([string]::IsNullOrEmpty($uninstallFile)) {
        Write-Host (Get-Date) "|" "Error: uninstallFile variable is not set." -ForegroundColor Red
        Stop-Transcript
        Exit 1
    }

    if (!(Test-Path $uninstallFile)) {
        Write-Host (Get-Date) "|" "Error: Uninstall file not found: $uninstallFile" -ForegroundColor Red
        Stop-Transcript
        Exit 1
    }

    Write-Host (Get-Date) "|" "Uninstalling using file: $uninstallFile" -ForegroundColor Cyan
    $proc = Start-Process "$uninstallFile" -Verb RunAs -ArgumentList $argumentList -PassThru -Wait
    $exitCode = $proc.ExitCode

    if ($exitCode -notin @(0, 3010, 1641)) {
        Write-Host (Get-Date) "|" "Uninstall failed. Exit code: $exitCode" -ForegroundColor Red
    }

    # PostUninstall
    # Delete tag files if present
    if (Test-Path "$($logDest)\$($fileName).tag") {
        Write-Host (Get-Date) "|" Removing $fileName tag file -ForegroundColor Green
        Remove-Item -Path "$($logDest)\$($fileName).tag"
    }
    $logFile = "$logDest\$fileName.log"
    if (Test-Path $logFile) {
        Write-Host (Get-Date) "|" Removing $logFile -ForegroundColor Green
        Remove-Item -Path $logFile
    }

    # Quit
    Write-Host (Get-Date) "|" "Uninstall complete. Exit code: $exitCode" -ForegroundColor Green
    Stop-Transcript
    Exit $exitCode
}
#endregion

#region Execution
# Make sure 64-bit PowerShell - Relaunch if not
if ("$env:PROCESSOR_ARCHITEW6432" -ne "ARM64") {
    if (Test-Path "$($env:WINDIR)\SysNative\WindowsPowerShell\v1.0\powershell.exe") {
        Write-Host (Get-Date) "|" Relaunching as 64-bit Powershell -ForegroundColor Yellow
        & "$($env:WINDIR)\SysNative\WindowsPowerShell\v1.0\powershell.exe" -ExecutionPolicy bypass -NoProfile -File "$PSCommandPath"
        Exit $lastexitcode
    }
}

#PreUninstall
$logDest = "$($env:ProgramData)\IntuneConfig"
if (!(Test-Path $logDest)) {
    New-Item -Path "$($env:ProgramData)" -Name "IntuneConfig" -ItemType Directory
}

# Create Transcripts subdirectory if it doesn't exist
if (!(Test-Path "$logDest\Transcripts")) {
    New-Item -Path "$logDest" -Name "Transcripts" -ItemType Directory
}

# Validate required variables
if ([string]::IsNullOrEmpty($fileName)) {
    Write-Host (Get-Date) "|" "Error: fileName variable is not set. Please specify a filename." -ForegroundColor Red
    Exit 1
}

Start-Transcript "$logDest\Transcripts\$fileName-uninstall.log" -Append

if ($null -ne $productName) {
    ProductUninstall
}
elseif (($null -eq $productName) -and ($null -ne $uninstallFile)) {
    FileUninstall
}
else {
    Write-Host (Get-Date) "|" "Error: Either productName or uninstallFile must be specified." -ForegroundColor Red
    Stop-Transcript
    Exit 1
}
#endregion