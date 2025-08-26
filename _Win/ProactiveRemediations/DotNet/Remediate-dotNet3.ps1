<#
# Script Name:     Remediate-dotNet3.ps1
# Description:     What is the script doing
# Notes:           Enables dotNet 3.5
#>

# Define Variables

#Script Body
    try
    {
        Enable-WindowsOptionalFeature -Online -FeatureName NetFx3 -All -NoRestart
        Write-Host "Complete"
        exit 0
    }
    catch{
        $errMsg = $_.Exception.Message
        Write-Error $errMsg
        exit 1
    }