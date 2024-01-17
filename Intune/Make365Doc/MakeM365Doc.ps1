# -----------------------------------------------
# M365 Documenter Script Wrapper
# -----------------------------------------------
# Launches the M365 Documentation PowerShell script
# developed by: Thomas Kurth
# https://github.com/ThomasKur
# https://github.com/ThomasKur/M365Documentation
# -----------------------------------------------
# this script written by Garth Williams
# garth.williams@insight.com
# -----------------------------------------------
# Update History
# -----------------------------------------------
# Date		What
# -----------------------------------------------
# 22Nov2022	Original version
# 07Dec2022	Added prompts
# 09Dec2022	Added -force overrides for
#		NuGet provider and modules
# -----------------------------------------------
$ProgVer = "v2.0-GKW"

# -----------------------------------------------
# TIP: You might want to modify the included Word
# template (i.e. consultant name change/header)
# -----------------------------------------------


# -----------------------------------------------
# Should not need to change anything below here
# -----------------------------------------------


# -----------------------------------------------
# set executionpolicy and clear screen
# -----------------------------------------------
set-executionpolicy unrestricted
cls

# -----------------------------------------------
# ... And lets start!
# -----------------------------------------------
write-host "------------------------------------" -foregroundcolor White
write-host "M365 documentation script $ProgVer " -Foregroundcolor Green
write-host "------------------------------------" -foregroundcolor White
$OrgName = Read-Host "Please enter Customer Name"

write-host "------------------------------------" -foregroundcolor White
Write-Host "     Select Service Area below" -Foregroundcolor Yellow
write-host "------------------------------------" -foregroundcolor White
write-host "        1 = Intune" -Foregroundcolor Yellow
write-host "        2 = AzureAD" -Foregroundcolor Yellow
write-host "        3 = CloudPrint" -Foregroundcolor Yellow
write-host "        4 = Windows365" -Foregroundcolor Yellow
write-host "        5 = InformationProtection" -Foregroundcolor Yellow
write-host "------------------------------------" -foregroundcolor white
$ServiceAreaInput = Read-Host "Select M365 Service Area (1/2/3/4/5)"

if ( 1 -eq $ServiceAreaInput )
{
$M365ServiceArea = "Intune"
}
elseif ( 2 -eq $ServiceAreaInput )
{
$M365ServiceArea = "AzureAD"
}
elseif ( 3 -eq $ServiceAreaInput )
{
$M365ServiceArea = "CloudPrint"
}
elseif ( 4 -eq $ServiceAreaInput )
{
$M365ServiceArea = "Windows365"
}
elseif ( 5 -eq $ServiceAreaInput )
{
$M365ServiceArea = "InformationProtection"
}
else
{
write-host "------------------------------------"
write-host "Sorry.  Invalid Service Area!"
write-host "------------------------------------"
write-host "If at first you don't succeeed ...."
write-host "------------------------------------"
start-sleep -s 3
exit
}


# -----------------------------------------------
# Now set the output report name prefix
# -----------------------------------------------
$ReportPrefix = "$OrgName-M365-$M365ServiceArea-As-Built"


# -------------------------------------------------------------------
# Get current path and file name and set up log file path\filename
# -------------------------------------------------------------------
$path = Get-Location
$scriptName = $MyInvocation.MyCommand.Name
$scriptLog = "$path\$ReportPrefix.log"


write-host "------------------------------------" -foregroundcolor white
write-host "MakeM365Doc script ready." -foreground Green
write-host "-Organization = " -foregroundcolor Yellow -NoNewline; write-host "$OrgName" -foreground Red
write-host "-Service Area = " -foregroundcolor Yellow -NoNewline; write-host "$M365ServiceArea" -foreground Red
write-host "------------------------------------" -foregroundcolor white
Read-host "Enter to continue, Ctrl-C to quit"

# -------------------------------------------------------------------
# Create Log file (uses $scriptLog)
# -------------------------------------------------------------------
Start-Transcript $scriptLog -Append


# -----------------------------------------------
# Install Package Provider
# -----------------------------------------------
write-host ""
write-host "-Installing Package provider ... " -foreground yellow
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force


