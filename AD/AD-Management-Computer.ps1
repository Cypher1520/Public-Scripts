<# VS Code Shortcuts
Collapse All: Ctrl+K CTRL+0
Expand All: Ctrl+K CTRL+J
#>

#-----------Computer Cleanup-----------#

    $comps = Import-CSV C:\Users\adm-crockwell\Desktop\delete.csv
    $date = Get-Date

    #Disable and Move computer to disabled computer OU
    ForEach ($c in $comps)

    {
    Set-ADComputer -Identity $c.delete -Enabled $false -Description "Disabled $date"
    }

    Get-ADComputer -Filter {enabled -eq "false"} | Remove-ADComputer -recursive

    #Delete Computers
    #ForEach ($c in $comps)
    #
    #{
    #Remove-ADComputer $c.Delete -Confirm:$false
    #}

#-----------Computer LastLogon-----------#
    Get-ADComputer -Filter * -Properties *  | Sort LastLogonDate | Select Name, LastLogonDate | Export-Csv E:\Reports\CompLastLogonDate.csv

#-----------Move Computer OU-----------#
    $computers = Import-Csv "Location"

    foreach ($comp in $computers)

    {
    Get-ADComputer $comp.name | Move-ADObject -TargetPath 'OU=Test-GPO-Temp,OU=CGY,OU=Workstations,OU=Access Corporate,DC=Access,DC=ad'
    }

#-----------Rejoi-----------
    Reset-ComputerMachinePassword -Server "cgydc05" -Credential '$crockwell@parexresources.local'