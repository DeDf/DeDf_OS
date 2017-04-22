
.CODE

inb PROC
push rdx
mov  rdx, rcx
in al, dx
pop rdx
ret
inb ENDP

outb PROC
xchg rcx, rdx
mov rax, rcx
out dx, al
xchg rcx, rdx
ret
outb ENDP

END
