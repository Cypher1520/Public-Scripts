#==========================================================================================
#
# Script Name:      TeamsPersonal_Remediation.ps1
# Description:      Removed Teams Personal App
#
# Change Log:       Paul Warren      09 Sept 2022        Script Created
#                   Paul Warren      19 Sept 2022        Added stop-process for msteams.exe
#==========================================================================================
try {
    #Kill msteams process
    If (Get-Process msteams -ErrorAction SilentlyContinue) {
        Try {
            Stop-Process msteams -Force
        }
        catch {
            Write-Output "Might be issues - Continue anyway..."
        }
       
    }
    Get-AppxPackage -Name MicrosoftTeams -AllUsers | Remove-AppPackage -AllUsers
    exit 0
}   
catch {
    $errMsg = $_.Exception.Message
    Write-Error $errMsg
    exit 1
}