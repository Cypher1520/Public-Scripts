#!/bin/bash
# Username and Password to create
username=ecoadmin
password='aA7EfZWXLpQ5258w!'
# Create User and add to admins
sysadminctl -addUser Admin -fullName Admin -UID 510 -GID 20 -shell /bin/bash -password $password -home /Users/$username -admin
# Create second account for testing
#sysadminctl -addUser Standard -fullName Standard -UID 511 -GID 20 -shell /bin/bash -password $password -home /Users/Standard -admin
if id "Admin" >/dev/null 2>&1; then
    # Get list of regular users
    users=$(dscl . -list /Users | grep -v -e "_" -e root -e nobody -e daemon -e $username)
    # Loop through them and remove them from Admins group
    for i in $users
    do
    dseditgroup -o edit -d $i -t user admin
    done
    exit 0
else
    exit 1
fi