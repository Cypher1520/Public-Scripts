<#
.AUTHOR
    Chris Rockwell
    Email: chris@r-is.tech | chris.rockwell@insight.com

.SYNOPSIS
    Lightweight installer wrapper for MSI and EXE packages. Detects installer
    type by file extension and runs a silent install with basic logging.

.DESCRIPTION
    This script installs a single MSI or EXE package using configurable
    argument lists. It captures a transcript and writes logs to
    %ProgramData%\IntuneConfig, then creates a tag file after successful
    installation. Customize installer behavior by editing the
    $msiArgumentList and $exeArgumentList variables and add any additional
    post-install actions in the PostInstall section inside each Install
    function.

.EXAMPLE
    Intune command for installation (copy/paste into intune program page):
        powershell.exe -ExecutionPolicy Bypass -NoProfile -File .\install.ps1

.NOTES
    - Set $fileName to the installer filename (e.g. 'package.msi' or 'setup.exe').
    - Successful exit codes treated as success: 0, 3010, 1641.
    - Adjust silent switches and transforms in $msiArgumentList and
      $exeArgumentList as needed for specific installers.
    - Silent install flag variants
        /s /silent /q /qn /qb --SILENT --VERYSILENT "/SILENT /VERYSILENT /SUPPRESSMSGBOXES /SP-"
#>

#region Variables
# Global Variables
$fileName = $null       # fill in "filename.msi/exe"
$installer = "Media\$fileName"
$tag = $false           # use $true/$false to set creating tag files.

# Log Variables
$logDest = "$($env:ProgramData)\IntuneConfig"
$logFile = "$logDest\$fileName.log"

# MSI Variables
# edit variables in below lists if necessary
$msiArgumentList = @(   # add any arguments for msi installations, quote each line if strings
    "/i "
    $installer
    "/qb!"
    "/norestart"
    "/L*v"
    $logFile
    # "ALLUSERS=1"
    # "ACCEPT_EULA=YES"
    # "OTHERATTRIBUTE=ABC"
    # "TRANSFORMS=transorm1.mst;transform2.mst"
)

# EXE Variables
$exeArgumentList = @(   # add any arguments for exe installations, quote each line if strings
    
)

#endregion

#region Functions
function InstallMSI {
    # Install
    Write-Host (Get-Date) "|" MSI Installing $fileName... -ForegroundColor Cyan
    $proc = Start-Process "msiexec.exe" -ArgumentList $msiArgumentList -Verb RunAs -PassThru
    $proc.WaitForExit()
    $result = $proc.ExitCode
    if (!($result -in $errorCodes)) {
        Write-Host (Get-Date) "|" Install Failed, Try again. Result: $result -ForegroundColor Red
        Stop-Transcript
        Exit $result
    }

    # PostInstall
    # creates tag file\
    if ($tag -eq $true) {
        if (!(Test-Path "$env:ProgramData\IntuneConfig\$($fileName).tag")) {
            Write-Host (Get-Date) "|" Creating Tag file. -ForegroundColor Cyan
            New-Item -Path "$env:ProgramData\IntuneConfig" -Name "$($fileName).tag" -ItemType File -Value "Tag" -Force
        }
    }

    # Quit
    Write-Host (Get-Date) "|" "Install complete, ExitCode: $($result)" -ForegroundColor Green
    Exit $result
}

function InstallEXE {
    # Install
    Write-Host (Get-Date) "|" EXE Installing $fileName...
    $proc = Start-Process -FilePath "$installer" -ArgumentList $exeArgumentList -Verb RunAs -PassThru
    $proc.WaitForExit()
    $result = $proc.ExitCode
    if (!($result -in $errorCodes)) {
        Write-Host (Get-Date) "|" Install Failed, Try again. Result: $result -ForegroundColor Red
        Stop-Transcript
        Exit $result
    }

    # PostInstall
    # creates tag file
    if ($tag -eq $true) {
        if (!(Test-Path "$env:ProgramData\IntuneConfig\$($fileName).tag")) {
            Write-Host (Get-Date) "|" Creating Tag file. -ForegroundColor Cyan
            New-Item -Path "$env:ProgramData\IntuneConfig" -Name "$($fileName).tag" -ItemType File -Value "Tag" -Force
        }
    }

    # Quit
    Write-Host (Get-Date) "|" Install complete -ForegroundColor Green
    Exit $result
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

# Log setup
if (!(Test-Path $logDest)) {
    New-Item -Path "$($env:ProgramData)" -Name "IntuneConfig" -ItemType Directory
}

# Create Transcripts subdirectory if it doesn't exist
if (!(Test-Path "$logDest\Transcripts")) {
    New-Item -Path "$logDest" -Name "Transcripts" -ItemType Directory
}

$errorCodes = @([int]0, 3010, 1641)     #errorcodes related to successful installation

Start-Transcript "$logDest\Transcripts\$fileName-install.log" -Append
#endregion

#region Execute
# Check if fileName is set
if ([string]::IsNullOrEmpty($fileName)) {
    Write-Host (Get-Date) "|" "Error: fileName variable is not set. Please specify a filename." -ForegroundColor Red
    Stop-Transcript
    Exit 1
}

if (($fileName.Substring($fileName.Length - 3) -eq "msi")) {
    InstallMSI 
}
elseif (($fileName.Substring($fileName.Length - 3) -eq "exe")) {
    InstallEXE
}
else {
    Write-Host (Get-Date) "|" File type not valid installer, please try again -ForegroundColor Red
    Stop-Transcript
}
#endregion