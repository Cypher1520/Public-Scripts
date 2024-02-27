<#
	.SYNOPSIS
	Removes orphaned files and temp folders after fresh image. 
	.DESCRIPTION
	Removes orphaned files and temp folders after fresh image. 
	Some errors are expected as the temp directories may have files locked.
	.INPUTS
	None
	.OUTPUTS
	Deletes up temp and orphaned files.
	.NOTES
	Version:        1.0.0
	Author:         Chris Rockwell
	Email: 			chris.rockwell@insight.com
	Creation Date:  2024/01/31
	Updated: 		2024/01/31
	.EXAMPLE
#>

#Remove orphaned files in C:\ Drive
$files = Get-ChildItem "C:\*.*" -Exclude '$WINDOWS.~BT' -Name
	foreach ($i in $files) {Remove-Item ("C:\"+$i)}


#Remove Directories including subfolder and files.

$folders = "C:\Perflogs", "C:\swsetup", "C:\inetpub", "C:\Drivers", "C:\Windows\Prefetch", "C:\Users\*\AppData\Local\Temp", "C:\Users\*\AppData\LocalLow\Temp", "C:\windows\Temp"
	foreach ($i in $folders) { if (Test-Path $i) {Remove-Item $i -Recurse -Force} }