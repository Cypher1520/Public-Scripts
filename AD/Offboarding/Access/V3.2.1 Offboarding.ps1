#***********************************************
#       AccessPipeline Offboarding Tool         
#***********************************************
# Written By Chris Rockwell for AccessPipeline  
#***********************************************
#
#*************
# Change Log:
#
# V3.2.1 - Added prompts to remove the user's PC from ActiveDirectory
#
# V3.2  - Added removal from Shared mailboxes
#       - Removed prompts for Distribution Group removal
# 
# V3.1  - fixed the auto reply to request manager name instead of using the share/forward username. 
#
# V3    - Added ex2010 hide mailbox function 
#		- Added some instructions for login prompts
#
# V2.2  - Removed forward option and simplified assigning the mailbox
#		- cleaned up the conversion to Shared section
#		- Added completion indicators to Off prem section
#
# V2.1 - Added section to remove user from O365 Distribution groups
#
# V2.0 - Conversion to shared was broken, fixed that
#
# V1.0.6 - Updated output to screen 
#        - Organized sections
#        - Added "to-do" reminder to end
#        - Remove Mobile devices from Exchange account access
#        - Exchange Auto-Reply set
#		 - Date entry  changed to be automatic
#		 - Clears phone numbers
#
# V1.0.5 - Logging Added 
#        - Step for removing user's Manager from AD
#
# V1.0.4 - Changed the save location of groups.csv to the new file server.
#
# V1.0.3 - Corrected bad formatting
#
# V1.0.2 - Added Note in details about disabled date 
#        - Added steps list
#        - Set Automatic Reply on Shared Mailbox
#
# V1.0.1 - Added append command to csv printout for AD groups.
#
# V1.0 - Steps included:
# Active Directory - Disable Users, Move to disabled users, Save groups as CSV and then remove, Reset Clients password
# Office 365 - Convert to Shared mailbox, Remove License, Delegate people(s) to Shared Mailbox, Forward if requested, Remove all exchange active sync mobile devices
#*************

# *********************************************************************************************
# On-Prem Activities
# *********************************************************************************************

Import-module ActiveDirectory

Write-Host("`n")
Write-Host 'What is the identity [Account name "auser"] of the User to be Offboarded?' -ForegroundColor Cyan
$duser = Read-Host 

Start-Transcript -Append -Path "\\fskprdfile01\IT_Files\_End_User_Services\DisabledUsersGroups\Log Files\$duser.txt"

$confirm = Read-Host("Are you sure you want to offboard $duser? [y/n]")
Write-Host("`n")
If($confirm -eq 'y')
    {
	$confirm2 = Read-Host("Are you REALLY SURE? [y/n]")
	Write-Host("`n")
	If($confirm2 -eq 'y')
		{
		Write-Host "Moving User to " -NoNewLine 
		Write-Host "Disabled Users" -ForegroundColor Yellow
			Get-ADUser $duser | Move-ADObject -targetpath (Get-ADOrganizationalUnit -filter "name -eq 'Disabled users'")
                
				Write-Host `n
				Write-Host("Complete.") -ForegroundColor Cyan
				Write-Host `n
		}
If($confirm -eq 'y')        
		{     
		Write-Host "User account is being " -NoNewLine
		Write-Host "Disabled " -ForegroundColor Yellow
			Disable-ADAccount -Identity $duser
            
				Write-Host `n
				Write-Host("Complete.") -ForegroundColor Cyan
				Write-Host `n
		}
If($confirm -eq 'y')		
		{
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
				Write-Host("Complete.") -ForegroundColor Cyan
				Write-Host `n
		}
If($confirm -eq 'y')		
		{
		$date = Get-Date
		Write-Host `n
		Write-Host "Adding todays date to users details in AD"
			Set-AdUser -Identity $duser -Description "Disabled $date"

				Write-Host `n
				Write-Host("Complete.") -ForegroundColor Cyan
				Write-Host `n
		}
If($confirm -eq 'y')		
		{
		$uname = Get-ADUser $duser | Select Name
		$uname2 = $uname.Name
		Write-Host "Appending " -NoNewLine
		Write-Host "'zz' " -ForegroundColor Yellow -NoNewLine
		Write-Host "to users display names AND clearing the users manager" -NoNewLine
			Rename-ADObject -identity (get-aduser $duser).distinguishedname -newname zz$uname2
			Set-ADUser $duser -DisplayName zz$uname2 -Manager $null

				Write-Host `n
				Write-Host("Complete.") -ForegroundColor Cyan
				Write-Host `n
		}
If($confirm -eq 'y')
		{
		Write-Host "Please enter a new password for " -NoNewLine
		Write-Host "$duser" -ForegroundColor Yellow
			Set-ADAccountPassword -Identity $duser -Reset
			
				Write-Host `n
				Write-Host("Complete.") -ForegroundColor Cyan
				Write-Host `n
		}
If($confirm -eq 'y')
		{
		Write-Host "Clearing " -NoNewLine
		Write-Host "phone number(s) " -ForegroundColor Yellow
		Write-Host "for $duser"
			Set-ADUser $duser -MobilePhone '-' -OfficePhone '-' -HomePhone '-' -Fax '-'
		
				Write-Host `n
				Write-Host("Complete.") -ForegroundColor Cyan
				Write-Host `n
		}	
	
If($confirm -eq 'y')
		{
		$pcremove = Read-Host "Would you like to remove the computer for $duser from AD? [y/n]"
		If($pcremove -eq 'y')
			{
			Write-Host "Please enter the " -NoNewLine
			Write-Host "Computer Name " -ForegroundColor Yellow
			Write-Host "Used by $duser for removal from ActiveDirectory"
				$cpname = Read-Host 'Computer Name:'

			Write-Host "Deleting " -NoNewLine
			Write-Host "$cpname " -ForegroundColor Yellow -NoNewLine
			Write-Host "from Active Directory"			
				Remove-ADComputer -Identity test -Confirm:$false
			
					Write-Host `n
					Write-Host("Complete.") -ForegroundColor Cyan
					Write-Host `n
			}
		}
	}

