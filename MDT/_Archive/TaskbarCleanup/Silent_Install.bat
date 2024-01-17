MKDIR C:\Windows\Support
MKDIR C:\Windows\Support\TaskbarCleanup
xcopy "%~DP0PinTo10v2.exe" "C:\Windows\Support\TaskbarCleanup\" /y
xcopy "%~DP0TaskBarCleanUp.bat" "C:\Windows\Support\TaskbarCleanup\" /y
regedit /s "%~DP0TaskbarCleanup.reg"
"%~DP0TaskBarCleanUp.bat"
