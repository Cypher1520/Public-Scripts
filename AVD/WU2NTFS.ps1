<#
\\avdprdarmstauw2065.file.core.windows.net\fslogixavdfme
#>

$oldPath = Read-Host Where to copy NTFS Permissions from
$newPath = Read-Host Where to copy NTFS Permissions to

#Create Folders
New-Item -Path "$newPath\O365" -ItemType "Directory"
New-Item -Path "$newPath\Profiles" -ItemType "Directory"

# Copy NTFS permissions to new fileshare.
$Acl = Get-Acl -Path $oldPath
Set-Acl -AclObject $Acl -Path $newPath

$Acl2 = Get-Acl -Path "$oldPath\O365"
Set-Acl -AclObject $Acl2 -Path "$newPath\O365"

$Acl3 = Get-Acl -Path "$oldPath\Profiles"
Set-Acl -AclObject $Acl3 -Path "$newPath\Profiles"