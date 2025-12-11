<#
.NOTES
    File    : detection.ps1
    Purpose : Intune Win32 App detection script template.
    Author  : Chris Rockwell 
    Email   : chris@r-is.tech | chris.rockwell@insight.com
    Usage   : Return exit code 0 when the application is detected (no install required).
              Return non-zero when detection fails (installer should run).

.DESCRIPTION
    Minimal, easy-to-edit template for use as the "Detection script" in Intune Win32 app
    packaging. The sample below checks for a tag file under a ProgramData path. Replace the
    detection logic with whatever artifact your installer creates (file, registry key, product
    version, etc.).
#>

#Variables
$path = "$env:ProgramData\AutopilotConfig\"
$file = $null       #Replace with filename from install/uninstall

#Detection Test
if (Test-Path ($path+$file+".tag") ) {
    Write-Host "Found $file.tag" -ForegroundColor Green
    Return 0 
    Exit 0
}