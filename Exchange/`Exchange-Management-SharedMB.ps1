<# VS Code Shortcuts
Collapse All: Ctrl+K CTRL+0
Expand All: Ctrl+K CTRL+J
#>

#---Mailbox Permissions
	Add-MailboxPermission -Identity 'SHAREDMB' -User 'USER' -AccessRights FullAccess -InheritanceType All -AutoMapping:'$true/$false'
	Remove-MailboxPermission -Identity 'SHAREDMB' -User 'USER' -AccessRights FullAccess -InheritanceType All

#-----------Mailbox Forwarding-----------#
	#Set-mailbox -Identity pqmanagement@accesspipeline.com -DeliverToMailboxAndForward $true -forwardingSMTPAddress etye@accesspipeline.com
	Add-MailboxPermission -Identity "" -User supportit -AccessRights FullAccess -InheritanceType All -AutoMapping $false
	Remove-MailboxPermission -Identity "" -User supportit -AccessRights FullAccess -InheritanceType All

#-----------Get Shared\Delegates-----------#
	Get-Mailbox –RecipientTypeDetails ‘SharedMailbox’ | Get-MailboxPermission | 
	where {$_.user.tostring() -ne "NT AUTHORITY\SELF" -and $_.IsInherited -eq $false} | 
	Format-Table Identity, User, AccessRights –AutoSize

#-----------Set Save Sent items-----------#
	Get-Mailbox -ResultSize unlimited -Filter {(RecipientTypeDetails -eq 'SharedMailbox')} | Set-Mailbox -MessageCopyForSentAsEnabled $True

#-----------Get Auto-mapping-----------#
	Get-ADUser "User1-User" -Properties msExchDelegateListLink | Select msExchDelegateListLink