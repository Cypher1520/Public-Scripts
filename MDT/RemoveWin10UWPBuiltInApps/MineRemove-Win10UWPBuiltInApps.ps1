function Write-LogEntry {
    param(
        [parameter(Mandatory=$true, HelpMessage="Value added to the RemovedWin10UWPApps.log file.")]
        [ValidateNotNullOrEmpty()]
        [string]$Value,
        [parameter(Mandatory=$false, HelpMessage="Name of the log file that the entry will written to.")]
        [ValidateNotNullOrEmpty()]
        [string]$FileName = "RemovedWin10UWPApps.log"
    )
    # Determine log file location
    $LogFilePath = Join-Path -Path $env:windir -ChildPath "Logs\$($FileName)"
    # Add value to log file
    try {
        Add-Content -Value $Value -LiteralPath $LogFilePath -ErrorAction Stop
    }
    catch [System.Exception] {
        Write-Warning -Message "Unable to append log entry to RemovedApps.log file"
    }
}
# Get a list of all apps
Write-LogEntry -Value "Starting built-in AppxPackage and AppxProvisioningPackage removal process"
$AppArrayList = Get-AppxPackage -PackageTypeFilter Bundle -AllUsers | Select-Object -Property Name, PackageFullName | Sort-Object -Property Name
# White list of appx packages to keep installed
$WhiteListedApps = @(
    "Microsoft.DesktopAppInstaller", 
    "Microsoft.Messaging", 
    "Microsoft.StorePurchaseApp"
    "Microsoft.WindowsCalculator", 
    "Microsoft.WindowsStore"
    "Microsoft.MicrosoftStickyNotes"
    "Microsoft.WindowsMaps"
    "Microsoft.BingWeather"
    "Microsoft.MicrosoftEdge"
    "Microsoft.Xbox.TCUI"
    "Microsoft.XboxApp"
    "Microsoft.XboxGameCallableUI"
    "Microsoft.XboxGameOverlay"
    "Microsoft.XboxIdentityProvider"
    "Microsoft.XboxSpeechToTextOverlay"
    "SpotifyAB.SpotifyMusic"
)
# Loop through the list of appx packages
foreach ($App in $AppArrayList) {
    # If application name not in appx package white list, remove AppxPackage and AppxProvisioningPackage
    if (($App.Name -in $WhiteListedApps)) {
        Write-LogEntry -Value "Skipping excluded application package: $($App.Name)"
    }
    else {
        # Gather package names
        $AppPackageFullName = Get-AppxPackage -Name $App.Name | Select-Object -ExpandProperty PackageFullName
        $AppProvisioningPackageName = Get-AppxProvisionedPackage -Online | Where-Object { $_.DisplayName -like $App.Name } | Select-Object -ExpandProperty PackageName
        # Attempt to remove AppxPackage
        if ($AppPackageFullName -ne $null) {
            try {
                Write-LogEntry -Value "Removing application package: $($App.Name)"
                Remove-AppxPackage -Package $AppPackageFullName -ErrorAction Stop | Out-Null
            }
            catch [System.Exception] {
                Write-LogEntry -Value "Removing AppxPackage failed: $($_.Exception.Message)"
            }
        }
        else {
            Write-LogEntry -Value "Unable to locate AppxPackage for app: $($App.Name)"
        }
        # Attempt to remove AppxProvisioningPackage
        if ($AppProvisioningPackageName -ne $null) {
            try {
                Write-LogEntry -Value "Removing application provisioning package: $($AppProvisioningPackageName)"
                Remove-AppxProvisionedPackage -PackageName $AppProvisioningPackageName -Online -ErrorAction Stop | Out-Null
            }
            catch [System.Exception] {
                Write-LogEntry -Value "Removing AppxProvisioningPackage failed: $($_.Exception.Message)"
            }
        }
        else {
            Write-LogEntry -Value "Unable to locate AppxProvisioningPackage for app: $($App.Name)"
        }
    }
}