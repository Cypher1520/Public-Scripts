@echo off
rem ---------------------------------------
rem Set HKCU key for Win10 or 11
rem ---------------------------------------
rem Garth Williams - Insight Canada
rem ---------------------------------------
rem call2 reg load/add/unload to modify
rem HKU key to set default HKCU values
rem ---------------------------------------
rem Detection: File
rem path: C:\ProgramData\AutopilotConfig
rem file: SetHKUDefaultKeys.tag
rem ---------------------------------------
rem RUN AS SYSTEM!
rem ---------------------------------------

:setup
if not exist "C:\ProgramData\AutopilotConfig" md "C:\ProgramData\AutopilotConfig"

:check_OS_ver
echo Checking for OS version ...
FOR /F "tokens=1,2,3 delims= " %%A IN ('wmic os get Caption') DO IF %%B EQU Windows set WVer=%%B %%C
rem echo Result 1:  %WVer%
if "%WVer%"=="Windows 10" goto Win10
if "%WVer%"=="Windows 11" goto Win11

:Win10
echo Modifying default HKCU hive for Windows 10 ...
rem DO STUFF HERE
echo Nothing done!
:tag_Win10
echo Set HKU key for default Windows 10 users > C:\ProgramData\AutopilotConfig\SetHKUDefaultKeys.tag
goto quit


:Win11
echo Modifying default HKCU hive for Windows 11 ...
echo Loading default User Key ...
reg load "HKU\customDefault" "C:\Users\Default\NTUSER.DAT"
echo -Set Start Menu (move to left) ...
reg add "HKU\customDefault\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "Start_ShowClassicMode" /t REG_DWORD /d 1 /f
echo -Set Task Bar (move to left) ...
reg add "HKU\customDefault\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "TaskbarAl" /t REG_DWORD /d 0 /f
echo Unloading default User Key ...
reg unload "HKU\customDefault"
:tag_Win11
echo Set HKU key for default Windows 11 users > C:\ProgramData\AutopilotConfig\SetHKUDefaultKeys.tag

:quit