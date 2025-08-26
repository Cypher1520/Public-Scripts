<#
.SYNOPSIS
    Installs one or more MSI or EXE applications using PowerShell, with support for custom arguments and logging.

.DESCRIPTION
    This script automates the installation of MSI and EXE files. It determines the installer type, applies default or file-specific arguments, and logs the installation process. Custom post-install steps can be added in the PostInstall sections of the functions. Supports batch installs, error handling, and transcript logging for auditing.

.AUTHOR
    Chris Rockwell
    Email: chris@r-is.tech | chris.rockwell@insight.com

.EXAMPLE
    # Install all files listed in the $fileNames array silently
    powershell.exe -ExecutionPolicy Bypass -File .\install.ps1

    # Example for Intune Win32 app deployment
    powershell.exe -ExecutionPolicy Bypass -command .\install.ps1

.NOTES
    References:
        $result = (Start-Process "msiexec.exe" -ArgumentList $argumentList -Verb RunAs -PassThru -Wait).ExitCode
        FOR /d %%G in ("*") DO xcopy /Y "FILES TO COPY" "C:\users\%%G\AppData\Roaming\..."
        FOR /D %%G in ("*") DO REN "C:\Users\%%G\AppData\Local\OpenText" "OpenText.old"
        PSADT reference:
            powershell.exe -ExecutionPolicy Bypass -command "& { & '.\Deploy-Application.ps1' -DeployMode 'Silent'; Exit $LastExitCode }"
            powershell.exe -ExecutionPolicy Bypass -command "& { & '.\Deploy-Application.ps1' -DeploymentType 'Uninstall' -DeployMode 'Silent'; Exit $LastExitCode }"
#>

#region Variables
# Global Variables - Define multiple files to install
$fileNames = @(
    # Add your files here, e.g.:
    # "app1.msi",
    # "app2.exe",
    # "app3.msi"
)

#Log Variables
$logDest = "$($env:ProgramData)\AutopilotConfig"

# MSI Variables - Templates (will be populated per file)
$msiArgumentTemplate = @(   #add any arguments for msi installations, quote each line if strings
    "/i"
    "{INSTALLER_PATH}"
    "/qb!"
    "/norestart"
    "/L*v"
    "{LOG_FILE}"
    <# Other e.g.:
    "ALLUSERS=1"
    "OTHERATTRIBUTE=ABC"
    "TRANSFORMS=transorm1.mst;transform2.mst"
    #>
)

# EXE Variables - Templates (will be populated per file)
$exeArgumentTemplate = @(   #add any arguments for exe installations, quote each line if strings
    <# Add EXE arguments here, e.g.:
    "/S"
    "/SILENT"
    "/VERYSILENT"
    "/SUPPRESSMSGBOXES"
    "--SILENT"
    "--VERYSILENT"
    "/SP-"
    #>
)

# File-specific configurations (optional - for files that need special handling)
$fileConfigs = @{
    # Example: Override default arguments for specific files
    # "specialapp.exe" = @("/SILENT", "/DIR=C:\SpecialApp")
    # "customapp.msi" = @("/i", "{INSTALLER_PATH}", "/qn", "CUSTOMPROP=VALUE")
}

#endregion

#region Functions
function Get-FileExtension {
    param([string]$fileName)
    return $fileName.Substring($fileName.LastIndexOf('.') + 1).ToLower()
}

function Get-InstallerArguments {
    param(
        [string]$fileName,
        [string]$installer,
        [string]$logFile
    )
    
    # Check for file-specific configuration first
    if ($fileConfigs.ContainsKey($fileName)) {
        $installArgs = $fileConfigs[$fileName].Clone()
        # Replace placeholders in custom configs
        for ($i = 0; $i -lt $installArgs.Count; $i++) {
            $installArgs[$i] = $installArgs[$i] -replace "{INSTALLER_PATH}", $installer
            $installArgs[$i] = $installArgs[$i] -replace "{LOG_FILE}", $logFile
        }
        return $installArgs
    }
    
    # Use default templates
    $extension = Get-FileExtension -fileName $fileName
    switch ($extension) {
        "msi" {
            $installArgs = $msiArgumentTemplate.Clone()
            for ($i = 0; $i -lt $installArgs.Count; $i++) {
                $installArgs[$i] = $installArgs[$i] -replace "{INSTALLER_PATH}", $installer
                $installArgs[$i] = $installArgs[$i] -replace "{LOG_FILE}", $logFile
            }
            return $installArgs
        }
        "exe" {
            return $exeArgumentTemplate.Clone()
        }
        default {
            throw "Unsupported file type: $extension"
        }
    }
}

function InstallMSI {
    param(
        [string]$fileName,
        [array]$argumentList
    )
    
    # Install
    Write-Host (Get-Date) "|" MSI Installing $fileName... -ForegroundColor Cyan
    $proc = Start-Process "msiexec.exe" -ArgumentList $argumentList -Verb RunAs -PassThru
    $proc.WaitForExit()
    $result = $proc.ExitCode
    
    if (!($result -in $errorCodes)) {
        Write-Host (Get-Date) "|" Install Failed for $fileName, Result: $result -ForegroundColor Red
        return $result
    }

    # PostInstall - creates tag file
    if (!(Test-Path "$env:ProgramData\AutopilotConfig\$($fileName).tag")) {
        Write-Host (Get-Date) "|" Creating Tag file for $fileName. -ForegroundColor Cyan
        New-Item -Path "$env:ProgramData\AutopilotConfig" -Name "$($fileName).tag" -ItemType File -Value "Tag" -Force
    }

    Write-Host (Get-Date) "|" "$fileName install complete, ExitCode: $($result)" -ForegroundColor Green
    return $result
}

