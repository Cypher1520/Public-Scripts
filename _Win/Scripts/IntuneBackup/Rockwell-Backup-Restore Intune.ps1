# ---------------------------------------
# cobbled together by Garth Williams (garth.williams@insight.com)
# I take ZERO credit.  I just put something together that works for me
# without the authors (see links), this would not happen
# ---------------------------------------
# This script will back up an Intune configuration to a folder on c:
# Then you can USE that folder to restore config to another tenant
# this can reduce configuration time substantially
# Main Rerefence https://srdn.io/2019/03/backup-and-restore-your-microsoft-intune-configuration-with-powershell/#:~:text=Backing%20up%20Intune%20configuration%20Now%20that%20you%20have,to%20backup%20that%20Intune%20configuration%21%20Start-IntuneBackup%20-Path%20C%3AtempIntuneBackup
# Sec. Reference: https://github.com/jseerden/IntuneBackupAndRestore/blob/master/IntuneBackupAndRestore/Public/Start-IntuneBackup.ps1
# Third Reference: https://thesysadminchannel.com/how-to-connect-to-microsoft-graph-api-using-powershell/#:~:text=Connect%20to%20Microsoft%20Graph%20API%20Using%20Interactive%20Logon,pops%20up%204%20You%20should%20see%20authentication%20complete
# ---------------------------------------

<# Variables #>
$tenantpref = "https://login.microsoftonline.com/"
$tenantsuff = Read-Host "Enter tenant ID ex. 'M365x45049586.onmicrosoft.com'"
$tenant = $tenantpref + $tenantsuff
$Path = "C:\temp\IntuneBackup"


<# Modules and connect to tenant #>
    if (Get-Module -ListAvailable -Name MSGraphFunctions) {
        Write-Host "MSGraphFunctions Installed" -ForegroundColor Green
    }
    else {
        Write-Host "Installing Module" -ForegroundColor Yellow
        Install-Module -Name MSGraphFunctions
    }

    if (Get-Module -ListAvailable -Name IntuneBackupAndRestore) {
        Write-Host "IntuneBackupAndRestore Installed"
    }
    else {
        Write-Host "Installing Backup Module" -ForegroundColor Yellow
        Install-Module -Name IntuneBackupAndRestore
    }

    Import-Module -Name MSGraphFunctions
    Import-Module -Name IntuneBackupAndRestore

    Update-MSGraphEnvironment -AuthUrl $tenant
    Connect-MSGraph

<# Basic #>
$response = Read-Host "
    Select which process to run
    1. Full Backup
    2. Full Restore
    Selection"

if ($response -eq 1){
    Start-IntuneBackup -Path $Path
}
if ($response -eq 2){
    Start-IntuneRestoreConfig -Path $Path
}

<# Backup #>

    # Entire Intune (will contain subfolders)
    # Start-IntuneBackup -Path $Path

    # ---------------------------------------
    # Just Configs and Compliance
    # ---------------------------------------
    # Invoke-IntuneBackupDeviceConfiguration -Path $Path
    # Invoke-IntuneBackupDeviceCompliancePolicy -Path $Path

    # -----------------------------------------
    # all Backup invocations (for cut and paste)
    <# -----------------------------------------
        Invoke-IntuneBackupClientApp -Path $Path
        Invoke-IntuneBackupClientAppAssignment -Path $Path
        Invoke-IntuneBackupConfigurationPolicy -Path $Path
        Invoke-IntuneBackupConfigurationPolicyAssignment -Path $Path
        Invoke-IntuneBackupDeviceCompliancePolicy -Path $Path
        Invoke-IntuneBackupDeviceCompliancePolicyAssignment -Path $Path
        Invoke-IntuneBackupDeviceConfiguration -Path $Path
        Invoke-IntuneBackupDeviceConfigurationAssignment -Path $Path
        Invoke-IntuneBackupDeviceManagementScript -Path $Path
        Invoke-IntuneBackupDeviceManagementScriptAssignment -Path $Path
        Invoke-IntuneBackupGroupPolicyConfiguration -Path $Path
        Invoke-IntuneBackupGroupPolicyConfigurationAssignment -Path $Path
        Invoke-IntuneBackupDeviceManagementIntent -Path $Path
        Invoke-IntuneBackupAppProtectionPolicy -Path $Path
        Invoke-IntuneBackupDeviceHealthScript -Path $Path
        Invoke-IntuneBackupDeviceHealthScriptAssignment -Path $Path
    #>


<# Restore #>
    # Don't have both enabled at the same time

    # Entire Intune
    # Start-IntuneRestoreConfig -Path $Path
    
    # -----------------------------------------
    # Just Configs and Compliance
    # Invoke-IntuneRestoreDeviceConfiguration -Path C:\temp\IntuneBackupsConfigPolicies
    # Invoke-IntuneRestoreDeviceCompliancePolicy -Path C:\temp\IntuneBackupsCompliancePolicies

    # -----------------------------------------
    <# all Restore invocations (for cut and paste)
        Invoke-IntuneRestoreConfigurationPolicy -Path $Path
        Invoke-IntuneRestoreDeviceCompliancePolicy -Path $Path
        Invoke-IntuneRestoreDeviceConfiguration -Path $Path
        Invoke-IntuneRestoreDeviceManagementScript -Path $Path
        Invoke-IntuneRestoreGroupPolicyConfiguration -Path $Path
        Invoke-IntuneRestoreDeviceManagementIntent -Path $Path
        Invoke-IntuneRestoreAppProtectionPolicy -Path $Path
    #>



    # ---------------------------------------
    # If you wish to restore the assignments for Intune configurations
    # NOTE: assignments can't be restored to another tenant
    # ---------------------------------------
    # Entire Intune
    # ---------------------------------------
    # Start-IntuneRestoreAssignments -Path $Path


    # -----------------------------------------
    # all Assignment restore invocations (for cut and paste)
    <# -----------------------------------------
        Invoke-IntuneRestoreConfigurationPolicyAssignment -Path $path -RestoreById $restoreById
        Invoke-IntuneRestoreClientAppAssignment -Path $path -RestoreById $restoreById
        Invoke-IntuneRestoreDeviceCompliancePolicyAssignment -Path $path -RestoreById $restoreById
        Invoke-IntuneRestoreDeviceConfigurationAssignment -Path $path -RestoreById $restoreById
        Invoke-IntuneRestoreDeviceManagementScriptAssignment -Path $path -RestoreById $restoreById
        Invoke-IntuneRestoreGroupPolicyConfigurationAssignment -Path $path -RestoreById $restoreById
    #>

# -------------
# end of script
# -------------
