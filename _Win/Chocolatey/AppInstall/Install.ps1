<#
    .NOTES
        Author: Chris Rockwell
        Email: chris@r-is.tech | chris.rockwell@insight.com

    .DESCRIPTION
        Will install applications from chocolatey, confirm that chocolatey, and then install the application
            It's best if chocolatey is installed first however as there's other features in our chocolatey install package. 
        Mandatory parameter "-id" 
        Get app names from "https://community.chocolatey.org/packages". The app name is after "choco install" listed for that app, copy exactly as shown on the page

    .EXAMPLE
        Intune Commands
            Install: powershell.exe -windowstyle hidden -ExecutionPolicy Bypass -command .\install.ps1 -id "APPNAME"
            Uninstall: powershell.exe -windowstyle hidden -ExecutionPolicy Bypass -command .\uninstall.ps1 -id "APPNAME"
#>

Param
(
    [parameter(Mandatory = $true)]
    [String[]]
    $id
)

#PreInstall
New-Item -Path "$($env:ProgramData)" -Name "AutopilotConfig" -ItemType Directory -ErrorAction SilentlyContinue | Out-Null
$logDest = "$($env:ProgramData)\AutopilotConfig"

Start-Transcript "$logDest\Transcripts\$id-Choco-install.log" -Append

#Test if installed, upgrade if true, install if not.
$localprograms = choco list
if ($localprograms -like "*$id*") {
    Write-Host "Upgrading: $id"
    choco upgrade $id -y
    Write-Host "Upgrading: $id, complete"
}
else {
    Write-Host "Installing: $id"
    choco install $id -y
    Write-Host "Installing: $id, complete"
}

#Confirm install and create tag file for detection.
$localprograms = choco list
if ($localprograms -like "*$id*") {
    Write-Host "App detected, Creating Tag file" -ForegroundColor Cyan
    New-Item -Path "$logDest" -Name "$id.tag" -ItemType File -Value "Tag" -ErrorAction SilentlyContinue | Out-Null
    Write-Host "Process complete" -ForegroundColor Green

    Stop-Transcript
    Exit 0
}
else {
    Write-Host "App not detected, Install not complete" -ForegroundColor Red
    
    Stop-Transcript
    Exit 1
}