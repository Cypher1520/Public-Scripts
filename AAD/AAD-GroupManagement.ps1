<# VS Code Shortcuts
Collapse All: Ctrl+K CTRL+0
Expand All: Ctrl+K CTRL+J
#>

#-----------Add a computer to a group-----------#
#$search = Read-Host 'Enter Computer Name'
$search = "WM-100010"
$obID = Get-AzureADDevice -SearchString $search
$obID.DisplayName

Write-Host "Adding The above Device(s) to Bitlocker & Targeted update AzureAD group " -NoNewline
foreach ($o in $obID) {
    #Add computer to Targeted Updates group
    Add-AzureADGroupMember -ObjectId 91a7a210-9091-4562-a2c0-8a52de8013cf -RefObjectId $o.ObjectID
    #ADd computer to Bitlocker Group
    Add-AzureADGroupMember -ObjectId bc6073e0-7956-4501-8776-8ab04892141b -RefObjectId $o.ObjectID
}

#-----------Get all Azure AD (Cloud) Groups-----------#
Get-AzureADGroup

#-----------Add Users to group from CSV-----------#    
#Add Users
$users = Import-Csv C:\temp\Batches.csv
$gObjID = (Get-AzureADGroup -SearchString 'Intune-M365UpgradePRD-Default-6').ObjectID
foreach ($u in $users) {
    $uObjID = (Get-AzureADUser -ObjectId $u.email).ObjectID
    Add-AzureADGroupMember -ObjectId $gObjID -RefObjectId $uObjID
    Write-Host $uObjID
}
    (Get-AzureADGroupMember -ObjectId $gObjID).count

#-----------Remove all users from a group-----------#
$gObjID = (Get-AzureADGroup -SearchString 'Intune-M365UpgradePRD-Default-6').ObjectID
$remove = Get-AzureADGroupMember -ObjectID $gObjID -All $true
$count = 0
foreach ($r in $remove) {
    Remove-AzureADGroupMember -ObjectID $gObjID -MemberId $r.ObjectId
    $count += 1
    Write-Host "Removed" $count
}
    (Get-AzureADGroupMember -ObjectId $gObjID).count