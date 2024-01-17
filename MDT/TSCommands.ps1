#Build Suspend
cscript.exe "%SCRIPTROOT%\LTISuspend.wsf"

#startmenu Import
$fileroot = $PSScriptRoot
Import-StartLayout -LayoutPath $fileroot\Layouts.xml -MountPath C:\