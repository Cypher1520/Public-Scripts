@echo off
goto :Variables

::-------------------Comment Block Start-------------------
    ---------------------------------------
    Installation script
    Chris Rockwell - Insight Canada
    chris.rockwell@insight.com
    ---------------------------------------
    ::References
        msiexec /i %installer% /qb! /norestart /l*v %logfile% rem TRANSFORMS=transform1.mst;transform2.mst
        reg add "<HKLM\REGISTRYLOCATION>" /v "<VALUENAME>" /t REG_SZ /d "<VALUEDATA>" /reg:<64/32> /f
            REG_SZ, REG_MULTI_SZ, REG_DWORD_BIG_ENDIAN, REG_DWORD, REG_BINARY, REG_DWORD_LITTLE_ENDIAN, REG_LINK, REG_FULL_RESOURCE_DESCRIPTOR, REG_EXPAND_SZ
        echo tag > C:\ProgramData\AutopilotConfig\<tag file>.tag
        cmd /c "OtherBatchFile.cmd"
        powershell.exe -ExecutionPolicy Bypass -NoLogo -NonInteractive -NoProfile -Command .\SCRIPT.ps1
        xcopy "Source" "Destination" /Y /I
        if exist "FOLDER" rd "FOLDER" /S /Q
        if exist "FILE" del /f "FILE"
        start /wait <PROGRAM.exe>
        FOR /d %%G in ("*") DO xcopy /Y "FILES TO COPY" "C:\users\%%G\AppData\Roaming\..."
        FOR /D %%G in ("*") DO REN "C:\Users\%%G\AppData\Local\OpenText" "OpenText.old"

    ::Silent install flag variants
        /s /silent /q /qn /qb --SILENT --VERYSILENT "/SILENT /VERYSILENT /SUPPRESSMSGBOXES /SP-"
    
    ::Active Setup
        if exist "C:\Program Files\Autodesk\AutoCAD*" goto :Install
        if not exist "C:\ProgramData\ObjectEnablers" md "C:\ProgramData\ObjectEnablers"
        Copy "%~dp0AutoCADSpoof.reg" "C:\ProgramData\ObjectEnablers\" /y
        REG ADD "HKLM\SOFTWARE\Microsoft\Active Setup\Installed Components\Object_Enablers_AutoCAD_Spoof" /v "StubPath" /d "cmd /c REG IMPORT %ProgramData%\ObjectEnablers\AutoCADSpoof.reg" /t REG_SZ /f
        REG ADD "HKLM\SOFTWARE\Microsoft\Active Setup\Installed Components\Object_Enablers_AutoCAD_Spoof" /v "Version" /t REG_SZ /d "1.0.0" /f   
::-------------------Comment Block End-------------------

:Variables
    set logdir=C:\ProgramData\AutopilotConfig
    set filename1=<FILENAME>
    set installer="%~dp0Media\%filename%"
    set logfile="%logdir%\%filename%.log"

::PreInstall
    if not exist %logdir% md %logdir%

::Install
    echo Installing %filename1%...

::PostInstall
    echo tag > %logdir%\%filename%.tag

::Quit
