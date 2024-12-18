<#
.AUTHOR
    Chris Rockwell
    Email: chris@r-is.tech | chris.rockwell@insight.com

.DESCRIPTION
    References
        $result = (Start-Process "msiexec.exe" -ArgumentList $argumentList -Verb RunAs -PassThru -Wait).ExitCode
        FOR /d %%G in ("*") DO xcopy /Y "FILES TO COPY" "C:\users\%%G\AppData\Roaming\..."
        FOR /D %%G in ("*") DO REN "C:\Users\%%G\AppData\Local\OpenText" "OpenText.old"

    Silent install flag variants
        /s /silent /q /qn /qb --SILENT --VERYSILENT "/SILENT /VERYSILENT /SUPPRESSMSGBOXES /SP-"

.Example
    Intune install command
        powershell.exe -windowstyle hidden -ExecutionPolicy Bypass -command .\install.ps1
#>

#region Variables
#-------------------------------------------
# Global Variables
$fileName = "<FILENAME>"
$installer = "Media\$fileName"

# MSI Variables
$logFile = "$logDest\$fileName.log"
$argumentList = @(
    "/i "
    $installer
    "/qb!"
    "/norestart"
    "/L*v"
    $logFile
    #"ALLUSERS=1"
    #"OTHERATTRIBUTE=ABC"
    #"TRANSFORMS=transorm1.mst;transform2.mst"
)

# EXE Variables
$argumentList = @(
    "OMAHA=1"
    #"/s"
    #"--SILENT"
)
#-------------------------------------------
#endregion

#region Functions
function InstallMSI {
    # Install
    Write-Host MSI Installing $fileName...
    $result = (Start-Process "msiexec.exe" -ArgumentList $argumentList -Verb RunAs -PassThru -Wait).ExitCode
    if (!($result -eq 0 -or $result -eq 3010 -or $result -eq 1641)) {
        Write-Host Install Failed -ForegroundColor Red
        Write-Host Exitcode: $result -ForegroundColor Red
        Stop-Transcript
        Exit $result
    }

    # PostInstall
    #creates tag file, detects if the tag file is there for testing scenarios, not necessary when a new install
    if (!(Test-Path "$env:ProgramData\AutopilotConfig\$($filename).tag")) {
        Write-Host Creating Tag file. -ForegroundColor Cyan
        New-Item -Path "$env:ProgramData\AutopilotConfig" -Name "$($filename).tag" -ItemType File -Value "Tag"
    }

    # Quit
    Stop-Transcript
    Write-Host "Install complete, ExitCode: $($result)" -ForegroundColor Green
    Exit $result
}

function InstallEXE {
    # Install
    Write-Host EXE Installing $fileName...
    $result = (Start-Process "$installer" -ArgumentList $argumentList -Verb RunAs -PassThru -Wait).ExitCode
    if (!($result -eq 0 -or $result -eq 3010 -or $result -eq 1641)) {
        Write-Host "Install Failed, Try again"-ForegroundColor Red
        Stop-Transcript
        Exit $result
    }

    # PostInstall
    #creates tag file, detects if the tag file is there for testing scenarios, not necessary when a new install
    if (!(Test-Path "$env:ProgramData\AutopilotConfig\$($fileName).tag")) {
        Write-Host Creating Tag file. -ForegroundColor Cyan
        New-Item -Path "$env:ProgramData\AutopilotConfig" -Name "$($fileName).tag" -ItemType File -Value "Tag"
    }

    # Quit
    Stop-Transcript
    Write-Host "Install complete" -ForegroundColor Green
    Exit $result
}
#endregion

#region PreInstall
# Make sure 64-bit PowerShell - Relaunch if not
if ("$env:PROCESSOR_ARCHITEW6432" -ne "ARM64") {
    if (Test-Path "$($env:WINDIR)\SysNative\WindowsPowerShell\v1.0\powershell.exe") {
        Write-Host Relaunching as 64-bit Powershell -ForegroundColor Cyan
        & "$($env:WINDIR)\SysNative\WindowsPowerShell\v1.0\powershell.exe" -ExecutionPolicy bypass -NoProfile -File "$PSCommandPath"
        Exit $lastexitcode
    }
}
#Log setup
$logDest = "$($env:ProgramData)\AutopilotConfig"
if (!(Test-Path $logDest)) {
    New-Item -Path "$($env:ProgramData)" -Name "AutopilotConfig" -ItemType Directory
}
Start-Transcript "$logDest\Transcripts\$fileName-install.log" -Append
#endregion

#region Exectue
if (($fileName.Substring($fileName.Length - 3) -eq "msi")) {
    InstallMSI 
}
elseif (($fileName.Substring($fileName.Length - 3) -eq "exe")) {
    InstallEXE
}
else {
    Write-Host "File type not valid installer, please try again" -ForegroundColor Red
}
#endregion