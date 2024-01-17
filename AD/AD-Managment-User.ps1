<# VS Code Shortcuts
Collapse All: Ctrl+K CTRL+0
Expand All: Ctrl+K CTRL+J
#>

#-----------Reset User PWD Expiry-----------
    $Users = Import-Csv .\Users1.csv
    ForEach ($User In $Users)
    {
    $ID = $User.ID
    Set-ADUser -Identity "$ID" -Replace @{pwdLastSet=0}
    }

    ForEach ($User In $Users)
    {
    $ID = $User.ID
    Set-ADUser -Identity "$ID" -Replace @{pwdLastSet=-1}
    }

#-----------Randomly Generate user password (runs in excel)-----------
    #=CHAR(RANDBETWEEN(65,65+25))&CHAR(RANDBETWEEN(97,122))&CHAR(RANDBETWEEN(97,122))&CHAR(RANDBETWEEN(97,122))&RANDBETWEEN(0,9)&RANDBETWEEN(0,9)&RANDBETWEEN(0,9)&RANDBETWEEN(0,9)

#-----------Home Directory-----------#
    Get-ADUser -Filter * -properties HomeDirectory | FT Samaccountname, HomeDirectory -Autosize | Out-File E:\reports\HomeDirectories.csv

#-----------Get Enabled Users-----------#
    Get-ADUser -Filter 'enabled -eq $true' -SearchBase "DC=Access,DC=ad" | Sort-Object | Select Name | 
    Export-Csv "C:\temp\EnabledUsers.csv"

#-----------Get Users Info-----------#
    #Get General User info#
    Get-Aduser -Filter * -Properties * -SearchBase 'OU=Users,OU=Access Corporate,DC=Access,DC=ad' | 
    Select Name,Title,Department,Manager,Office,OfficePhone,MobilePhone,Enabled,GivenName,Surname,SamAccountName

    #Find users that contain name
    Get-ADUser -Filter {SAMAccountName -like "*tuser*"}

    #Full list user info targetting OU
    Get-ADUser -SearchBase "OU=Access Corporate,DC=Access,DC=ad" -Filter * -Properties * | Select DisplayName,Enabled,LockedOut,GivenName,Surname,SamAccountName,UserPrincipalName,EmailAddress,StreetAddress,City,State,Country,PostalCode,Company,Department,Title,Description,LastLogonDate,Office,TelephoneNumber,OfficePhone,MobilePhone,TempDID | Export-Csv "C:\temp\UserInfo.csv"

    #export multiple attributes from array
    Get-ADUser -Filter * -Properties * | select name, @{L='ProxyAddress_1'; E={$_.proxyaddresses[0]}},@{L='ProxyAddress_2';E={$_.ProxyAddresses[1]}}

#-----------Set User AD Info-----------#
    $update = Import-Csv "C:\temp\GAL-Update.csv"
    foreach ($u in $update)
    {
        Set-ADUser $u.SamAccountName -StreetAddress $u.StreetAddress -City $u.City -State $u.State -Country $u.Country -PostalCode $u.PostalCode -Company $u.Company -Title $u.NewTitle -Office $u.NewOffice -OfficePhone $u.OfficePhone <#-Manager $u.Manager#> -Department $u.Department -MobilePhone $u.MobilePhone
    }

#-----------User Groups-----------#
    Get-ADPrincipalGroupMembership "USERNAME" | Sort-Object | Select Name
    
    #get users in OU - Add to security group
    Get-ADUser -Filter * -SearchBase "OU=Users,OU=Access Corporate,DC=Access,DC=ad" | % {Add-ADGroupMember "H Drive Mapping" -Members $_}
    #Copy groups from user to user
    Get-ADPrincipalGroupMembership "ORIGINALUSER" | % {Add-ADGroupMember $_.Name -Members "COPYTOUSER"}

#-----------Get User LastLogon-----------#
    $accounts = Import-Csv C:\Users\adm-crockwell\Desktop\book1.csv
    
    ForEach ($a in $accounts)
    {
    Get-ADUser -Filter "SamAccountName -eq '$($a.samaccountname)'" -Properties * | Select-Object Name,LastLogonDate
    }

#-----------Set User Home Directory-----------#
    
    $users = Import-Csv C:\Temp\HomeDirectories.csv
    foreach ($user in $users)
        {
        Get-ADUser -Filter "SamAccountName -eq '$($user.samaccountname)'" -Properties * | Set-ADUser -HomeDirectory $($user.HomeDirectory)
        }
    #Clear user home directory
    Get-AdUser -Filter * -SearchBase "OU=Disabled Users,DC=Access,DC=ad" | Set-ADUser -HomeDirectory $null -WhatIf

#-----------User Cleanup-----------#
    $users = Import-CSV C:\Users\adm-crockwell\Desktop\UserDel.csv
    $date = Get-Date

    #Disable/Move computer to disabled computer OU
    ForEach ($U in $users)

    {
    #Get-ADUser -Identity $U.Name | Move-ADObject -TargetPath "OU=Callow,OU=Vendors,OU=Users,OU=Access Corporate,DC=Access,DC=ad"
    Set-ADUser -Identity $U.Name -Enabled $false -Description "Disabled $date"
    }

    #Delete Users
    #ForEach ($U in $users)

    #{
    #Remove-ADUser $U.Name -Confirm:$false
    #}

