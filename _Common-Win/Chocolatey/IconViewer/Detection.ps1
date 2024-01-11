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

$app = "iconviewer"
$localprograms = choco list
if ($localprograms -like "*$app*")
{
    Write-Host "Found $app" 
    Return 0 
    Exit 0
}