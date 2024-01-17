#Get-Help info
    Get-Command *set-distribtuiongroup*
    Help set-distributiongroup
    Get-Command -Module Microsoft.HostIntegration.PowerShell

#Aliases
    % - Foreach-object
    ? - Where-Object

# - Comment out

#equivalent to %~dp0
    $currentloc = $psscriptroot

#Run as admin
    Test-Connection -ComputerName $RemoteComputers -Quiet
    Invoke-Command -ComputerName cgyprddc01 -Credential access\adm-crockwell -ScriptBlock {Add-adgroup "Enable Cyber Security - AD" -Member ccollins}

    Start-Process powershell -Verb runas

    #  $Variable+'extra after variable'

#Run PS on remote PC
    Invoke-Command -ComputerName WORKSTATION -Credential CREDENTIALS -ScriptBlock 
    {

    }

    Enter-PSSession "FQDN MACHINE NAME" -Credential 'parexresources\$crockwell']

#Environmental Variables
    Get-Childitem -Path Env:* | Sort-Object Name