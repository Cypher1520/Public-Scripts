<#
.AUTHOR
    Chris Rockwell
    Email: chris@r-is.tech | chris.rockwell@insight.com

.DESCRIPTION
    Installs applications from Winget
    Use "Winget search "appname" to find the app ID's to use when calling install.ps1"

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

# Install winget if not present
$hasPackageManager = Get-AppPackage -name 'Microsoft.DesktopAppInstaller'
if (!$hasPackageManager -or [version]$hasPackageManager.Version -lt [version]"1.10.0.0") {
    "Installing winget Dependencies"
    Add-AppxPackage -Path 'https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx'
    $releases_url = 'https://api.github.com/repos/microsoft/winget-cli/releases/latest'

    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $releases = Invoke-RestMethod -uri $releases_url
    $latestRelease = $releases.assets | Where-Object { $_.browser_download_url.EndsWith('msixbundle') } | Select-Object -First 1

    "Installing winget from $($latestRelease.browser_download_url)"
    Add-AppxPackage -Path $latestRelease.browser_download_url
}
else {
    "winget already installed"
}

# Install
Write-Host "Installing app ID: $ID"
$result = (winget install --exact --id $ID --silent --accept-package-agreements --accept-source-agreements --disable-interactivity --scope=machine).split("\")[-1]

# PostInstall
#creates tag file, detects if the tag file is there for testing scenarios, not necessary when a new install

if ($result -eq "Successfully installed") {
    Write-Host Creating Tag file. -ForegroundColor Cyan
    New-Item -Path "$($logDest)" -Name "$($ID).tag" -ItemType File -Value "Tag" -ErrorAction SilentlyContinue
    Write-Host "Install complete, Result: $($result)" -ForegroundColor Green

    Stop-Transcript
    Exit 0
}
else {
    Write-Host "Install not complete, Result: $result" -ForegroundColor Red
    
    Stop-Transcript
    Exit 1
}