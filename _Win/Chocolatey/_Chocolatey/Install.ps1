<#
    .NOTES
        https://community.chocolatey.org/packages
        Must first have Chocolatey installed
        https://www.thelazyadministrator.com/2020/02/05/intune-chocolatey-a-match-made-in-heaven/

    .DESCRIPTION
        Intune Commands
            Install: powershell.exe -executionpolicy bypass .\install.ps1
            Uninstall: powershell.exe -executionpolicy bypass .\uninstall.ps1

    .EXAMPLE
        ------------- Install -------------
            $app = "APPNAME"
            $localprograms = choco list
            if ($localprograms -like "*$app*")
            {
                C:\ProgramData\chocolatey\choco.exe upgrade $app -y
            }
            Else
            {
                C:\ProgramData\chocolatey\choco.exe install $app -y
            }
#>

#Install Chocolatey
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

#ScheudledTask
$taskname = "Update Chocolatey Apps"
$taskdescription = "Automatically updates all Chocolatey applications on Startup"
$action = New-ScheduledTaskAction -Execute powershell.exe -Argument "Start-Transcript -Path 'C:\ProgramData\chocolatey\logs\AutoUpdateChocolateyApps.log'; choco upgrade all -y; Stop-Transcript"
$trigger = New-ScheduledTaskTrigger -AtStartup
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries
Register-ScheduledTask -Action $action -Trigger $trigger -TaskName $taskname -Description $taskdescription -Settings $settings -User "System"