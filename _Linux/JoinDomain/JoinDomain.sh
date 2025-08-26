#!/bin/sh
#reference https://codymoler.github.io/tutorials/ubuntu-active-directory/

#Updates system so no fails due to out of date packages
sudo apt -y update
#Install realmd, sssd, adcli
apt-get install -y sssd-ad sssd-tools realmd adcli
#Create/Edit krb5 config file
nano /etc/krb5.conf
#Modify /etc/krb5.conf
    #****Modify to target domain name****
[libdefaults]
default_realm = EQUISOFT.COM
rdns = false
#install remaining packages
apt-get install -y krb5-user sssd-krb5
#Set hostname to FQDN
    #****Set to target domain FQDN****
hostnamectl set-hostname HOSTNAME.EQUISOFT.COM
#get kerberos ticket
    #****use AD username****
kinit yourusername
#Join system to domain
    #****use domain account info****
realm join -v -U yourusername EQUISOFT.COM
    #Check “activate mkhomedir”. Tab and hit Enter to select Ok.
#Test to see if the integration is working correctlyPermalink
id yourusername@EQUISOFT.COM

:'
#----Optional----
#Modify pam to automatically create a home directory for AD users
pam-auth-update

#Update your sudoers file to include your domain administrators security group with full sudo access:

#Add a file to sudoers.d which follows the standard format for permissions. Enter the group:
%mydomainadmingroup@MYDOMAIN.NET ALL=(ALL) NOPASSWD:ALL

#Tell realm to not let anyone but the selected group login:
realm permit -g mydomainadmingroup@MYDOMAIN.NET
'