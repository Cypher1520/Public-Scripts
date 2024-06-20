Get-ADComputer -Filter {OperatingSystem -like "*windows*server*"} -Properties DNSHostName, OperatingSystem,IPv4Address | sort DNSHostname

$servers = Get-ADComputer -Filter { OperatingSystem -like "*server*" } -Properties * | select Name,OperatingSystem,OperatingSystemVersion,CanonicalName