function InstallEXE {
    param(
        [string]$fileName,
        [string]$installer,
        [array]$argumentList
    )
    
    # Install
    Write-Host (Get-Date) "|" EXE Installing $fileName... -ForegroundColor Cyan
    $proc = Start-Process -FilePath "$installer" -ArgumentList $argumentList -Verb RunAs -PassThru
    $proc.WaitForExit()
    $result = $proc.ExitCode
    
    if (!($result -in $errorCodes)) {
        Write-Host (Get-Date) "|" Install Failed for $fileName, Result: $result -ForegroundColor Red
        return $result
    }

    # PostInstall - creates tag file
    if (!(Test-Path "$env:ProgramData\AutopilotConfig\$($fileName).tag")) {
        Write-Host (Get-Date) "|" Creating Tag file for $fileName. -ForegroundColor Cyan
        New-Item -Path "$env:ProgramData\AutopilotConfig" -Name "$($fileName).tag" -ItemType File -Value "Tag" -Force
    }

    Write-Host (Get-Date) "|" "$fileName install complete, ExitCode: $($result)" -ForegroundColor Green
    return $result
}
#endregion

#region PreInstall
# Make sure 64-bit PowerShell - Relaunch if not
if ("$env:PROCESSOR_ARCHITEW6432" -ne "ARM64") {
    if (Test-Path "$($env:WINDIR)\SysNative\WindowsPowerShell\v1.0\powershell.exe") {
        Write-Host (Get-Date) "|" Relaunching as 64-bit Powershell -ForegroundColor Cyan
        & "$($env:WINDIR)\SysNative\WindowsPowerShell\v1.0\powershell.exe" -ExecutionPolicy bypass -NoProfile -File "$PSCommandPath"
        Exit $lastexitcode
    }
}

#Log setup
if (!(Test-Path $logDest)) {
    New-Item -Path "$($env:ProgramData)" -Name "AutopilotConfig" -ItemType Directory
}

# Create Transcripts subdirectory if it doesn't exist
if (!(Test-Path "$logDest\Transcripts")) {
    New-Item -Path "$logDest" -Name "Transcripts" -ItemType Directory
}

$errorCodes = @([int]0, 3010, 1641)     #errorcodes related to successful installation

# Start transcript with timestamp
$transcriptName = "MultiInstall-$(Get-Date -Format 'yyyyMMdd-HHmmss').log"
Start-Transcript "$logDest\Transcripts\$transcriptName" -Append
#endregion

#region Execute
# Check if fileNames array is populated
if ($fileNames.Count -eq 0) {
    Write-Host (Get-Date) "|" "Error: No files specified in fileNames array. Please add filenames to install." -ForegroundColor Red
    Stop-Transcript
    Exit 1
}

Write-Host (Get-Date) "|" "Starting installation of $($fileNames.Count) file(s)..." -ForegroundColor Cyan

$overallSuccess = $true
$installResults = @()

foreach ($fileName in $fileNames) {
    try {
        Write-Host "`n" (Get-Date) "|" "Processing: $fileName" -ForegroundColor Yellow
        
        # Set up paths for this file
        $installer = "Media\$fileName"
        $logFile = "$logDest\$fileName.log"
        
        # Check if file exists
        if (!(Test-Path $installer)) {
            Write-Host (Get-Date) "|" "Error: File not found: $installer" -ForegroundColor Red
            $installResults += @{FileName = $fileName; Result = "File Not Found"; ExitCode = 2}
            $overallSuccess = $false
            continue
        }
        
        # Get file extension and determine install method
        $extension = Get-FileExtension -fileName $fileName
        $arguments = Get-InstallerArguments -fileName $fileName -installer $installer -logFile $logFile
        
        switch ($extension) {
            "msi" {
                $result = InstallMSI -fileName $fileName -argumentList $arguments
            }
            "exe" {
                $result = InstallEXE -fileName $fileName -installer $installer -argumentList $arguments
            }
            default {
                Write-Host (Get-Date) "|" "Unsupported file type: $extension for file $fileName" -ForegroundColor Red
                $installResults += @{FileName = $fileName; Result = "Unsupported Type"; ExitCode = 3}
                $overallSuccess = $false
                continue
            }
        }
        
        # Track results
        if ($result -in $errorCodes) {
            $installResults += @{FileName = $fileName; Result = "Success"; ExitCode = $result}
        } else {
            $installResults += @{FileName = $fileName; Result = "Failed"; ExitCode = $result}
            $overallSuccess = $false
        }
        
    } catch {
        Write-Host (Get-Date) "|" "Error processing $fileName`: $($_.Exception.Message)" -ForegroundColor Red
        $installResults += @{FileName = $fileName; Result = "Exception"; ExitCode = 999}
        $overallSuccess = $false
    }
}

# Summary
Write-Host "`n" (Get-Date) "|" "Installation Summary:" -ForegroundColor Cyan
Write-Host "=" * 50 -ForegroundColor Cyan
foreach ($result in $installResults) {
    $color = if ($result.Result -eq "Success") { "Green" } else { "Red" }
    Write-Host "$($result.FileName): $($result.Result) (Exit Code: $($result.ExitCode))" -ForegroundColor $color
}

if ($overallSuccess) {
    Write-Host "`n" (Get-Date) "|" "All installations completed successfully!" -ForegroundColor Green
    Stop-Transcript
    Exit 0
} else {
    Write-Host "`n" (Get-Date) "|" "One or more installations failed. Check logs for details." -ForegroundColor Red
    Stop-Transcript
    Exit 1
}
#endregion