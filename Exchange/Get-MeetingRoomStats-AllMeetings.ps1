# Script:	Get-MeetingRoomStats.ps1
# Purpose:	Gather statistics regarding meeting room usage
# Author:	Nuno Mota
# E-mail:   nuno.filipe.mota@gmail.com
# Date:		May 2017
# Version:	0.1
#           0.2 - 20171214 - Added support for Exchange Online (Office 365)



<#
.SYNOPSIS
Gather statistics regarding meeting room usage

.DESCRIPTION
This script uses Exchange Web Services to connect to one or more meeting rooms and gather statistics regarding their usage between to specific dates

IMPORTANT:
  - You must use the room's SMTP address;
  - You must have at least Reviewer rights to the meeting room's calendar (FullAccess to the mailbox will also work);
  - Maximum range to search is two years;
  - Maximum of 1000 meetings are returned;
  - Exchange AutoDiscover needs to be working.


.EXAMPLE
C:\PS> .\Get-MeetingRoomStats.ps1 -RoomListSMTP "room.1@domain.com, room.2@domain.com" -From "01/01/2017" -To "01/02/2017" -Verbose

Description
-----------
This command will:
   1. Process room.1@domain.com and room.2@domain.com meeting rooms;
   2. Gather statistics for both room between 1st of Jan and 1st of Feb (please be aware of your date format: day/month vs month/day);
   3. Write progress information as it goes along because of the -Verbose switch


.EXAMPLE
C:\> .\Get-MeetingRoomStats.ps1 -RoomListSMTP "room.1@domain.com, room.2@domain.com" -ExchangeOnline -Verbose

Description
-----------
This command will gather statistics from Exchange Online for the specified meeting rooms for the current month.

.\Get-MeetingRoomStats-AllMeetings.ps1 -RoomListSMTP "fsk-room1-boardroom@wolfmidstream.com, fsk-room2-boardroom@wolfmidstream.com," -From "01/01/2019" -To "5/17/2019" -ExchangeOnline -Verbose

fsk-room1-boardroom@wolfmidstream.com, fsk-room2-boardroom@wolfmidstream.com, fsk-room3-boardroom@wolfmidstream.com, cln-room1-boardroom@wolfmidstream.com, stf-room1-boardroom@wolfmidstream.com, stg-room1-boardroom@wolfmidstream.com, stg-room2-boardroom@accesspipeline.onmicrosoft.com

.EXAMPLE
C:\PS> Get-Help .\Get-MeetingRoomStats.ps1 -Full

Description
-----------
Shows this help manual.

.EXAMPLE
Working template

.\Get-MeetingRoomStats-AllMeetings.ps1 -RoomListSMTP "pool1-cgy@wolfmidstream.com, pool1-cln-694418@wolfmidstream.com, pool1-fsk-682299@wolfmidstream.com, pool1-stg-694419@wolfmidstream.com, pool2-fsk-680846@wolfmidstream.com, pool2-stg-694420@wolfmidstream.com, pool3-fsk-a25268@wolfmidstream.com, pool3-stg-681262@wolfmidstream.com, pool4-fsk-690389@wolfmidstream.com, pool4-stg-a32183@wolfmidstream.com, pool5-fsk-963587@wolfmidstream.com, pool6-fsk-673164@wolfmidstream.com, pool7-fsk-693589@wolfmidstream.com" -From "01/01/2019" -To "5/31/2019" -ExchangeOnline -Verbose | Export-Csv .\PoolUnitStats_5312019.csv -NoTypeInformation

#Boardrooms
fsk-room1-boardroom@wolfmidstream.com, fsk-room2-boardroom@wolfmidstream.com, fsk-room3-boardroom@wolfmidstream.com, cln-room1-boardroom@wolfmidstream.com, stf-room1-boardroom@wolfmidstream.com, stg-room1-boardroom@wolfmidstream.com, stg-room2-boardroom@accesspipeline.onmicrosoft.com

#PoolUnits
pool1-cgy@wolfmidstream.com, pool1-cln-694418@wolfmidstream.com, pool1-fsk-682299@wolfmidstream.com, pool1-stg-694419@wolfmidstream.com, pool2-fsk-680846@wolfmidstream.com, pool2-stg-694420@wolfmidstream.com, pool3-fsk-a25268@wolfmidstream.com, pool3-stg-681262@wolfmidstream.com, pool4-fsk-690389@wolfmidstream.com, pool4-stg-a32183@wolfmidstream.com, pool5-fsk-963587@wolfmidstream.com, pool6-fsk-673164@wolfmidstream.com, pool7-fsk-693589@wolfmidstream.com

#>


[CmdletBinding()]
Param (
	[Parameter(Position = 0, Mandatory = $True)]
	[String] $RoomListSMTP,

	[Parameter(Position = 1, Mandatory = $False)]
	[DateTime] $From = (Get-Date -Day 1 -Hour 0 -Minute -0 -Second 0),
	
	[Parameter(Position = 2, Mandatory = $False)]
	[DateTime] $To = (Get-Date -Day 1 -Hour 0 -Minute -0 -Second 0).AddMonths(1),

	[Parameter(Position = 3)]
	[Switch] $ExchangeOnline = $False
)


