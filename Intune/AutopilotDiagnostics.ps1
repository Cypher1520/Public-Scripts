<#
Source: https://oofhours.com/2020/07/12/windows-autopilot-diagnostics-digging-deeper/
#>

Set-ExecutionPolicy -ExecutionPolicy Bypass
Install-Script Get-AutopilotDiagnostics -Force -Confirm:$false -AllowClobber
.\Get-AutopilotDiagnostics.ps1 -Online