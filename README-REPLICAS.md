# Copyright (c) 2002-2019 by Symas Corporation
# All rights reserved.

# openldap-mmr-tutorial

Contains documentation and config to setup an openldap cascading replica cluster designed for the classroom.

Overview:

This tutorial will use OpenLDAP for Linux: 2.4.48.1

## Prerequisites

* RHEL7 or Centos7
* Successful completion of [README-MASTERS](README-MASTERS.md).

Run commands as root.

## Installation

1. Copy the configs:

From the project repo:

```
cp config/slapd-c.conf.replica /etc/openldap/slapd-c.conf
cp config/slapd-d.conf.replica /etc/openldap/slapd-d.conf
```

2. Make folders:

a. slapd:

```
mkdir /etc/openldap/c
mkdir /etc/openldap/d
```

b. DB

```
mkdir /var/lib/ldap/sample-c
mkdir /var/lib/ldap/sample-d
```

3. Test slapd configs:

```
slaptest -f /etc/openldap/slapd-c.conf -u
slaptest -f /etc/openldap/slapd-d.conf -u
```

4. Fire it up

```
/usr/sbin/slapd -h ldap://slapdtrain:391 -f /etc/openldap/slapd-c.conf -F /etc/openldap/c -l local6
/usr/sbin/slapd -h ldap://slapdtrain:392 -f /etc/openldap/slapd-d.conf -F /etc/openldap/d -l local7
```

5. Set firewall rules:

(if connecting remotely)

```
firewall-cmd --permanent --add-port=391/tcp
firewall-cmd --permanent --add-port=392/tcp
firewall-cmd --reload
```

6. Test it:

a. Install Apache Directory Studio to the desktop env.  Connect to one of the masters.  Edit an entry, make sure it replicates to the other.

b. Perform a command line search:

```
ldapsearch -x -LLL -H ldap://slapdtrain:391 -D "cn=svcact,ou=admin,dc=example,dc=com" -w password -s sub -b 'ou=People,dc=example,dc=com' objectclass="*"

ldapsearch -x -LLL -H ldap://slapdtrain:392 -D "cn=svcact,ou=admin,dc=example,dc=com" -w password -s sub -b 'ou=People,dc=example,dc=com' objectclass="*"

ldapsearch -x -LLL -H ldap://slapdtrain:391 -D "uid=huey,ou=people,dc=example,dc=com" -w password -s sub -b 'uid=huey,ou=people,dc=example,dc=com' objectclass="*"

ldapsearch -x -LLL -H ldap://slapdtrain:391 -D "uid=huey,ou=people,dc=example,dc=com" -w password -s sub -b 'uid=dewey,ou=people,dc=example,dc=com' objectclass="*"
```

7. Advanced Testing:

filtered replication

a. Add louie to Zone Z1:

```
ldapmodify -a -x -D "cn=manager,dc=example,dc=com" -w secret -H ldap://slapdtrain:389 -f test/louie2.ldif
```

b. Verify louie now appears in search in Zone 1 replica:

```
ldapsearch -x -LLL -H ldap://slapdtrain:391 -D "cn=svcact,ou=admin,dc=example,dc=com" -w password -s sub -b 'ou=People,dc=example,dc=com' objectclass="*"
```

c. Now remove Z1 from Louie:"

```
ldapmodify -a -x -D "cn=manager,dc=example,dc=com" -w secret -H ldap://slapdtrain:389 -f test/louie3.ldif

```

d. Verify louie now disappears from Zone 1 replica:

```
ldapsearch -x -LLL -H ldap://slapdtrain:391 -D "cn=svcact,ou=admin,dc=example,dc=com" -w password -s sub -b 'ou=People,dc=example,dc=com' objectclass="*"
```

e. Context CSN Verification:

i. Retrieve CSN's on Server C:
```
ldapsearch -H ldap://slapdtrain:391 -D "cn=manager,dc=example,dc=com" -w secret -x -s base -b dc=example,dc=com -LLL contextCSN

contextCSN
dn: dc=example,dc=com
contextCSN: 20191030111536.567316Z#000000#001#000000
contextCSN: 20191013084924.621362Z#000000#002#000000
```

ii. Retrieve CSN's on Server D:
```
ldapsearch -H ldap://slapdtrain:392 -D "cn=manager,dc=example,dc=com" -w secret -x -s base -b dc=example,dc=com -LLL contextCSN

contextCSN: 20191030111536.567316Z#000000#001#000000
contextCSN: 20191013084924.621362Z#000000#002#000000
```

f. Compare.


8. Troubleshooting

a. View the logs:

```
tail -f openldap-c.log
tail -f openldap-c.log
```

b. Run script:


i. With C (Where's Louie)
```
./script/check_syncrepl_extended -p ldap://slapdtrain:389  -c ldap://slapdtrain:391 -b dc=example,dc=com -D cn=manager,dc=example,dc=com -P secret
...
2019-10-30 08:45:34,561 - WARNING : Not found objects on ldap://slapdtrain:391 :
  - uid=louie,ou=People,dc=example,dc=com
```

ii. With D (What about Dewey)
```
./script/check_syncrepl_extended -p ldap://slapdtrain:389  -c ldap://slapdtrain:392 -b dc=example,dc=com -D cn=manager,dc=example,dc=com -P secret
...
2019-10-30 08:44:06,529 - WARNING : Not found objects on ldap://slapdtrain:392 :
  - uid=dewey,ou=People,dc=example,dc=com
```

