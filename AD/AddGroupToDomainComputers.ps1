$Comp = Get-ADComputer -Filter {Name -like "*l1*"}

foreach ($c in $comp)
{
Add-ADGroupMember -Identity WAP -Members $c.DistinguishedName
}

<#foreach ($c in $comp)
{
    Get-ADComputer $c.Name -Properties MemberOf | Select-Object -Property @{N= "Name";E= {$_.samaccountname}},@{N= "Groups";E={$_.Memberof}} 
}#>