<#
	.SYNOPSIS
	Backups up and restores Intune to github repo
	.DESCRIPTION
    Checks if script installed and if not installs it
	Will ask if you want to backup or restore, and then set variables to run the commands
	.INPUTS
	Action, Content type, target repo, github account, personal token # (https://github.com/settings/tokens)
	.OUTPUTS
	Backup: Backs up the target intune tenant to target account/repo
    
	.NOTES
	Version:        1.0.0
	Author:         Chris Rockwell
	Email: 			chris.rockwell@insight.com
	Creation Date:  2024/01/31
	Updated: 		2024/01/31
	Script Author: 	https://andrewstaylor.com/2022/12/07/intune-backing-up-and-restoring-your-environment-new-and-improved/#usage
	.EXAMPLE
#>

#Test if script installed, install if not present.
If (Test-Path ("$env:ProgramFiles\WindowsPowerShell\Scripts\intune-backup-restore-withgui.ps1"))
{}
else {
	Install-Script -Name intune-backup-restore-withgui -Force -Confirm:$false
}

#connect to tenant
Connect-AzureAD

#Variables
do {
	$action = Read-Host "What would you like to do? (Backup/Restore)"
} while ($action -eq "")
do {
	$selected = Read-Host "What content? (All/Selected)"
} while ($selected -eq "")
do {
	$ownername = Read-Host "Owner name (Github account name)"
} while ($ownername -eq "")
do {
	$reponame = Read-Host Reponame
} while ($reponame -eq "")
do {
	$token = Read-Host Token
} while ($token -eq "")

#set the inputs
Write-Host ""
Write-Host "Inputs: " -ForegroundColor Cyan
Write-Host "Backup/Restore Type: " -ForegroundColor Green -NoNewline 
Write-Host $action
Write-Host "Content to backup: " -ForegroundColor Green -NoNewline
Write-Host $selected
Write-Host "Target Repo: " -ForegroundColor Green -NoNewline
Write-Host $reponame
Write-Host "Github Owner Name: " -ForegroundColor Green -NoNewline
Write-Host $ownername
Write-Host "Token: " -ForegroundColor Green -NoNewline
Write-Host $token

#Display connection information
$connection = get-azureADtenantdetail
Write-Host ""
Write-Host "Target-Tenant: " -ForegroundColor Red -NoNewline
Write-Host $connection.DisplayName

#Confirmation
Write-Host "Is the above company and input correct? " -ForegroundColor Red -NoNewline
$confirm = Read-Host "(Y/N)"

#Execution
if ($confirm -ne "Y") {
	exit
}
elseif ($action = "Backup") {
	intune-backup-restore-withgui.ps1 -type backup -selected $selected -reponame $reponame -ownername $ownername -token $token
}
elseif ($action = "Restore") {
	intune-backup-restore-withgui.ps1 -type restore -selected $selected -reponame $reponame -ownername $ownername -token $token
}