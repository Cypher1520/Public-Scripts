<#
 Script Name:     Detect-dotNet3.ps1
 Description:     Whats the script doing for detection
 Notes:           Detects if dotNet3.5 is enabled
#>

# Define Variables

#Script Body
try {
    if ( ( Get-WindowsOptionalFeature -Online -FeatureName NetFx3).State -eq "Enabled" ) {
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