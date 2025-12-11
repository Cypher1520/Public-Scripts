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

.EXAMPLE
    Run the following to get list of installed applications, then copy the DisplayName and paste into  $ProductName
        $uninstallPaths = @(
            "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
            "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
        )

        foreach ($path in $uninstallPaths) {
            Get-ItemProperty $path -ErrorAction SilentlyContinue | Where-Object { $_.DisplayName } | Sort DisplayName | Select-Object DisplayName
        }
#>

$productName = "$null" # Set DisplayName of app to detect, example above

# Registry paths for installed applications
$uninstallPaths = @(
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
    "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
)

$found = $false

foreach ($path in $uninstallPaths) {
    $apps = Get-ItemProperty $path -ErrorAction SilentlyContinue | Where-Object {
        $_.DisplayName -and $_.DisplayName -like "*$productName*"
    }
    if ($apps) {
        $found = $true
        break
    }
}

if ($found) {
    Write-Host "$productName Detected"
    exit 0
} else {
    Write-Host "$productName Not Detected"
    exit 1
}