# Winget Deployment Package for intune

1. Find app ID you want to install
    winget search "app name", copy the app id

2. upload the install.intunewin to intune, fill out details as needed

3. In the "Install Command" and "uninstall command" fields respectively input:
    powershell.exe -windowstyle hidden -ExecutionPolicy Bypass -command .\install.ps1 -id <APPID>
    powershell.exe -windowstyle hidden -ExecutionPolicy Bypass -command .\uinstall.ps1 -id <APPID>
    Replacing <APPID> with previously copied app ID. 

4. Detection script if you choose to use it, will need to edit line #33, put the app ID in there as well. 