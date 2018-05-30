
SETUP_SEG         equ 0x6000        ; setup module load into SETUP_SEG
INIT_SEG          equ 0x9000
TEMP_PML4T_BASE   equ 0x100000      ; temp pml4t base address(CR3)

;
;    kernel (mickey) (0xffff8000_00400000)
;

;---------------------------------------------------
; Enter proected mode
;---------------------------------------------------
setup_next:

CMOS_INDEX_PORT         equ 0x70

   cli
   in al, CMOS_INDEX_PORT         ; frist: NMI disable, port - 0x70
   or al, 0x80
   out CMOS_INDEX_PORT, al 
 
   db 0x66                        ;   adjust to 32-bit operand size    
   lgdt [temp_gdt_limit]          ; second: load temp GDT into gdtr
  
   mov eax, cr0                   ; third: enable proected mode
   bts eax, 0                     ;   CR0.PE = 1
   bts eax, 1                     ;   CR0.MP = 1
   mov cr0, eax                   ;   enable protected mode
 
   jmp dword code32_sel:code32_entry  ; fourth: far jmp proected mode code

   
   bits 32

; Now: entry 32bit protected mode, but paging is disable
;  So: memory address is physical address

 code32_entry:

   mov ax, data32_sel
   mov ds, ax
   mov es, ax
   mov ss, ax
   mov esp, 0x7ff0

;------------------------------------
; setup for long mode
;------------------------------------
 
   call init_temp_page
 
   ; now: set temp CR3 for temp long mode
   mov eax, TEMP_PML4T_BASE
   mov cr3, eax
   
   mov ecx, 0xc0000080         ; EFER registe address
   rdmsr                       ; read into edx:eax
   bts eax, 8                  ; enable long mode
   bts eax, 0                  ; enable syscall/sysret
   wrmsr                       ; write into EFER with edx:eax
   
   mov eax, cr4
   bts eax, 5                  ; CR4.PAE = 1
   bts eax, 9                  ; CR4.OSFXSR = 1
   mov cr4, eax   

   mov eax,cr0
   bts eax, 0
   bts eax, 31                 ; enable page
   mov cr0,eax                 ; active long mode

; Now,here processor running at long mode
; but it's compatibility mode with legacy GDT and legacy IDT, legacy TSS
; CS is legacy protected mode's code segment selector

   ; jmp for enter long mode - 64bit mode
   ; and selector index descriptor at legacy GDT
   jmp code64_sel:code64_entry

                align 4
IMAGE_BASE   dq  0
ENTRY_RVA    dd  0

;---------------------------------------
; long mode - 64bit code 
;---------------------------------------   
   bits 64
   
code64_entry:
; the step: enter long mode, the long mode is temporary, too

   ;mov ebx, dword [mem_total]

; 解析PE文件，加载.text, .data节，然后转到
   mov rbx, INIT_SEG
   mov ax, WORD [ebx]
   cmp ax, 0x5A4D                    ; 'MZ'
   jnz $
   
   add ebx, DWORD [ebx + 0x3C]        ; sizeof(IMAGE_DOS_HEADER) == 0x3C
   mov eax, DWORD [ebx]
   cmp eax, 0x4550                   ; 'PE'
   jnz $
   
   mov eax, DWORD [ebx + 0x28]        ; NtHeader.OptionalHeader.AddressOfEntryPoint
   mov DWORD [ENTRY_RVA], eax
   
   mov rax, QWORD [ebx + 0x30]        ; NtHeader.OptionalHeader.ImageBase
   mov QWORD [IMAGE_BASE], rax
   
   add ebx, 0x108                     ; p + sizeof(IMAGE_NT_HEADERS64)
   mov rax, QWORD [ebx]
   mov rcx, 0x747865742E              ; .text
   cmp rax, rcx
   jnz $
   
;--------------------------------------
; copy .text
;--------------------------------------
   xor rcx, rcx
   mov ecx, DWORD [ebx + 8]           ; .text size
   
   xor rax, rax
   mov eax, DWORD [ebx + 0x14]        ; .text RAW
   mov rsi, INIT_SEG
   add rsi, rax                       ; .text In INIT_SEG
   
   xor rax, rax
   mov eax, DWORD [ebx + 0xC]         ; .text RVA
   mov rdi, QWORD [IMAGE_BASE]
   add rdi, rax
   
   rep movsb
   
