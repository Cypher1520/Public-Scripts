Start-Transcript -Append -Path "\\fskprdfile01\IT_Files\_End_User_Services\DisabledUsersGroups\Log Files\$duser.txt"
Clear-Host

Write-Host `n
Write-Host 'What is the identity [Account name "firstletterlastname"] of the User to be Offboarded?' -ForegroundColor Cyan
$duser = Read-Host 
Write-Host `n

$confirm = Read-Host("Are you sure you want to proceed? [y/n]")
Write-Host `n

# AD Activities

	If($confirm -eq 'y')
		{
		$pcremove = Read-Host "Would you like to remove the computer for $duser from AD? [y/n]"
		Write-Host `n
	
	#Removing computer from AD
		If($pcremove -eq 'y')
			{

			Write-Host "Please enter the " -NoNewLine
			Write-Host "Computer Name " -ForegroundColor Yellow -NoNewLine
			Write-Host "Used by $duser for removal from ActiveDirectory"
			Write-Host `n
				
				$cpname = Read-Host 'Computer Name'
				Write-Host `n

			Write-Host "Deleting " -NoNewLine
			Write-Host "$cpname " -ForegroundColor Yellow -NoNewLine
			Write-Host "from Active Directory"			
				Remove-ADComputer -Identity $cpname -Confirm:$false
			
					Write-Host `n
					Write-Host("Complete.") -ForegroundColor Cyan
					Write-Host `n
			}

	#Removing AD Groups
			Write-Host `n
			Write-Host "Removing all Group Memberships except " -NoNewline
			Write-Host "Domain Users " -ForegroundColor Yellow
			Write-Host "Copy of groups removed located at" -NoNewline
			Write-Host "'\\fskprdfile01\IT_Files\_End_User_Services\DisabledUsersGroups\$duser.csv'" -ForegroundColor Cyan
				(GET-ADUSER –Identity $duser –Properties MemberOf | Select-Object MemberOf).MemberOf | Out-File \\fskprdfile01\IT_Files\_End_User_Services\DisabledUsersGroups\$duser.csv -Append
				$User = Get-ADUser $duser -Properties MemberOf
				$Groups = $User.memberOf | ForEach-Object {Get-ADGroup $_}
				$Groups |ForEach-Object {Remove-ADGroupMember -Identity $_ -Members $User -Confirm:$false}
			
				Write-Host `n
				Write-Host("Complete.") -ForegroundColor Green
				Write-Host `n
		}

		Write-Host "Active Directory process " -NoNewline
		Write-Host("Complete.") -ForegroundColor Green
		Write-Host `n

