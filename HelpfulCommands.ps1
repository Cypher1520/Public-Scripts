#Get-Help info
    Get-Command *set-distribtuiongroup*
    Help set-distributiongroup
    Get-Command -Module Microsoft.HostIntegration.PowerShell

#Aliases
    % - Foreach-object
    ? - Where-Object

# - Comment out
    <# Comment between #>

#equivalent to %~dp0
    $currentloc = $psscriptroot

#Run as admin
    Test-Connection -ComputerName $RemoteComputers -Quiet
    Invoke-Command -ComputerName "<SERVER/COMPUTER>" -Credential "<domain\user>" -ScriptBlock {Add-adgroup "Enable Cyber Security - AD" -Member ccollins}

    Start-Process powershell -Verb runas

    #  $Variable+'extra after variable'

#Run PS on remote PC
    Invoke-Command -ComputerName WORKSTATION -Credential CREDENTIALS -ScriptBlock 
    {

    }

    Enter-PSSession "FQDN MACHINE NAME" -Credential 'DOMAIN\USER']

#Environmental Variables
    Get-Childitem -Path Env:* | Sort-Object Name

#Uninstall Modules
    $AzModules = Get-InstalledModule | where { $_.Name -like "Az" }

    # Generate a list of Az PowerShell modules to uninstall
    $AzModules = ($AzVersions | ForEach-Object {
            Import-Clixml -Path (Join-Path -Path $_.InstalledLocation -ChildPath PSGetModuleInfo.xml)
        }).Dependencies.Name | Sort-Object -Descending -Unique

    # Remove the Az modules from memory and then uninstall them
    $AzModules | ForEach-Object {
        Remove-Module -Name $_.Name -ErrorAction SilentlyContinue
        Write-Output "Attempting to uninstall module: $_.Name"
        Uninstall-Module -Name $_.Name -AllVersions
    }