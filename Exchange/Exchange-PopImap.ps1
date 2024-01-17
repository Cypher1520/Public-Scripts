Get-CASMailboxPlan | fl Name
Get-CASMailboxPlan "MAILBOXPLANNAME" -ImapEnabled $false -PopEnabled $false
Get-CASMailboxPlan "MAILBOXPLANNAME" | Select ImapEnabled,PopEnabled

Get-CASMailbox -Filter {ImapEnabled -eq "true" -or PopEnabled -eq "true" } | Select-Object @{n = "Identity"; e = {$_.primarysmtpaddress}} | Set-CASMailbox -ImapEnabled $false -PopEnabled $false
Get-CASMailboxPlan -Filter {ImapEnabled -eq "true" -or PopEnabled -eq "true" } | set-CASMailboxPlan -ImapEnabled $false -PopEnabled $false