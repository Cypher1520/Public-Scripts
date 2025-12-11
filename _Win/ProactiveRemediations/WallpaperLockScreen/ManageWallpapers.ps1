<#
.AUTHOR
    Chris Rockwell
    Email: chris@r-is.tech | chris.rockwell@insight.com
    reference: https://cloudinfra.net/set-desktop-lock-screen-wallpaper-using-intune-win32-app/

.DESCRIPTION
  Copys image from package to local folder to use for desktop and lock screen.
  Paired with configuration profile to set the desktop background and lockscreen in a locked setting, configuration settings profile included in folder.

.Example
    Intune Install command
        powershell.exe -windowstyle hidden -ExecutionPolicy Bypass -command .\ManageWallpapers.ps1 -action install

    Intune Uninstall command
        powershell.exe -windowstyle hidden -ExecutionPolicy Bypass -command .\ManageWallpapers.ps1 -action uninstall
#>


Param
(
    [parameter(Mandatory)]
    [String]$action
    )

$wallpaperPath = "C:\Windows\Web\Wallpaper"

function installWallpaper {
    Copy-Item -Path ".\DesktopWallpaper.jpg" -Destination $wallpaperPath -force
    Copy-Item -Path ".\LockScreenWallpaper.jpg" -Destination $wallpaperPath -force
}

function uninstallWallpaper {
    Remove-Item "C:\Windows\Web\Wallpaper\DesktopWallpaper.jpg" -force
    Remove-Item "C:\Windows\Web\Wallpaper\LockScreenWallpaper.jpg" -force
}

if ($action -eq "install") {
    Write-Host Installing
    installWallpaper
}

elseif ($action -eq "uninstall") {
    Write-Output Uninstalling
    uninstallWallpaper
}

else {
    Write-Output $action
    Write-Host Incorrect action
}