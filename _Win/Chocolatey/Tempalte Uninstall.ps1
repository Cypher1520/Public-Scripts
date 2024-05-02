<#
    .NOTES
        https://community.chocolatey.org/packages
        Must first have Chocolatey installed
        https://www.thelazyadministrator.com/2020/02/05/intune-chocolatey-a-match-made-in-heaven/

    .DESCRIPTION
        Intune Commands
            Install: powershell.exe -executionpolicy bypass .\install.ps1
            Uninstall: powershell.exe -executionpolicy bypass .\uninstall.ps1

    .EXAMPLE
        ------------- Uninstall -------------
            $app = "APPNAME"
            $localprograms = choco list
            if ($localprograms -like "*$app*")
            {
                choco uninstall $app -y
            }
#>

$app = "APP"
$localprograms = choco list
if ($localprograms -like "*$app*")
{
    choco uninstall $app -y --remove-dependencies
}