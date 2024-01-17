<# VS Code Shortcuts
Collapse All: Ctrl+K CTRL+0
Expand All: Ctrl+K CTRL+J
#>

<#SYNTAX
    Get-DistributionGroup -Identity "Name" | FL
    Set-DistributionGroup -Identity 
    [-AcceptMessagesOnlyFrom <MultiValuedProperty>]
    [-AcceptMessagesOnlyFromDLMembers <MultiValuedProperty>]
    [-AcceptMessagesOnlyFromSendersOrMembers <MultiValuedProperty>]
    [-Alias <String>]
    [-ArbitrationMailbox <MailboxIdParameter>]
    [-BypassModerationFromSendersOrMembers <MultiValuedProperty>]
    [-BypassNestedModerationEnabled <$true | $false>]
    [-BypassSecurityGroupManagerCheck <SwitchParameter>]
    [-Confirm <SwitchParameter>]
    [-CreateDTMFMap <$true | $false>]
    [-DisplayName <String>]
    [-DomainController <Fqdn>]
    [-EmailAddresses <ProxyAddressCollection>]
    [-EmailAddressPolicyEnabled <$true | $false>]
    [-ExpansionServer <String>]
    [-ForceUpgrade <SwitchParameter>]
    [-GenerateExternalDirectoryObjectId <SwitchParameter>]
    [-GrantSendOnBehalfTo <MultiValuedProperty>]
    [-HiddenFromAddressListsEnabled <$true | $false>]
    [-IgnoreDefaultScope <SwitchParameter>]
    [-IgnoreNamingPolicy <SwitchParameter>]
    [-MailTip <String>]
    [-MailTipTranslations <MultiValuedProperty>]
    [-ManagedBy <MultiValuedProperty>]
    [-MaxReceiveSize <Unlimited>]
    [-MaxSendSize <Unlimited>]
    [-MemberDepartRestriction <Closed | Open | ApprovalRequired>]
    [-MemberJoinRestriction <Closed | Open | ApprovalRequired>]
    [-ModeratedBy <MultiValuedProperty>]
    [-ModerationEnabled <$true | $false>]
    [-Name <String>]
    [-PrimarySmtpAddress <SmtpAddress>]
    [-RejectMessagesFrom <MultiValuedProperty>]
    [-RejectMessagesFromDLMembers <MultiValuedProperty>]
    [-RejectMessagesFromSendersOrMembers <MultiValuedProperty>]
    [-ReportToManagerEnabled <$true | $false>]
    [-ReportToOriginatorEnabled <$true | $false>]
    [-RequireSenderAuthenticationEnabled <$true | $false>]
    [-ResetMigrationToUnifiedGroup <SwitchParameter>]
    [-RoomList <SwitchParameter>]
    [-SamAccountName <String>]
    [-SendModerationNotifications <Never | Internal | Always>]
    [-SendOofMessageToOriginatorEnabled <$true | $false>]
    [-SimpleDisplayName <String>]
    [-UMDtmfMap <MultiValuedProperty>]
    [-WindowsEmailAddress <SmtpAddress>]
    
    [-CustomAttribute1 <String>] - [-CustomAttribute15 <String>]
    [-ExtensionCustomAttribute1 <MultiValuedProperty>] - [-ExtensionCustomAttribute5 <MultiValuedProperty>]
#>

#-----------Create Distribution Group-----------#
    New-DistributionGroup -Identity responseteam -MemberDepartRestriction Open -MemberJoinRestriction ApprovalRequired -ManagedBy phoulahan -RequireSenderAuthenticationEnabled $false

    #import groups from csv
    Import-csv "A:\Clouds\OneDrive - Stratiform Inc\Documents\GMP\Groupsreport.csv" | % {New-DistributionGroup -Name $_.Name -PrimarySmtpAddress $_.PrimaryEmail -MemberDepartRestriction Open -MemberJoinRestriction ApprovalRequired -RequireSenderAuthenticationEnabled $false -ManagedBy "deboucher@gmpfirstenergy.com" }

    #hide all from address list
    Get-DistributionGroup | % {Set-DistributionGroup $_.Name -HiddenFromAddressListsEnabled $true}

#-----------Set Parameters-----------#
    Get-DistributionGroup | % {Set-DistributionGroup -Identity $_.Name -HiddenFromAddressListsEnabled:$false}

    Set-DistributionGroup -Identity "responseteam" -MemberDepartRestriction Open -MemberJoinRestriction ApprovalRequired -ManagedBy phoulahan -RequireSenderAuthenticationEnabled $false
    Set-DistributionGroup -Identity "responseteam" -ManagedBy phoulahan

#-----------Add Members-----------#
    $users = @("kstrickland", "kreardon", "rwatt", "bgray")
    foreach ($u in $users)
    {
    Add-DistributionGroupMember -Identity responseteam -Member $u
    }

#-----------Creating Room Lists for Teams-----------#
    New-DistributionGroup -Name "GROUPNAME" -RoomList
    Add-DistributionGroupMember -Identity "LISTNAME" -Member "EMAILOFROOM(S)"