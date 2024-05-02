<#
    .NOTES
        Detection script for Chocolatey

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
            $file = "EXECUTABLE.exe"
            $path = "C:\Program Files\..."

            #Detection Test
            if (Test-Path ($path + '\' + $file) ) {
            Write-Host "Found $file" 
            Return 0 
            Exit 0
}
#>

#Variables
$target = "C:\ProgramData\chocolatey\choco.exe"

#Detection Test
if (Test-Path ($target) ) {
    Write-Host "Found $target" 
    Return 0 
    Exit 0
}