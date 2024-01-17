cmd /c reg delete "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Taskband" /f
cmd /c %~dp0PinTo10v2.exe /pintb "C:\Program Files (x86)\Internet Explorer\iexplore.exe"
cmd /c %~dp0Pinto10v2.exe /pintb "C:\Windows\Explorer.exe"
cmd /c %~dp0Pinto10v2.exe /pintb "C:\Program Files (x86)\Microsoft Office\root\Office16\OUTLOOK.EXE"