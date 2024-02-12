#!/bin/bash
#set -x

#NOTE
# This script is very minimalistic. It has no logging or error handling!
# It's only purpose was to test if I could add shares to the dock quick and dirty.
# You should use the "add-smb-shares-2-dock.sh" script instead!

# Source
# https://allthingscloud.blog/deploy-network-drive-mappings-on-macos-with-microsoft-intune/

# [Removed the original script header from original script]

# Define variables
appname="Dock"

# [Removed Other initializations and function definitions...]
# define your network shares here
netshares=(   "smb://192.168.0.12/Data"
              "smb://192.168.0.12/Home"
              "smb://192.168.0.12/Tools")

echo ""
echo "# $(date) | Starting install of $appname"
echo ""

# [Removed Other script functionalities like waiting for desktop, Swift Dialog updates etc....]

# Add only network shares to Dock using defaults
if [[ "$netshares" ]]; then
  echo "$(date) |  Adding Network Shares to Dock"
  for j in "${netshares[@]}"; do
      label="$(basename $j)"
      echo "$(date) |  Adding [$j][$label] to Dock"     
      defaults write com.apple.dock persistent-others -array-add "<dict><key>tile-data</key><dict><key>label</key><string>$label</string><key>url</key><dict><key>_CFURLString</key><string>$j</string><key>_CFURLStringType</key><integer>15</integer></dict></dict><key>tile-type</key><string>url-tile</string></dict>"
      updateSplashScreen wait "Adding $j to Dock"
  done
fi

# [Removed rest of the script for Dock settings like Magnification, Minimize Icons, etc...]

echo "$(date) | Restarting Dock"
killall Dock

# [Removed rest of the script for completion log, launching Company Portal for ABM managed devices...]