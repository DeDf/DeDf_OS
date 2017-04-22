
; *********************************************************
; * boot.asm for mouseOS operating system project         *
; *                                                       *
; * Copyright (c) 2009-2010                               *
; * All rights reserved.                                  *
; * mik(deng zhi)                                         *
; * visit web site : www.mouseos.com                      *
; * bug send email : mik@mouseos.com                      *
; *                                                       *
; * version 0.01 by mik                                   *
; *********************************************************

BOOT_SEG        equ 0x7c00        ; boot    module load into BOOT_SEG
SETUP_SEG       equ 0x6000        ; setup   module load into SETUP_SEG
INIT_SEG        equ 0x9000        ; init    module load into INIT_SEG 
ROUTINE_SEG     equ 0xb000        ; routine module load into ROUTINE_SEG
DRIVER_SEG      equ 0xc000        ; driver  module load into DRIVER_SEG
MICKEY_SEG      equ 0xd000        ; mickey  module load into MICKEY_SEG

; sector                      floppy image offset

SETUP_SECTOR    equ 1           ; 0x200
INIT_SECTOR     equ 8           ; 0x1000
ROUTINE_SECTOR  equ 18          ; 0x2400
MICKEY_SECTOR   equ 24          ; 0x3000
DRIVER_SECTOR   equ 40          ; 0x5000 

;
; boot (BOOT_SEG:0x7c00) load from floppy sector 0
;   |
;   \-------------> setup         (SETUP_SEG:   0x6000) load from floppy sector 1
;          |          |
;          |          \----> init (INIT_SEG:    0x9000) load from floppy sector 8
;          |
;          \------> runtine       (RUNTINE_SEG: 0xb000) load from floppy sector 18
;          | 
;          \------> driver        (DRIVER_SEG:  0xc000) load from floppy sector 40  
;          |
;          \------> kernel:mickey (MICKEY_SEG:  0xd000) load from floppy sector 24


   bits 16

   org BOOT_SEG                   ; for int 19
 
start:

SYSTEM_CONTROL_PORT             equ     0x92

; A20 gate enable

   cli
   in al, SYSTEM_CONTROL_PORT     ; port - 0x92
   or al, 0x02
   out SYSTEM_CONTROL_PORT, al 
   sti

   mov ax, cs
   mov ds, ax
   mov es, ax
   mov ss, ax
   mov sp, BOOT_SEG
   
   lea si, [load_msg]
   mov ah, 0x0e                   ; 电传打字机输出   AH=0EH   AL=字符，BH=页码，BL=颜色（只适用于图形模式）
   xor bh, bh
   call printmsg

; load setup module from floppy SETUP_SECTOR 
   mov di, SETUP_SECTOR
   mov si, SETUP_SEG - 4
   call load_module
   jc failure

; load init module from floppy INIT_SECTOR
   mov di, INIT_SECTOR
   mov si, INIT_SEG - 8
   call load_module
   jc failure

; load runtine module from floppy ROUTINE_SECTOR
   mov di, ROUTINE_SECTOR
   mov si, ROUTINE_SEG - 8
   call load_module
   jc failure   

; load mickey module from floppy MICKEY_SECTOR
   mov di, MICKEY_SECTOR
   mov si, MICKEY_SEG - 8
   call load_module
   jc failure

; load driver module from floppy DRIVER_SECTOR
   mov di, DRIVER_SECTOR
   mov si, DRIVER_SEG - 8
   call load_module
   jc failure

;-----------------------------------------------
; goto setup module
;------------------------------------------------   
   push 0
   push SETUP_SEG
   retf


failure:
   lea si, [failure_msg]
   mov ah, 0x0e
   xor bh, bh
   call printmsg
   jmp $


;----------------------------------------------------------------------
; read_sector(int sector, char *buf) - read one floppy sector(LBA mode)
; input:  di - sector
;         si - buf
;----------------------------------------------------------------------

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


;-------------------------------------------------------------------------
; load_module(int sector, char *buf) -   load OS module from floppy
;
; input:  di - sector
;         si - buf
;--------------------------------------------------------------------------
load_module:
   call read_sector    ; read_sector(sector, buf)
   jc load_module_done
   call dot
   mov ecx, dword [si]
   add ecx, 512 - 1
   shr ecx, 9
  
load_module_loop:  
   dec ecx
   jz load_module_done 
   inc di
   add si, 0x200
   call read_sector
   jc load_module_done
   call dot
   jmp load_module_loop
 
load_module_done:  
   ret

;-----------------------------------
; printmsg() - print message
;-----------------------------------
printmsg:
   lodsb
   test al,al
   jz done
   int 0x10
   jmp printmsg
done:   
   ret


;--------------------------
; dot() - print dot
;--------------------------
dot:   
   push ax
   push bx
   mov ah, 0x0e
   xor bh, bh
   mov al, '.'
   int 0x10      
   pop bx
   pop ax
   ret
   

load_msg                db 'load DeDf_OS ', 0
failure_msg             db 'failure !!!', 0
   
times 510-($-$$) db 0
   
dw 0xaa55
   
; end of boot.asm