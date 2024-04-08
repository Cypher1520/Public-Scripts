<#
    ---------------------------------------
    Application package script
    Chris Rockwell - Insight Canada
    chris.rockwell@insight.com
    ---------------------------------------
    References
    ---------------------------------------
        $result = (Start-Process "msiexec.exe" -ArgumentList $argumentList -Verb RunAs -PassThru -Wait).ExitCode
        msiexec /i $installer /qb! /norestart /l*v $logfile #TRANSFORMS=transform1.mst;transform2.mst
        reg add "<HKLM\REGISTRYLOCATION>" /v "<VALUENAME>" /t REG_SZ /d "<VALUEDATA>" /reg:<64/32> /f
            REG_SZ, REG_MULTI_SZ, REG_DWORD_BIG_ENDIAN, REG_DWORD, REG_BINARY, REG_DWORD_LITTLE_ENDIAN, REG_LINK, REG_FULL_RESOURCE_DESCRIPTOR, REG_EXPAND_SZ
        echo tag > C:\ProgramData\AutopilotConfig\<tag file>.tag
        xcopy "Source" "Destination" /Y /I
        FOR /d %%G in ("*") DO xcopy /Y "FILES TO COPY" "C:\users\%%G\AppData\Roaming\..."
        FOR /D %%G in ("*") DO REN "C:\Users\%%G\AppData\Local\OpenText" "OpenText.old"
    ---------------------------------------
    Silent install flag variants
    ---------------------------------------
        /s /silent /q /qn /qb --SILENT --VERYSILENT "/SILENT /VERYSILENT /SUPPRESSMSGBOXES /SP-"
    ---------------------------------------
    Intune install command
    ---------------------------------------
        powershell.exe -ExecutionPolicy Bypass -NoLogo -NonInteractive -NoProfile -Command .\install.ps1
#>

#---------------------------------------
# Variables
#---------------------------------------
$logDest = "$($env:ProgramData)\AutopilotConfig"
$fileName = "<FILENAME>"
$installer = "Media\$fileName"
$logFile = "$logDest\$fileName.log"

$argumentList = @(
    "/i "
    $installer
    "/qb!"
    "/norestart"
    "/L*v"
    $logFile
    #"ALLUSERS=1"
    #"OTHERATTRIBUTE=??"
)

#---------------------------------------
# Make sure 64-bit PowerShell - Relaunch if not
#---------------------------------------
if ("$env:PROCESSOR_ARCHITEW6432" -ne "ARM64") {
    if (Test-Path "$($env:WINDIR)\SysNative\WindowsPowerShell\v1.0\powershell.exe") {
        Write-Host Relaunching as 64-bit Powershell -ForegroundColor Cyan
        & "$($env:WINDIR)\SysNative\WindowsPowerShell\v1.0\powershell.exe" -ExecutionPolicy bypass -NoProfile -File "$PSCommandPath"
        Exit $lastexitcode
    }
}

#---------------------------------------
# PreInstall
#---------------------------------------
Start-Transcript "$logDest\Transcripts\$fileName-install.log" -Append

if (!(Test-Path $logDest)) {
    New-Item -Path "$($env:ProgramData)" -Name "AutopilotConfig" -ItemType Directory
}

#---------------------------------------
# Install
#---------------------------------------
Write-Host Installing $fileName...
$result = (Start-Process "msiexec.exe" -ArgumentList $argumentList -Verb RunAs -PassThru -Wait).ExitCode
if (!($result -eq 0 -or $result -eq 3010 -or $result -eq 1641)) {
    Write-Host Install Failed -ForegroundColor Red
    Write-Host Exitcode: $result -ForegroundColor Red
    Stop-Transcript
    Exit $result
}

#---------------------------------------
# PostInstall
#---------------------------------------
if (!(Test-Path "$env:ProgramData\AutopilotConfig\$($filename).tag")) {
    Write-Host Creating Tag file. -ForegroundColor Cyan
    New-Item -Path "$env:ProgramData\AutopilotConfig" -Name "$($filename).tag" -ItemType File -Value "Tag"
}

#---------------------------------------
# Quit
#---------------------------------------
Stop-Transcript
Write-Host "Install complete, ExitCode: $($result)" -ForegroundColor Green
Exit $result