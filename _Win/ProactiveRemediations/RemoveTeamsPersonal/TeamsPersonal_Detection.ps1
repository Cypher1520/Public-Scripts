#==========================================================================================
#
# Script Name:     TeamsPersonal_Detection.ps1
# Description:     Looks for the Teams Personal App 
#
# Change Log:      Paul Warren      09 Sept 2022        Script Created       
#    
#==========================================================================================

# Define Variables
$TeamsApp = Get-AppxProvisionedPackage -online | where-object { $_.PackageName -like "*MicrosoftTeams*" }

try {
    if ($TeamsApp.DisplayName -eq "MicrosoftTeams") {
        Write-Output "Teams Built-in Present"
        Exit 1
    }
    ELSE {
        Write-Output "Teams Built-in Not Present"
        Exit 0
    }
}   
catch {
    $errMsg = $_.Exception.Message
    Write-Error $errMsg
    exit 1
}