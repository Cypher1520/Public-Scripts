<# VS Code Shortcuts
Collapse All: Ctrl+K CTRL+0
Expand All: Ctrl+K CTRL+J
#>

#-----------Get Users-----------#
    Get-User * | Select UserPrincipalName,WindowsLiveID,MicrosoftOnlineServicesID,AccountDisabled,City,CountryOrRegion,Department,DisplayName,Fax,FirstName,LastName,Manager,MobilePhone,Office,Phone,PostalCode,StateOrProvince,StreetAddress,Title,WindowsEmailAddress,Identity | sort -Property UserPrincipalName | Export-Csv .\CurrentUsers.csv -NoTypeInformation

#-----------Remove Deleted User-----------#
    #Remove-MsolUser -UserPrincipalName "USER EMAIL" -Force -RemoveFromRecycleBin

    Remove-MsolUser -UserPrincipalName USER@COMPANYEMAIL.com -Force -RemoveFromRecycleBin

#-----------Get Users Shared Memberships-----------#
    #1
    Get-Mailbox | Get-MailboxPermission -user "USER"

    #2
    $user = "USER@COMPANYEMAIL.com"
    $mailbox=get-mailbox $user
    $dgs= Get-DistributionGroup
    
    foreach($dg in $dgs){
        
        $DGMs = Get-DistributionGroupMember -identity $dg.Identity
        foreach ($dgm in $DGMs){
            if ($dgm.name -eq $mailbox.name){
        
                write-host 'User Found In Group' $dg.identity
                #Remove-DistributionGroupMember $dg.Name -Member $user -Confirm:$false
            }
        }
    }
  
#-----------Delete Users from CSV-----------#
    $users = Import-Csv "A:\Clouds\OneDrive - Stratiform Inc\Documents\GMP\importResults.csv"
    foreach ($u in $users)
    {Remove-MsolUser -UserPrincipalName $u.Username -Force -RemoveFromRecycleBin}

    	
    Remove-MsolUser -UserPrincipalName user@COMPANYEMAIL.onmicrosoft.com -Force -RemoveFromRecycleBin

#-----------Add User Alias-----------#
    Import-CSV "A:\Clouds\OneDrive - Stratiform Inc\Documnts\GMP\O365Import.csv"e | ForEach {Set-Mailbox $_.Mailbox -EmailAddresses @{add=$_.NewEmailAddress}}