# O365 Activities
	#Login/info/confirmation
		If($confirm -eq 'y')
			{
			Write-Host "Office365 Process"
			Write-Host "Login is following format" -NoNewline
			Write-Host " 'GlobalAdminAccout@accesspipeline.com' " -ForegroundColor Green
			
			$UserCredential = Get-Credential 'adm-crockwell@accesspipeline.com'
			$O365Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $UserCredential -Authentication Basic -AllowRedirection
			Import-PSSession $O365Session

			Import-Module MSOnline
			Connect-msolservice -credential $UserCredential
	
			Get-Mailbox -identity $duser | Get-MailboxStatistics | Select TotalItemSize
				Write-Host("`nWould you like to continue with the conversion to a shared mailbox? ") -NoNewLine
				Write-Host("[y/n]: ") -ForegroundColor Yellow -NoNewLine
					$continue = Read-Host 
				Write-Host `n
			}	
	If($continue -eq 'y')
	{   
	#Add Delegate permissions
		Write-Host ("Please enter the ") -NoNewLine
		Write-Host ("email ") -ForegroundColor Yellow -NoNewLine
		$manager = Read-Host ("for the users manager")

		Write-Host ("`nDoes the mailbox need to be assigned to the users Manager? ") -NoNewline
		Write-Host ("[y/n]: ") -ForegroundColor Yellow -NoNewLine
		$yn = Read-Host 
			If($yn -eq 'y')
			{
			Write-Host("`nAdding Mailbox permissions...")
				foreach ($m in $manager)
					{
						Add-MailboxPermission $duser -User ((out-string -InputObject $m).Trim()) -AccessRights FullAccess
					}
			Write-Host `n					
			Write-Host("Complete.") -ForegroundColor Cyan
			}
					
	#Convert to Shared Mailbox	
		Write-Host `n
		Write-Host("Changing Mailbox to Shared...")
		
		Get-Mailbox -identity $duser | set-mailbox -type “Shared”
		Set-Mailbox $duser -ProhibitSendReceiveQuota 50GB -ProhibitSendQuota 49.75GB -IssueWarningQuota 49.5GB
		
			Write-Host `n		
			Write-Host("Complete.") -ForegroundColor Cyan
			Write-Host `n
	
	#Hide Mailbox from Addressbook
		Write-Host `n
		Write-Host("Hidding the mailbox from Address list...")

			Set-RemoteMailbox -Identity $duser -HiddenFromAddressListsEnabled $true
	
			Write-Host `n		
			Write-Host("Complete.") -ForegroundColor Cyan
			Write-Host `n

	#Remove Licenses
		Write-Host("Removing assigned licenses...")
		$license = (Get-MSOLUser -UserPrincipalName $duser@accesspipeline.com).Licenses.AccountSkuId
		Set-MsolUserLicense -UserPrincipalName $duser@accesspipeline.com -RemoveLicenses $license 
		
			Write-Host `n
			Write-Host("Complete.") -ForegroundColor Cyan
			Write-Host `n

	#Remove Mobile Devices
		Write-Host("Removing Mobile Devices from users Exchange account...")
			Get-MobileDevice -Mailbox $duser@accesspipeline.com | ForEach {Remove-MobileDevice -Identity $_.Identity} -Confirm:$false
				
			Write-Host `n
			Write-Host("Complete.") -ForegroundColor Cyan
			Write-Host `n

	#Automatic Reply
		Write-Host ("Setting Automatic Reply for $duser@accesspipeline.com")
		$message = "Please be informed that this person is no longer with Access Pipeline.  If this is an important, Access Pipeline business related matter please email their manager at $manager"
			Set-MailboxAutoReplyConfiguration $duser@accesspipeline.com -AutoReplyState Enabled -InternalMessage $message -ExternalMessage $message
				
			Write-Host `n 
			Write-Host("Complete.") -ForegroundColor Cyan
			Write-Host `n

	#Removing DG's						
		Write-Host ("Removing user from all O365 Distribution Groups")
	
			$adname = (get-aduser $duser).name
			$mailbox = get-mailbox $duser
			$dgs = Get-DistributionGroup

			foreach($dg in $dgs)
			{
			$DGMs = Get-DistributionGroupMember -identity $dg.Identity
				foreach ($dgm in $DGMs)
					{if ($dgm.name -eq $mailbox.name)
						{"Removing $user from Group $dg"
						Remove-DistributionGroupMember $dg.Name -Member $duser@accesspipeline.com -Confirm:$flase -BypassSecurityGroupManagerCheck
						}
					}
			}
		
		Write-Host `n
		Write-Host("Complete.") -ForegroundColor Cyan
		Write-Host `n

	#Removing Shared Mailbox Permissions
		Write-Host ("Removing user permissions from all Mailboxes ***can take a minute***")
	
			$shared = Get-Mailbox | Get-MailboxPermission -User $duser
			
		foreach($sm in $shared)
			{  
			Remove-MailboxPermission -Identity $sm.Identity -User $duser -AccessRights FullAccess -InheritanceType All -Confirm:$false
			}
		Write-Host `n
		Write-Host("Complete.") -ForegroundColor Cyan
		Write-Host `n
	}

	Write-Host "Process complete, press" -NoNewline
	Write-Host " [Enter]"  -ForegroundColor Green -NoNewline
	Read-Host " To complete"
		
	Stop-Transcript

	Remove-PSSession $O365Session

Write-Host "******************************************" -ForegroundColor Red
Write-Host "Remaining Tasks" -ForegroundColor Cyan
Write-Host "******************************************" -ForegroundColor Red
Write-Host "Velocity EHS" -ForegroundColor White
Write-Host "Delete computer from AVG" -ForegroundColor White
Write-Host "Send CMDS Email" -ForegroundColor White
Write-Host "Avaya Phones" -ForegroundColor White
Write-Host "Equipment Pickup" -ForegroundColor White
Write-Host "******************************************" -ForegroundColor Red