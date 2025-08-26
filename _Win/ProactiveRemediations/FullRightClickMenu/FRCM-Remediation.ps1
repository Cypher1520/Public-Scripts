<#
# Script Name:     FRCM-Remediation.ps1
# Description:     Remediation script to extend the rightclick menu in Windows 11.
# Notes:           N/A
#>

# Define Variables

#Script Body
    try
    {
        reg add "HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" /f /ve
        exit 0
    }
    catch{
        $errMsg = $_.Exception.Message
        Write-Error $errMsg
        exit 1
    }