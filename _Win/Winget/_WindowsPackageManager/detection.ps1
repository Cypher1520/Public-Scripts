<#
.NOTES
    Detection script for WinGet

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
# resolve winget_exe
$winget_exe = Resolve-Path "C:\Program Files\WindowsApps\Microsoft.DesktopAppInstaller_*_*__8wekyb3d8bbwe\winget.exe"
if ($winget_exe.count -gt 1) {
    $winget_exe = $winget_exe[-1].Path
}

# check exe and functionality
if ($winget_exe) {
    if (& $winget_exe -v) {
        Write-Host "Found it!"
    }
}