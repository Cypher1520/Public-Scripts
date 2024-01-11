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
        ------------- Install -------------
            $app = "APPNAME"
            $localprograms = choco list
            if ($localprograms -like "*$app*")
            {
                C:\ProgramData\chocolatey\choco.exe upgrade $app -y
            }
            Else
            {
                C:\ProgramData\chocolatey\choco.exe install $app -y
            }
#>

$app = "unifying"
$localprograms = choco list
if ($localprograms -like "*$app*")
{
    C:\ProgramData\chocolatey\choco.exe upgrade $app -y
}
Else
{
    C:\ProgramData\chocolatey\choco.exe install $app -y
}