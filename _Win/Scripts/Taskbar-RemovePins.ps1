<#
.SYNOPSIS
    Removes Microsoft Store from the Taskbar
.INPUTS
  None
.OUTPUTS
  None
.NOTES
  Version:        1.0
  Author:         Chris Rockwell
  Creation Date:  2023-06-19
  Purpose/Change: Remove Store from taskbar
.EXAMPLE
  .\Taskbar-RemoveStore.ps1 -Force
  Removes Store from taskbar
  Run as administrator
#>

function unpin_taskbar([string]$appname) {
    ((New-Object -Com Shell.Application).NameSpace('shell:::{4234d49b-0245-4df3-b780-3893943456e1}').Items() |
        Where-Object{$_.Name -eq $appname}).Verbs() | Where-Object{$_.Name.replace('&','') -match 'Unpin from taskbar'} | ForEach-Object{$_.DoIt()}
}

foreach ($taskbarapp in 'Microsoft Store') {
    Write-Host unpinning $taskbarapp
    unpin_taskbar("$taskbarapp") -Force
}