
#pragma once
//#pragma comment (linker, "/MERGE:.rdata=.data")

typedef          char      int8_t;
typedef unsigned char     uint8_t;

typedef          short    int16_t;
typedef unsigned short   uint16_t;

typedef          int      int32_t;
typedef unsigned int     uint32_t;

typedef          __int64  int64_t;
typedef unsigned __int64 uint64_t;

typedef unsigned __int64   size_t;

//=================regs.asm=================
void outb(uint16_t port, uint8_t data);
uint8_t inb(uint16_t port);

void cpu_idle(void);

//=================common.c=================
void * __cdecl memmove (
                        void * dst,
                        const void * src,
                        size_t count
                        );

//=================CGA.c=================
void cga_init(void);
void cga_putc(int c);

