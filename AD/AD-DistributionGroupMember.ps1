<#

.Requires -version 2 - Runs in Exchange Management Shell

.SYNOPSIS
.\DistributionGroupMemberReport.ps1 - It Can Display all the Distribution Group and its members on a List

Or It can Export to a CSV file


Example 1

[PS] C:\DG>.\DistributionGroupMemberReport.ps1


Distribution Group Member Report
----------------------------

1.Display in Shell

2.Export to CSV File

Choose The Task: 1

DisplayName                   Alias                         Primary SMTP address          Distriubtion Group
-----------                   -----                         --------------------          ------------------
Atlast1                       Atlast1                       Atlast1@targetexchange.in     Test1
Atlast2                       Atlast2                       Atlast2@careexchange.in       Test1
Blink                         Blink                         Blink@targetexchange.in       Test1
blink1                        blink1                        blink1@targetexchange.in      Test1
User2                         User2                         User2@careexchange.in         Test11
User3                         User3                         User3@careexchange.in         Test11
User4                         User4                         User4@careexchange.in         Test11
WithClient                    WithClient                    WithClient@careexchange.in    Test11
Blink                         Blink                         Blink@targetexchange.in       Test11
blink1                        blink1                        blink1@targetexchange.in      Test11

Example 2

[PS] C:\DG>.\DistributionGroupMemberReport.ps1


Distribution Group Member Report
----------------------------

1.Display in Shell

2.Export to CSV File

Choose The Task: 2
Enter the Path of CSV file (Eg. C:\DG.csv): C:\DGmembers.csv

.Author
Written By: Satheshwaran Manoharan

Change Log
V1.0, 11/10/2012 - Initial version

Change Log
V1.1, 02/07/2014 - Added "Enter the Distribution Group name with Wild Card"

Change Log
V1.2, 19/07/2014 - Added "Recipient OU,Distribution Group Primary SMTP address,Distribution Group Managers,Distribution Group OU"
V1.2.1, 19/07/2014 - Added "Option- Enter the Distribution Group name with Wild Card (Display)"
V1.2.2, 19/07/2014 - Added "Fixed "Hashtable-to-Object conversion is not supported in restricted language mode or a Data section"

V1.3,05/08/2014 - Hashtable-to-Object conversion is not supported - Fixed 
#>

Write-host "

Distribution Group Member Report
----------------------------

1.Display in Exchange Management Shell

2.Export to CSV File

3.Enter the Distribution Group name with Wild Card (Export)

4.Enter the Distribution Group name with Wild Card (Display)

Dynamic Distribution Group Member Report
----------------------------

5.Display in Exchange Management Shell

6.Export to CSV File

7.Enter the Dynamic Distribution Group name with Wild Card (Export)

8.Enter the Dynamic Group name with Wild Card (Display)"-ForeGround "Cyan"

#----------------
# Script
#----------------

Write-Host "               "

