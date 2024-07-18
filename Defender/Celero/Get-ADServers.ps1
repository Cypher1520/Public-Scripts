Get-ADComputer -Filter {OperatingSystem -like "*windows*server*"} -Properties DNSHostName, OperatingSystem,IPv4Address | sort DNSHostname

Get-ADComputer -Filter { OperatingSystem -like "*server*" } -Properties * | select Name,OperatingSystem,OperatingSystemVersion,CanonicalName | Export-Csv C:\Temp\MDE\ADServers.csv