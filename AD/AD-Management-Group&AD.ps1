<# VS Code Shortcuts
Collapse All: Ctrl+K CTRL+0
Expand All: Ctrl+K CTRL+J
#>

#-----------Group Membership Export-----------#
    $Groups = (Get-AdGroup -filter * | Where {$_.name -like "G Access*"} | select name -expandproperty name)
    $Table = @()
    $Record = [ordered]@{
    "Group Name" = ""
    "Name" = ""
    "Username" = ""
    }
    Foreach ($Group in $Groups)
    {
    $Arrayofmembers = Get-ADGroupMember -identity $Group | select name,samaccountname
        foreach ($Member in $Arrayofmembers)
            {
            $Record."Group Name" = $Group
            $Record."Name" = $Member.name
            $Record."UserName" = $Member.samaccountname
            $objRecord = New-Object PSObject -property $Record
            $Table += $objrecord
            }
    }
    $Table | export-csv "C:\Temp\SecurityGroups.csv" -NoTypeInformation

#-----------Group Membership to individual files-----------#
    # Dumps AD group memberships to files
    # Author: Aaron Kennedy
    # Version 1.0

    if ((get-module -listavailable | ? {$_.name -eq "activedirectory"}) -eq $null) {
        write-host -foregroundcolor red "This script requires the Active Directory PowerShell module.  It can be installed as part of the Remote Server Administration Toolkit."
        exit
    }
    if ((get-module activedirectory) -eq $null) {import-module activedirectory}

    write-host "********************************************************************************"
    write-host "********************************************************************************"
    $domainname = (get-addomain).name
    $currentpath = split-path $MyInvocation.MyCommand.Path
    $proceed = read-host "This script will dump the membership of each group in the '$domainname' domain to individual files in the current folder '$currentpath'.  Do you wish to proceed? (y/N)"
    write-host "********************************************************************************"
    write-host "********************************************************************************"
    if ($proceed -eq "y") {
        $groups = get-adgroup -filter *
        foreach ($group in $groups) {
            $groupname = ($group | select-object Name).Name
            write-host "Writing $groupname members to file..."
            get-adgroupmember $group | select-object Name,ObjectClass | export-csv "$currentpath\Members_$groupname.csv"
        }
        write-host "Group memberships exported to file(s)."
    }

#-----------Groups in OU-----------#
    Get-ADObject -Filter 'ObjectClass -eq "group"' -SearchBase 'OU=SharePoint Groups,OU=Groups,OU=Access Corporate,DC=Access,DC=ad' | Sort-Object Name -Descending | FT Name

#-----------Create Groups from file-----------#
    $group = Import-Csv "D:\Clouds\OneDrive for Business\Shared\groups.csv"

    foreach ($g in $group)
    {
    New-ADGroup -Name ($g).Name -Description ($g).Description -GroupScope Global -Path "OU=SharePoint,OU=Security Groups,OU=Groups,OU=Access Corporate,DC=Access,DC=ad"
    }

#-----------Add users to groups from file-----------#
    $user = Import-Csv "D:\Clouds\OneDrive for Business\Shared\users.csv"
    
    foreach ($u in $user)
    {
    Add-ADGroupMember -Identity $u.group -Members $u.uname -Confirm:$false
    }

#-----------Protect All OU's-----------#
    Get-ADOrganizationalUnit -filter * -Properties ProtectedFromAccidentalDeletion | 
	where {$_.ProtectedFromAccidentalDeletion -eq $false} | 
        Set-ADOrganizationalUnit -ProtectedFromAccidentalDeletion $true

#-----------Add users to group from other group-----------#
    Add-ADGroupMember -Identity 'New Group' -Members (Get-ADGroupMember -Identity 'Old Group' -Recursive)