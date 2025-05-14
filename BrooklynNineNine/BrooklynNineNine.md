Tools : 
- nmap
- ftp
- hydra
- ssh
- openvpn

Let's say that the ip address of the attacked machine is : <IP>

STEP  1 : 
- Connection to the network using openVPN and the VPN file given by TryHackMe. sudo openvpn <vpnfile>

STEP 2 :
- Ping the attacked machine to see if we are in the same network than the attacked machine. (The attacked machine can also block external pings, but in the easy ctf it never happens but it's still good to know).  ping <IP>

STEP 3 : 
- Enumeration : Scanning all the open ports of the machine to see which ports is open or not. (Every open ports are a potential way to get into the machine)
- Command : nmap   -sV  -sC  -T4  <IP>
- We can see that 3 ports are open :
	- PORT     -  STATE  -  SERVICE  - VERSION
	- 21 / tcp  -  OPEN   -  FTP          -  vsftpd 3.0.3
	- 22 / tcp -  OPEN   -  SSH          -  openSSH 7.6p1
	- 80 / tcp -  OPEN   -  HTTP       -  Apache httpd 2.4.29

STEP 4 :
- We can enter the ip address of the attacked machine in our browser to access the http service running on the machine.
- An image appears and it is a way to finish the CTF but I find the other method way more interesting so we wont continue on this way.
- Now, we have FTP and SSH left to try to get root on the attacked machine. SSH always requires a Username and a Password and we don't have any of them so it seems difficult to get into the machine by this way, 
- But FTP can be misconfigured and we could connect to the machine with this service very easily, let's try that.
- Command : ftp <IP>   
- A Username is required. By default FTP username is : anonymous
- A Password is required. By default FTP password is : (nothing)
- TADA, we are connected to the machine thanks to the FTP service (That does not mean that we have access to the machine !!! We only have access the FTP service of the machine).

STEP 5 :
- We can try the command ls or dir to have an idea of what files the are here. And we can see that in fact, there is a file named note_to_jake.txt.
- Lets import that file on our machine using the get command : get note_to_jake.txt 
- Now that we have the file on our machine, we can exit the FTP connection an look what's in this file.
- We see that Amy is telling to a user name Jake that he should really change his password because it's really weak.

STEP 6 :
- So Jake's password is weak, let's try to connect to the jake user on the attacked machine with SSH.
- We have a user "Jake" or "jake", we can try to bruteforce his password with Hydra.
- Lets try the command : hydra  -l  jake  -P   <wordlist>   <ip>  ssh  -v  -t 4
- After waiting a few minutes, we can see that Hydra succeed to find the password of jake : 987654321. (In fact it's a bad password)
- Let's connect to the jake user : ssh jake@<ip> -p 22  and we can enter the password found just before.
- We are now connected to the machine as the jake user. The goal now is to find a way to get root without any information about the root password : We call that the Escalation Privilege.

STEP 7 :
- At first, we will take a look at the files and directories in the machine to see if we can find something interesting. We can see that there is 3 directories : holt, amy and jake and we can enter in each of them to access their files.
- In the holt directory there is a user.txt file and we have the permission to read it so let's read it. cat user.txt , Nice we have now the first Flag of the room.
- Now we would like to access the /root directory to find the root flag.
- First interesting thing to do when we are looking to escalate privilege is to check if our user jake can execute some command as root WITHOUT password.
- We can see that with the sudo -l command. Let's try that and we see that in fact jake can execute the less command that is stored in /usr/bin/
- less is a tool that display the content of a file or the output of a command one page at the time. But with less WE CAN ALSO EXECUTE COMMAND. But if you remember well, less is executed as root, so if I execute a command like /bin/bash in less that is himself executed as root, /bin/bash will be executed as root and TADA, we will be root.
- Let's use the less command on a random file. : sudo less /etc/profile, Interesting already, no password has been asked to execute less as sudo.
- Now lets execute a command in the less tool like that : !/bin/bash.
- Now a new shell appears : Lets try to see who we are with the command : whoami    -->   root.
- We are now root ! We just have to look into the /root directory to see the root.txt that contains the final flag !




-----------------------------------------------------------------------------------------------------------------------


- OPENVPN (Connexion au reseau de la machine cible):  openvpn --config config.ovpn --daemon

- PING (Ping la machine cible pour verifier la bonne communication):  ping <ip>

- NMAP (Scan de ports):  nmap -sV -sC -T4 <ip>       =>     -sV : Scan les versions des services
				                                                                              -sC : Test les scripts par defaut sur les services
				                                                                              -T4 : Permet d'aller plus vite (Scan aggressif)


- FTP (Connexion au serveur ftp mal configure):   ftp <ip>     =>  (Verifier si le service ftp est mal configure : Username = anonymous
								                                                                                                                           Password  = (no password)
	                                                                               get <file>  => Transfert un fichier du serveur ftp sur note machine (Il faut donc etre connecter au serveur ftp) 
  

- HYDRA (Brute Force mot de passe ssh): hydra -l <username> -P <wordlist> <ip> ssh -v -t 4  => -t 4 : Utilisations de 4 threads pour aller plus vite
								                                                                                                                         -v    : Ajoute de la verbosite, affiche tous les tests d'HYDRA

- SSH (Connexion a la machine cible):  ssh <username>@<ip> -p <port>


- SUDO -L  (Escalade de privilege) :   sudo -l   =>   Affiche les commandes que l'utilisateur courant peut executer avec sudo sans mot de passe, exploiter la commande                                                                                       grace au site gtfobins