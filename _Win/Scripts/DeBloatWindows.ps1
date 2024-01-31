# ---------------------------------------------------------------------
# Debloat Win11
# Link: https://andrewstaylor.com/2022/08/09/removing-bloatware-from-windows-10-11-via-script/
# Run as PS script assigned to 64bit devices
# ---------------------------------------------------------------------

# Set up script dowload and and logging folder
$DebloatFolder = "C:\ProgramData\AutopilotConfig\Debloat"
If (Test-Path $DebloatFolder) {
    Write-Output "$DebloatFolder exists. Skipping."
}
Else {
    Write-Output "The folder '$DebloatFolder' doesn't exist. This folder will be used for storing logs created after the script runs. Creating now."
    Start-Sleep 1
    New-Item -Path "$DebloatFolder" -ItemType Directory
    Write-Output "The folder $DebloatFolder was successfully created."
}

# Start PS logging
Start-Transcript -Path "$DebloatFolder\removebloat.log"

# Where to put the script
$templateFilePath = "C:\ProgramData\AutopilotConfig\Debloat\removebloat.ps1"

# Get/save the script
Invoke-WebRequest `
    -Uri "https://raw.githubusercontent.com/andrew-s-taylor/public/main/De-Bloat/RemoveBloat.ps1" `
    -OutFile $templateFilePath `
    -UseBasicParsing `
    -Headers @{"Cache-Control" = "no-cache" }

# Run the script
invoke-expression -Command $templateFilePath