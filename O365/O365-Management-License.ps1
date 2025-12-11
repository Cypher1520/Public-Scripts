<# VS Code Shortcuts
Collapse All: Ctrl+K CTRL+0
Expand All: Ctrl+K CTRL+J
#>

#-----------SKU ID's-----------#
    Get-MsolAccountSku

#-----------get all users and licenses assigned to each-----------#
    Get-MSOLUser -All | where {$_.isLicensed -eq "TRUE"} | select userprincipalname,islicensed,{$_.Licenses.AccountSkuId} | Sort-Object -Property UserPrincipalName

#-----------get users with a license, and assign another license-----------#
    Get-Msoluser -All | where {$_.islicensed -eq "TRUE" -and $_.Licenses.AccountSkuId -eq 'ParexResources:ENTERPRISEPACK'} | % {Set-MsolUserLicense -UserPrincipalName $_.UserPrincipalName -AddLicenses "ParexResources:EMS"}

(get-MsolUser -UserPrincipalName chris.rockwell@travelalberta.com).licenses.AccountSkuId
foreach ($u in $users) {Set-MsolUserLicense -UserPrincipalName chris.rockwell@travelalberta.com -RemoveLicenses "TravelAlberta:ENTERPRISEWITHSCAL"}

#-----------Add License-----------#
    % {Set-MsolUserLicense -UserPrincipalName $_.UserPrincipalName -AddLicenses "COMPANY:ENTERPRISEPREMIUM"}

#-----------Remove License-----------#
    #Get disabled users and remove licenses
    $users = Get-MsolUser -All | Where-Object {$_.DisplayName -like "zz*"}
    $upn = ($users | where {$_.isLicensed -eq $true}).UserPrincipalName
    foreach ($name in $upn)
    {(get-MsolUser -UserPrincipalName $name).license.AccountSkuId | foreach {Set-MsolUserLicense -UserPrincipalName $name -RemoveLicenses $_}}

    #Remove license from a user
    $upn = 'jennifer.son@travelalberta.com'
    (get-MsolUser -UserPrincipalName $upn).licenses.AccountSkuId |
    foreach {Set-MsolUserLicense -UserPrincipalName $upn -RemoveLicenses $_}
    
#-----------Service plans-----------#
    #get list of license Services from user
    (Get-MsolUser -UserPrincipalName chris.rockwell@travelalberta.com).Licenses.ServiceStatus

    #remove license service(s) from all users
    $allUsers = Get-Msoluser -All | where {$_.islicensed -eq "TRUE"} 
    foreach ($u in $allUsers)
    {
        $O365Licences = New-MsolLicenseOptions -AccountSkuId globalmarkets:ENTERPRISEPACK -DisabledPlans "BPOS_S_TODO_2"
        Set-MsolUserLicense -UserPrincipalName $u.UserPrincipalName -LicenseOptions $O365Licences
    }

#-----------Bulk Load Licenses-----------#
    Get-MsolUser -User testuser@domain.com | ForEach {
        #Get-MsolUser -All | Where { $_.IsLicensed -eq $true} | ForEach {
        #Import-Csv c:\o365\AssignLicenseOptions.csv | ForEach {
        $Upn = $_.UserPrincipalName
        $Exchange = "Disabled"; $SharePoint = "Disabled"; $Lync = "Disabled"; $Office = "Disabled"; $WebApps = "Disabled"
        (Get-MsolUser -User $Upn).Licenses[0].ServiceStatus | ForEach {
            If ($_.ServicePlan.ServiceName -eq "EXCHANGE_S_ENTERPRISE" -and $_.ProvisioningStatus -ne "Disabled") { $Exchange = "Enabled" }
            If ($_.ServicePlan.ServiceName -eq "SHAREPOINTENTERPRISE" -and $_.ProvisioningStatus -ne "Disabled") { $SharePoint = "Enabled" }
            If ($_.ServicePlan.ServiceName -eq "MCOSTANDARD" -and $_.ProvisioningStatus -ne "Disabled") { $Lync = "Enabled" }
            If ($_.ServicePlan.ServiceName -eq "OFFICESUBSCRIPTION" -and $_.ProvisioningStatus -ne "Disabled") { $Office = "Enabled" }
            If ($_.ServicePlan.ServiceName -eq "SHAREPOINTWAC" -and $_.ProvisioningStatus -ne "Disabled") { $WebApps = "Enabled" } }
            $DisabledOptions = @()
            If ($Exchange -eq "Disabled") { $DisabledOptions += "EXCHANGE_S_ENTERPRISE" }
            If ($SharePoint -eq "Disabled") { $DisabledOptions += "SHAREPOINTENTERPRISE" }
            If ($Lync -eq "Disabled") { $DisabledOptions += "MCOSTANDARD" }
            #If ($Office -eq "Disabled") { $DisabledOptions += "OFFICESUBSCRIPTION" }
            If ($WebApps -eq "Disabled") { $DisabledOptions += "SHAREPOINTWAC" }
            $LicenseOptions = New-MsolLicenseOptions -AccountSkuId "tenant:ENTERPRISEPACK" -DisabledPlans $DisabledOptions
            Set-MsolUserLicense -User $Upn -LicenseOptions $LicenseOptions }

#-----------Get users with license - Add to AzureAD group-----------#
    $users = Get-Msoluser -All | where {$_.islicensed -eq "TRUE" -and $_.Licenses.AccountSkuId -eq 'ParexResources:ENTERPRISEPACK'} 
    ForEach ($u in $users) 
        { 
            $obj = ($u).objectID
            Add-AzureADGroupMember -ObjectId db5632ff-120a-499d-963f-585956363aa6 -RefObjectId $obj
        }