<#
.NOTES
    Detection script for Wallpaper Config

.DESCRIPTION
    Intune Commands
        Install: powershell.exe -executionpolicy bypass .\install.ps1
        Uninstall: powershell.exe -executionpolicy bypass .\uninstall.ps1

.EXAMPLE
    Detect from registry
        $path = "HKLM:\SOFTWARE\..."
        $value = "VALUE"

        #Detection Test
        if (Test-Path -Path $path) {
        Write-Host "Found Registry Entry" 
        Return 0 
        Exit 0
        }
    
    Detect File
        $path = "$env:ProgramData\AutopilotConfig\"
        $file = "<TAGFILE>" + ".tag"

        #Detection Test
        if (Test-Path ($path+$file) ) {
            Write-Host "Found $file" -ForegroundColor Green
            Return 0 
            Exit 0
        }
#>

#Variables
$path = "C:\Windows\Web\Wallpaper\DesktopWallpaper.jpg"

#Detection Test
if (Test-Path ($path) ) {
    Return 0 
    Exit 0
}