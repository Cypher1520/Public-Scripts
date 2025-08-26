$CurrentWin10 = [Version]"10.0.19045"
$CurrentWin11 = [Version]"10.0.26100"

$GetOS = Get-ComputerInfo -property OsVersion
$OSversion = [Version]$GetOS.OsVersion

if  ($OSversion -match [Version]"10.0.1")
    {
    if  ($OSversion -lt $CurrentWin10)
        {
        Write-Output "OS version currently on $OSversion"
        Exit 1
        }
    }

if  ($OSversion -match [Version]"10.0.2")
    {
    if  ($OSversion -lt $CurrentWin11)
        {
        Write-Output "OS version currently on $OSversion"
        Exit 1
        }
    }