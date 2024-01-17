$DT = (Get-Date).AddDays(-30).ToString("MM/dd/yyyy")
Get-Mailbox | Search-Mailbox -SearchQuery "received:< $DT" -DeleteContent -target