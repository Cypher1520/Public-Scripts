<# VS Code Shortcuts
Collapse All: Ctrl+K CTRL+0
Expand All: Ctrl+K CTRL+J
#>

$duser = Read-Host 'Enter Username'
$date = ((Get-Date).ToString("dd MM yyyy"))

#Moving user to OU
    Get-ADUser $duser | Move-ADObject -targetpath (Get-ADOrganizationalUnit -filter "name -eq 'Disabled users'")

#Disable User
    Disable-ADAccount -Identity $duser

#Log & remove users groups
    (GET-ADUSER –Identity $duser –Properties MemberOf | Select-Object MemberOf).MemberOf | Out-File \\fskprdfile01\IT_Files\_End_User_Services\DisabledUsersGroups\$duser.csv -Append
    $User = Get-ADUser $duser -Properties MemberOf
    $Groups = $User.memberOf | ForEach-Object {Get-ADGroup $_}
    $Groups |ForEach-Object {Remove-ADGroupMember -Identity $_ -Members $User -Confirm:$false}

#Renaming account
    Rename-ADObject -identity (get-aduser $duser).distinguishedname -newname zz$uname2

#Set User info
    Set-AdUser -Identity $duser -Description "Disabled $date" -DisplayName zz$uname2 -Manager $null -MobilePhone '-' -OfficePhone '-' -HomePhone '-' -Fax '-'

#Reset password
    Set-ADAccountPassword -Identity $duser -Reset

#Removing PC
    $pcremove = Read-Host "Would you like to remove the computer for $duser from AD? [y/n]"
    If($pcremove -eq 'y')
        {
            $cpname = Read-Host 'Computer Name:'
            Remove-ADComputer -Identity test -Confirm:$false
        }

#Hide From Addressbook
    Set-ADUser $duser -Replace @{msExchHideFromAddressLists=$true}

#List Mailbox info
    Get-Mailbox -identity $duser"@parexresources.com" | Get-MailboxStatistics | Select TotalItemSize

#Assign Mailbox permissions
    $accessuser = Read-Host 'Enter Manager/delegate for permissions to mailbox'
    foreach ($a in $accessuser)
    {
        Add-MailboxPermission $duser -User ((out-string -InputObject $a).Trim()) -AccessRights FullAccess
    }

#Convert to shared
    Get-Mailbox -identity agonzales@naturespath.com | set-mailbox -type “Shared”
    Set-Mailbox agonzales@naturespath.com -ProhibitSendReceiveQuota 50GB -ProhibitSendQuota 49.75GB -IssueWarningQuota 49.5GB

#Removing Licenses
    $license = (Get-MSOLUser -UserPrincipalName $duser@parexresources.com).Licenses[0].AccountSkuId
    Set-MsolUserLicense -UserPrincipalName $duser@parexresources.com -RemoveLicenses $license

#Removing mobile devices
    Get-MobileDevice -Mailbox $duser@parexresources.com | ForEach {Remove-MobileDevice -Identity $_.Identity} -Confirm:$false

#Auto Reply
    $manager = Read-Host 'Enter Manager email for auto reply'
    Set-MailboxAutoReplyConfiguration $duser@parexresources.com -AutoReplyState Enabled -InternalMessage "Please be informed that this person is no longer with Access Pipeline.  If this is an important, Access Pipeline business related matter please email their manager at '$manager'" -ExternalMessage "Please be informed that this person is no longer with Access Pipeline.  If this is an important, Access Pipeline business related matter please email their manager at '$manager'"

#Removing O365 Dist Groups
    $mailbox = Get-Mailbox $duser
    $dgs = Get-DistributionGroup

    foreach($dg in $dgs)
    {
        $DGMs = Get-DistributionGroupMember -identity $dg.Identity
            foreach ($dgm in $DGMs)
            {
                if ($dgm.name -eq $mailbox.name)
                {
                    "Removing $user from Group $dg.identity"
                    Remove-DistributionGroupMember $dg.Name -Member $duser@parexresources.com -Confirm:$flase
                }
            }
    }

#Removing from all Mailboxes
    $shared = Get-Mailbox | Get-MailboxPermission -User $duser
    $shared
    foreach($sm in $shared)
    {
        Remove-MailboxPermission -Identity $sm.Identity -User $duser -AccessRights $sm.AccessRights -Confirm:$false
    }

Write-Host ("`n")
Write-Host "******************************************" -ForegroundColor Red
Write-Host "Tasks remaining" -ForegroundColor Cyan
Write-Host "******************************************" -ForegroundColor Red
Write-Host "Velocity EHS" -ForegroundColor White
Write-Host "Transfer P:\ Drive to users Manager" -ForegroundColor White
Write-Host "Phone/Avaya steps" -ForegroundColor White
Write-Host "Equipment Pickups and Spreadsheet updates" -ForegroundColor White
Write-Host "Remove users computers from Intune" -ForegroundColor White
Write-Host "Remove users computer from AD" -ForegroundColor White
Write-Host "******************************************" -ForegroundColor Red