# -----------------------------------------------
# Install modules (onto computer)
# -----------------------------------------------
write-host ""
write-host "-Installing modules ... " -foreground yellow
Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted
Install-Module MSAL.PS -allowclobber -Scope AllUsers -Force
Install-Module PSWriteWord -allowclobber -Scope AllUsers -Force
Install-Module M365Documentation -allowclobber -Scope AllUsers -Force


# -----------------------------------------------
# Import modules (into memory for script)
# -----------------------------------------------
write-host ""
write-host "-Importing modules ... " -foreground yellow
Import-Module MSAL.PS
Import-Module PSWriteWord
Import-Module M365Documentation


# -------------------------------------------------------------------
# Copy Insight Word template file to script location
# Note: Destination might need to be changed if PS modules are updated
# -------------------------------------------------------------------
Copy-Item "$path\Template.docx" "C:\Program Files\WindowsPowerShell\Modules\M365Documentation\3.1.2\Data\Template.docx" -Force


# -----------------------------------------------
# Disconnect from current tenant
# -----------------------------------------------
# write-host ""
# write-host "-Disconnecting from Azure ... " -foreground yellow
# maybe add an if connected?
# Disconnect-AzureAD


# -----------------------------------------------
# Connect to tenant
# -----------------------------------------------
# write-host ""
# write-host "-Connecting to Azure ... " -foreground yellow
# Connect-AzureAD

# -----------------------------------------------
# Connect with M365Doc ...
# -----------------------------------------------
write-host ""
write-host "-Connecting M365Doc to Azure ... " -foreground yellow
Connect-M365Doc


# -----------------------------------------------
# Collect M365 Service Area Data
# -----------------------------------------------
write-host ""
Write-Host "-Collecting " -Foregroundcolor Yellow -NoNewline; Write-Host "$M365ServiceArea " -Foregroundcolor Red -NoNewline; Write-Host "data ..." -Foregroundcolor yellow

if ($M365ServiceArea -eq "Intune") {
    $doc = Get-M365Doc -Components $M365ServiceArea -ExcludeSections "MobileAppDetailed"
}

if ($M365ServiceArea -eq "AzureAD") {
    $doc = Get-M365Doc -Components $M365ServiceArea
}

if ($M365ServiceArea -eq "CloudPrint") {
    $doc = Get-M365Doc -Components $M365ServiceArea
}

if ($M365ServiceArea -eq "Windows365") {
    $doc = Get-M365Doc -Components $M365ServiceArea
}

if ($M365ServiceArea -eq "InformationProtection") {
    $doc = Get-M365Doc -Components $M365ServiceArea
}


# -----------------------------------------------
# Output collected data to a Word file
# -----------------------------------------------
write-host ""
write-host "-Writing to Word file ..." -foreground yellow
write-host " -File: $ReportPrefix-$($doc.CreationDate.ToString("yyyyMMddHHmm")).docx ..." -foreground cyan
$doc | Write-M365DocWord -FullDocumentationPath ".\$ReportPrefix-$($doc.CreationDate.ToString("yyyyMMddHHmm")).docx"


# -----------------------------------------------
# Not fully tested yet, files DO get created
# -----------------------------------------------
# Output the data to CSV files, one per section
# Enable or comment out as needed
# -----------------------------------------------
# write-host "-Writing to CSV files ..." -foreground yellow
# $Dest = "$Path\CSV"
# if (-not (Test-Path $Dest))
# {
#    write-host " -Making CSV sub-directory ..." -foreground cyan
#    mkdir $Dest
# }
# $doc | Write-M365DocCSV -FullDocumentationPath "$Dest"


# -----------------------------------------------
# Not tested yet
# -----------------------------------------------
# Output the data to JSON files, one per section
# Enable or comment out as needed
# -----------------------------------------------
# write-host "-Writing to JSON files ..." -foreground yellow
# $Dest = "$Path\JSON"
# if (-not (Test-Path $Dest))
# {
#     write-host " -Making JSON sub-directory ..." -foreground cyan
#     mkdir $Dest
# }
# $doc | Write-M365DocJson -FullDocumentationPath "$Dest"


# ------------------------------------
# Exit the script
# ------------------------------------
write-host ""
write-host "------------------------------------"
write-host "Script completed." -foreground green
write-host "------------------------------------"

Stop-Transcript
Exit 0