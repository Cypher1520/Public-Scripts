@echo off
goto :Variables

::-------------------Comment Block Start-------------------
-------------------------------
Win32 Uninstall .cmd wrapper
Chris Rockwell - Insight
-------------------------------
    you need to find and replace the GUID between the {} in the uninstall commands below
    to do that run following through Powershell
    "get-wmiobject Win32_Product | Sort-Object -Property Name | Format-Table IdentifyingNumber, Name, Version -AutoSize" (no quotes)
    
::References examples: 
    msiexec /x %msicode% /qn /norestart
    powershell.exe -ExecutionPolicy Bypass -NoLogo -NonInteractive -NoProfile -Command .\Uninstall.ps1
    if exist "FOLDER" rd "FOLDER" /S /Q
    if exist "FILE" del /f "FILE"

::-------------------Comment Block End-------------------

:Variables
    if not exist "C:\ProgramData\AutopilotConfig" md "C:\ProgramData\AutopilotConfig"
    set logdir=C:\ProgramData\AutopilotConfig
    set filename=<FILENAME>
    set logfile="%logdir%\%filename%.log"
    set msicode="{MSI CODE}"
    set exeuninstall="Uninstall file location"

::PreUninstall
    
::Uninstall
    echo Uninstalling %filename%...

::PostUninstall
    if exist %logfile% del /f %logfile%
    if exist "C:\ProgramData\AutopilotConfig\%filename%.tag" del "C:\ProgramData\AutopilotConfig\%filename%.tag"

::Quit
