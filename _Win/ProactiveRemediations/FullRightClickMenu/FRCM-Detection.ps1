<#
 Script Name:     FRCM-Detection.ps1
 Description:     Detects if the right click menu is the full menu or refined version in Windows 11
 Notes:           N/A
#>

# Define Variables

#Script Body
try
{
    if (Test-Path -Path "HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32") {
        Write-Host "Success"
        exit 0
    }
    else{
        Write-Host "Fail"        
        exit 1
    }   
}
catch{
    $errMsg = $_.Exception.Message
    Write-Error $errMsg
    exit 1
}