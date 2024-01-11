#!/bin/zsh
# Username and Password to create
username=Admin
password='supercomplexpassword1!'
# Create User and add to admins
sysadminctl -addUser Admin -fullName Admin -UID 510 -GID 20 -shell /bin/bash -password $password -home /Users/$username -admin
sysadminctl -addUser Standard -fullName Standard -UID 511 -GID 20 -shell /bin/bash -password $password -home /Users/Standard -admin
# Get list of regular users
users=$(dscl . -list /Users | grep -v -e "_" -e root -e nobody -e daemon -e $username -e chris)
# Loop through them and remove them from Admins group
for i in $users
do
dseditgroup -o edit -d $i -t user admin
done