Write-Host "`n"
Write-Host "Active Directory Process complete, press" -NoNewline
Write-Host " [Enter] " -ForegroundColor Green -NoNewline
Write-Host "to Continue... " -NoNewline
$input = Read-Host

Stop-Transcript

# *********************************************************************************************
# EX2010 Activities
# *********************************************************************************************

If($confirm -eq 'y')
	{
	Write-Host "`n"
	Write-Host "Hiding Mailbox for EX2010,"
	Write-Host "Login is following format" -NoNewLine
	Write-Host " 'access\YourDomainAdminLogin' " -ForegroundColor Green -NoNewLine
	Write-Host "`n"

	Start-Transcript -Append -Path "\\fskprdfile01\IT_Files\_End_User_Services\DisabledUsersGroups\Log Files\$duser.txt"

	$cred = Get-Credential access\adm-crockwell
	$2010session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://access-ex05/powershell -Credential $cred
	Import-PSSession $2010session

	Write-Host "`n"
	Write-Host "Hidding users mailbox in EX2010"

	Set-RemoteMailbox -Identity $duser -HiddenFromAddressListsEnabled $true

	Remove-PSSession $2010session

		Write-Host `n
		Write-Host("Complete.") -ForegroundColor Cyan
		Write-Host `n

	Write-Host "`n"
	Write-Host "Exchange 2010 Process complete, press" -NoNewline
	Write-Host " [Enter] " -ForegroundColor Green -NoNewline
	Write-Host "to Continue... " -NoNewline
	$input = Read-Host
	
Stop-Transcript

# *********************************************************************************************
# O365 Activities
# *********************************************************************************************

Start-Transcript -Append -Path "\\fskprdfile01\IT_Files\_End_User_Services\DisabledUsersGroups\Log Files\$duser.txt"

	Write-Host "`n"
	Write-Host "Beginning Office365 process"
	Write-Host "press" -NoNewline
	Write-Host " [Enter] " -ForegroundColor Green -NoNewline
	Write-Host "to Continue... "
	Write-Host "Login is following format" -NoNewline
	Write-Host " 'GlobalAdminAccout@accesspipeline.com' " -ForegroundColor Green
	Write-Host "`n"

	$UserCredential = Get-Credential adm-crockwell@accesspipeline.com
	$O365Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $UserCredential -Authentication Basic -AllowRedirection
	Import-PSSession $O365Session

	Import-Module MSOnline
	Connect-msolservice -credential $UserCredential

	Get-Mailbox -identity $duser"@accesspipeline.com" | Get-MailboxStatistics | Select TotalItemSize
		Write-Host("`nWould you like to continue with the conversion to a shared mailbox? ") -NoNewLine
		Write-Host("[y/n]: ") -ForegroundColor Yellow
		$continue = Read-Host 
		
	If($continue -eq 'y')
		{   Write-Host ("Does the mailbox need to be assigned to the users Manager? ") -NoNewline
			Write-Host ("[y/n]: ") -ForegroundColor Yellow -NoNewLine
			$yn = Read-Host 
			Write-Host("`n")
			If($yn -eq 'y')

			{
				Write-Host ("Please enter the user to allow access ") -NoNewline
				Write-Host ("[email address] ") -ForegroundColor Yellow -NoNewLine
				$accessuser = Read-Host 
			}
			
		}
			
			Write-Host("`n")
			Write-Host("Changing Mailbox to Shared...")
			Get-Mailbox -identity $duser | set-mailbox -type “Shared”
			Set-Mailbox $duser -ProhibitSendReceiveQuota 50GB -ProhibitSendQuota 49.75GB -IssueWarningQuota 49.5GB
			
				Write-Host("`n")		
				Write-Host("Complete.") -ForegroundColor Cyan
				Write-Host("`n")

			If($yn -eq 'y')
				{
					Write-Host("Adding Mailbox permissions...")
					foreach ($a in $accessuser)
						{
							Add-MailboxPermission $duser -User ((out-string -InputObject $a).Trim()) -AccessRights FullAccess
						}
					
				Write-Host `n
				Write-Host("Complete.") -ForegroundColor Cyan
				Write-Host `n
				
				}
			
		Write-Host("Removing assigned licenses...")
		$license = (Get-MSOLUser -UserPrincipalName $duser@accesspipeline.com).Licenses[0].AccountSkuId
		Set-MsolUserLicense -UserPrincipalName $duser@accesspipeline.com -RemoveLicenses $license 
			
				Write-Host `n
				Write-Host("Complete.") -ForegroundColor Cyan
				Write-Host `n

		Write-Host("Removing Mobile Devices from users Exchange account...")
			Get-MobileDevice -Mailbox $duser@accesspipeline.com | ForEach {Remove-MobileDevice -Identity $_.Identity} -Confirm:$false
					
				Write-Host `n
				Write-Host("Complete.") -ForegroundColor Cyan
				Write-Host `n

		Write-Host ("Please enter the user's Manager's email to set Automatic Reply ") -NoNewline
		Write-Host ("[email address] ") -ForegroundColor Yellow -NoNewLine
		$manager = Read-Host 
			Write-Host ("Setting Automatic Reply for $duser@accesspipeline.com")
			Set-MailboxAutoReplyConfiguration $duser@accesspipeline.com -AutoReplyState Enabled -InternalMessage "Please be informed that this person is no longer with Access Pipeline.  If this is an important, Access Pipeline business related matter please email their manager at '$manager'" -ExternalMessage "Please be informed that this person is no longer with Access Pipeline.  If this is an important, Access Pipeline business related matter please email their manager at '$manager'"
					
					Write-Host `n 

					Write-Host("Complete.") -ForegroundColor Cyan
					Write-Host `n
			
			
		Write-Host ("Removing user from all O365 Distribution Groups")
		
			$adname = (get-aduser $duser).name
			$mailbox = get-mailbox $duser
			$dgs = Get-DistributionGroup
	 
			foreach($dg in $dgs)
			{
				$DGMs = Get-DistributionGroupMember -identity $dg.Identity
					foreach ($dgm in $DGMs){if ($dgm.name -eq $mailbox.name)
						{"Removing $user from Group $dg.identity"
						Remove-DistributionGroupMember $dg.Name -Member $duser@accesspipeline.com -Confirm:$flase
					}
				}
			}
			
				Write-Host `n
				Write-Host("Complete.") -ForegroundColor Cyan
				Write-Host `n


		Write-Host ("Removing user permissions from all Mailboxes ***can take a minute***")
		
			$shared = Get-Mailbox | Get-MailboxPermission -User $duser
				$shared
		   foreach($sm in $shared)
		   {  
			   Remove-MailboxPermission -Identity $sm.Identity -User $duser -AccessRights $sm.AccessRights -Confirm:$false
		   }
				Write-Host `n
				Write-Host("Complete.") -ForegroundColor Cyan
				Write-Host `n
	}	

    Write-Host "Process complete, press" -NoNewline
    Write-Host " [Enter]"  -ForegroundColor Green -NoNewline
    Write-Host " To end..."
    Read-Host 
	
    Remove-PSSession $O365Session

Stop-Transcript    
            
		Write-Host("`n")
        Write-Host("********************************************************") -ForegroundColor Red
		Write-Host("Tasks completed") -ForegroundColor Cyan
		Write-Host("********************************************************") -ForegroundColor Red
        Write-Host("Moved the User to 'Disabled Users' OU") -ForegroundColor White
		Write-Host("Disable the AD Account") -ForegroundColor White
        Write-Host("Removed all of group user's memberships except 'Domain Users'") -ForegroundColor White
        Write-Host("of group memberships except 'Domain Users'") -ForegroundColor White
        Write-Host("Append 'zz' to the beginning of the users 'Name' and 'Display Name'") -ForegroundColor White
        Write-Host("Reset the users password") -ForegroundColor White
        Write-Host("Set details for user account to current date that the user was offboarded") -ForegroundColor White
		Write-Host("Clear the Manager that is set on the user account.") -ForegroundColor White
		Write-Host("Clear all phone numbers from AD account") -ForegroundColor White
		Write-Host("Delete the users Computer from ActiveDirectory") -ForegroundColor White
        Write-Host("********************************************************") -ForegroundColor Red
			
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