$number = Read-Host "Choose The Task"
$output = @()
switch ($number) 
{

1 {

$AllDG = Get-DistributionGroup -resultsize unlimited

Foreach($dg in $allDg)

{

$Members = Get-DistributionGroupMember $Dg.name -resultsize unlimited

$Total = $Members.Count

$RemoveNull = $Total-1

For($i=0;$i -le $RemoveNull;$i++)

{

$userObj = New-Object PSObject

$userObj | Add-Member NoteProperty -Name "DisplayName" -Value $members[$i].Name
$userObj | Add-Member NoteProperty -Name "Alias" -Value $members[$i].Alias
$userObj | Add-Member NoteProperty -Name "Primary SMTP address" -Value $members[$i].PrimarySmtpAddress
$userObj | Add-Member NoteProperty -Name "Distribution Group" -Value $DG.Name


Write-Output $Userobj

}

}

;Break}

2 {

$CSVfile = Read-Host "Enter the Path of CSV file (Eg. C:\DG.csv)" 

$AllDG = Get-DistributionGroup -resultsize unlimited

Foreach($dg in $allDg)

{

$Members = Get-DistributionGroupMember $Dg.name -resultsize unlimited

$Total = $Members.Count

$RemoveNull = $Total-1

For($i=0;$i -le $RemoveNull;$i++)

{
$managers = $Dg | Select @{Name='DistributionGroupManagers';Expression={[string]::join(";", ($_.Managedby))}}

$userObj = New-Object PSObject

$userObj | Add-Member NoteProperty -Name "DisplayName" -Value $members[$i].Name
$userObj | Add-Member NoteProperty -Name "Alias" -Value $members[$i].Alias
$userObj | Add-Member NoteProperty -Name "RecipientType" -Value $members[$i].RecipientType
$userObj | Add-Member NoteProperty -Name "Recipient OU" -Value $members[$i].OrganizationalUnit
$userObj | Add-Member NoteProperty -Name "Primary SMTP address" -Value $members[$i].PrimarySmtpAddress
$userObj | Add-Member NoteProperty -Name "Distribution Group" -Value $DG.Name
$userObj | Add-Member NoteProperty -Name "Distribution Group Primary SMTP address" -Value $DG.PrimarySmtpAddress
$userObj | Add-Member NoteProperty -Name "Distribution Group Managers" -Value $managers.DistributionGroupManagers
$userObj | Add-Member NoteProperty -Name "Distribution Group OU" -Value $DG.OrganizationalUnit
$userObj | Add-Member NoteProperty -Name "Distribution Group Type" -Value $DG.GroupType
$userObj | Add-Member NoteProperty -Name "Distribution Group Recipient Type" -Value $DG.RecipientType


$output += $UserObj  

}

$output | Export-csv -Path $CSVfile -NoTypeInformation

}



;Break}

3 {

$CSVfile = Read-Host "Enter the Path of CSV file (Eg. C:\DG.csv)" 

$Dgname = Read-Host "Enter the DG name or Range (Eg. DGname , DG*,*DG)"

$AllDG = Get-DistributionGroup $Dgname -resultsize unlimited

Foreach($dg in $allDg)

{

$Members = Get-DistributionGroupMember $Dg.name -resultsize unlimited

$Total = $Members.Count

$RemoveNull = $Total-1

For($i=0;$i -le $RemoveNull;$i++)

{

$managers = $Dg | Select @{Name='DistributionGroupManagers';Expression={[string]::join(";", ($_.Managedby))}}

$userObj = New-Object PSObject

$userObj | Add-Member NoteProperty -Name "DisplayName" -Value $members[$i].Name
$userObj | Add-Member NoteProperty -Name "Alias" -Value $members[$i].Alias
$userObj | Add-Member NoteProperty -Name "RecipientType" -Value $members[$i].RecipientType
$userObj | Add-Member NoteProperty -Name "Recipient OU" -Value $members[$i].OrganizationalUnit
$userObj | Add-Member NoteProperty -Name "Primary SMTP address" -Value $members[$i].PrimarySmtpAddress
$userObj | Add-Member NoteProperty -Name "Distribution Group" -Value $DG.Name
$userObj | Add-Member NoteProperty -Name "Distribution Group Primary SMTP address" -Value $DG.PrimarySmtpAddress
$userObj | Add-Member NoteProperty -Name "Distribution Group Managers" -Value $managers.DistributionGroupManagers
$userObj | Add-Member NoteProperty -Name "Distribution Group OU" -Value $DG.OrganizationalUnit
$userObj | Add-Member NoteProperty -Name "Distribution Group Type" -Value $DG.GroupType
$userObj | Add-Member NoteProperty -Name "Distribution Group Recipient Type" -Value $DG.RecipientType

$output += $UserObj   

}

$output | Export-csv -Path $CSVfile -NoTypeInformation

}

;Break}

4 {

$Dgname = Read-Host "Enter the DG name or Range (Eg. DGname , DG*,*DG)"

$AllDG = Get-DistributionGroup $Dgname -resultsize unlimited

Foreach($dg in $allDg)

{

$Members = Get-DistributionGroupMember $Dg.name -resultsize unlimited

$Total = $Members.Count

$RemoveNull = $Total-1

For($i=0;$i -le $RemoveNull;$i++)

{

$userObj = New-Object PSObject

$userObj | Add-Member NoteProperty -Name "DisplayName" -Value $members[$i].Name
$userObj | Add-Member NoteProperty -Name "Alias" -Value $members[$i].Alias
$userObj | Add-Member NoteProperty -Name "Primary SMTP address" -Value $members[$i].PrimarySmtpAddress
$userObj | Add-Member NoteProperty -Name "Distribution Group" -Value $DG.Name


Write-Output $Userobj

}

}

;Break}


5 {

$AllDG = Get-DynamicDistributionGroup -resultsize unlimited

Foreach($dg in $allDg)

{

$Members = Get-Recipient -RecipientPreviewFilter $dg.RecipientFilter -resultsize unlimited

$Total = $Members.Count

$RemoveNull = $Total-1

For($i=0;$i -le $RemoveNull;$i++)

{

$userObj = New-Object PSObject

$userObj | Add-Member NoteProperty -Name "DisplayName" -Value $members[$i].Name
$userObj | Add-Member NoteProperty -Name "Alias" -Value $members[$i].Alias
$userObj | Add-Member NoteProperty -Name "Primary SMTP address" -Value $members[$i].PrimarySmtpAddress
$userObj | Add-Member NoteProperty -Name "Distribution Group" -Value $DG.Name


Write-Output $Userobj

}

}

;Break}

6 {

$CSVfile = Read-Host "Enter the Path of CSV file (Eg. C:\DYDG.csv)" 

$AllDG = Get-DynamicDistributionGroup -resultsize unlimited

Foreach($dg in $allDg)

{

$Members = Get-Recipient -RecipientPreviewFilter $dg.RecipientFilter -resultsize unlimited

$Total = $Members.Count

$RemoveNull = $Total-1

For($i=0;$i -le $RemoveNull;$i++)

{
$managers = $Dg | Select @{Name='DistributionGroupManagers';Expression={[string]::join(";", ($_.Managedby))}}

$userObj = New-Object PSObject

$userObj | Add-Member NoteProperty -Name "DisplayName" -Value $members[$i].Name
$userObj | Add-Member NoteProperty -Name "Alias" -Value $members[$i].Alias
$userObj | Add-Member NoteProperty -Name "RecipientType" -Value $members[$i].RecipientType
$userObj | Add-Member NoteProperty -Name "Recipient OU" -Value $members[$i].OrganizationalUnit
$userObj | Add-Member NoteProperty -Name "Primary SMTP address" -Value $members[$i].PrimarySmtpAddress
$userObj | Add-Member NoteProperty -Name "Distribution Group" -Value $DG.Name
$userObj | Add-Member NoteProperty -Name "Distribution Group Primary SMTP address" -Value $DG.PrimarySmtpAddress
$userObj | Add-Member NoteProperty -Name "Distribution Group Managers" -Value $managers.DistributionGroupManagers
$userObj | Add-Member NoteProperty -Name "Distribution Group OU" -Value $DG.OrganizationalUnit
$userObj | Add-Member NoteProperty -Name "Distribution Group Type" -Value $DG.RecipientType
$userObj | Add-Member NoteProperty -Name "Distribution Group Recipient Type" -Value $DG.RecipientType


$output += $UserObj  

}

$output | Export-csv -Path $CSVfile -NoTypeInformation

}

;Break}


7 {

$CSVfile = Read-Host "Enter the Path of CSV file (Eg. C:\DYDG.csv)" 

$Dgname = Read-Host "Enter the DG name or Range (Eg. DynmicDGname , Dy*,*Dy)"

$AllDG = Get-DynamicDistributionGroup $Dgname -resultsize unlimited

Foreach($dg in $allDg)

{

$Members = Get-Recipient -RecipientPreviewFilter $dg.RecipientFilter -resultsize unlimited

$Total = $Members.Count

$RemoveNull = $Total-1

For($i=0;$i -le $RemoveNull;$i++)

{

$managers = $Dg | Select @{Name='DistributionGroupManagers';Expression={[string]::join(";", ($_.Managedby))}}

$userObj = New-Object PSObject

$userObj | Add-Member NoteProperty -Name "DisplayName" -Value $members[$i].Name
$userObj | Add-Member NoteProperty -Name "Alias" -Value $members[$i].Alias
$userObj | Add-Member NoteProperty -Name "RecipientType" -Value $members[$i].RecipientType
$userObj | Add-Member NoteProperty -Name "Recipient OU" -Value $members[$i].OrganizationalUnit
$userObj | Add-Member NoteProperty -Name "Primary SMTP address" -Value $members[$i].PrimarySmtpAddress
$userObj | Add-Member NoteProperty -Name "Distribution Group" -Value $DG.Name
$userObj | Add-Member NoteProperty -Name "Distribution Group Primary SMTP address" -Value $DG.PrimarySmtpAddress
$userObj | Add-Member NoteProperty -Name "Distribution Group Managers" -Value $managers.DistributionGroupManagers
$userObj | Add-Member NoteProperty -Name "Distribution Group OU" -Value $DG.OrganizationalUnit
$userObj | Add-Member NoteProperty -Name "Distribution Group Type" -Value $DG.RecipientType
$userObj | Add-Member NoteProperty -Name "Distribution Group Recipient Type" -Value $DG.RecipientType

$output += $UserObj   

}

$output | Export-csv -Path $CSVfile -NoTypeInformation

}


;Break}

8 {

$Dgname = Read-Host "Enter the Dynamic DG name or Range (Eg. DynamicDGname , DG*,*DG)"

$AllDG = Get-DynamicDistributionGroup $Dgname -resultsize unlimited

Foreach($dg in $allDg)

{

$Members = Get-Recipient -RecipientPreviewFilter $dg.RecipientFilter -resultsize unlimited

$Total = $Members.Count

$RemoveNull = $Total-1

For($i=0;$i -le $RemoveNull;$i++)

{

$userObj = New-Object PSObject

$userObj | Add-Member NoteProperty -Name "DisplayName" -Value $members[$i].Name
$userObj | Add-Member NoteProperty -Name "Alias" -Value $members[$i].Alias
$userObj | Add-Member NoteProperty -Name "Primary SMTP address" -Value $members[$i].PrimarySmtpAddress
$userObj | Add-Member NoteProperty -Name "Distribution Group" -Value $DG.Name


Write-Output $Userobj

}

}

;Break}

Default {Write-Host "No matches found , Enter Options 1 or 2" -ForeGround "red"}

}