<#
# Script Name:     ScriptName.ps1
# Description:     What is the script doing
# Notes:           Notes on the remediation/instructions to change in the script
#>

# Define Variables

#Script Body
    try
    {
        #Action
        Write-Host "Complete"
        exit 0
    }
    catch{
        $errMsg = $_.Exception.Message
        Write-Error $errMsg
        exit 1
    }