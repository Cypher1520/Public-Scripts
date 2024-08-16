# Remove Microsoft bloatware/crapware
# Original file https://gist.github.com/mark05e/a79221b4245962a477a49eb281d97388#file-remove-hpbloatware-ps1 
# and modified by Jeroen Burgerhout (@BurgerhoutJ)

# Custom logging function
function Write-Log {
    param (
        [Parameter(Mandatory = $true)]
        [string] $Message
    )

    $logFilePath = "$($env:ProgramData)\AutopilotConfig\RemoveBloatware.log"
    Add-Content -Path $logFilePath -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss'): $Message"
}

# List of built-in apps to remove
$UninstallPackages = @(
    #Default
    "Clipchamp.Clipchamp"
    "Microsoft.BingNews"
    "Microsoft.BingWeather"
    "Microsoft.Getstarted"
    "Microsoft.GetHelp"
    "Microsoft.Microsoft3DViewer"
    "Microsoft.MicrosoftOfficeHub"
    "Microsoft.MicrosoftSolitaireCollection"
    "Microsoft.People"
    "Microsoft.PowerAutomateDesktop"
    "Microsoft.MixedReality.Portal"
    "Microsoft.Office.OneNote"
    "Microsoft.OneConnect"
    "Microsoft.SkypeApp"    
    "Microsoft.windowscommunicationsapps"
    "Microsoft.WindowsFeedbackHub"
    "Microsoft.WindowsMaps"
    "Microsoft.YourPhone"
    "Microsoft.ZuneMusic"
    "Microsoft.ZuneVideo"
    "MicrosoftTeams"
    "Microsoft.BingTranslator"
    "Microsoft.BingSports"
    "Microsoft.BingFinance"
    "Microsoft.MinecraftUWP"
    "Microsoft.BingFoodAndDrink"
    "Microsoft.BingHealthAndFitness"
    "Microsoft.BingTravel"
    "Microsoft.WindowsReadingList"
    "Microsoft.Messaging"
    "Microsoft.Office.Sway"
    "Microsoft.WindowsPhone"
    "Microsoft.Wallet"
    "Microsoft.Print3D"
    "Microsoft.MicrosoftPowerBIForWindows"
    "Microsoft.FreshPaint"
    "Microsoft.3DBuilder"
    
<#
    #Extra
    "Microsoft.Xbox.TCUI"
    "Microsoft.XboxApp"
    "Microsoft.XboxGameCallableUI"
    "Microsoft.XboxGameOverlay"
    "Microsoft.XboxGamingOverlay"
    "Microsoft.XboxIdentityProvider"
    "Microsoft.XboxSpeechToTextOverlay"
    "Microsoft.WindowsSoundRecorder"
    "Microsoft.MicrosoftStickyNotes"
#>
)

# List of programs to uninstall
$UninstallPrograms = @(
)

$InstalledPackages = Get-AppxPackage -AllUsers | Where { ($UninstallPackages -contains $_.Name) }
$ProvisionedPackages = Get-AppxProvisionedPackage -Online | Where { ($UninstallPackages -contains $_.DisplayName) }
$InstalledPrograms = Get-Package | Where { $UninstallPrograms -contains $_.Name }

# Print a warning for not found apps
$UninstallPackages | ForEach {
    if (($_ -notin $InstalledPackages.Name) -and ($_ -notin $ProvisionedPackages.DisplayName)) {
        Write-Log -Message "Warning: App not found: [$_]"
    }
}

# Remove provisioned packages first
ForEach ($ProvPackage in $ProvisionedPackages) {

    Write-Log -Message "Attempting to remove provisioned package: [$($ProvPackage.DisplayName)]..."

    Try {
        Remove-AppxProvisionedPackage -PackageName $ProvPackage.PackageName -Online -ErrorAction Stop > $null
        Write-Log -Message "Successfully removed provisioned package: [$($ProvPackage.DisplayName)]"
    }
    Catch {
        Write-Log -Message "Warning: Failed to remove provisioned package: [$($ProvPackage.DisplayName)]"
    }
}

# Remove appx packages
ForEach ($AppxPackage in $InstalledPackages) {

    Write-Log -Message "Attempting to remove Appx package: [$($AppxPackage.Name)]..."

    Try {
        Remove-AppxPackage -Package $AppxPackage.PackageFullName -AllUsers -ErrorAction Stop > $null
        Write-Log -Message "Successfully removed Appx package: [$($AppxPackage.Name)]"
    }
    Catch {
        Write-Log -Message "Warning: Failed to remove Appx package: [$($AppxPackage.Name)]"
    }
}

# Remove installed programs
$InstalledPrograms | ForEach {

    Write-Log -Message "Attempting to uninstall: [$($_.Name)]..."

    Try {
        $_ | Uninstall-Package -AllVersions -Force -ErrorAction Stop > $null
        Write-Log -Message "Successfully uninstalled: [$($_.Name)]"
    }
    Catch {
        Write-Log -Message "Warning: Failed to uninstall: [$($_.Name)]"
    }
}

# Create a tag file just so Intune knows this was installed
if (-not (Test-Path "$($env:ProgramData)\AutopilotConfig")) {
    New-Item -ItemType Directory -Force -Path "$($env:ProgramData)\AutopilotConfig" > $null
}
Set-Content -Path "$($env:ProgramData)\AutopilotConfig\RemoveBloatware.ps1.tag" -Value "Installed"