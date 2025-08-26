Stop-service -Name wuauserv -Force
Stop-service -Name WSearch -Force
Stop-service -Name IntuneManagementExtension -Force
TASKKILL /F /IM OneDrive.exe /T