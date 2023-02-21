@echo off
goto :Variables

::-------------------Comment Block Start-------------------
---------------------------------------
Installation script
Chris Rockwell - Insight Canada
chris.rockwell@insight.com
---------------------------------------
References
msiexec /i "<MSIFILE>" /ALLUSERS=1 TRANSFORMS=transform1.mst;transform2.mst;transform3.mst /qb-! /norestart /l*v %logfile%
reg add "<HKLM\REGISTRYLOCATION>" /v "<VALUENAME>" /t REG_SZ /d "<VALUEDATA>" /f
echo tag > C:\ProgramData\AutopilotConfig\<tag file>.tag
cmd /c "OtherBatchFile.cmd"
powershell.exe -ExecutionPolicy Bypass -Command .\SCRIPTNAME.ps1
---------------------------------------
::-------------------Comment Block End-------------------

:Variables
    set installer="%~dp0<APP>"
    set logfile=C:\ProgramData\AutopilotConfig\<APP>.log
    set logdir=C:\ProgramData\AutopilotConfig

::PreInstall
    if not exist "C:\ProgramData\AutopilotConfig" md "C:\ProgramData\AutopilotConfig"

::install
    echo Installing <APP>...
    ::msiexec /i %installer% /q /norestart /l*v %logfile%
    ::%installer% /ALLUSERS /S /VERYSILENT

::PostInstall

::Quit
