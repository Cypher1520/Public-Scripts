<#
Enable on remote server before running script 
Enable-PSRemoting -Force
#>
Invoke-Command -Computername 'azrprddc01' -ScriptBlock { Start-AdSyncSyncCycle -PolicyType Delta }