#-----------User Primary Group-----------#
    $users = Get-ADGroupMember "remoteworkers"
    $users.objectGUID

    get-aduser boardroom3 -properties primarygroupid

    Get-ADUser -filter {primaryGroupID -eq 1828} | Select Name | Sort-object Name

    $group = get-adgroup "Domain Users"
    $groupSid = $group.sid
    $groupSid
    $GroupID = $groupSid.Value.Substring($groupSid.Value.LastIndexOf("-")+1)
    Get-ADUser "cogz10" | Set-ADObject -Replace @{primaryGroupID="$GroupID"}

#-----------Disable Users tasks-----------#
    Get-AdUser -Filter * -SearchBase "OU=Disabled Users,DC=Access,DC=ad" | Set-ADUser -HomeDirectory $null
    $user = Get-ADUser -Filter * -SearchBase "OU=Disabled Users,DC=Access,DC=ad" 

    foreach ($u in $user)
    {
    Disable-ADAccount -Identity $u.SamAccountName | Set-ADuser -Identity $u.SamAccountName -Add @{msExchHideFromAddressLists="TRUE"}
    }

#-----------Admin account groups-----------#
    Get-ADUser -LDAPFilter "(name=*)" -SearchScope Subtree `
    -SearchBase "OU=Admin Accounts,OU=Access Corporate,DC=access,DC=ad" | %{
    $user = $_
    $user | Get-ADPrincipalGroupMembership | 
    Select @{N="User";E={$user.sAMAccountName}},@{N="Group";E={$_.Name}}
    }| Select User,Group | Export-Csv C:\report.csv -nti

#-----------Remove ALL Groups from user-----------#
    <#
    (GET-ADUSER –Identity $duser –Properties MemberOf | Select-Object MemberOf).MemberOf | Out-File \\fskprdfile01\IT_Files\_End_User_Services\DisabledUsersGroups\$duser.csv -Append
    #>
    $User = Get-ADUser $duser -Properties MemberOf
    $Groups = $User.memberOf | ForEach-Object {Get-ADGroup $_}
    $Groups |ForEach-Object {Remove-ADGroupMember -Identity $_ -Members $User -Confirm:$false}
    
    #***Remove all groups from user in an OU***
    $users = Get-AdUser -SearchBase "OU=Retired Accounts,OU=Travel Alberta,DC=travelalberta,DC=local"
    foreach ($u in $users)
    {
        $MemOf = Get-ADUser $u -Properties MemberOf
        $Groups = $MemOf.memberOf | ForEach-Object {Get-ADGroup $_}
        $Groups | ForEach-Object {Remove-ADGroupMember -Identity $_ -Members $MemOf -Confirm:$false}
    }

#-----------Hide user from Addressbook - ADSI-----------#
    $users = Get-AdUser -Filter * -SearchBase "OU-FQDN"
    foreach ($u in $users)
    {
    $MemOf = Get-ADUser $u -Properties MemberOf
    $Groups = $MemOf.memberOf | ForEach-Object {Get-ADGroup $_}
    $Groups | ForEach-Object {Remove-ADGroupMember -Identity $_ -Members $MemOf -Confirm:$false}
    $UserDN = (Get-ADUser $u -Properties DistinguishedName).DistinguishedName
    Set-ADObject -Identity $UserDN -replace @{msExchHideFromAddressLists=$true}
    Set-ADObject -Identity $UserDN –clear ShowinAddressBook
    }

#-----------Logon Script-----------
    Get-ADUser -Filter * -SearchBase "OU=User Accounts,DC=santhosh,DC=lab" | Set-ADUser –scriptPath “\\San01\test.bat” 
    Get-ADUser -Filter * -SearchBase "OU=User Accounts,DC=santhosh,DC=lab" | Set-ADUser -Clear scriptPath
    Get-ADGroupMember "H Drive Mapping" | Set-ADUser -Clear scriptPath

#-----------Get Users Groups-----------
    Get-ADPrincipalGroupMembership "USERNAME" | Select Name

    Get-ADPrincipalGroupMembership nicola.dawes | % {Add-ADGroupMember $_.Name -Members teresa.retzlaff}

#-----------Get Users in OU-----------
    Get-ADUser -Filter {Enabled -eq $true} <#-SearchBase "USEROU"#> -Properties * | sort-object -property Name | Select Name,UserPrincipalName,DistinguishedName | Export-Csv 'D:\Clouds\Google Drive\Work\Scripts\AD\Calgary.csv'

#-----------Get Users Excluding OU-----------
    $OUDN = "EXCLUSIONOU"
    Get-ADUser -Filter {Enabled -eq $true} -SearchBase "SEARCHOU" | Where-Object { $_.DistinguishedName -notlike "*,$OUDN" } | Sort -Property Name | Select Name,UserPrincipalName | Export-Csv 'D:\Clouds\Google Drive\Work\Scripts\AD\Field.csv'

#-----------Add User to another users groups-----------
    Get-ADUser -Identity "COPYFROM" -Properties memberof | 
    Select-Object -ExpandProperty memberof | 
    Add-ADGroupMember -Members "COPYTO" -PassThru | 
    Select-Object -Property SamAccountName