# Copyright (c) 2002-2019 by Symas Corporation
# All rights reserved.

# openldap-mmr-tutorial

Contains documentation and config to setup openldap multi-master replication cluster designed for the classroom.

Overview:

This tutorial will use OpenLDAP for Linux: 2.4.48.1

## Prerequisites

Note: These steps have been performed on the virtual box VM supplied as part of the class.

* RHEL7 or Centos7

Run commands as root.

Install git:

```
yum -y install git
```

Install the project from the git repo:

```
git clone https://gitlab.symas.net/smckinney/openldap-mmr-tutorial.git
```

or 

```
git clone git@gitlab.symas.net:smckinney/openldap-mmr-tutorial.git
```

## Installation

1. First ensure all existing openldap packages have been removed from the system.

```
systemctl stop slapd
yum erase openldap-clients openldap-servers
```

yum erase symas-openldap-clients symas-openldap-servers
yum -y install openldap-clients openldap-servers

2. Prepare the machine:

```
wget -q https://repo.symas.com/configs/SOFL/rhel7/sofl.repo -O /etc/yum.repos.d/sofl.repo
yum -y update
```

3. Install the package:

```
yum -y install symas-openldap-clients symas-openldap-servers

```

4. Copy the configs:

Navigate to the location you created the project repo. From the root folder of the project repo, copy config files:

```
cp config/*.schema /etc/openldap/schema
cp config/slapd-a.conf.master /etc/openldap/slapd-a.conf
cp config/slapd-b.conf.master /etc/openldap/slapd-b.conf
cp certs/* /etc/openldap/certs
```

5. Make folders:

a. slapd:

```
mkdir /etc/openldap/a
mkdir /etc/openldap/b
```

b. DB

```
mkdir /var/lib/ldap/sample-a
mkdir /var/lib/ldap/accesslog-a
mkdir /var/lib/ldap/sample-b
mkdir /var/lib/ldap/accesslog-b
```

6. Add hostname to /etc/hosts

a. Obtain your ip address:

```
[root@slapdtrain openldap]# ifconfig
enp0s8: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 192.168.56.102  netmask 255.255.255.0  broadcast 192.168.56.255
        inet6 fe80::9699:ee7f:4407:88bb  prefixlen 64  scopeid 0x20<link>
        ether 08:00:27:96:5e:aa  txqueuelen 1000  (Ethernet)
        RX packets 36287  bytes 3090251 (2.9 MiB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 27503  bytes 17132368 (16.3 MiB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0
```

b. Edit hosts file:

```
vi /etc/hosts
```

c. Add: 

```
192.168.56.102   slapdtrain
```

d. Save and exit.

e. Verify

```
[root@slapdtrain openldap]# ping slapdtrain
PING slapdtrain (192.168.56.102) 56(84) bytes of data.
64 bytes from slapdtrain (192.168.56.102): icmp_seq=1 ttl=64 time=0.025 ms
```

7. Enable the sys logger:


8. Test slapd configs:

```
slaptest -f /etc/openldap/slapd-a.conf -u
slaptest -f /etc/openldap/slapd-b.conf -u
```

9. Import bootstrap data:

a. Test the import with -u option:

```
slapadd -v -u -c -f /etc/openldap/slapd-a.conf -l config/bootstrap.ldif
```

b. Perform the import:

```
slapadd -v -c -f /etc/openldap/slapd-a.conf -l config/bootstrap.ldif
```

10. Configure syslog:

a. Edit the config file

```
vi /etc/rsyslog.conf
``` 

b. Add after "local7":

```
local4.*                                            /var/log/openldap-a.log
local5.*                                            /var/log/openldap-b.log
local6.*                                            /var/log/openldap-c.log
local7.*                                            /var/log/openldap-d.log
```

c. Restart the rsyslog daemon:
```
service rsyslog restart
```

11. Fire it up

```
/usr/sbin/slapd -h ldap://slapdtrain:389 -f /etc/openldap/slapd-a.conf -F /etc/openldap/a -l local4
/usr/sbin/slapd -h ldap://slapdtrain:390 -f /etc/openldap/slapd-b.conf -F /etc/openldap/b -l local5
```

12. Set firewall rules:

(if connecting remotely)

```
firewall-cmd --permanent --add-port=389/tcp
firewall-cmd --permanent --add-port=390/tcp
firewall-cmd --reload
```

13. Test it:

a. Install Apache Directory Studio to the desktop env.  Connect to one of the masters.  Edit an entry, make sure it replicates to the other.

b. Perform a command line search:

```
ldapsearch -x -LLL -H ldap://slapdtrain:389 -D "cn=manager,dc=example,dc=com" -w secret -s sub -b 'dc=example,dc=com' objectclass="*"
ldapsearch -x -LLL -H ldap://slapdtrain:390 -D "cn=manager,dc=example,dc=com" -w secret -s sub -b 'dc=example,dc=com' objectclass="*"
```

14. Advanced Testing:

replication

a. Update attribute on one master:

```
ldapmodify -a -x -D "cn=manager,dc=example,dc=com" -w secret -H ldap://slapdtrain:390 -f test/louie.ldif
```

b. Verify the other master receives the update:

```
ldapsearch -x -LLL -H ldap://slapdtrain:389 -D "cn=manager,dc=example,dc=com" -w secret -s sub -b 'uid=Huey,ou=People,dc=example,dc=com' objectclass="*" -E '!sync=rp'
```

c. Context CSN Verification:

CSN Syntax

  Values in this syntax are encoded according to the following BNF:

  CSN = timestamp '#' operation-counter '#' replica-id 

  timestamp = <generalizedTimeString as specified in 6.14 of [RFC2252]>

  operation-counter = 6hex-digit

  replica-id = 2hex-digit

  The timestamp SHALL use GMT and SHALL NOT include fractional seconds.


e.g.:
            |-- timestamp -------| |-ctr-|--rid----|
contextCSN: 20191030111536.567316Z#000000#001#000000

i. Retrieve CSN's on Server A:
```
ldapsearch -H ldap://slapdtrain:389 -D "cn=manager,dc=example,dc=com" -w secret -x -s base -b dc=example,dc=com -LLL contextCSN

contextCSN
dn: dc=example,dc=com
contextCSN: 20191030111536.567316Z#000000#001#000000
contextCSN: 20191013084924.621362Z#000000#002#000000
```

ii. Retrieve CSN's on Server B:
```
ldapsearch -H ldap://slapdtrain:390 -D "cn=manager,dc=example,dc=com" -w secret -x -s base -b dc=example,dc=com -LLL contextCSN

contextCSN
dn: dc=example,dc=com
contextCSN: 20191030111536.567316Z#000000#001#000000
contextCSN: 20191013084924.621362Z#000000#002#000000
```

d. Compare the two.

15. Troubleshooting

a. View the logs:

```
tail -f openldap-a.log
tail -f openldap-b.log
```

b. Python script:

From the root project folder:

```
./script/check_syncrepl_extended -p ldap://slapdtrain:389  -c ldap://slapdtrain:390 -b dc=example,dc=com -D cn=manager,dc=example,dc=com -P secret
...
INFO : No sync problem detected
```
