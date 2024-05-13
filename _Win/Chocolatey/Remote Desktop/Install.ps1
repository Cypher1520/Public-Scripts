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
                choco upgrade $app -y
            }
            Else
            {
                choco install $app -y
            }
#>

if (!(Test-Path "C:\ProgramData\chocolatey\choco.exe")) {
    Write-host Chocolatey not installed, installing now
    Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
}
else {
    $app = "remote-desktop-client"
    $localprograms = choco list
    if ($localprograms -like "*$app*") {
        choco upgrade $app -y
    }
    Else {
        choco install $app -y
    }
}