Function Load-EWS {
	Write-Verbose "Loading EWS Managed API"
	$EWSdll = (($(Get-ItemProperty -ErrorAction SilentlyContinue -Path Registry::$(Get-ChildItem -ErrorAction SilentlyContinue -Path 'Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Exchange\Web Services' | Sort Name -Descending | Select -First 1 -ExpandProperty Name)).'Install Directory') + "Microsoft.Exchange.WebServices.dll")

	If (Test-Path $EWSdll) {
		Try {
			Import-Module $EWSdll -ErrorAction Stop
		} Catch {
			Write-Verbose -Message "Unable to load EWS Managed API: $($_.Exception.Message). Exiting Script."
			Exit
		}
	} Else {
		Write-Verbose "EWS Managed API not installed. Please download and install the current version of the EWS Managed API from http://go.microsoft.com/fwlink/?LinkId=255472. Exiting Script."
		Exit
	}
}


Function Connect-Exchange {
	Param ([String] $Mailbox)
	
	# Load EWS Managed API dll
	Load-EWS

	# Create Exchange Service Object and set Exchange version
	Write-Verbose "Creating Exchange Service Object using AutoDiscover"
	$service = New-Object Microsoft.Exchange.WebServices.Data.ExchangeService([Microsoft.Exchange.WebServices.Data.ExchangeVersion]::Exchange2013_SP1)
	
	If ($ExchangeOnline) {
		$service.Url = [system.URI] "https://outlook.office365.com/EWS/Exchange.asmx"
		$cred = Get-Credential
		$srvCred = New-Object System.Net.NetworkCredential($cred.UserName.ToString(), $cred.GetNetworkCredential().Password.ToString()) 
		$service.Credentials = $srvCred
	} Else {
		$service.AutodiscoverUrl($Mailbox)
	}

	If (!$service.URL) {
		Write-Verbose -Message "Error conneting to Exchange Web Services (no AutoDiscover URL). Exiting Script."
		Exit
	} Else {
		Return $service
	}
}



#################################################################
# Script Start
#################################################################

# Initialize an array that will contain statistics for each room
[Array] $meetingCollection = @()

# Connect to local Exchange server or Exchange Online (Office 365)
$service = Connect-Exchange -Mailbox ($RoomListSMTP.Split(",")[0])

ForEach ($room in $RoomListSMTP.Split(",") -replace (" ", "")) {

	# Bind to the room's Calendar folder
	Try {
		Write-Verbose -Message "Binding to the $room Calendar folder."
		$folderID = New-Object Microsoft.Exchange.WebServices.Data.FolderId([Microsoft.Exchange.WebServices.Data.WellKnownFolderName]::Calendar, $room) -ErrorAction Stop
		$Calendar = [Microsoft.Exchange.WebServices.Data.Folder]::Bind($service, $folderID)
	} Catch {
		Write-Verbose "Unable to connect to $room. Please check permissions: $($_.Exception.Message). Skipping $room."
		Continue
	}

	# Define the calendar view and properties to load (required to get attendees)
	Try {
		$psPropset = New-Object Microsoft.Exchange.WebServices.Data.PropertySet([Microsoft.Exchange.WebServices.Data.BasePropertySet]::FirstClassProperties)  
		$CalendarView = New-Object Microsoft.Exchange.WebServices.Data.CalendarView($From, $To, 1000)    
		$fiItems = $service.FindAppointments($Calendar.Id,$CalendarView)    
		If ($fiItems.Items.Count -gt 0) {[Void] $service.LoadPropertiesForItems($fiItems, $psPropset)}
	} Catch {
		Write-Verbose "Unable to retrieve data from $room calendar. Please check permissions: $($_.Exception.Message). Skipping $room."
		Continue
	}

	# Initialize/reset variables used for statistics
	[Int] $totalMeetings = $totalDuration = $totalAttendees = $totalReqAttendees = $totalOptAttendees = $totalAM = $totalPM = $totalRecurring = 0
	ForEach ($meeting in $fiItems.Items) {

		$totalMeetings++

		# Save the meeting information
		$mtgObj = New-Object PSObject -Property @{
			From		= $From
			To		= $To
			RoomEmail	= $room
			Duration 	= $meeting.Duration.TotalMinutes
			ReqAttendees 	= $meeting.RequiredAttendees.Count
			OptAttendees	= $meeting.OptionalAttendees.Count
			Start		= $meeting.Start
			isRecurring	= $meeting.IsRecurring
		}
		$meetingCollection += $mtgObj
		Write-Verbose -Message "Meeting $totalMeetings $room $meeting.Start"
	}
}

# Print and export the results
$meetingCollection | Select From, To, RoomEmail, Duration, ReqAttendees, OptAttendees, Start, isRecurring | Sort From, RoomEmail
$meetingCollection | Select From, To, RoomEmail, Duration, ReqAttendees, OptAttendees, Start, isRecurring | Sort From, RoomName, RoomEmail | Export-Csv "MeetingRoomStats_$((Get-Date).ToString('yyyyMMdd')).csv" -NoTypeInformation