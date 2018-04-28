;-------------------------------------------------------------------------
;                          Version 0.0.1 by DeDf
; BIOS INT 19h �Ὣ MBR (512�ֽ�)װ�ص��ڴ�0x7c00����Ȼ��JUMP��0x7c00ִ��
;-------------------------------------------------------------------------

   bits 16       ; ָ��Ϊ16λ���ģʽ

   org 0x7c00    ; ָ���������ʼ��ַΪ0x7c00

start:

;---------------------------------------------------
; enable A20 gate  https://wiki.osdev.org/A20_Line
;---------------------------------------------------

   cli
   in al, 0x92   ; port 0x92 - System control and status register
   or al, 2
   out 0x92, al  ; port 0x92
   sti

;---------------------------------------------------

   mov ax, cs
   mov ds, ax
   mov es, ax
   mov ss, ax
   mov sp, 0x7c00

   lea si, [load_msg]
   call print

load_sector:
   mov di, 1
   mov si, 0x6000
   call read_sector
   jc failure
   jmp 0x6000

   mov ah, 0x42
   ;mov si, DISK_ADDRESS_PACKET
   int 0x13

failure:
   lea si, [fail_msg]
   call print
   jmp $

;---------------------------------------------------
; read_sector(di - sector, si - buf) LBA mode
;---------------------------------------------------

read_sector:
   push cx
   push dx
   push es
   push ds
   pop  es

   mov bx, si             ; data buffer
   mov ax, di             ; disk sector number

; LBA mode --> CHS mode

; cylinder = L / 36
   mov cl, 36
   div cl
   mov ch, al             ; ch = cylinder

; head = (L % 36) / 18
   mov al, ah
   xor ah, ah
   mov cl, 18
   div cl
   mov dh, al             ; dh = head

; sector = (L % 36) % 18 + 1
   mov cl, ah             ; cl = sector
   inc cl

   xor dl, dl             ; dl = drive

; ch - cylinder
; cl - sector ( 1 - 63)
; dh - head
; dl - drive number
; es:bx - data buffer

   mov ax, 0x201
   int 0x13

   pop es
   pop dx
   pop cx

   ret

;---------------------------------------------------
; print()
;---------------------------------------------------
print:
   mov ah, 0x0e     ; �紫���ֻ���� : AH=0EH  AL=�ַ���BH=ҳ�룬BL=��ɫ��ֻ������ͼ��ģʽ��
   xor bh, bh
printc:
   lodsb
   test al,al
   jz done
   int 0x10
   jmp printc
done:
   ret

;---------------------------------------------------

load_msg                db 'load DeDf_OS ~', 0
fail_msg                db 'read sector failed !!', 0

times 510-($-$$) db 0   ; $ �ǵ�ǰλ��, $$ �Ƕο�ʼλ��, $ - $$ �ǵ�ǰλ���ڶ��ڵ�ƫ��

dw 0xaa55               ; MBR������־

; - End -