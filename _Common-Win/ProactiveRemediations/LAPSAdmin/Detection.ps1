<#
==================================================

Script Name:     Detection-Account.ps1
Description:     Checks for LAPSAdmin account for Windows LAPS Management
Notes:           Customize the script by editing Variable for admin account name.

==================================================
#>

# Define Variables
$localAdminName = "SunAdmin11"

#=============Script Body=============
try
{
    if (-Not($localAdmin = Get-LocalUser -name $localAdminName)) {
        Write-Host "Fail"
        exit 1
    }
    else{
        Write-Host "Pass"        
        exit 0
    }   
}
catch{
    $errMsg = $_.Exception.Message
    Write-Error $errMsg
    exit 1
}