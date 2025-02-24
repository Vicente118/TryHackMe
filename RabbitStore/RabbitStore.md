My ip : 10.2.3.159
Target ip : 10.10.67.46

Ports enumeration :
```
nmap -sC -sV -T4 -p- 10.10.67.46

22/tcp    open  ssh     OpenSSH 8.9p1 Ubuntu 3ubuntu0.10 (Ubuntu Linux; protocol 2.0)
80/tcp    open  http    Apache httpd 2.4.52
|_http-server-header: Apache/2.4.52 (Ubuntu)
|_http-title: Did not follow redirect to http://cloudsite.thm/
4369/tcp  open  epmd    Erlang Port Mapper Daemon
| epmd-info: 
|   epmd_port: 4369
|   nodes: 
|_    rabbit: 25672
25672/tcp open  unknown
```

Adding cloudsite.thm and storage.cloudsite.thm to /etc/hosts

Subdirectory fuzzing :
```
 gobuster dir -w `fzf-wordlists` -u http://cloudsite.thm/ -t 75 -x php,html,txt
 
  gobuster dir -w `fzf-wordlists` -u http://storage.cloudsite.thm/ -t 75 -x php,html,txt
```

Nothing interesting, let's dive into the Erlang Port Mapper Daemon port. We find that there is a possible RCE for this service but we need a cookie that we don't have now. (exploit-db.com)
