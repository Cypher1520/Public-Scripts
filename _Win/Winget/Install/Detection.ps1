<#
.NOTES
    Detection script for Winget Application

.DESCRIPTION
    Custom Detection script detects if the app targeted is installed.

.EXAMPLE
    Detect File
        $path = "$env:ProgramData\AutopilotConfig\"
        $file = "<TAGFILE>" + ".tag"

        #Detection Test
        if (Test-Path ($path+$file) ) {
            Write-Host "Found $file" -ForegroundColor Green
            Return 0 
            Exit 0
        }

    Detect from registry
        $path = "HKLM:\SOFTWARE\..."
        $value = "VALUE"

        #Detection Test
        if (Test-Path -Path $path) {
        Write-Host "Found Registry Entry" 
        Return 0 
        Exit 0
        }
#>

#Variable
$ID = "VideoLAN.VLC"

#Detection Test
$path = "$env:ProgramData\_Intune\"
$file = $ID + ".tag"
if (Test-Path ($path+$file) ) {
    Write-Host "Found $file" -ForegroundColor Green
    Return 0 
    Exit 0
}