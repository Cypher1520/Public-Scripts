<#
    .NOTES
        https://community.chocolatey.org/packages
        Must first have Chocolatey installed

    .DESCRIPTION
        Intune Commands
            Install: powershell.exe -executionpolicy bypass .\install.ps1
            Uninstall: powershell.exe -executionpolicy bypass .\uninstall.ps1

    .EXAMPLE
        ------------- Detection -------------
            $app = "APPNAME"
            $localprograms = choco list
            if ($localprograms -like "*$app*")
            {
                Write-Host "Found $app" 
                Return 0 
                Exit 0
            }
#>

#Variables
$target = "C:\Program Files\Remote Desktop\msrdcw.exe"

#Detection Test
if (Test-Path ($target) ) {
    Write-Host "Found $target" 
    Return 0 
    Exit 0
}