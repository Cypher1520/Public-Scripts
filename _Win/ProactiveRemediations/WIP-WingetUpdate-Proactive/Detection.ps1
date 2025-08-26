<#
Software Detection Script to see if software needs an update
Author: Chris Rockwell | chris@r-is.tech | chris.rockwell@insight.com
#>

#Help System to find winget.exe

#Variables

#Check locally installed software version
$Available = (winget.exe update --include-unknown)[-1]

#Check if needs update
if ($Available.contains("upgrades available")) {
    write-host "Updates availabe"
    exit 1
}

else {
    exit 0
}