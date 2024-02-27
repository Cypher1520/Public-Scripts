<#
	.SYNOPSIS
	Retrieves the LAPS admin password for the local machine
	.DESCRIPTION
    Requires the Graph API for Authentication, installs if not present then connects to Entra ID. After the connection is established then the script will copy the local admin pw to clipboard.
	.INPUTS
	Login to AAD popup. 
	.OUTPUTS
	Local Admin PW to Clipboard
    
	.NOTES
	Version:        1.0.0
	Author:         Chris Rockwell
	Email: 			chris.rockwell@insight.com
	Creation Date:  2024/02/23
	Updated: 		2024/02/23
	
	.EXAMPLE
	
#>

#Module management
If (!(Test-Path ("$env:ProgramFiles\WindowsPowerShell\Modules\Microsoft.Graph.Authentication"))) { 
    Install-Module -Name Microsoft.Graph.Authentication -Confirm:$false -Force
    Write-Host "Installing Backup script" -ForegroundColor Yellow
}
else {
    Write-Host Authentication Module Installed -ForegroundColor Green
}

Connect-MgGraph -Scopes "DeviceLocalCredential.Read.All" -ContextScope Process -NoWelcome
Import-Module Microsoft.Graph.Authentication

#Variables
$device = HOSTNAME.EXE
#$file = C:\Temp\LAPS.txt

Set-Clipboard -Value (Get-LapsAADPassword -DeviceIds $device -IncludePasswords -AsPlainText).Password