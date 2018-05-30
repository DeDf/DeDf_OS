;-------------------------------------------------------------------------
;                          Version 0.0.1 by DeDf
; BIOS INT 19h �Ὣ MBR (512�ֽ�)װ�ص��ڴ�0x7c00����Ȼ��JUMP��0x7c00ִ��
;-------------------------------------------------------------------------

   bits 16       ; ָ��Ϊ16λ���ģʽ
   org 0x7c00    ; ָ���������ʼ��ַΪ0x7c00

start:

   xor ax, ax
   mov ds, ax
   mov es, ax
   mov ss, ax
   mov sp, 0x7c00
   
;---------------------------------------------------
; enable A20 gate  https://wiki.osdev.org/A20_Line
;---------------------------------------------------

   cli
   in al, 0x92   ; port 0x92 - System control and status register
   or al, 2
   out 0x92, al  ; port 0x92
   sti

;---------------------------------------------------

   call get_system_memory
   test eax, eax
   jz memory_failure
   
;---------------------------------------------------

   mov eax, 0x80000000            ; test cpu        
   cpuid 
   cmp eax, 0x80000000            ;   is support externed feature ?
   jbe cpu_no_long
   mov eax, 0x80000001            ;   get cupid
   cpuid
   bt edx, 29                     ;   is support long mode ?
   jnc cpu_no_long
   jmp $

;---------------------------------------------------

cpu_no_long:
   lea esi, [cpu_no_long_msg]
   call print
   jmp $
   
memory_failure:
   lea si, [mem_msg]
   call print
   jmp $

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
get_system_memory:

memseg_count_low    equ 0x6000
memseg_count_high   equ 0x6004
mem_OS_low          equ 0x6008
mem_OS_high         equ 0x600c
ARDS_table          equ 0x6010

;struct e820entry {  
;    __u64 addr; /* start of memory segment */
;    __u64 size; /* size of memory segment */
;    __u32 type; /* type of memory segment */
;} ARDS, Address Range Descriptor Structure

do_e820:
   xor ebx, ebx
   mov [memseg_count_low],  ebx
   mov [memseg_count_high], ebx
   mov [mem_OS_low],        ebx
   mov [mem_OS_high],       ebx
   mov edi, ARDS_table          ; ���ARDS��

do_e820_loop:   
   mov eax, 0xe820
   mov ecx, 20                  ; sizeof(ARDS) == 20
   mov edx, 0x534d4150          ; 'SMAP'����Ϊϵͳӳ��
   int 0x15
   jc get_system_memory_failure
   xor eax, 0x534d4150          ; 'SMAP'
   jnz get_system_memory_failure
   test ebx, ebx
   jz get_system_memory_done
   
; --- use e820 get memory size ---   

   mov eax, dword [edi+16]      ; ARDS.type
   cmp eax, 1                   ; type == OS_RAM
   jne do_e820_next
   mov eax, dword [mem_OS_low]
   mov esi, dword [edi+8]       ; lengthLow
   add eax, esi
   mov [mem_OS_low], eax
   mov eax, dword [mem_OS_high]
   mov esi, dword [edi+0xc]     ; lengthHigh
   adc eax, esi
   mov [mem_OS_high], eax
   
do_e820_next:   
   mov dword [memseg_count_low], ebx  ; ebxֵΪ�ڴ��index����1����
   add edi, ecx
   jmp do_e820_loop
   
get_system_memory_failure:
   xor eax, eax

get_system_memory_done:  
   mov eax, 1
   ret

;---------------------------------------------------

mem_msg          db 'e820 !',  0
cpu_no_long_msg  db 'no long mode !', 0

times 510-($-$$) db 0   ; $ �ǵ�ǰλ��, $$ �Ƕο�ʼλ��, $ - $$ �ǵ�ǰλ���ڶ��ڵ�ƫ��

dw 0xaa55               ; MBR������־

; - End -