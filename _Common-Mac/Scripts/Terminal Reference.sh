#trigger enrollment profile
sudo profiles renew -type enrollment

#convert plist to txt
plutil -convert xml1 /path/to/old.plist -o /path/to/new.plist

#dmg package info
defaults read /Applications/Company\ Portal.app/Contents/Info CFBundleIdentifier
defaults read /Applications/Company\ Portal.app/Contents/Info CFBundleShortVersionString

#Guest account
#sudo if needed
sysadminctl -guestAccount off
sysadminctl -guestAccount on

#caffeinate
#time is in seconds
caffeinate -t 4000