<#
    .NOTES
        Author: Chris Rockwell
        Email: chris@r-is.tech | chris.rockwell@insight.com

    .DESCRIPTION
        Will uninstall applications previously installed with chocolatey.
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

#PreUninstall
$logDest = "$($env:ProgramData)\AutopilotConfig"
New-Item -Path "$($env:ProgramData)" -Name "AutopilotConfig" -ItemType Directory -ErrorAction SilentlyContinue

Start-Transcript "$logDest\Transcripts\$ID-Uninstall.log" -Append

#Uninstall
$localprograms = choco list
if ($localprograms -like "*$id*")
{
    Write-Host "$id found, uninstalling"
    choco uninstall $id -y --remove-dependencies
}

#Confirm and cleanup
if (!($localprograms -like "*$id*")) {
    if (Test-Path "$($logDest)\$($id).tag") {
        Write-Host "Removing $id tag file" -ForegroundColor Green
        Remove-Item -Path "$($logDest)\$($id).tag"
        Write-Host "Uninstall complete" -ForegroundColor Green

        Stop-Transcript
        Exit 0
    }
    else {
        Write-Host "Uninstall not complete, Result: $result" -ForegroundColor Red
        
        Stop-Transcript 
        Exit 1
    }
}