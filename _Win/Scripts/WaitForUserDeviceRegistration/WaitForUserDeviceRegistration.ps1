# --------------------------------------
# WaitForUserDeviceRegistration.ps1
# --------------------------------------
# this device will pause and loop until 
# it sees an event ID 306 that indicates
# that the device registration completed
# --------------------------------------
# Version 2.0 - Garth Williams
# added logging and 5 second delay
# after task start.
# --------------------------------------
# Original version info
# Version 1.6 - Steve Prentice, 2020
#
# Used to pause device ESP during Autopilot Hybrid Join to wait for
# the device to sucesfully register into AzureAD before continuing.
#
# Use IntuneWinAppUtil to wrap and deploy as a Windows app (Win32).
# See ReadMe.md for more information.
#
# Tip: Win32 apps only work as tracked apps in device ESP from 1903.
#
# Exits with return code 3010 to indicate a soft reboot is needed,
# which in theory it isn't, but it suited my purposes.

# -----------------------------
# Make log and tag directory
# -----------------------------
If (-Not (Test-Path "$($env:ProgramData)\AutopilotConfig"))
{
    Mkdir "$($env:ProgramData)\AutopilotConfig"
}

# Start logging
Start-Transcript "$($env:ProgramData)\AutopilotConfig\WaitForUserDeviceRegistration.log"

$filter304 = @{
  LogName = 'Microsoft-Windows-User Device Registration/Admin'
  Id = '304' # Automatic registration failed at join phase
}

$filter306 = @{
  LogName = 'Microsoft-Windows-User Device Registration/Admin'
  Id = '306' # Automatic registration Succeeded
}

$filter334 = @{
  LogName = 'Microsoft-Windows-User Device Registration/Admin'
  Id = '334' # Automatic device join pre-check tasks completed. The device can NOT be joined because a domain controller could not be located.
}

$filter335 = @{
  LogName = 'Microsoft-Windows-User Device Registration/Admin'
  Id = '335' # Automatic device join pre-check tasks completed. The device is already joined.
}

$filter20225 = @{
  LogName = 'Application'
  Id = '20225' # A dialled connection to RRAS has sucesfully connected.
}

# Wait for up to 60 minutes, re-checking once a minute...
While (($counter++ -lt 60) -and (!$exitWhile)) {
    # Let's get some events...
    $events304   = Get-WinEvent -FilterHashtable $filter304   -MaxEvents 1 -EA SilentlyContinue
    $events306   = Get-WinEvent -FilterHashtable $filter306   -MaxEvents 1 -EA SilentlyContinue
    $events334   = Get-WinEvent -FilterHashtable $filter334   -MaxEvents 1 -EA SilentlyContinue
    $events335   = Get-WinEvent -FilterHashtable $filter335   -MaxEvents 1 -EA SilentlyContinue
    $events20225 = Get-WinEvent -FilterHashtable $filter20225 -MaxEvents 1 -EA SilentlyContinue

    If ($events335) { $exitWhile = "True" }

    ElseIf ($events306) { $exitWhile = "True" }

    ElseIf ($events20225 -And $events334 -And !$events304) {
        Write-Host "RRAS dialled sucesfully. Trying Automatic-Device-Join task to create userCertificate..."
        Start-ScheduledTask "\Microsoft\Windows\Workplace Join\Automatic-Device-Join"
        Write-Host "Sleeping for 60s..."
        Start-Sleep -Seconds 60
    }

    Else {
        Write-Host "No events indicating successful device registration with Azure AD."
        Write-Host "Sleeping for 60s..."
        Start-Sleep -Seconds 60
        If ($events304) {
            Write-Host "Trying Automatic-Device-Join task again..."
            Start-ScheduledTask "\Microsoft\Windows\Workplace Join\Automatic-Device-Join"
            Write-Host "Sleeping for 5s..."
            Start-Sleep -Seconds 5
        }
    }
}

If ($events306) { 
    Write-Host $events306.Message
    Write-Host "Exiting with return code 3010 to indicate a soft reboot is needed."
    # Create a tag file so Intune knows this was installed
    Set-Content -Path "$($env:ProgramData)\AutopilotConfig\WaitForUserDeviceRegistration.tag" -Value "Installed"
    Stop-Transcript
    Exit 3010
}

If ($events335) { Write-Host $events335.Message }

Write-Host "Script complete, exiting."
Set-Content -Path "$($env:ProgramData)\AutopilotConfig\WaitForUserDeviceRegistration.tag" -Value "Installed"
Stop-Transcript