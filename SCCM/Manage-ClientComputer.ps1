<# VS Code Shortcuts
Collapse All: Ctrl+K CTRL+0
Expand All: Ctrl+K CTRL+J
#>

#-----------Cleanup Client CCMCache-----------
    $resman= New-Object -ComObject "UIResource.UIResourceMgr"
    $cacheInfo=$resman.GetCacheInfo()
    $cacheinfo.GetCacheElements()  | foreach {$cacheInfo.DeleteCacheElement($_.CacheElementID)}

#-----------Reinstall Client-----------
    #F:\ConfigMgr\CMUClient
    ccmsetup.exe /unistall
    ccmsetup.exe /mp:bogsccm01.parexresources.local /logon SMSSITECODE=A01