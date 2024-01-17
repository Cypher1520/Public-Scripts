$FormatEnumerationLimit =-1
$sgroup = Get-Group -RecipientTypeDetails MailUniversalSecurityGroup -resultsize unlimited
$sgroup | sort displayname | foreach {Get-Group -Identity $_.WindowsEmailAddress | fl displayname,members} > SGroupMembers.txt

$Mailboxes = Get-Mailbox -RecipientTypeDetails SharedMailbox -ResultSize:Unlimited | Select Identity,Alias,DisplayName | sort displayname
$mailboxes | sort displayname | foreach {Get-MailboxPermission -Identity $_.alias | ft identity,user,accessrights} > SharedPermissions.txt