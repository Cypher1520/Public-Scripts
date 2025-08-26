<# VS Code Shortcuts
Collapse All: Ctrl+K CTRL+0
Expand All: Ctrl+K CTRL+J
#>

#-----------get content location for all apps-----------
    Get-CMApplication | Get-CMDeploymentType | ForEach-Object {
        $xml = [xml]$_.SDMPackageXML; $xml.AppMgmtDigest.DeploymentType.Installer.Contents.Content.Location
    }
#-----------Remove an app-----------
    #Get App Info
    $App = Read-Host Enter App Name
    $Application = Get-CMApplication -Name $App
    $AppMgmt = ([xml]$Application.SDMPackageXML).AppMgmtDigest
    $AppName = $AppMgmt.Application.DisplayInfo.FirstChild.Title

        foreach ($DeploymentType in $AppMgmt.DeploymentType) 
        {
            # Fill properties
            $AppData = @{            
                AppName            = $AppName
                Location           = $DeploymentType.Installer.Contents.Content.Location
                DeploymentTypeName = $DeploymentType.Title.InnerText
                Technology         = $DeploymentType.Installer.Technology
                ContentId          = $DeploymentType.Installer.Contents.Content.ContentId
                }                           

            # Create object
            $Object = New-Object PSObject -Property $AppData
        
            # Return it
            $Object
        }

    #Deleting App
            Write-Host "Would you like to remove the following app from SCCM?" -ForegroundColor Red
            Write-Host $Application.LocalizedDisplayName -ForegroundColor Cyan
            Write-Host 'Y/N' -ForegroundColor Red
            $RemoveApp = Read-host
                If ($RemoveApp -eq "y")
                {
                    Get-CMApplication -Name $Application.LocalizedDisplayName | Remove-CMApplication -Force
                }
                
    #Removing the Content folder from DML
        $targ = "filesystem::$($DeploymentType.Installer.Contents.Content.Location)"
        $test = Test-Path $targ
        If ($test -eq $True)
        {
            Write-Host 'Would you like to delete the following folder?' -ForegroundColor Red
            Write-Host ($DeploymentType.Installer.Contents.Content.Location) -ForegroundColor Cyan
            Write-Host ' Y/N' -ForegroundColor Red
            $DeleteFolder = Read-Host
                If ($DeleteFolder -eq "Y")
                {
                    Remove-Item $targ -Recurse
                }
        }

        Else
        {
            Write-Host 'Folder does not exist' -ForegroundColor Green
        }

    #Deletion test        
        $test = Test-Path $targ
        If ($test -eq $False)
        {
            Write-Host "Folder is deleted" -ForegroundColor Green
        }
        Else
        {
            Write-Host "Folder not deleted, check file path" $DeploymentType.Installer.Contents.Content.Location -ForegroundColor Red
        }