#-----------User Info-----------#
    
    #Set User info
    Import-CSV "A:\Clouds\OneDrive - Stratiform Inc\Documents\GMP\GMPUserInfo.csv" | % {Set-User -Identity $_.Identity -City $_.City -Department $_.Department -DisplayName $_.DisplayName -Fax $_.Fax -FirstName $_.FirstName -LastName $_.LastName -MobilePhone $_.MobilePhone -Office $_.Office -Phone $_.Phone -PostalCode $_.PostalCode -StateOrProvince $_.StateOrProvince -StreetAddress $_.StreetAddress -Title $_.Title -Company $_.Company <#-Manager $_.Manager -CountryOrRegion $_.CountryOrRegion#>}

    #PW
    Import-CSV "USERLISTCSV.csv" | % {Set-MsolUserPassword -UserPrincipalName $_.Username -NewPassword $_.Password -ForceChangePassword:$false}
    
#-----------Contacts-----------#
    #import from csv
    Import-Csv "A:\Clouds\OneDrive - Stratiform Inc\Documents\GMP\user_gmpsec.csv" | % {New-MailContact -Name $_.DisplayName -DisplayName $_.DisplayName -ExternalEmailAddress $_.UserPrincipalName -FirstName $_.FirstNamez -LastName $_.LastName}

    Import-Csv "A:\clouds\OneDrive - Stratiform Inc\Documents\GMP\CASLContacts.csv" | % {New-MailContact -Name $_.DisplayName -ExternalEmailAddress $_.Email -DisplayName $_.DisplayName}
    
    #hide from addressbook
    Import-Csv "A:\clouds\OneDrive - Stratiform Inc\Documents\GMP\CASLContacts.csv" | % {Set-MailContact -Identity $_.Identity -HiddenFromAddressListsEnabled $true}
    Get-MailContact -Filter {Displayname -like "zzCASL*"} -ResultSize Unlimited | % {Set-MailContact -Identity $_.Identity -HiddenFromAddressListsEnabled $true}
   
    #add to group
    $groupid = Get-MsolGroup | Where-Object {$_.DisplayName -eq “CASL-blacklist”}
    $users = Get-MailContact -Filter {Displayname -like "zzCASL*"} -ResultSize Unlimited
    $users | foreach {Add-DistributionGroupMember -Identity "CASL-Blacklist" -Member $_.Name}

    #Get and remomve 
    Get-MailContact | % {Remove-MailContact -Identity $_.Name -Confirm:$false}
    Import-CSV "A:\Clouds\OneDrive - Stratiform Inc\Documents\GMP\GMPContactInfo.csv" | % {Remove-contact -Identity $_.Identity -Confirm:$false}

    #SetContactInfo
    Import-CSV "A:\Clouds\OneDrive - Stratiform Inc\Documents\GMP\GMPContactInfo.csv" | % {Set-Contact -Identity $_.Identity -WindowsEmailAddress $_.WindowsEmailAddress -City $_.City -Company $_.Company -CountryOrRegion $_.Country -Department $_.Department -Fax $_.Fax -FirstName $_.FirstName -LastName $_.LastName -Title $_.Title -Office $_.Office -MobilePhone $_.MobilePhoneNumber -Phone $_.Phone -PostalCode $_.PostalCode -StateOrProvince $_.StateOrProvince -StreetAddress $_.StreetAddress}

    $Import = Import-CSV "A:\Clouds\OneDrive - Stratiform Inc\Documents\GMP\GMPContactInfo.csv" | % {Set-MailContact -Identity $_.Identity -DisplayName $_.DisplayName -Alias $_.Alias}

    #get-contacts
    Get-Contact | Select City,Company,CountryOrRegion,Department,DisplayName,Fax,FirstName,LastName,MobilePhone,Phone,PostalCode,RecipientType,StateOrProvince,StreetAddres,Identity,WindowsEmailAddress | Export-Csv .\ContactInfo.csv -NoTypeInformation

        Get-Contact | Select City,Company,CountryOrRegion,Department,DisplayName,Fax,FirstName,LastName,MobilePhone,Phone,PostalCode,RecipientType,StateOrProvince,StreetAddres,Identity,WindowsEmailAddress | Where-Object {$_.DisplayName -notlike "zz*"} | Export-Csv "A:\Clouds\OneDrive - Stratiform Inc\Documents\GMP\Securities\ContactInfo.csv" -NoTypeInformation
    
    #GetContacts & Groups
    #See .AD\AD-DistributionGroupMember.ps1
    Get-MailContact -Filter {Displayname -like "ext.*"} -ResultSize Unlimited | Select DisplayName,Alias | Export-Csv "A:\Clouds\OneDrive - Stratiform Inc\Documents\GMP\extusers.csv" -NoTypeInformation

#-----------Disabled Users-----------#
    #Get disabled accounts, convert to Shared
    Get-MsolUser -All | where {$_.islicensed -eq "true" -and $_.DisplayName -like "zz*"} | % {Set-Mailbox -Identity $_.UserPrincipalName -Type Shared}

#-----------Find MFA registered users-----------#
    Get-MsolUser -All | where {$_.StrongAuthenticationMethods -ne $null} | Select-Object -Property UserPrincipalName | Sort -Property UserPrincipalName

#-----------Clear MFA settings for user-----------#
    Get-MsolUser "USERPRINCIPALNAME" | Set-MSOLUSER $_.StrongAuthenticationMethods $null
    Set-MsolUser -UserPrincipalName "user@COMPANYEMAIL.com" -StrongAuthenticationMethods @()

#-----------Force password change-----------#
    #Single user
    Set-MsolUserPassword -UserPrincipalName dquinn@gmpsecurities.com -ForceChangePasswordOnly:$true -ForceChangePassword:$true

    #Group of users
    Get-MsolUser -All | ? {$_.Country -eq "USA"} | Set-MsolUserPassword -ForceChangePasswordOnly $true -ForceChangePassword $true

#-----------Force password change-----------#
    Set-Mailbox "MAILBOX" -ForwardingAddress $Null

#-----------Add User to Group-----------#
    Add-MsolGroupMember -