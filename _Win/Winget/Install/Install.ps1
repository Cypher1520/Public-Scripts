<#
.AUTHOR
    Chris Rockwell
    Email: chris@r-is.tech | chris.rockwell@insight.com

.DESCRIPTION
    Installs applications from Winget
    Use "Winget search 'appname' to find the app ID's to use when calling install.ps1"

.Example
    Intune install command
        powershell.exe -windowstyle hidden -ExecutionPolicy Bypass -command .\install.ps1 -id <APPID CASE SENSITIVE>
#>

Param
(
    [parameter(Mandatory = $true)]
    [String[]]
    $ID
)

# PreInstall
$logDest = "$($env:ProgramData)\_Intune"
New-Item -Path "$($env:ProgramData)" -Name "_Intune" -ItemType Directory -ErrorAction SilentlyContinue
Start-Transcript "$logDest\Transcripts\$ID-install.log" -Append

# resolve winget_exe
$winget_exe = winget ls --accept-source-agreements

# Install
if (!$winget_exe[13]) { 
    $wingeterror = "Winget not installed"
    Write-Error $wingeterror
}
else {
    Write-Host "Winget Detected, installing app ID: $ID"
    $result = (winget install --exact --id $ID --silent --accept-package-agreements --accept-source-agreements --disable-interactivity --scope=machine).split("\")[-1]
}

# PostInstall
#creates tag file, detects if the tag file is there for testing scenarios, not necessary when a new install
if (!$wgeterror) {
    Write-Host Creating Tag file. -ForegroundColor Cyan
    New-Item -Path "$($logDest)" -Name "$($ID).tag" -ItemType File -Value "Tag" -ErrorAction SilentlyContinue
    Write-Host "Install complete, Result: $($result)" -ForegroundColor Green
        
    Stop-Transcript
    Exit 0
}
else {
    if ($null -eq $result) {
        $result = $wingeterror
    }
    Write-Host "Install not complete, Result: $result" -ForegroundColor Red
    
    Stop-Transcript
    Exit 1
}