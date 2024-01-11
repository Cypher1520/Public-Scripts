<#
 Script Name:     BLtoAAD_Detection.ps1
 Description:     Detection script for backing up Bitlocker Key to AAD/EntraID
 Notes:           
#>

# Define Variables

#Script Body
Try {
    $Result = get-winevent -FilterHashTable @{LogName = "Microsoft-Windows-BitLocker/BitLocker Management" } | Where-Object { ($_.id -eq 845) } | ft message
    $ID = $Result | measure-Object
    If ($ID.Count -gt 0) {
        Write-Output "Bitlocker backup to Azure AD succeeded"
        Exit 0
    }
    Else {
        Write-Output $result
        Exit 1
    }
}
    
catch
{
    Write-Warning "Value Missing"
    Exit 1
}