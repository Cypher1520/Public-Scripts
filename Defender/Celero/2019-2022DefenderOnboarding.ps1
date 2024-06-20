#Create folder if not already present
if (!(Test-Path "C:\Celero\MDE")) {
    Write-Host Creating MDE folder -ForegroundColor Yellow
    New-Item -Path "C:\Celero" -Name "MDE" -ItemType Directory
}

#download onboarding package for 2012-2016 servers.
Copy-Item -Path "\\client.ad.celero.prv\NETLOGON\Applications\MdeServers\WindowsDefenderATPOnboardingPackage-2019-2022" -Destination "C:\Celero\MDE" -Recurse

#test if disable antivirus is present, remove if necessary
if ((Get-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender").DisableAntiSpyware -eq 1) {
    Write-Host Removing entry -ForegroundColor Red
    Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender" -Name "DisableAntiSpyware"
}

#execute onboarding package
Set-Location "C:\Celero\MDE\WindowsDefenderATPOnboardingPackage-2019-2022"
.\WindowsDefenderATPOnboardingScript.cmd

#confirm if the devices is in passive to prove enrollment
if ((Get-MpComputerStatus).AMRunningMode -eq "Passive Mode") {
    Write-host Defender Onboarding complete -ForegroundColor Green
}
else {
    Write-Host Defender onboarding not complete -ForegroundColor Red
}