Get-Mailbox -RecipientTypeDetails RoomMailbox,EquipmentMailbox | Select Name,Alias,UserPrincipalName | ft -AutoSize
Get-Mailbox -RecipientTypeDetails EquipmentMailbox | Select UserPrincipalName | ft -AutoSize

Get-MailboxFolderPermission $room | Ft -AutoSize
Remove-MailboxFolderPermission $room -User swelsh -Confirm:$false

Add-MailboxFolderPermission $room -user jshipka -AccessRights Owner
Add-MailboxFolderPermission $room -user ijensen -AccessRights Owner
Add-MailboxFolderPermission $room -user swelsh -AccessRights Owner

Get-MailboxPermission $room | Where {$_.IsInherited -ne $true} | ft -AutoSize

Add-MailboxPermission $room -User jshipka -AccessRights FullAccess -InheritanceType All -AutoMapping:$false -Confirm:$false
Add-MailboxPermission $room -User ijensen -AccessRights FullAccess -InheritanceType All -AutoMapping:$false -Confirm:$false
Add-MailboxPermission $room -User swelsh -AccessRights FullAccess -InheritanceType All -AutoMapping:$false -Confirm:$false

#Rooms
$room = "cln-room1-boardroom@wolfmidstream.com"
$room = "fsk-room2-boardroom@wolfmidstream.com"
$room = "fsk-room1-boardroom@wolfmidstream.com"
$room = "fsk-room3-boardroom@wolfmidstream.com"
$room = "stg-room1-boardroom@wolfmidstream.com"
$room = "stf-room1-boardroom@wolfmidstream.com"
$room = "stg-room2-boardroom@accesspipeline.onmicrosoft.com"

spareofficefsk@accesspipeline.com

room1497-athabasca@accesspipeline.onmicrosoft.com 
room1435-lacombe@accesspipeline.onmicrosoft.com
room1441-camrose@accesspipeline.onmicrosoft.com
room1485-smokylake@accesspipeline.onmicrosoft.com 
room1598-strathcona@accesspipeline.onmicrosoft.com
room1502-clearwater@accesspipeline.onmicrosoft.com
room1511-bighorn@accesspipeline.onmicrosoft.com
room1512-lakeland@accesspipeline.onmicrosoft.com
room1541-foothills@accesspipeline.onmicrosoft.com
room1585-parkland@accesspipeline.onmicrosoft.com

hoteloffice3cgy@accesspipeline.onmicrosoft.com    
hoteloffice2cgy@accesspipeline.onmicrosoft.com    
hoteloffice4cgy@accesspipeline.onmicrosoft.com    
hoteloffice1cgy@accesspipeline.onmicrosoft.com
easymeeting@accesspipeline.onmicrosoft.com
ittestlab-cgy@accesspipeline.onmicrosoft.com
ittestlab-fsk@accesspipeline.onmicrosoft.com

#Equipment
pool5-fsk-963587@accesspipeline.onmicrosoft.com
pool1-stg-694419@accesspipeline.onmicrosoft.com
pool2-fsk-680846@accesspipeline.onmicrosoft.com
pool2-stg-694420@accesspipeline.onmicrosoft.com
pool1-cln-694418@accesspipeline.onmicrosoft.com
pool3-fsk-a25268@accesspipeline.onmicrosoft.com
pool7-fsk-693589@accesspipeline.onmicrosoft.com
pool4-fsk-690389@accesspipeline.onmicrosoft.com
pool4-stg-a32183@accesspipeline.onmicrosoft.com
pool1-fsk-682299@accesspipeline.onmicrosoft.com
pickercln@accesspipeline.onmicrosoft.com        
pickerstg@accesspipeline.onmicrosoft.com
pool1-cgy@accesspipeline.onmicrosoft.com
centennialloaner1@accesspipeline.onmicrosoft.com
centenniallaptop2@accesspipeline.onmicrosoft.com
centenniallaptop3@accesspipeline.onmicrosoft.com
centenniallaptop4@accesspipeline.onmicrosoft.com
pool2-cgy@accesspipeline.onmicrosoft.com