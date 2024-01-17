<# VS Code Shortcuts
Collapse All: Ctrl+K CTRL+0
Expand All: Ctrl+K CTRL+J
#>

$aduser = "nancy.cherniwchan"
$USERNAME = "$aduser@travelalberta.com"
$DELEGATE = "lisa.gorchinski@travelalberta.com"
$date = Get-Date
$dname = (get-msoluser -UserPrincipalName "$aduser@travelalberta.com").DisplayName

#---AD---
    #Disable User account and remove manager
        Disable-ADAccount -Identity $aduser
        Set-AdUser -Identity $aduser -Description "Disabled $date" -Manager $null

    #Move user to retired accounts
        Get-ADUser $aduser | Move-ADObject -targetpath "OU=Retired Accounts,OU=Travel Alberta,DC=travelalberta,DC=local"

    #renaming account and manage
        $dname = (Get-ADUser $aduser | Select Name).Name
        
        Rename-ADObject -identity (get-aduser "$aduser").distinguishedname -newname "zz$dname"
        Set-ADUser $aduser -DisplayName zz$dname
        
    #Record and remove AD groups
        (GET-ADUSER –Identity $aduser –Properties MemberOf | Select-Object MemberOf).MemberOf | Out-File \\ta-fs02\it$\UserGroups\$aduser.csv -Append
        $User = Get-ADUser $aduser -Properties MemberOf
        $Groups = $User.memberOf | ForEach-Object {Get-ADGroup $_}
        $Groups |ForEach-Object {Remove-ADGroupMember -Identity $_ -Members $User -Confirm:$false}

    #Set User Password
        Set-ADAccountPassword -Identity $aduser -reset

#---O365---
#Get users Shared mailbox membership
    $Mailboxes = get-mailbox | Get-MailboxPermission -user "$USERNAME"
    $Mailboxes

#Remove user from shared mailboxes
    foreach ($DG in $mailboxes) {Remove-MailboxPermission $DG.Identity -User $USERNAME -AccessRights $DG.AccessRights -Confirm:$false}

#set Auto replies
    
    $reply = "<html><head></head><body><p>Please be advised that $dname is no longer with Travel Alberta, for any inquiries please contact $DELEGATE.</br> 
    </br>
    Thank you
    </p></body></html>"
    Set-MailboxAutoReplyConfiguration -Identity $USERNAME -AutoReplyState enabled -ExternalMessage $reply -InternalMessage $reply
    Get-MailboxAutoReplyConfiguration $username

#convert to shared mailbox
    Set-mailbox "$USERNAME" -Type Shared

#Delegate mailbox access
    Add-MailboxPermission "$USERNAME" -User "$DELEGATE" -AccessRights FullAccess -AutoMapping:$true

#Remove UMMailbox
    Disable-UMMailbox -Identity "$USERNAME" -Confirm:$false

#Remove O365 Licenses
    $license = (Get-MsolUser -UserPrincipalName $USERNAME).licenses.AccountSkuId
    foreach ($l in $license)
    {Set-MsolUserLicense -UserPrincipalName $USERNAME -RemoveLicenses $l}