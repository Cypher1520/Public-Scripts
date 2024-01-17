<# VS Code Shortcuts
Collapse All: Ctrl+K CTRL+0
Expand All: Ctrl+K CTRL+J
#>

#-----------Rooms-----------#
    #Get-Mailbox -ResultSize Unlimited -RecipientTypeDetails RoomMailBox | Add-MailboxPermission -User crockwell@accesspipeline.com -AccessRights FullAccess -InheritanceType All

    Get-Mailbox -ResultSize Unlimited -RecipientTypeDetails RoomMailBox | Remove-MailboxPermission -User crockwell@accesspipeline.com -AccessRights FullAccess -InheritanceType All

    #Get-mailbox “ROOM NAME” | set-mailbox –resourcecapacity “#”
    Get-mailbox “boardroom1stf” | set-mailbox –resourcecapacity “12”

#-----------Equipment/Resource-----------#
    #Get-Mailbox -ResultSize Unlimited -RecipientTypeDetails EquipmentMailBox | Add-MailboxPermission -User crockwell@accesspipeline.com -AccessRights FullAccess -InheritanceType All
    Get-Mailbox -ResultSize Unlimited -RecipientTypeDetails EquipmentMailBox | Remove-MailboxPermission -User crockwell@accesspipeline.com -AccessRights FullAccess

    #Set-MailboxFolderPermission "unit001@accesspipeline.com:\Calendar" -User Default -AccessRights Reviewer
    
    #Delegates
    Set-CalendarProcessing -Identity "Room222" -ResourceDelegates "ed@contoso.com","ayla@contoso.com","tony@contoso.com"

    #Processing policies
    Set-CalendarProcessing -Identity roomcgyboardroom@gmpfirstenergy.com -DeleteSubject $False -AddOrganizerToSubject $False

#-----------Users-----------#

    Remove-MailboxPermission -Identity "USERNAME" -User "DELEGATE" -AccessRights FullAccess -InheritanceType All
    Get-MailboxPermission -Identity "USERNAME" | d

    #Check Delegates
    Get-Mailbox hr@accesspipeline.com | FT GrantSendOnBehalfTo
    #alternative
    Get-Mailbox | ? {$_.GrantSendOnBehalfTo -match "USERNAME"}

	#SendAs
    Add-RecipientPermission "MAILBOX" -AccessRights SendAs -Trustee "USERNAME"

	#List all mailboxes to which a user has Send As permissions
    Get-Mailbox | Get-RecipientPermission -Trustee crockwell

	#List all mailboxes a user has Full Access Permissions
    Get-Mailbox | Get-MailboxPermission -User crockwell

	#List all share/user/room/resource mailboxes to which a user has Full Access permissions
    Get-Mailbox -RecipientTypeDetails UserMailbox,SharedMailbox -ResultSize Unlimited | Get-MailboxPermission -User crockwell

#-----------Shared Mailboxes-----------#

	#Forwards to a user and keeps a copy in Mailbox
    Set-mailbox -Identity "MAILBOX" -DeliverToMailboxAndForward $true -forwardingSMTPAddress "FORWARDTO"
    Add-MailboxPermission -Identity "MAILBOX" -User "USER" -AccessRights FullAccess -InheritanceType All -AutoMapping:"$true/$false" -Confirm:"$true/$false"
    Remove-MailboxPermission -Identity "SHAREDMAILBOX" -User "USER" -AccessRights FullAccess -InheritanceType All
    Add-RecipientPermission "MAILBOX" -AccessRights SendAs -Trustee "USER"

    #Get list of shared and who has access
    Get-Mailbox –RecipientTypeDetails ‘SharedMailbox’ | Get-MailboxPermission | where {$_.user.tostring() -ne "NT AUTHORITY\SELF" -and $_.IsInherited -eq $false} | Format-Table Identity, User, AccessRights –AutoSize

    Get-Mailbox –RecipientTypeDetails ‘SharedMailbox’ | Where-Object {$_.Name -notlike "zz*"} | Select Name,Identity,User,AccessRights | Export-Csv "C:\Users\crockwell\OneDrive - Access Pipeline Inc\Shared\Reports\OffboardedUsers2.csv" -NoTypeInformation | Get-MailboxPermission | where {$_.user.tostring() -ne "NT AUTHORITY\SELF" -and $_.IsInherited -eq $false} | Select Name,Identity,User,AccessRights | Export-Csv "C:\Users\crockwell\OneDrive - Access Pipeline Inc\Shared\Reports\OffboardedUsers.csv" -NoTypeInformation

    #Get list of shared mailboxes for a user
    Get-Mailbox | Get-MailboxPermission -User "USERNAME"

    #Grant SendOnBehalfOf/SendAs
    Set-Mailbox "MAILBOX"  -GrantSendOnbehalfto "DELEGATE"
    Get-Mailbox "MAILBOX" | fl DisplayName,GrantSendOnBehalfTo
    Set-Mailbox "MAILBOX" -MesssageCopyForSendOnBehalfEnabled:$true -MessageCopyForSentAsEnabled:$true

    #Convert Disabled users to Shared Mailboxes
    Get-Mailbox -Filter 'Name -like "zz*"' | % {Set-Mailbox $_.Alias -Type Shared}

#-----------AutoReplies-----------#
    $reply = "<html><head></head><body><p>
    Hello,</br>
    </br>
    Thanks you for your email.  I am no longer working with Travel Alberta – my last day was 6 April 2018. If you email requires immediate attention please forward it to Eleanor Sequeira, Finance Lead for Consumer, eleanor.sequeira@travelalberta.com.</br>
    </br>
    Thank you,</br>
    Jennifer son</br>
    </p></body></html>"
    Set-MailboxAutoReplyConfiguration industryevents@travelalberta.com -AutoReplyState Enabled -InternalMessage $reply -ExternalMessage $reply

	#$reply = "<html><head></head><body><p>first line</br>second line</p></body></html>"
    #Set-MailboxAutoReplyConfiguration -Identity UserAccount -AutoReplyState enabled -ExternalMessage $reply    

#-----------Inbox Rules-----------#
    #Get/Disable/Remove inbox rules for a certain inbox

    #Lists all rules for listed mailbox
    Get-InboxRule -Mailbox 'email address' | Select Name,Description | FL

    #Turns off the rule specified
    Disable-InboxRule -Identity 'rule name' -Mailbox 'email address'

    #Deletes the rule specified
    Remove-InboxRule -Identity 'rule name' -Mailbox 'email address'

    #Creates a rule using specified parameters
    New-InboxRule "DeleteZendesk" -DeleteMessage $true -From "support@accesspipeline.com" -Mailbox "helpdesk@accesspipeline.com"

#-----------Calendar-----------#
    #  USER@COMPANY.COM:\Calendar 
    #Add-MailboxFolderPermission "TARGETMAILBOX@COMPANY.com":\Calendar -User "USERTOADDPERMISSIONS@COMPANY.COM" -AccessRights "RIGHTS TO APPLY TO USER"
    
    Set-MailboxFolderPermission $calendar@accesspipeline.com:\Calendar -User $user@accesspipeline.com -AccessRights owner
    Get-MailboxFolderPermission $calendar@accesspipeline.com:\Calendar| Ft -AutoSize
    Remove-MailboxFolderPermission $calendar@accesspipeline.com:\Calendar -User $user@accesspipeline.com -Confirm:$false

    Add-MailboxFolderPermission pool1-cgy@accesspipeline.com:\Calendar -User crockwell@accesspipeline.com -AccessRights Owner
    
#-----------Security Groups-----------#
	#List all user mailboxes to which members of a security group have access
    Get-Mailbox -RecipientTypeDetails UserMailbox -ResultSize Unlimited | Get-RecipientPermission -Trustee secgrp

	#List mailboxes a security group have access to
    Get-Mailbox | Get-MailboxPermission -User secgrp

#-----------Forwarding-----------#
    #Get all mailboxes forwarding email
    Get-Mailbox -Filter * | Where-Object DeliverToMailboxAndForward -EQ True | Select Name,ForwardingSmtpAddress | FT -AutoSize

    #Set forwarding
    Set-Mailbox -Identity "SOURCE" -DeliverToMailboxAndForward $true -ForwardingSmtpAddress "DESTINATION"
    
#-----------Unified Messaging-----------#
    Get-UMMailbox -Identity "USERNAME"
    Disable-UMMailbox -Identity $_.UserPrincipalName -Confirm:$false
    
    #Disable UMMailbox for all disabled users
    Get-Mailbox -Filter 'Name -like "zz*"' | foreach {Disable-UMMailbox -Identity $_.UserPrincipalName -Confirm:$false}

#-----------Clutter-----------#
    Set-Clutter -Identity "USEREMAIL" -Enable "$false/$true"

#-----------FocusedInbox-----------#
    Set-OrganizationConfig -FocusedInboxOn:$"True/false"
    Set-FocusedInbox -Identity "USEREMAIL" -FocusedInboxOn:$"true/false"
    Get-FocusedInbox -Identity "USEREMAIL"

#-----------Send Size Limits-----------#
    #Single Mailbox
    Set-Mailbox -Identity alias@domain.com -MaxSendSize 75MB -MaxReceiveSize 75MB -UseDatabaseQuotaDefaults:$false
    #Multiple Mailboxes
    (“alias”, “alias2”, “alias3”) | % {Set-Mailbox –Identity $_ -MaxSendSize 35MB -MaxReceiveSize 35MB} -UseDatabaseQuotaDefaults:$false
    #All Mailboxes
    Get-Mailbox | Set-Mailbox -MaxSendSize 35MB -MaxReceiveSize 35MB -UseDatabaseQuotaDefaults:$false
    #Set defaults
    Get-MailboxPlan | Set-MailboxPlan -MaxSendSize 35MB -MaxReceiveSize 35MB

#-----------Exchange ATP Phish Filtering-----------#
    Get-PhishFilterPolicy
    Set-PhishFilterPolicy

#-----------Get Permissions-----------#
    #SendAs
    Import-Csv "D:\Clouds\OneDrive - Stratiform Inc\Documents\GMP\Permissions.csv" | % {Add-RecipientPermission $_.Mailbox -AccessRights SendAs -Trustee $_.User -Confirm:$false}
    #Behalfof
    Import-Csv "D:\Clouds\OneDrive - Stratiform Inc\Documents\GMP\Permissions.csv" | % {Set-Mailbox $_.Mailbox -GrantSendOnBehalfTo $_.User}
    #FullAccess
    Import-Csv "D:\Clouds\OneDrive - Stratiform Inc\Documents\GMP\Permissions.csv" | % {Add-MailboxPermission -Identity $_.Mailbox -User $_.User -AccessRights FullAccess -InheritanceType All -AutoMapping:$true}

    #Remove SendAs
    Import-Csv "A:\Clouds\OneDrive - Stratiform Inc\Documents\GMP\Permissions.csv" | % {Remove-RecipientPermission $_.Mailbox -AccessRights SendAs -Trustee $_.User -Confirm:$false}
        #Check
        Get-RecipientPermission reception 
    #Remove BehalfOf
    Import-Csv "A:\Clouds\OneDrive - Stratiform Inc\Documents\GMP\Permissions.csv" | % {Set-Mailbox $_.Mailbox -GrantSendOnBehalfTo @{remove=$_.User}}
        #check
        Get-Mailbox deboucher | Select -ExpandProperty GrantSendOnBehalfTo | Select Name,Parent
    #Remove Full
    Import-Csv "A:\Clouds\OneDrive - Stratiform Inc\Documents\GMP\Permissions.csv" | % {Remove-MailboxPermission $_.Mailbox -User $_.User -AccessRights FullAccess -Confirm:$false}