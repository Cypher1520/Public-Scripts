#!/bin/bash
# Username and Password to create
username=Admin
password='gGfX9^AnN$'
# Create User and add to admins
sysadminctl -addUser $username -fullName $username -UID 510 -GID 20 -shell /bin/bash -password $password -home /Users/$username -admin
# Create second account for testing
sysadminctl -addUser Standard -fullName Standard -UID 511 -GID 20 -shell /bin/bash -password $password -home /Users/Standard -admin
# Get list of regular users
users=$(dscl . -list /Users | grep -v -e "_" -e root -e nobody -e daemon -e $username -e Chris)
# Loop through them and remove them from Admins group
for i in $users
do
dseditgroup -o edit -d $i -t user admin
done