;--------------------------------------
; copy .data
;--------------------------------------
   add ebx, 0x28
   
   xor rcx, rcx
   mov ecx, DWORD [ebx + 8]           ; .data size
   
   xor rax, rax
   mov eax, DWORD [ebx + 0x14]        ; .data RAW
   mov rsi, INIT_SEG
   add rsi, rax                       ; .data In INIT_SEG
   
   xor rax, rax
   mov eax, DWORD [ebx + 0xC]         ; .data RVA
   mov rdi, QWORD [IMAGE_BASE]
   add rdi, rax
   
   rep movsb
   
;----------------------------------
; enter mickey.init
;----------------------------------   
   mov rax, QWORD [IMAGE_BASE]        ; 0xffff800000000000
   xor rcx, rcx
   mov ecx, DWORD [ENTRY_RVA]
   add rax, rcx
   push code64_sel                    ; temp_GDT entry
   push rax
   dw 0xcb48                          ; retf_qword

   bits 32

;----------------------------------------------------
; temp page translation table structure for long mode
; the pml4t base is: TEMP_PML4T_BASE (0x100000)
;----------------------------------------------------

;      virtual                    physical                      size
; 1.  0x00000000                 0x00000000 (2M page)            2M
; 2.  0xffff8000_00000000        0x00200000 (2M page)            2M
;

init_temp_page:

PG_P            equ 0x01
PG_W            equ 0x02
PG_USER         equ 0x04    ; A user-mode access caused the fault.
PG_PS           equ 0x80    ; PDE : 2M page

;----------  0 map to 0 --------------

; set pml4e:  pml4t[0] ---> 0x101000
   mov eax, TEMP_PML4T_BASE
   mov dword [eax], 0x101000 | PG_P | PG_W | PG_USER
   mov dword [eax + 4], 0
   
; set pdpe:  pdpt[0] ---> 0x102000
   mov eax, 0x101000
   mov dword [eax], 0x102000 | PG_P | PG_W | PG_USER
   mov dword [eax + 4], 0
   
; set pde:  pdt[0] ---> 0x00000000 (2M-page)
   mov eax, 0x102000
   mov dword [eax], 0 | PG_P | PG_W | PG_USER | PG_PS
   mov dword [eax + 4], 0

; -----  0xffff8000_00000000 map to 0x200000 -----

; set pml4e:  pml4t[0x100] ---> 0x103000
   mov eax, TEMP_PML4T_BASE
   mov dword [eax + 0x100 * 8], 0x103000 | PG_P | PG_W | PG_USER
   mov dword [eax + 0x100 * 8 + 4], 0
 
; set pdpe:  pdpt[0] ---> 0x104000
   mov eax, 0x103000
   mov dword [eax], 0x104000 | PG_P | PG_W | PG_USER
   mov dword [eax+4] , 0
 
; set pde:  pdt[0] ---> 0x200000 (2M-page)
   mov eax, 0x104000
   mov dword [eax], 0x200000 | PG_P | PG_W | PG_USER | PG_PS
   mov dword [eax + 4], 0   
   
   ret

; *** temp system data structure  ***

                align 4
TEMP_GDT:   
null            dq 0

temp_code32     dd 0x0000ffff      ; base=0, limit=0xfffff
                dd 0x00cf9a00      ; G=1,D=1,P=1,C=0,R=1, DPL=00   

temp_code64     dd 0x0000ffff
                dd 0x002f9a00

temp_data32     dd 0x0000ffff      ; base=0,limit=0xffff
                dd 0x00cf9200      ; G=1,D=1,P=1,E=0,W=1, DPL=00            
TEMP_GDT_END:


code32_sel      equ 0x08      ; selector.SI = 1
code64_sel      equ 0x10      ; selector.SI = 2
data32_sel      equ 0x18      ; selector.SI = 3


temp_gdt_limit  dw TEMP_GDT_END - TEMP_GDT
temp_gdt_base   dd TEMP_GDT


setup_end:
