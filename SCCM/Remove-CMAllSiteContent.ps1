<#
.Synopsis
   Removing distributed content on either Distribution Point Group or multiple Distribution Points
.DESCRIPTION
   Instead of removing content from one distribution point one at the time is this function created to serve a multi purpose removing distributed content. 

.REQUIREMENTS
   You need to know the SiteCode of your SCCM Environment. This is stated at the top, inside of Configuration Manager (example X01) 

.EXAMPLE
   Remove-CMAllSiteContent -PackageName 'TestApplication' -CMSiteCode X01
    - Follow the upcoming steps

   If you know the PackageID, this will facilitate the search. 
   Remove-CMAllSiteContent -PackageID X0100001 -CMSiteCode X01 
   - Follow the upcoming steps

.PARAMETERS
    $PackageName
        This parameter is used search for both packages and applications. This is a wildcard search. The parameter is Mandatory. 
        This parameter is set to DefaultParameterSetName. If PackageID is specified, this parameter is not needed.
            Example: If you have an application named "Test123" and a package named "Test122", and you search for "Test", both of them will be found. 
                     
    $PackageID
        This parameter is used if you just want to remove distributed content of a single package / application. The parameter accepts ValueFromPipeline & is NOT mandatory
        This parameter should only be used if you are sure of what content you want to have removed from all the distribution points / the distribution point group. 
        
    $CMSiteCode
        This parameter is used to specify the site code. The side code is easyest found inside the Configuration Manager console, or the cmdlet "Get-CMSite". The parameter is Mandatory. 
        

.NOTES
   Name: Remove-CMAllSiteContent.ps1
   Author: Johan Nilsson
   Date Created: 2019-01-15
   Version History:
       2019-01-15 - Johan Nilsson
           Initial Creation
       2019-01-23 - Johan Nilsson
           Finishing steps with error handling
           Created a solution to the issue if one application is distributed to Distribution Point Group and another distributed to to multiple Distribution Points
       2019-01-24 - Johan Nilsson
           Added a Break-part - If the content could be found, but was not distributed to any Distributin Point / Distribution Point Group 
       2019-02-11 - Johan Nilsson
           Fixed the issue with the built in cmdlet Remove-CMContentDistribution not being able to remove applications with the PackageID parameter
           If Distribution is Application - Using Name because SQLMessage = SQL Server Conversion failed when converting the nvarchar value PackageID (example X0100001) to data type int.
           - Resolved this issue by using CI_ID instead of PackageID - Just applications 
       2019-03-06 
           Added support to remove OS-Images, Task Sequences and Software Update Packages 
       2019-03-13 
           Resolved the issue with single application on multiple Distribution Points 
#>

function Remove-CMAllSiteContent {
    [CmdletBinding(
        DefaultParameterSetName='PackageName')
    ]
    Param (
        # Specify the Package Name
        [Parameter(
            HelpMessage = 'Declare the name of the distributed content. This will do a wildcard search both in Packages & Applications. Try to be as specific as possible.',
            Mandatory=$true,
            ParameterSetName='PackageName',
            Position=0
        )]
        $PackageName,

        # Specify the Package ID
        
        [Parameter(
            HelpMessage = 'Specify the SCCM Package ID',
            ParameterSetName='PackageID',
            ValueFromPipeLineByPropertyName = $true
        )]
        $PackageID,

        # Specify the SCCM Site Code (Example X01)
        [Parameter(
            HelpMessage = 'Specify the SCCM Site Code. Example X01.',
            Mandatory = $true
        )]
        [ValidateNotNullOrEmpty()]
        $CMSiteCode

    )

    Begin {
        try { 
            $GetCMSite = Get-Command Get-CMSite -ErrorAction Stop
        }
        catch {
            Try {
                Write-Verbose "Attempting to import SCCM Module"
                Import-Module (Join-Path $(Split-Path $ENV:SMS_ADMIN_UI_PATH) ConfigurationManager.psd1) -Verbose:$false
                if((Get-Module ConfigurationManager) -eq $null) {
                    Import-Module "$($ENV:SMS_ADMIN_UI_PATH)\..\ConfigurationManager.psd1" 
                }

                ## Connect to the site's drive if it is not already present
                if((Get-PSDrive -Name $CMSiteCode -PSProvider CMSite -ErrorAction SilentlyContinue) -eq $null) {
                    New-PSDrive -Name $CMSiteCode -PSProvider CMSite -Root $ProviderMachineName
                }
                
                ## Set the current location to be the site code.
                Set-Location "$($CMSiteCode):\" 
                Write-Verbose "Successfully imported the SCCM Module"
            }
            Catch {
                Write-Warning "Failure to import SCCM Cmdlets."
            }
        } 

        if (((Get-Location).Path) -replace [Regex]::Escape(':\'),"" -eq ($CMSiteCode)) {
            $DistributionPoints = Get-CMDistributionPoint -AllSite
        }
        else {
            Set-Location "$($CMSiteCode):\"
            $DistributionPoints = Get-CMDistributionPoint -AllSite
        }
        try {
            $DistributionPointGroup = Get-CMDistributionPointGroup -ErrorAction Stop
        }
        catch {
            Write-Output "No distribution point groups were found"
        }
    }

    Process {
        if ($PackageName) {
            $CMApp = @()
            try {
                if ($null -ne (Get-CMApplication -Name "*$PackageName*")) {
                    $CMApp += Get-CMApplication -Name "*$PackageName*" -ErrorAction Continue
                    if ($true -eq ((Get-CMApplication -Name "*$PackageName*"  -ErrorAction Continue) -ne $null)) {
                        $CMApp | Where-Object {$_.Type -eq $null} | Add-Member -MemberType NoteProperty Type('ApplicationID')
                    }
                }
                if ($null -ne (Get-CMPackage -Name "*$PackageName*")) {
                    $CMApp += Get-CMPackage -Name "*$PackageName*"  -ErrorAction Continue 
                    if ($true -eq ((Get-CMPackage -Name "*$PackageName*"  -ErrorAction Continue) -ne $null)) {
                        $CMApp | Where-Object {$_.Type -eq $null} | Add-Member -MemberType NoteProperty Type('PackageID')
                    }
                }
                if ($null -ne (Get-CMDriverPackage -Name "*$PackageName*")) {
                    $CMApp += Get-CMDriverPackage -Name "*$PackageName*" -ErrorAction Continue
                    if ($true -eq ((Get-CMDriverPackage -Name "*$PackageName*"  -ErrorAction Continue) -ne $null)) {
                        $CMApp | Where-Object {$_.Type -eq $null} | Add-Member -MemberType NoteProperty Type('DriverPackageId') 
                    }
                }
                if ($null -ne (Get-CMOperatingSystemImage -Name "*$PackageName*")) {
                    $CMApp += Get-CMOperatingSystemImage -Name "*$PackageName*" -ErrorAction Continue
                    if ($true -eq ((Get-CMOperatingSystemImage -Name "*$PackageName*"  -ErrorAction Continue) -ne $null)) { 
                        $CMApp | Where-Object {$_.Type -eq $null} | Add-Member -MemberType NoteProperty Type('OperatingSystemImageId') 
                    }

                }
                if ($null -ne (Get-CMTaskSequenceDeployment -Name "*$PackageName*")) {
                    $CMApp += Get-CMTaskSequenceDeployment -Name "*$PackageName*" -ErrorAction Continue
                    if ($true -eq ((Get-CMTaskSequenceDeployment -Name "*$PackageName*"  -ErrorAction Continue) -ne $null)) {
                        $CMApp | Where-Object {$_.Type -eq $null} | Add-Member -MemberType NoteProperty Type('TaskSequenceID') 
                    }

                }
                if ($null -ne (Get-CMBootImage -Name "*$PackageName*")) {
                    $CMApp += Get-CMBootImage -Name "*$PackageName*" -ErrorAction Stop
                    if ($true -eq ((Get-CMBootImage -Name "*$PackageName*"  -ErrorAction Continue) -ne $null)) {
                        $CMApp | Where-Object {$_.Type -eq $null} | Add-Member -MemberType NoteProperty Type('BootImageID') 
                    }
                }                
            }
            catch {
                Write-Warning "Unable to find Application or Package with name $PackageName"
            }
            ## If more than one application is found
            if (($CMApp.count) -gt 1) {
                $MoreObjects = @() 
                $i = 1
                foreach ($App in $CMApp) {
                    if ($App.PackageID -and $App.Name) {
                        if (0 -lt (Get-CMDistributionStatus -Id $App.PackageID).Targeted) {
                            $MoreObjects += [PSCustomObject]@{
                                Name = $App.Name
                                PackageID = $App.PackageID
                                AppType = $App.Type
                                ObjectNumber = $i
                            }
                            $i++
                        }
                    }
                    if ($App.PackageID -and $App.LocalizedDisplayName) {
                        if (0 -lt (Get-CMDistributionStatus -Id $App.PackageID).Targeted) {
                            $MoreObjects += [PSCustomObject]@{
                                Name = $App.LocalizedDisplayName
                                PackageID = $App.PackageID
                                AppType = $App.Type
                                ObjectNumber = $i
                            }
                            $i++
                        }
                    }
                    else {
                        Write-Output "Invalid Package - Going to next app"
                    }
                }
                if (1 -eq $MoreObjects.count) {
                    $CMApp = $CMApp | Where {$_.LocalizedDisplayName -eq $MoreObjects.name}
                }
                
                $MoreObjects += [pscustomobject]@{
                    Name = 'All'
                    PackageID = ''
                    AppType = ''
                    ObjectNumber = 0
                }
                $MoreObjects += [pscustomobject]@{
                    Name = 'Exit'
                    PackageID = ''
                    AppType = ''
                    ObjectNumber = 999
                }
                $MoreObjects = $MoreObjects | Sort-Object ObjectNumber
                if ($false -eq ($MoreObjects.name -match $PackageName)) {
                    Write-Output "Could not find any distributed content with the name $PackageName - Exiting this script"
                    Start-Sleep -Seconds 4
                    Break
                }
                if ((1 -eq ($MoreObjects | Where {$_.Name -ne 'All' -and $_.Name -ne 'Exit'}).name.count)) { 
                    $MoreObjects | Where {$_.Name -ne 'All'}| Format-Table -AutoSize
                }
                else {
                    $MoreObjects | Format-Table -AutoSize
                }
                do {
                    if (1 -eq ($MoreObjects | Where {$_.Name -ne 'All' -and $_.Name -ne 'Exit'}).name.count -and $null -eq $ObjectNumber) {
                        $ObjectNumber = Read-Host "Found one application matching the name $PackageName - Please select the Object Number to continue" 
                    }
                    if (1 -lt ($MoreObjects | Where {$_.Name -ne 'All' -and $_.Name -ne 'Exit'}).name.count -and $null -eq $ObjectNumber) {
                        $ObjectNumber = Read-Host "Found more than one application matching the name $PackageName - Please select the Object Number you want to remove"
                    }
                    elseif ($null -eq $ObjectNumber) {
                        $ObjectNumber = Read-Host "Found the application matching the name $PackageName - Please select the Object Number you want to remove"
                    } 
                }
                until ($MoreObjects.ObjectNumber -contains $ObjectNumber)
            }
            ## If only one application is found
            if (($CMApp.Count) -eq 1) {
                $OneObject = @() 
                Write-Output "Found distributed content with the name $($CMApp.LocalizedDisplayName)"
                $OneObject += [pscustomobject]@{
                    Name = $CMApp.LocalizedDisplayName
                    PackageID = $CMApp.PackageID
                    AppType = $CMApp.Type
                    ObjectNumber = 1
                }
                $OneObject += [pscustomobject]@{
                    Name = 'Exit'
                    PackageID = ''
                    ObjectNumber = 999
                }
            }
            ## Removing every distributed application / package containing the name $Objects
            if ($ObjectNumber -eq 0) {
                $AllObjects = $MoreObjects | Where {$_.ObjectNumber -ne 0 -and $_.ObjectNumber -ne 999}
                Write-Output "Removing the following distributions: "$($CMApp.Name)""
                do { 
                    $Confirm = Read-Host "Is this correct? Y/N" 
                }
                until ($Confirm -eq 'Y' -or 'N') 
                if ('Y' -eq $Confirm) {
                    Write-Output "Confirmed. Removing distributed content from each Distribution Point"

                    ## Foreach application in applications
                    foreach ($Object in $AllObjects) {
                        try {
                            ## If Distribution is Application - Using Name because SQLMessage = SQL Server Conversion failed when converting the nvarchar value PackageID (example X0100001) to data type int.
                            ## Resolved by changing to CI_ID
                            if (0 -lt (Get-CMDistributionStatus -Id $Object.PackageID).Targeted) {
                                if (([string]$Object.Type) -eq 'ApplicationID') {
                                    try {
                                        Write-Output "Trying to remove $($Object.Name) from DistributionPointGroup - Application"
                                        Remove-CMContentDistribution -DistributionPointGroupName (Get-CMDistributionPointGroup).Name -ApplicationId $Object.CI_ID -Force -Confirm:$false -ErrorAction Stop
                                    }
                                    catch {
                                        Write-Output "Unable to remove $($Object.Name) from DistributionPointGroup - Application, trying Package"    
                                    }
                                }
                                if (([string]$Object.Type) -eq 'PackageID') {
                                    try {
                                        Remove-CMContentDistribution -DistributionPointGroupName (Get-CMDistributionPointGroup).Name -PackageId $Object.PackageID -Force -Confirm:$false -ErrorAction Stop
                                    }
                                    catch {
                                        Write-Output "Unable to remove $($Object.Name) from DistributionPointGroup - Application, trying DriverPackageId"    
                                    }

                                }
                                if (([string]$Object.Type) -eq 'DriverPackageId') {
                                    try {
                                        Remove-CMContentDistribution -DistributionPointGroupName (Get-CMDistributionPointGroup).Name -DriverPackageId $Object.PackageID -Force -Confirm:$false -ErrorAction Stop
                                    }
                                    catch {
                                        Write-Output "Unable to remove $($Object.Name) from DistributionPointGroup - Application, trying OperatingSystemImageId"    
                                    }

                                }
                                if (([string]$Object.Type) -eq 'OperatingSystemImageId') {
                                    try {
                                        Remove-CMContentDistribution -DistributionPointGroupName (Get-CMDistributionPointGroup).Name -OperatingSystemImageId $Object.PackageID -Force -Confirm:$false -ErrorAction Stop
                                    }
                                    catch {
                                        Write-Output "Unable to remove $($Object.Name) from DistributionPointGroup - Application, trying TaskSequenceID"    
                                    }

                                }
                                if (([string]$Object.Type) -eq 'TaskSequenceID') {
                                    try {
                                        Remove-CMContentDistribution -DistributionPointGroupName (Get-CMDistributionPointGroup).Name -TaskSequenceId $Object.Id -Force -Confirm:$false -ErrorAction Stop
                                    }
                                    catch {
                                        Write-Output "Unable to remove $($Object.Name) from DistributionPointGroup - Application, trying BootImageId"    
                                    }

                                }
                                if (([string]$Object.Type) -eq 'BootImageID') {
                                try {
                                        Remove-CMContentDistribution -DistributionPointGroupName (Get-CMDistributionPointGroup).Name -BootImageId $Object.PackageID -Force -Confirm:$false -ErrorAction Stop
                                    }
                                    catch {
                                        Write-Output "Unable to remove $($Object.Name) from DistributionPointGroup - Exiting script"    
                                        Start-Sleep -Seconds 3
                                        Break
                                    }

                                }
                            }
                            if (0 -lt (Get-CMDistributionStatus -Id $Object.PackageID).Targeted) {
                                foreach ($DistributionPoint in $DistributionPoints) {
                                    try {
                                        if (([string]$Object.Type).Replace(" ","") -eq 'ApplicationID') {
                                            try {
                                                Remove-CMContentDistribution -DistributionPointName $DistributionPoint.NetworkOSPath.Replace("\\","")  -ApplicationId $Object.CI_ID -Force -Confirm:$false -ErrorAction Stop
                                                Write-Output "$($Object.PackageID) successfully removed from Distribution Point $($DistributionPoint.NetworkOSPath)"
                                            }
                                            catch {
                                                Write-Output "Failed to remove $($Object.PackageID)from Distribution Point $($DistributionPoint.NetworkOSPath)"
                                            }
                                        }
                                        if (([string]$cmapp.Type).Replace(" ","") -eq 'PackageID') {
                                            try {
                                                Remove-CMContentDistribution -DistributionPointName $DistributionPoint.NetworkOSPath.Replace("\\","") -PackageId $Object.PackageID -Force -Confirm:$false -ErrorAction Stop
                                            }
                                            catch {
                                                Write-Output "Failed to remove $($Object.PackageID)from Distribution Point $($DistributionPoint.NetworkOSPath)"
                                            }
                                        }
                                        if (([string]$cmapp.Type).Replace(" ","") -eq 'DriverPackageId') {
                                            try {
                                                Remove-CMContentDistribution -DistributionPointName $DistributionPoint.NetworkOSPath.Replace("\\","") -DriverPackageId $Object.PackageID -Force -Confirm:$false -ErrorAction Stop
                                            }
                                            catch {
                                                Write-Output "Failed to remove $($Object.PackageID)from Distribution Point $($DistributionPoint.NetworkOSPath)"
                                            }
                                        }
                                        if (([string]$cmapp.Type).Replace(" ","") -eq 'OperatingSystemImageId') {
                                            try {
                                                Remove-CMContentDistribution -DistributionPointName $DistributionPoint.NetworkOSPath.Replace("\\","") -OperatingSystemImageId $Object.PackageID -Force -Confirm:$false -ErrorAction Stop
                                            }
                                            catch {
                                                Write-Output "Failed to remove $($Object.PackageID)from Distribution Point $($DistributionPoint.NetworkOSPath)"
                                            }
                                        }
                                        if (([string]$cmapp.Type).Replace(" ","") -eq 'TaskSequenceID') {
                                            try {
                                                Remove-CMContentDistribution -DistributionPointName $DistributionPoint.NetworkOSPath.Replace("\\","") -TaskSequenceID $Object.PackageID -Force -Confirm:$false -ErrorAction Stop
                                            }
                                            catch {
                                                Write-Output "Failed to remove $($Object.PackageID)from Distribution Point $($DistributionPoint.NetworkOSPath)"
                                            }
                                        }
                                        if (([string]$cmapp.Type).Replace(" ","") -eq 'BootImageID') {
                                            try {
                                                Remove-CMContentDistribution -DistributionPointName $DistributionPoint.NetworkOSPath.Replace("\\","") -BootImageID $Object.PackageID -Force -Confirm:$false -ErrorAction Stop
                                            }
                                            catch {
                                                Write-Output "Failed to remove $($Object.PackageID)from Distribution Point $($DistributionPoint.NetworkOSPath)"
                                            }
                                        }
                                    }
                                    catch {
                                        Write-Output "$($Error[0].CategoryInfo.Reason)"    
                                    }
                                }
                            }
                        }
                        catch {
                            Write-Output "$($Error[0].Exception)"
                        }
                    }
                }
                if ('N' -eq $Confirm) {
                    Write-Output "This was incorrect. Exiting script."
                    Start-Sleep -Seconds 3
                    Break
                }

            }
            ## 999 is equal to exiting the script
            if ($ObjectNumber -eq 999) {
                Write-Output "You chose to exit the script."
                Start-Sleep -Seconds 3
                Break
            }
            if ($null -eq $OneObject -and $null -eq $CMApp) {
                Write-Output "Nothing was found with the name $PackageName - Exiting script" 
                Start-Sleep -Seconds 3
                Break
            }

            ## Removing the distributed application / package             
            if (($ObjectNumber -ne 999) -and ($ObjectNumber -ne 0)) {
                $OneObject = $MoreObjects | Where-Object {$_.ObjectNumber -ne 999 -and $_.ObjectNumber -eq $ObjectNumber}
                ## Selecting CMApp based on ObjectNumber. Starts on 0, therefor -1
                if (1 -lt $CMApp.count) {
                    if ("$($CMApp[$ObjectNumber -1].LocalizedDisplayName)" -eq '') {
                        Write-Output "Removing the following distribution: "$($CMApp[$ObjectNumber -1].Name)""
                    }
                    if ("$($CMApp[$ObjectNumber -1].LocalizedDisplayName)" -ne '') {
                        Write-Output "Removing the following distribution: "$($CMApp[$ObjectNumber -1].LocalizedDisplayName)""
                    }
                    if (("$($CMApp[$ObjectNumber -1].LocalizedDisplayName)" -ne '') -and ("$($CMApp[$ObjectNumber -1].Name)" -ne '')) {
                        Write-Output "Removing the selected distribution"
                    }
                }
                if (1 -eq $CMApp.Count) {
                    if ("$($CMApp[$ObjectNumber -1].LocalizedDisplayName)" -eq '') {
                        Write-Output "Removing the following distribution: "$($CMApp.Name)""
                    }
                    if ("$($CMApp[$ObjectNumber -1].LocalizedDisplayName)" -ne '') {
                        Write-Output "Removing the following distribution: "$($CMApp.LocalizedDisplayName)""
                    }
                    else {
                        Write-Output "Removing the selected distribution"
                    }
                }
                if (0 -eq $CMApp.count) {
                    Write-Output 'Unable to find any apps, script will now exit'
                    Start-Sleep -Seconds 3
                    Break
                }
                do { 
                    $Confirm = Read-Host "Is this correct? Y/N" 
                }
                until ($Confirm -eq 'Y' -or 'N')
                if ('Y' -eq $Confirm) {
                    Write-Output "Confirmed. Removing distributed content from Distribution Points or Distribution Point Group"
                    ## If there are distribution point group(s), content will firstly be removed from them
                    if ($true -eq $DistributionPointGroup) {
                        ## Verify that the content is distributed
                        Try {
                            $DistObject = Get-CMDistributionStatus -Id $CMApp.PackageID -ErrorAction SilentlyContinue
                        }
                        Catch {
                            $DistObject = Get-CMDistributionStatus -Id $($CMApp[$ObjectNumber -1].PackageID)
                        }
                        if ($null -ne $DistObject) {
                            if ($DistributionPointGroup.count -gt 1) {
''
                                try {
                                    if (1 -eq $CMApp.Count) {
                                        foreach ($DstPointGroup in $DistributionPointGroup) {
                                            try {
                                                if (([string]$CMApp.Type).Replace(" ","") -eq 'ApplicationID') {
                                                    try {
                                                        Remove-CMContentDistribution -DistributionPointGroupName $DstPointGroup.Name -ApplicationId $($CMApp.CI_ID) -Force -Confirm:$false -ErrorAction Stop
                                                        Write-Output "Removing $($CMApp.LocalizedDisplayName) from $($DstPointGroup.Name)"
                                                        $Removed = 1
                                                    }
                                                    catch {
                                                        Write-Output "Failed to remove $($CMApp.PackageID)from Distribution Point $($DstPointGroup.Name)"
                                                    }
                                                }
                                                if (([string]$cmapp.Type).Replace(" ","") -eq 'PackageID') {
                                                    try {
                                                        Remove-CMContentDistribution -DistributionPointGroupName $DstPointGroup.Name -PackageId $CMApp.PackageID -Force -Confirm:$false -ErrorAction Stop
                                            			Write-Output "Removing $($CMApp.PackageID) from $($DstPointGroup.Name)"
                                                        $Removed = 1
                                                    }
                                                    catch {
                                                        Write-Output "Failed to remove $($CMApp.PackageID)from Distribution Point $($DstPointGroup.Name)"
                                                    }
                                                }
                                                if (([string]$cmapp.Type).Replace(" ","") -eq 'DriverPackageId') {
                                                    try {
                                                        Remove-CMContentDistribution -DistributionPointGroupName $DstPointGroup.Name -DriverPackageId $CMApp.PackageID -Force -Confirm:$false -ErrorAction Stop
                                            			Write-Output "Removing $($CMApp.PackageID) from $($DstPointGroup.Name)"
                                                        $Removed = 1
                                                    }
                                                    catch {
                                                        Write-Output "Failed to remove $($CMApp.PackageID)from Distribution Point $($DstPointGroup.Name)"
                                                    }
                                                }
                                                if (([string]$cmapp.Type).Replace(" ","") -eq 'OperatingSystemImageId') {
                                                    try {
                                                        Remove-CMContentDistribution -DistributionPointGroupName $DstPointGroup.Name -OperatingSystemImageId $CMApp.PackageID -Force -Confirm:$false -ErrorAction Stop
                                            			Write-Output "Removing $($CMApp.PackageID) from $($DstPointGroup.Name)"
                                                        $Removed = 1
                                                    }
                                                    catch {
                                                        Write-Output "Failed to remove $($CMApp.PackageID)from Distribution Point $($DstPointGroup.Name)"
                                                    }
                                                }
                                                if (([string]$cmapp.Type).Replace(" ","") -eq 'TaskSequenceID') {
                                                    try {
                                                        Remove-CMContentDistribution -DistributionPointGroupName $DstPointGroup.Name -TaskSequenceID $CMApp.PackageID -Force -Confirm:$false -ErrorAction Stop
                                            			Write-Output "Removing $($CMApp.PackageID) from $($DstPointGroup.Name)"
                                                        $Removed = 1
                                                    }
                                                    catch {
                                                        Write-Output "Failed to remove $($CMApp.PackageID)from Distribution Point $($DstPointGroup.Name)"
                                                    }
                                                }
                                                if (([string]$cmapp.Type).Replace(" ","") -eq 'BootImageID') {
                                                    try {
                                                        Remove-CMContentDistribution -DistributionPointGroupName $DstPointGroup.Name -BootImageID $CMApp.PackageID -Force -Confirm:$false -ErrorAction Stop
                                            			Write-Output "Removing $($CMApp.PackageID) from $($DstPointGroup.Name)"
                                                        $Removed = 1
                                                    }
                                                    catch {
                                                        Write-Output "Failed to remove $($CMApp.PackageID)from Distribution Point $($DstPointGroup.Name)"
                                                    }
                                                }
                                            }
                                            catch {
                                                Write-Output "$($Error[0].CategoryInfo.Reason)"    
                                            }
                                        }
                                    }
                                    if (1 -lt $CMApp.Count) {
''
                                        foreach ($DstPointGroup in $DistributionPointGroup) {
                                            try {
                                                if (([string]$($CMApp[$ObjectNumber -1]).Type).Replace(" ","") -eq 'ApplicationID') {
                                                    try {
                                                        Remove-CMContentDistribution -DistributionPointGroupName $DstPointGroup.Name -ApplicationId $($CMApp[$ObjectNumber -1].CI_ID) -Force -Confirm:$false -ErrorAction Stop
                                                        Write-Output "Removing $($CMApp[$ObjectNumber -1].LocalizedDisplayName) from $($DstPointGroup.Name)"
                                                    }
                                                    catch {
                                                        Write-Output "Failed to remove $($CMApp[$ObjectNumber -1].PackageID) from Distribution Point $($DstPointGroup.Name)"
                                                    }
                                                }
                                                if (([string]$($CMApp[$ObjectNumber -1]).Type).Replace(" ","") -eq 'PackageID') {
                                                    try {
                                            			Remove-CMContentDistribution -DistributionPointGroupName $DstPointGroup.Name -PackageId $($CMApp[$ObjectNumber -1].PackageID) -Force -Confirm:$false -ErrorAction Stop
                                            			Write-Output "Removing $($CMApp[$ObjectNumber -1].PackageID) from $($DstPointGroup.Name)"
                                                    }
                                                    catch {
                                                        Write-Output "Failed to remove $($CMApp[$ObjectNumber -1].PackageID) from Distribution Point $($DstPointGroup.Name)"
                                                    }
                                                }
                                                if (([string]$($CMApp[$ObjectNumber -1]).Type).Replace(" ","") -eq 'DriverPackageId') {
                                                    try {
                                                        Remove-CMContentDistribution -DistributionPointGroupName $DstPointGroup.Name -DriverPackageId $($CMApp[$ObjectNumber -1].PackageID) -Force -Confirm:$false -ErrorAction Stop
                                            			Write-Output "Removing $($CMApp[$ObjectNumber -1].PackageID) from $($DstPointGroup.Name)"
                                                    }
                                                    catch {
                                                        Write-Output "Failed to remove $($CMApp[$ObjectNumber -1].PackageID) from Distribution Point $($DstPointGroup.Name)"
                                                    }
                                                }
                                                if (([string]$CMApp[$ObjectNumber -1].Type).Replace(" ","") -eq 'OperatingSystemImageId') {
                                                    try {
                                                        Remove-CMContentDistribution -DistributionPointGroupName $DstPointGroup.Name -OperatingSystemImageId $($CMApp[$ObjectNumber -1].PackageID) -Force -Confirm:$false -ErrorAction Stop
                                            			Write-Output "Removing $($CMApp[$ObjectNumber -1].PackageID) from $($DstPointGroup.Name)"
                                                    }
                                                    catch {
                                                        Write-Output "Failed to remove $($CMApp[$ObjectNumber -1].PackageID) from Distribution Point $($DstPointGroup.Name)"
                                                    }
                                                }
                                                if (([string]$($CMApp[$ObjectNumber -1]).Type).Replace(" ","") -eq 'TaskSequenceID') {
                                                    try {
                                                        Remove-CMContentDistribution -DistributionPointGroupName $DstPointGroup.Name -TaskSequenceID $($CMApp[$ObjectNumber -1].PackageID) -Force -Confirm:$false -ErrorAction Stop
                                            			Write-Output "Removing $($CMApp[$ObjectNumber -1].PackageID) from $($DstPointGroup.Name)"
                                                    }
                                                    catch {
                                                        Write-Output "Failed to remove $($CMApp[$ObjectNumber -1].PackageID)from Distribution Point $($DstPointGroup.Name)"
                                                    }
                                                }
                                                if (([string]$($CMApp[$ObjectNumber -1]).Type).Replace(" ","") -eq 'BootImageID') {
                                                    try {
                                                        Remove-CMContentDistribution -DistributionPointGroupName $DstPointGroup.Name -BootImageID $($CMApp[$ObjectNumber -1].PackageID) -Force -Confirm:$false -ErrorAction Stop
                                            			Write-Output "Removing $($CMApp[$ObjectNumber -1].PackageID) from $($DstPointGroup.Name)"
                                                    }
                                                    catch {
                                                        Write-Output "Failed to remove $($CMApp[$ObjectNumber -1].PackageID) from Distribution Point $($DstPointGroup.Name)"
                                                    }
                                                }
                                            }
                                            catch {
                                                Write-Output "$($Error[0].CategoryInfo.Reason)"    
                                            }
                                        }
                                    }
                                }
                                catch {
                                    if (1 -eq $CMApp.Count) {
                                        Write-Output "Unable to remove $($CMApp.LocalizedDisplayName) from Distribution Point Group, trying each Distribution Point"
                                    }
                                    if (1 -lt $CMApp.Count) {
                                        Write-Output "Unable to remove $($CMApp[$ObjectNumber -1].LocalizedDisplayName) from Distribution Point Group, trying each Distribution Point"
                                    }
                                }
                                try {
                                    if (1 -eq $CMApp.Count -and $Removed -ne 1) {
                                        foreach ($DistributionPoint in $DistributionPoints) {
                                            try {
                                                if (([string]$CMApp.Type).Replace(" ","") -eq 'ApplicationID') {
                                                    try {
                                                        Remove-CMContentDistribution -DistributionPointName $DistributionPoint.NetworkOSPath.Replace("\\","")  -ApplicationId $CMApp.CI_ID -Force -Confirm:$false -ErrorAction Stop
                                                        Write-Output "$($CMApp.PackageID) successfully removed from Distribution Point $($DistributionPoint.NetworkOSPath)"
                                                    }
                                                    catch {
                                                        Write-Output "Failed to remove $($CMApp.PackageID)from Distribution Point $($DistributionPoint.NetworkOSPath)"
                                                    }
                                                }
                                                if (([string]$cmapp.Type).Replace(" ","") -eq 'PackageID') {
                                                    try {
                                                        Remove-CMContentDistribution -DistributionPointName $DistributionPoint.NetworkOSPath.Replace("\\","") -PackageId $CMApp.PackageID -Force -Confirm:$false -ErrorAction Stop
                                                    }
                                                    catch {
                                                        Write-Output "Failed to remove $($CMApp.PackageID)from Distribution Point $($DistributionPoint.NetworkOSPath)"
                                                    }
                                                }
                                                if (([string]$cmapp.Type).Replace(" ","") -eq 'DriverPackageId') {
                                                    try {
                                                        Remove-CMContentDistribution -DistributionPointName $DistributionPoint.NetworkOSPath.Replace("\\","") -DriverPackageId $CMApp.PackageID -Force -Confirm:$false -ErrorAction Stop
                                                    }
                                                    catch {
                                                        Write-Output "Failed to remove $($CMApp.PackageID)from Distribution Point $($DistributionPoint.NetworkOSPath)"
                                                    }
                                                }
                                                if (([string]$cmapp.Type).Replace(" ","") -eq 'OperatingSystemImageId') {
                                                    try {
                                                        Remove-CMContentDistribution -DistributionPointName $DistributionPoint.NetworkOSPath.Replace("\\","") -OperatingSystemImageId $CMApp.PackageID -Force -Confirm:$false -ErrorAction Stop
                                                    }
                                                    catch {
                                                        Write-Output "Failed to remove $($CMApp.PackageID)from Distribution Point $($DistributionPoint.NetworkOSPath)"
                                                    }
                                                }
                                                if (([string]$cmapp.Type).Replace(" ","") -eq 'TaskSequenceID') {
                                                    try {
                                                        Remove-CMContentDistribution -DistributionPointName $DistributionPoint.NetworkOSPath.Replace("\\","") -TaskSequenceID $CMApp.PackageID -Force -Confirm:$false -ErrorAction Stop
                                                    }
                                                    catch {
                                                        Write-Output "Failed to remove $($CMApp.PackageID)from Distribution Point $($DistributionPoint.NetworkOSPath)"
                                                    }
                                                }
                                                if (([string]$cmapp.Type).Replace(" ","") -eq 'BootImageID') {
                                                    try {
                                                        Remove-CMContentDistribution -DistributionPointName $DistributionPoint.NetworkOSPath.Replace("\\","") -BootImageID $CMApp.PackageID -Force -Confirm:$false -ErrorAction Stop
                                                    }
                                                    catch {
                                                        Write-Output "Failed to remove $($CMApp.PackageID)from Distribution Point $($DistributionPoint.NetworkOSPath)"
                                                    }
                                                }
                                            }
                                            catch {
                                                Write-Output "$($Error[0].CategoryInfo.Reason)"    
                                            }
                                        }
                                    }
                                    if (1 -lt $CMApp.Count -and $Removed -ne 1) {
                                        foreach ($DistributionPoint in $DistributionPoints) {
                                            try {
                                                if (([string]$($CMApp[$ObjectNumber -1]).Type).Replace(" ","") -eq 'ApplicationID') {
                                                    try {
                                                        Remove-CMContentDistribution -DistributionPointName $DistributionPoint.Name -ApplicationId $($CMApp[$ObjectNumber -1].CI_ID) -Force -Confirm:$false -ErrorAction Stop
                                                        Write-Output "Removing $($CMApp[$ObjectNumber -1].LocalizedDisplayName) from $($DistributionPoint.Name)"
                                                    }
                                                    catch {
                                                        Write-Output "Failed to remove $($CMApp[$ObjectNumber -1].Name)from Distribution Point $($DistributionPoint.Name)"
                                                    }
                                                }
                                                if (([string]$($CMApp[$ObjectNumber -1]).Type).Replace(" ","") -eq 'PackageID') {
                                                    try {
                                            			Remove-CMContentDistribution -DistributionPointName $DistributionPoint.Name -PackageId $($CMApp[$ObjectNumber -1].PackageID) -Force -Confirm:$false -ErrorAction Stop
                                            			Write-Output "Removing $($CMApp[$ObjectNumber -1].PackageID) from $($DistributionPoint.Name)"
                                                    }
                                                    catch {
                                                        Write-Output "Failed to remove $($CMApp[$ObjectNumber -1].PackageID)from Distribution Point $($DistributionPoint.Name)"
                                                    }
                                                }
                                                if (([string]$($CMApp[$ObjectNumber -1]).Type).Replace(" ","") -eq 'DriverPackageId') {
                                                    try {
                                                        Remove-CMContentDistribution -DistributionPointName $DistributionPoint.Name -DriverPackageId $($CMApp[$ObjectNumber -1].PackageID) -Force -Confirm:$false -ErrorAction Stop
                                            			Write-Output "Removing $($CMApp[$ObjectNumber -1].PackageID) from $($DistributionPoint.Name.Name)"
                                                    }
                                                    catch {
                                                        Write-Output "Failed to remove $($CMApp[$ObjectNumber -1].PackageID) from Distribution Point $($DistributionPoint.Name.Name)"
                                                    }
                                                }
                                                if (([string]$CMApp[$ObjectNumber -1].Type).Replace(" ","") -eq 'OperatingSystemImageId') {
                                                    try {
                                                        Remove-CMContentDistribution -DistributionPointName $DistributionPoint.Name -OperatingSystemImageId $($CMApp[$ObjectNumber -1].PackageID) -Force -Confirm:$false -ErrorAction Stop
                                            			Write-Output "Removing $($CMApp[$ObjectNumber -1].PackageID) from $($DistributionPoint.Name)"
                                                    }
                                                    catch {
                                                        Write-Output "Failed to remove $($CMApp[$ObjectNumber -1].PackageID) from Distribution Point $($DstPointGroup.Name)"
                                                    }
                                                }
                                                if (([string]$($CMApp[$ObjectNumber -1]).Type).Replace(" ","") -eq 'TaskSequenceID') {
                                                    try {
                                                        Remove-CMContentDistribution -DistributionPointName $DistributionPoint.Name -TaskSequenceID $($CMApp[$ObjectNumber -1].PackageID) -Force -Confirm:$false -ErrorAction Stop
                                            			Write-Output "Removing $($CMApp[$ObjectNumber -1].PackageID) from $($DistributionPoint.Name)"
                                                    }
                                                    catch {
                                                        Write-Output "Failed to remove $($CMApp[$ObjectNumber -1].PackageID)from Distribution Point $($DistributionPoint.Name)"
                                                    }
                                                }
                                                if (([string]$($CMApp[$ObjectNumber -1]).Type).Replace(" ","") -eq 'BootImageID') {
                                                    try {
                                                        Remove-CMContentDistribution -DistributionPointName $DistributionPoint.Name -BootImageID $($CMApp[$ObjectNumber -1].PackageID) -Force -Confirm:$false -ErrorAction Stop
                                            			Write-Output "Removing $($CMApp[$ObjectNumber -1].PackageID) from $($DistributionPoint.Name)"
                                                    }
                                                    catch {
                                                        Write-Output "Failed to remove $($CMApp[$ObjectNumber -1].PackageID) from Distribution Point $($DistributionPoint.Name)"
                                                    }
                                                }
                                            }

                                            catch {
                                                Write-Output "$($Error[0].CategoryInfo.Reason)"    
                                            }
                                        }
                                        #foreach ($DistributionPoint in $DistributionPoints) {
                                            #try {
                                            #    Remove-CMContentDistribution -DistributionPointName $DistributionPoint.NetworkOSPath.Replace("\\","") -ApplicationName $($CMApp[$ObjectNumber -1].LocalizedDisplayName) -Force -Confirm:$false -ErrorAction SilentlyContinue
                                            #    Write-Output "Removing $($CMApp[$ObjectNumber -1].LocalizedDisplayName) from $($distributionpoint.NetworkOSPath)"
                                            #     
                                            #}
                                            #catch {
                                            #    if ($null -eq $SuccessApp) {
                                            #        Remove-CMContentDistribution -DistributionPointName $DistributionPoint.NetworkOSPath.Replace("\\","") -PackageId $($CMApp[$ObjectNumber -1].PackageID) -Force -Confirm:$false -ErrorAction SilentlyContinue
                                            #        Write-Output "Removing $($CMApp.LocalizedDisplayName) from $($distributionpoint.NetworkOSPath)"
                                            #    }
                                            #}
                                            #Write-Output "Removing $($CMApp[$ObjectNumber -1].LocalizedDisplayName) from $($distributionpoint.NetworkOSPath)"
                                        #}
                                    }
                                }
                                catch {
                                    Write-Output "Unable to remove $($CMApp[$ObjectNumber -1].LocalizedDisplayName) - $($Error[0].CategoryInfo) - $($Error[0].InvocationInfo.Line)"
                                }
                            }
                            if ($DistributionPointGroup.count -eq 1) {
                                try {
                                    if (1 -eq $CMApp.Count) {
                                            ## If Distribution is Application - Using Name because SQLMessage = SQL Server Conversion failed when converting the nvarchar value PackageID (example X0100001) to data type int.
                                            if (([string]$($CMApp.Type).Replace(" ","") -eq 'ApplicationID')) {
                                                try {
                                                    Remove-CMContentDistribution -DistributionPointGroupName $DistributionPointGroup.Name -ApplicationName $($CMApp.CI_ID) -Force -Confirm:$false -ErrorAction Stop
                                                    Write-Output "Removing $($CMApp.LocalizedDisplayName) from $($DistributionPointGroup.Name)"
                                                    $Removed = 1
                                                }
                                                catch {
                                                    Write-Output "Failed to remove $($CMApp.LocalizedDisplayName) from Distribution Point $($DstPointGroup.Name)"
                                                }
                                            }
                                            if (([string]$($CMApp.Type).Replace(" ","") -eq 'PackageID')) {
                                                try {
                                                    Remove-CMContentDistribution -DistributionPointGroupName $DistributionPointGroup.Name -PackageId $($CMApp.PackageID) -Force -Confirm:$false -ErrorAction Stop
                                                    Write-Output "Removing $($CMApp.LocalizedDisplayName) from $($DistributionPointGroup.Name)"
                                                    $Removed = 1
                                                }
                                                catch {
                                                    Write-Output "Failed to remove $($CMApp.LocalizedDisplayName) from Distribution Point $($DstPointGroup.Name)"
                                                }
                                            }
                                            if (([string]$($CMApp.Type).Replace(" ","") -eq 'DriverPackageId')) {
                                                try {
                                                    Remove-CMContentDistribution -DistributionPointGroupName $DistributionPointGroup.Name -DriverPackageId $($CMApp.PackageID) -Force -Confirm:$false -ErrorAction Stop
                                                    Write-Output "Removing $($CMApp.LocalizedDisplayName) from $($DistributionPointGroup.Name)"
                                                    $Removed = 1
                                                }
                                                catch {
                                                    Write-Output "Failed to remove $($CMApp.LocalizedDisplayName) from Distribution Point $($DstPointGroup.Name)"
                                                }
                                            }
                                            if (([string]$($CMApp.Type).Replace(" ","") -eq 'OperatingSystemImageId')) {
                                                try {
                                                    Remove-CMContentDistribution -DistributionPointGroupName $DistributionPointGroup.Name -OperatingSystemImageId $($CMApp.PackageID) -Force -Confirm:$false -ErrorAction Stop
                                                    Write-Output "Removing $($CMApp.LocalizedDisplayName) from $($DistributionPointGroup.Name)"
                                                    $Removed = 1
                                                }
                                                catch {
                                                    Write-Output "Failed to remove $($CMApp.LocalizedDisplayName) from Distribution Point $($DstPointGroup.Name)"
                                                }
                                            }
                                            if (([string]$($CMApp.Type).Replace(" ","") -eq 'TaskSequenceID')) {
                                                try {
                                                    Remove-CMContentDistribution -DistributionPointGroupName $DistributionPointGroup.Name -TaskSequenceID $($CMApp.PackageID) -Force -Confirm:$false -ErrorAction Stop
                                                    Write-Output "Removing $($CMApp.LocalizedDisplayName) from $($DistributionPointGroup.Name)"
                                                    $Removed = 1
                                                }
                                                catch {
                                                    Write-Output "Failed to remove $($CMApp.LocalizedDisplayName) from Distribution Point $($DstPointGroup.Name)"
                                                }
                                            }
                                            if (([string]$($CMApp.Type).Replace(" ","") -eq 'BootImageID')) {
                                                try {
                                                    Remove-CMContentDistribution -DistributionPointGroupName $DistributionPointGroup.Name -BootImageID $($CMApp.PackageID) -Force -Confirm:$false -ErrorAction Stop
                                                    Write-Output "Removing $($CMApp.LocalizedDisplayName) from $($DistributionPointGroup.Name)"
                                                    $Removed = 1
                                                }
                                                catch {
                                                    Write-Output "Failed to remove $($CMApp.LocalizedDisplayName) from Distribution Point $($DstPointGroup.Name)"
                                                }
                                            }
                                            
                                            catch {
                                                Write-Output "$($Error[0].CategoryInfo.Reason)"    
                                            }

                                        }
                                    if (1 -lt $CMApp.Count) {
                                        # If Distribution is Application
                                        try {
                                            if (([string]$($CMApp[$ObjectNumber -1]).Type).Replace(" ","") -eq 'ApplicationID') {
                                                try {
                                                    Remove-CMContentDistribution -DistributionPointGroupName $DistributionPointGroup.Name -ApplicationId $($CMApp[$ObjectNumber -1].CI_ID) -Force -Confirm:$false -ErrorAction Stop
                                                    Write-Output "Removing $($CMApp[$ObjectNumber -1].LocalizedDisplayName) from $($DistributionPointGroup.Name)"
                                                    $Removed = 1
                                                }
                                                catch {
                                                    Write-Output "Failed to remove $($CMApp[$ObjectNumber -1].LocalizedDisplayName) from Distribution Point $($DistributionPointGroup.Name)"
                                                }
                                            }
                                            if (([string]$($CMApp[$ObjectNumber -1]).Type).Replace(" ","") -eq 'PackageID') {
                                                try {
                                        			Remove-CMContentDistribution -DistributionPointGroupName $DistributionPointGroup.Name -PackageId $($CMApp[$ObjectNumber -1].PackageID) -Force -Confirm:$false -ErrorAction Stop
                                        			Write-Output "Removing $($CMApp[$ObjectNumber -1].PackageID) from $($DistributionPointGroup.Name)"
                                                    $Removed = 1
                                                }
                                                catch {
                                                    Write-Output "Failed to remove $($CMApp[$ObjectNumber -1].PackageID) from Distribution Point $($DistributionPointGroup.Name)"
                                                }
                                            }
                                            if (([string]$($CMApp[$ObjectNumber -1]).Type).Replace(" ","") -eq 'DriverPackageId') {
                                                try {
                                                    Remove-CMContentDistribution -DistributionPointGroupName $DistributionPointGroup.Name -DriverPackageId $($CMApp[$ObjectNumber -1].PackageID) -Force -Confirm:$false -ErrorAction Stop
                                        			Write-Output "Removing $($CMApp[$ObjectNumber -1].PackageID) from $($DistributionPointGroup.Name)"
                                                    $Removed = 1
                                                }
                                                catch {
                                                    Write-Output "Failed to remove $($CMApp.PackageID)from Distribution Point $($DistributionPointGroup.Name)"
                                                }
                                            }
                                            if (([string]$CMApp[$ObjectNumber -1].Type).Replace(" ","") -eq 'OperatingSystemImageId') {
                                                try {
                                                    Remove-CMContentDistribution -DistributionPointGroupName $DistributionPointGroup.Name -OperatingSystemImageId $($CMApp[$ObjectNumber -1].PackageID) -Force -Confirm:$false -ErrorAction Stop
                                        			Write-Output "Removing $($CMApp.PackageID) from $($DistributionPointGroup.Name)"
                                                    $Removed = 1
                                                }
                                                catch {
                                                    Write-Output "Failed to remove $($CMApp[$ObjectNumber -1].PackageID) from Distribution Point $($DistributionPointGroup.Name)"
                                                }
                                            }
                                            if (([string]$($CMApp[$ObjectNumber -1]).Type).Replace(" ","") -eq 'TaskSequenceID') {
                                                try {
                                                    Remove-CMContentDistribution -DistributionPointGroupName $DistributionPointGroup.Name -TaskSequenceID $($CMApp[$ObjectNumber -1].PackageID) -Force -Confirm:$false -ErrorAction Stop
                                        			Write-Output "Removing $($CMApp[$ObjectNumber -1].PackageID) from $($DistributionPointGroup.Name)"
                                                    $Removed = 1
                                                }
                                                catch {
                                                    Write-Output "Failed to remove $($CMApp[$ObjectNumber -1].PackageID)from Distribution Point $($DistributionPointGroup.Name)"
                                                }
                                            }
                                            if (([string]$($CMApp[$ObjectNumber -1]).Type).Replace(" ","") -eq 'BootImageID') {
                                                try {
                                                    Remove-CMContentDistribution -DistributionPointGroupName $DistributionPointGroup.Name -BootImageID $($CMApp[$ObjectNumber -1].PackageID) -Force -Confirm:$false -ErrorAction Stop
                                        			Write-Output "Removing $($CMApp[$ObjectNumber -1].PackageID) from $($DistributionPointGroup.Name)"
                                                    $Removed = 1
                                                }
                                                catch {
                                                    Write-Output "Failed to remove $($CMApp[$ObjectNumber -1].PackageID) from Distribution Point $($DistributionPointGroup.Name)"
                                                }
                                            }
                                        }
                                        catch {
                                            Write-Output "$($Error[0].CategoryInfo.Reason)" 
                                        }
                                    }
                                }
                                catch {
                                    Write-Output "$($Error[0].CategoryInfo.Reason)"
                                }
                            }
                            if ($true -eq $DistributionPoints -and $Removed -ne 1) {
                                try {
                                    foreach ($DistributionPoint in $DistributionPoints) {
                                        try {
                                            if (1 -eq $CMApp.Count) {
                                                if (([string]$CMApp.Type).Replace(" ","") -eq 'ApplicationID') {
                                                    try {
                                                        Remove-CMContentDistribution -DistributionPointName $($DistributionPoint.NetworkOSPath -replace '\\','') -ApplicationId $CMApp.CI_ID -Force -Confirm:$false -ErrorAction Stop
                                                        Write-Output "Removing $($CMApp.LocalizedDisplayName) from $($DistributionPoint.NetworkOSPath -replace '\\','')"
                                                    }
                                                    catch {
                                                        Write-Output "Failed to remove $($CMApp.PackageID) from Distribution Point $($DistributionPoint.NetworkOSPath -replace '\\','')"
                                                    }
                                                }
                                                if (([string]$cmapp.Type).Replace(" ","") -eq 'PackageID') {
                                                    try {
                                                        Remove-CMContentDistribution -DistributionPointName $($DistributionPoint.NetworkOSPath -replace '\\','') -PackageId $CMApp.PackageID -Force -Confirm:$false -ErrorAction Stop
                                        	    		Write-Output "Removing $($CMApp.PackageID) from $($DistributionPoint.NetworkOSPath -replace '\\','')"
                                                    }
                                                    catch {
                                                        Write-Output "Failed to remove $($CMApp.PackageID) from Distribution Point $($DistributionPoint.NetworkOSPath -replace '\\','')"
                                                    }
                                                }
                                                if (([string]$cmapp.Type).Replace(" ","") -eq 'DriverPackageId') {
                                                    try {
                                                        Remove-CMContentDistribution -DistributionPointName $($DistributionPoint.NetworkOSPath -replace '\\','') -DriverPackageId $CMApp.PackageID -Force -Confirm:$false -ErrorAction Stop
                                        	    		Write-Output "Removing $($CMApp.PackageID) from $($DistributionPoint.NetworkOSPath -replace '\\','')"
                                                    }
                                                    catch {
                                                        Write-Output "Failed to remove $($CMApp.PackageID) from Distribution Point $($DistributionPoint.NetworkOSPath -replace '\\','')"
                                                    }
                                                }
                                                if (([string]$cmapp.Type).Replace(" ","") -eq 'OperatingSystemImageId') {
                                                    try {
                                                        Remove-CMContentDistribution -DistributionPointName $($DistributionPoint.NetworkOSPath -replace '\\','') -OperatingSystemImageId $CMApp.PackageID -Force -Confirm:$false -ErrorAction Stop
                                        		    	Write-Output "Removing $($CMApp.PackageID) from $($DistributionPoint.NetworkOSPath -replace '\\','')"
                                                    }
                                                    catch {
                                                        Write-Output "Failed to remove $($CMApp.PackageID) from Distribution Point $($DistributionPoint.NetworkOSPath -replace '\\','')"
                                                    }
                                                }
                                                if (([string]$cmapp.Type).Replace(" ","") -eq 'TaskSequenceID') {
                                                    try {
                                                        Remove-CMContentDistribution -DistributionPointName $($DistributionPoint.NetworkOSPath -replace '\\','') -TaskSequenceID $CMApp.PackageID -Force -Confirm:$false -ErrorAction Stop
                                        		    	Write-Output "Removing $($CMApp.PackageID) from $($DistributionPoint.NetworkOSPath -replace '\\','')"
                                                    }
                                                    catch {
                                                        Write-Output "Failed to remove $($CMApp.PackageID) from Distribution Point $($DistributionPoint.NetworkOSPath -replace '\\','')"
                                                    }
                                                }
                                                if (([string]$cmapp.Type).Replace(" ","") -eq 'BootImageID') {
                                                    try {
                                                        Remove-CMContentDistribution -DistributionPointName $($DistributionPoint.NetworkOSPath -replace '\\','') -BootImageID $CMApp.PackageID -Force -Confirm:$false -ErrorAction Stop
                                        		    	Write-Output "Removing $($CMApp.PackageID) from $($DistributionPoint.NetworkOSPath -replace '\\','')"
                                                    }
                                                    catch {
                                                        Write-Output "Failed to remove $($CMApp.PackageID) from Distribution Point $($DistributionPoint.NetworkOSPath -replace '\\','')"
                                                    }
                                                }
                                            }
                                            if (1 -lt $CMApp.Count) {
                                                if (([string]$($CMApp[$ObjectNumber -1].Type)).Replace(" ","") -eq 'ApplicationID') {
                                                    try {
                                                        Remove-CMContentDistribution -DistributionPointName $($DistributionPoint.NetworkOSPath -replace '\\','') -ApplicationId $($CMApp[$ObjectNumber -1].CI_ID) -Force -Confirm:$false -ErrorAction Stop
                                                        Write-Output "Removing $($CMApp[$ObjectNumber -1].LocalizedDisplayName) from $($DistributionPoint.NetworkOSPath -replace '\\','')"
                                                    }
                                                    catch {
                                                        Write-Output "Failed to remove $($CMApp[$ObjectNumber -1].PackageID) from Distribution Point $($DistributionPoint.NetworkOSPath -replace '\\','')"
                                                    }
                                                }
                                                if (([string]$($CMApp[$ObjectNumber -1].Type)).Replace(" ","") -eq 'PackageID') {
                                                    try {
                                                        Remove-CMContentDistribution -DistributionPointName $($DistributionPoint.NetworkOSPath -replace '\\','') -PackageId $($CMApp[$ObjectNumber -1].PackageID) -Force -Confirm:$false -ErrorAction Stop
                                        		    	Write-Output "Removing $($CMApp[$ObjectNumber -1].PackageID) from $($DistributionPoint.NetworkOSPath -replace '\\','')"
                                                    }
                                                    catch {
                                                        Write-Output "Failed to remove $($CMApp[$ObjectNumber -1].PackageID) from Distribution Point $($DistributionPoint.NetworkOSPath -replace '\\','')"
                                                    }
                                                }
                                                if (([string]$($CMApp[$ObjectNumber -1].Type)).Replace(" ","") -eq 'DriverPackageId') {
                                                    try {
                                                        Remove-CMContentDistribution -DistributionPointName $($DistributionPoint.NetworkOSPath -replace '\\','') -DriverPackageId $($CMApp[$ObjectNumber -1].PackageID) -Force -Confirm:$false -ErrorAction Stop
                                        		    	Write-Output "Removing $($CMApp[$ObjectNumber -1].PackageID) from $($DistributionPoint.NetworkOSPath -replace '\\','')"
                                                    }
                                                    catch {
                                                        Write-Output "Failed to remove $($CMApp[$ObjectNumber -1].PackageID) from Distribution Point $($DistributionPoint.NetworkOSPath -replace '\\','')"
                                                    }
                                                }
                                                if (([string]$($CMApp[$ObjectNumber -1].Type)).Replace(" ","") -eq 'OperatingSystemImageId') {
                                                    try {
                                                        Remove-CMContentDistribution -DistributionPointName $($DistributionPoint.NetworkOSPath -replace '\\','') -OperatingSystemImageId $($CMApp[$ObjectNumber -1].PackageID) -Force -Confirm:$false -ErrorAction Stop
                                        		    	Write-Output "Removing $($CMApp[$ObjectNumber -1].PackageID) from $($DistributionPoint.NetworkOSPath -replace '\\','')"
                                                    }
                                                    catch {
                                                        Write-Output "Failed to remove $($CMApp[$ObjectNumber -1].PackageID) from Distribution Point $($DistributionPoint.NetworkOSPath -replace '\\','')"
                                                    }
                                                }
                                                if (([string]$($CMApp[$ObjectNumber -1].Type)).Replace(" ","") -eq 'TaskSequenceID') {
                                                    try {
                                                        Remove-CMContentDistribution -DistributionPointName $($DistributionPoint.NetworkOSPath -replace '\\','') -TaskSequenceID $($CMApp[$ObjectNumber -1].PackageID) -Force -Confirm:$false -ErrorAction Stop
                                        		    	Write-Output "Removing $($CMApp[$ObjectNumber -1].PackageID) from $($DistributionPoint.NetworkOSPath -replace '\\','')"
                                                    }
                                                    catch {
                                                        Write-Output "Failed to remove $($CMApp[$ObjectNumber -1].PackageID) from Distribution Point $($DistributionPoint.NetworkOSPath -replace '\\','')"
                                                    }
                                                }
                                                if (([string]$($CMApp[$ObjectNumber -1].Type)).Replace(" ","") -eq 'BootImageID') {
                                                    try {
                                                        Remove-CMContentDistribution -DistributionPointName $($DistributionPoint.NetworkOSPath -replace '\\','') -BootImageID $($CMApp[$ObjectNumber -1].PackageID) -Force -Confirm:$false -ErrorAction Stop
                                        		    	Write-Output "Removing $($CMApp[$ObjectNumber -1].PackageID) from $($DistributionPoint.NetworkOSPath -replace '\\','')"
                                                    }
                                                    catch {
                                                        Write-Output "Failed to remove $($CMApp[$ObjectNumber -1].PackageID) from Distribution Point $($DistributionPoint.NetworkOSPath -replace '\\','')"
                                                    }
                                                }
                                            }
                                        }
                                        catch {
                                            if ("$($CMApp[$ObjectNumber -1].LocalizedDisplayName)" -eq '') {
                                                Write-Output "Unable to remove $($CMApp[$ObjectNumber -1].Name) from Distribution Point(s)"
                                            }
                                            if ("$($CMApp[$ObjectNumber -1].LocalizedDisplayName)" -ne '') {
                                                Write-Output "Unable to remove $($CMApp[$ObjectNumber -1].LocalizedDisplayName) from Distribution Point(s)"
                                            }
                                        }
                                    }
                                }
                                catch {
                                    Write-Output "Unable to remove $($CMApp[$ObjectNumber -1].Name) - $($Error[0].CategoryInfo) - $($Error[0].InvocationInfo.Line)"
                                }
                            }
                        }
                        else {
                            Write-Output "No distribution was found with $($CMApp.Name)"
                        }
                    }
                    else {
                        Write-Output 'Did not find either Distribution Points or Distribution Point Groups - Exiting Script'
                        Start-Sleep -Seconds 3
                        Break
                    }
                }
                if ('N' -eq $Confirm) {
                    Write-Output "This was incorrect. Exiting script."
                    Start-Sleep -Seconds 3
                    Break
                }
            }
        }

        if ($true -eq $PackageID) {
            $CMApp = @()
            try {
                # CMApplication cannot handle PackageID, hence the Where-Object filtering
                $CMApp += Get-CMApplication | Where-Object {$_.PackageID -eq $PackageID} -ErrorAction Continue 
                $CmApp += Get-CMPackage -Id "$PackageID" -ErrorAction Continue
                $CMApp += Get-CMSoftwareUpdateDeploymentPackage -Id "$PackageID" -ErrorAction Continue
                $CMApp += Get-CMOperatingSystemImage -Id "$PackageID" -ErrorAction Continue
                $CMApp += Get-CMTaskSequenceDeployment -TaskSequenceId "$PackageID" -ErrorAction Stop
            }
            catch {
                Write-Output "Invalid PackageID - Exiting script"
                Start-Sleep -Seconds 3
                Break
            }
            ## If there are distribution point group(s), content will firstly be removed from them
            if (($true -eq $DistributionPointGroup) -or ($true -eq $DistributionPoints)) {
                ## Verify that the content is distributed
                if (0 -lt (Get-CMDistributionStatus -Id $PackageID).Targeted) {
                    Write-Output "Found distributed content with the name $($CMApp.Name) - This distribution will be removed"
                    do {
                        $Confirm = Read-Host "Is this correct? Y/N"
                    }
                    until ($Confirm -eq 'Y' -or 'N') 
                    if ('Y' -eq $Confirm) {
                        try {
                            if (1 -lt $DistributionPointGroup.count) {
                                foreach ($DstPointGroup in $DistributionPointGroup) {
                                    try {
                                        if (([string]$CMApp.Type).Replace(" ","") -eq 'ApplicationID') {
                                            try {
                                                Remove-CMContentDistribution -DistributionPointGroupName $DstPointGroup.Name -ApplicationId $($CMApp.CI_ID) -Force -Confirm:$false -ErrorAction Stop
                                                Write-Output "Removing $($CMApp.LocalizedDisplayName) from $($DstPointGroup.Name)"
                                            }
                                            catch {
                                                Write-Output "Failed to remove $($CMApp.PackageID) from Distribution Point $($DstPointGroup.Name)"
                                            }
                                        }
                                        if (([string]$cmapp.Type).Replace(" ","") -eq 'PackageID') {
                                            try {
                                                Remove-CMContentDistribution -DistributionPointGroupName $DstPointGroup.Name -PackageId $CMApp.PackageID -Force -Confirm:$false -ErrorAction Stop
                                    			Write-Output "Removing $($CMApp.PackageID) from $($DstPointGroup.Name)"
                                            }
                                            catch {
                                                Write-Output "Failed to remove $($CMApp.PackageID) from Distribution Point $($DstPointGroup.Name)"
                                            }
                                        }
                                        if (([string]$cmapp.Type).Replace(" ","") -eq 'DriverPackageId') {
                                            try {
                                                Remove-CMContentDistribution -DistributionPointGroupName $DstPointGroup.Name -DriverPackageId $CMApp.PackageID -Force -Confirm:$false -ErrorAction Stop
                                    			Write-Output "Removing $($CMApp.PackageID) from $($DstPointGroup.Name)"
                                            }
                                            catch {
                                                Write-Output "Failed to remove $($CMApp.PackageID) from Distribution Point $($DstPointGroup.Name)"
                                            }
                                        }
                                        if (([string]$cmapp.Type).Replace(" ","") -eq 'OperatingSystemImageId') {
                                            try {
                                                Remove-CMContentDistribution -DistributionPointGroupName $DstPointGroup.Name -OperatingSystemImageId $CMApp.PackageID -Force -Confirm:$false -ErrorAction Stop
                                    			Write-Output "Removing $($CMApp.PackageID) from $($DstPointGroup.Name)"
                                            }
                                            catch {
                                                Write-Output "Failed to remove $($CMApp.PackageID) from Distribution Point $($DstPointGroup.Name)"
                                            }
                                        }
                                        if (([string]$cmapp.Type).Replace(" ","") -eq 'TaskSequenceID') {
                                            try {
                                                Remove-CMContentDistribution -DistributionPointGroupName $DstPointGroup.Name -TaskSequenceID $CMApp.PackageID -Force -Confirm:$false -ErrorAction Stop
                                    			Write-Output "Removing $($CMApp.PackageID) from $($DstPointGroup.Name)"
                                            }
                                            catch {
                                                Write-Output "Failed to remove $($CMApp.PackageID) from Distribution Point $($DstPointGroup.Name)"
                                            }
                                        }
                                        if (([string]$cmapp.Type).Replace(" ","") -eq 'BootImageID') {
                                            try {
                                                Remove-CMContentDistribution -DistributionPointGroupName $DstPointGroup.Name -BootImageID $CMApp.PackageID -Force -Confirm:$false -ErrorAction Stop
                                    			Write-Output "Removing $($CMApp.PackageID) from $($DstPointGroup.Name)"
                                            }
                                            catch {
                                                Write-Output "Failed to remove $($CMApp.PackageID) from Distribution Point $($DstPointGroup.Name)"
                                            }
                                        }
                                    }
                                    catch {
                                        Write-Output "$($Error[0].CategoryInfo.Reason)"    
                                    }
                                }
                            }
                        }
                        catch {
                            if ("$($CMApp[$ObjectNumber -1].LocalizedDisplayName)" -eq '') {
                                Write-Output "Unable to remove $($CMApp[$ObjectNumber -1].Name) from Distribution Point Group"
                            }
                            if ("$($CMApp[$ObjectNumber -1].LocalizedDisplayName)" -ne '') {
                                Write-Output "Unable to remove $($CMApp[$ObjectNumber -1].LocalizedDisplayName) from Distribution Point Group"
                            }
                        }
                        try {
                            foreach ($DistributionPoint in $DistributionPoints) {
                                try {
                                    if (([string]$CMApp.Type).Replace(" ","") -eq 'ApplicationID') {
                                        try {
                                            Remove-CMContentDistribution -DistributionPointName $DistributionPoint.Name -ApplicationId $CMApp.CI_ID -Force -Confirm:$false -ErrorAction Stop
                                            Write-Output "Removing $($CMApp.LocalizedDisplayName) from $($DistributionPoint.Name)"
                                        }
                                        catch {
                                            Write-Output "Failed to remove $($CMApp.PackageID)from Distribution Point $($DistributionPoint.Name)"
                                        }
                                    }
                                    if (([string]$cmapp.Type).Replace(" ","") -eq 'PackageID') {
                                        try {
                                            Remove-CMContentDistribution -DistributionPointName $DistributionPoint.Name -PackageId $CMApp.PackageID -Force -Confirm:$false -ErrorAction Stop
                                			Write-Output "Removing $($CMApp.PackageID) from $($DistributionPoint.Name)"
                                        }
                                        catch {
                                            Write-Output "Failed to remove $($CMApp.PackageID)from Distribution Point $($DistributionPoint.Name)"
                                        }
                                    }
                                    if (([string]$cmapp.Type).Replace(" ","") -eq 'DriverPackageId') {
                                        try {
                                            Remove-CMContentDistribution -DistributionPointName $DistributionPoint.Name -DriverPackageId $CMApp.PackageID -Force -Confirm:$false -ErrorAction Stop
                                			Write-Output "Removing $($CMApp.PackageID) from $($DistributionPoint.Name)"
                                        }
                                        catch {
                                            Write-Output "Failed to remove $($CMApp.PackageID)from Distribution Point $($DistributionPoint.Name)"
                                        }
                                    }
                                    if (([string]$cmapp.Type).Replace(" ","") -eq 'OperatingSystemImageId') {
                                        try {
                                            Remove-CMContentDistribution -DistributionPointName $DistributionPoint.Name -OperatingSystemImageId $CMApp.PackageID -Force -Confirm:$false -ErrorAction Stop
                                			Write-Output "Removing $($CMApp.PackageID) from $($DistributionPoint.Name)"
                                        }
                                        catch {
                                            Write-Output "Failed to remove $($CMApp.PackageID)from Distribution Point $($DistributionPoint.Name)"
                                        }
                                    }
                                    if (([string]$cmapp.Type).Replace(" ","") -eq 'TaskSequenceID') {
                                        try {
                                            Remove-CMContentDistribution -DistributionPointName $DistributionPoint.Name -TaskSequenceID $CMApp.PackageID -Force -Confirm:$false -ErrorAction Stop
                                			Write-Output "Removing $($CMApp.PackageID) from $($DistributionPoint.Name)"
                                        }
                                        catch {
                                            Write-Output "Failed to remove $($CMApp.PackageID)from Distribution Point $($DistributionPoint.Name)"
                                        }
                                    }
                                    if (([string]$cmapp.Type).Replace(" ","") -eq 'BootImageID') {
                                        try {
                                            Remove-CMContentDistribution -DistributionPointName $DistributionPoint.Name -BootImageID $CMApp.PackageID -Force -Confirm:$false -ErrorAction Stop
                                			Write-Output "Removing $($CMApp.PackageID) from $($DistributionPoint.Name)"
                                        }
                                        catch {
                                            Write-Output "Failed to remove $($CMApp.PackageID)from Distribution Point $($DistributionPoint.Name)"
                                        }
                                    }
                                }
                                catch {
                                    if ("$($CMApp[$ObjectNumber -1].LocalizedDisplayName)" -eq '') {
                                        Write-Output "Unable to remove $($CMApp[$ObjectNumber -1].Name) from Distribution Point(s)"
                                    }
                                    if ("$($CMApp[$ObjectNumber -1].LocalizedDisplayName)" -ne '') {
                                        Write-Output "Unable to remove $($CMApp[$ObjectNumber -1].LocalizedDisplayName) from Distribution Point(s)"
                                    }
                                }
                            }
                        }
                        catch {
                            Write-Output "Unable to remove $($CMApp[$ObjectNumber -1].Name) - $($Error[0].CategoryInfo) - $($Error[0].InvocationInfo.Line)"
                        }
                    }
                    if ('N' -eq $Confirm) {
                        Write-Output 'This was not correct - Exiting script'
                        Start-Sleep -Seconds 3
                        Break
                    } 
                }
            }
            else {
                Write-Output 'Neither Distribution Points or Distribution Point Groups found - Exiting script'
                Start-Sleep -Seconds 3
                Break
            }
        }
    }

    ## End of the script
    End {
        Write-Output "Finished - Exiting script" 
    }
}