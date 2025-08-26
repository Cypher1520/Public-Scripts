# Retrieve all GPOs (not all GPO Reports!)
$AllGpos = Get-GPO -All
# Create a custom object holding all the GPOs and their links (separate for each distinct OU)
$GpoLinks = foreach ($g in $AllGpos){
        [xml]$Gpo = Get-GPOReport -ReportType Xml -Guid $g.Id
        foreach ($i in $Gpo.GPO.LinksTo) {
                [PSCustomObject]@{
                "Name" = $Gpo.GPO.Name
                "Link" = $i.SOMPath
                "Link Enabled" = $i.Enabled
                }
            }
        }
# Creates a variable targetting the specific OU's
$mtlcomp = $GpoLinks | Where {$_.Link -eq "dwpv.com/DWPV/Montreal/Computers"}
$mtluser = $GpoLinks | Where {$_.Link -eq "dwpv.com/DWPV/Montreal/Users-Autopilot"}
$nycomp = $GpoLinks | Where {$_.Link -eq "dwpv.com/DWPV/New York/Computers-Autopilot"}
$nyuser = $GpoLinks | Where {$_.Link -eq "dwpv.com/DWPV/New York/Users-Autopilot"}
$torcomp = $GpoLinks | Where {$_.Link -eq "dwpv.com/DWPV/Toronto/Computers-Autopilot"}
$toruser = $GpoLinks | Where {$_.Link -eq "dwpv.com/DWPV/Toronto/Users-Autopilot"}

# OU1
Foreach ($mc in $mtlcomp){
$name = $mc.name
Get-GPOReport -ReportType Xml -Name $name -Path "C:\Temp\GPOs\MTLComp\$name.xml"
}
# OU2
Foreach ($mu in $mtluser){
$name = $mu.name
Get-GPOReport -ReportType Xml -Name $name -Path "C:\Temp\GPOs\MTLUser\$name.xml"
}
# OU3
Foreach ($nc in $nycomp){
$name = $nc.name
Get-GPOReport -ReportType Xml -Name $name -Path "C:\Temp\GPOs\NYCComp\$name.xml"
}
# OU4
Foreach ($nu in $nyuser){
$name = $nu.name
Get-GPOReport -ReportType Xml -Name $name -Path "C:\Temp\GPOs\NYCUser\$name.xml"
}
# OU5
Foreach ($tc in $torcomp){
$name = $nu.name
Get-GPOReport -ReportType Xml -Name $name -Path "C:\Temp\GPOs\TORComp\$name.xml"
}
# OU6
Foreach ($tu in $toruser){
$name = $nu.name
Get-GPOReport -ReportType Xml -Name $name -Path "C:\Temp\GPOs\TORUser\$name.xml"
}