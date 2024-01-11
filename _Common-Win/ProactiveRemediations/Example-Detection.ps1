<#
 Script Name:     ScriptName.ps1
 Description:     Whats the script doing for detection
 Notes:           Notes/Instructions on things to change if any in the script
#>

# Define Variables

#Script Body
try {
    if (Test-Path) {
        #Exit if pass
        Write-Host "Success"
        exit 0
    }
    else {
        #Exit if fail
        Write-Host "Fail"        
        exit 1
    }   
}
catch {
    $errMsg = $_.Exception.Message
    Write-Error $errMsg
    exit 1
}