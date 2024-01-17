cmd /c reg delete "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Taskband" /f
cmd /c %DEPLOYROOT%\CustomScripts\TaskbarCleanup\PinTo10v2.exe /pintb "C:\Program Files (x86)\Internet Explorer\iexplore.exe"
cmd /c %DEPLOYROOT%\CustomScripts\TaskbarCleanup\Pinto10v2.exe /pintb "C:\Windows\Explorer.exe"