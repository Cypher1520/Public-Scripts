@echo off
rem -------------------------------
rem Win32 Uninstall .cmd wrapper
rem Garth Williams - Insight
rem -------------------------------
rem you need to find and replace the GUID between the {} in the uninstall commands below
rem to do that run following through Powershell
rem "get-wmiobject Win32_Product | Sort-Object -Property Name | Format-Table IdentifyingNumber, Name, Version -AutoSize" (no quotes)
rem -------------------------------
rem uninstall example: msiexec /x {<MSICODE>} /q
rem -------------------------------
set logdir=C:\ProgramData\AutoPilotConfig
rem -------------------------------

:check_OS_ver
echo Checking for OS version ...
FOR /F "tokens=1,2,3 delims= " %%A IN ('wmic os get Caption') DO IF %%B EQU Windows set WVer=%%B %%C
rem echo Result 1:  %WVer%
if "%WVer%"=="Windows 10" goto Win10
if "%WVer%"=="Windows 11" goto Win11

:Win10
echo Resetting default HKCU hive for Windows 10 ...
echo Nothing done!
goto post_setup

:Win11
echo Restting HKCU hive for Windows 11 ...
echo Loading default User Key ...
reg load "HKU\customDefault" "C:\Users\Default\NTUSER.DAT"
echo -Set Start Menu (move to center) ...
reg add "HKU\customDefault\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "Start_ShowClassicMode" /t REG_DWORD /d 0 /f
echo -Set Task Bar (move to center) ...
reg add "HKU\customDefault\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "TaskbarAl" /t REG_DWORD /d 1 /f
echo Unloading default User Key ...
reg unload "HKU\customDefault"

:real_current_user
echo Now do for REAL current user ...
echo -Set Start Menu (move to center) ...
reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "Start_ShowClassicMode" /t REG_DWORD /d 0 /f
echo -Set Task Bar (move to center) ...
reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "TaskbarAl" /t REG_DWORD /d 1 /f
goto post_setup

:post_setup
if exist C:\ProgramData\AutopilotConfig\SetHKUDefaultKeys.tag del /f C:\ProgramData\AutopilotConfig\SetHKUDefaultKeys.tag

:quit