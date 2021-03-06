
#include "common.h"

// CGA (Color Graphics Adapter)
// MDA (Monochrome Display Adapter)

#define MONO_BASE       0x3B4
#define MONO_BUF        0xB0000  // 这是MDA的缓冲区地址
#define CGA_BASE        0x3D4
#define CGA_BUF         0xB8000  // 这是CGA的缓冲区地址
#define CRT_ROWS        25
#define CRT_COLS        80
#define CRT_SIZE        (CRT_ROWS * CRT_COLS)

static uint16_t *crt_buf;
static uint16_t crt_pos;
static uint16_t addr_6845;

void cga_init(void)
{
    volatile uint16_t *p = (uint16_t *) (CGA_BUF);
    uint16_t t = *p;
    uint32_t pos;

    *p = (uint16_t) 0xA55A;
    if (*p != 0xA55A)
    {
        p = (uint16_t *) (MONO_BUF);
        addr_6845 = MONO_BASE;
    }
    else
    {
        *p = t;
        addr_6845 = CGA_BASE;
    }

    // get cursor location
    outb(addr_6845, 14);
    pos = inb(addr_6845 + 1) << 8;
    outb(addr_6845, 15);
    pos |= inb(addr_6845 + 1);

    crt_buf = (uint16_t *) p;
    crt_pos = pos;
}

/* cga_putc - print character to console */
void cga_putc(int c)
{
    // set black on white
    if (!(c & ~0xFF))
    {
        c |= 0x0700;
    }

    switch (c & 0xff)
    {
    case '\b':
        if (crt_pos > 0)
        {
            crt_pos--;
            crt_buf[crt_pos] = (c & ~0xff) | ' ';
        }
        break;

    case '\n':
        crt_pos += CRT_COLS;
    case '\r':
        crt_pos -= (crt_pos % CRT_COLS);
        break;

    default:
        crt_buf[crt_pos++] = c;	// write the character
        break;
    }

    // What is the purpose of this?
    if (crt_pos >= CRT_SIZE)
    {
        int i;
        memmove(crt_buf,
            crt_buf + CRT_COLS,
            (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));

        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
        {
            crt_buf[i] = 0x0700 | ' ';
        }

        crt_pos -= CRT_COLS;
    }

    // move that little blinky thing
    outb(addr_6845, 14);
    outb(addr_6845 + 1, crt_pos >> 8);
    outb(addr_6845, 15);
    outb(addr_6845 + 1, (uint8_t)crt_pos);
}