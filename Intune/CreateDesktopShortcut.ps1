# ------------------------------------------------
# PowerShell script to create Desktop shortcut
# ------------------------------------------------
# Thanks to Niels Kok
# https://www.nielskok.tech/microsoft365/deploy-internet-shortcut-with-custom-icon-via-intune-using-win32app/
# ------------------------------------------------
# modified slightly by Garth Williams (garth.williams@insight.com)
# ------------------------------------------------
$null = $WshShell = New-Object -comObject WScript.Shell
$path = "C:\Users\Public\Desktop\CBN-Home.url"
$targetpath = "
https://www.cbnco.com/"
$iconlocation = "C:\ProgramData\AutopilotConfig\Icons\CBN.ico"
$iconfile = "IconFile=" + $iconlocation
$Shortcut = $WshShell.CreateShortcut($path)
$Shortcut.TargetPath = $targetpath
$Shortcut.Save()
Add-Content $path "HotKey=0"
Add-Content $path "$iconfile"
Add-Content $path "IconIndex=0"

#Alternative

# Create Shortcut for EasyView on Public Local Laptop Desktop
$TargetFile = "C:\Program Files (x86)\Curtis Instruments\Easy View\EasyView.EXE"
$PublicDesktopPath = [Environment]::GetFolderPath('CommonDesktopDirectory')
$ShortcutFile = "$PublicDesktopPath\EasyView.lnk"
$WScriptShell = New-Object -ComObject WScript.Shell

# Check if shortcut already exists
if (-not (Test-Path $ShortcutFile)) {
    # Create shortcut if it doesn't exist
    $Shortcut = $WScriptShell.CreateShortcut($ShortcutFile)
    $Shortcut.TargetPath = $TargetFile
    $Shortcut.Save()
}