
#pragma comment (linker, "/MERGE:.rdata=.data")

typedef          char      int8_t;
typedef unsigned char     uint8_t;

typedef          short    int16_t;
typedef unsigned short   uint16_t;

typedef          int      int32_t;
typedef unsigned int     uint32_t;

typedef          __int64  int64_t;
typedef unsigned __int64 uint64_t;

/***** Serial I/O code *****/
#define COM1            0x3F8

#define COM_RX          0	// In:  Receive buffer (DLAB=0)
#define COM_TX          0	// Out: Transmit buffer (DLAB=0)
#define COM_DLL         0	// Out: Divisor Latch Low (DLAB=1)
#define COM_DLM         1	// Out: Divisor Latch High (DLAB=1)
#define COM_IER         1	// Out: Interrupt Enable Register
#define COM_IER_RDI     0x01	// Enable receiver data interrupt
#define COM_IIR         2	// In:  Interrupt ID Register
#define COM_FCR         2	// Out: FIFO Control Register
#define COM_LCR         3	// Out: Line Control Register
#define COM_LCR_DLAB    0x80	// Divisor latch access bit
#define COM_LCR_WLEN8   0x03	// Wordlength: 8 bits
#define COM_MCR         4	// Out: Modem Control Register
#define COM_MCR_RTS     0x02	// RTS complement
#define COM_MCR_DTR     0x01	// DTR complement
#define COM_MCR_OUT2    0x08	// Out2 complement
#define COM_LSR         5	// In:  Line Status Register
#define COM_LSR_DATA    0x01	// Data available
#define COM_LSR_TXRDY   0x20	// Transmit buffer avail
#define COM_LSR_TSRE    0x40	// Transmitter off
#define COM_BAUDRATE    115200

#define CONSBUFSIZE 512

static struct {
    uint8_t buf[CONSBUFSIZE];
    uint32_t rpos;
    uint32_t wpos;
} cons;

void outb(uint16_t port, uint8_t data);
uint8_t inb(uint16_t port);

int serial_exists;

static void serial_init(void)
{
    // Turn off the FIFO
    outb(COM1 + COM_FCR, 0);

    // Set speed; requires DLAB latch
    outb(COM1 + COM_LCR, COM_LCR_DLAB);
    outb(COM1 + COM_DLL, (uint8_t) (115200 / COM_BAUDRATE));
    outb(COM1 + COM_DLM, 0);

    // 8 data bits, 1 stop bit, parity off; turn off DLAB latch
    outb(COM1 + COM_LCR, COM_LCR_WLEN8 & ~COM_LCR_DLAB);

    // No modem controls
    outb(COM1 + COM_MCR, 0);
    // Enable rcv interrupts
    outb(COM1 + COM_IER, COM_IER_RDI);

    // Clear any preexisting overrun indications and interrupts
    // Serial port doesn't exist if COM_LSR returns 0xFF
    serial_exists = (inb(COM1 + COM_LSR) != 0xFF);
    (void)inb(COM1 + COM_IIR);
    (void)inb(COM1 + COM_RX);
}

/* stupid I/O delay routine necessitated by historical PC design flaws */
static void delay(void)
{
    inb(0x84);
    inb(0x84);
    inb(0x84);
    inb(0x84);
}

static void serial_putc_sub(int c)
{
    // 若TX处于非就绪状态则delay
    int i;
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i++)
    {
        delay();
    }

    outb(COM1 + COM_TX, c);
}

/* serial_putc - print character to serial port */
static void serial_putc(int c)
{
    if (c == '\b')
    {
        serial_putc_sub('\b');
        serial_putc_sub(' ');
        serial_putc_sub('\b');
    }
    else
    {
        serial_putc_sub(c);
    }
}

int Init()
{
    const unsigned char *p = "(THU.CST) os is loading ...\n";
    int StrLen = sizeof("(THU.CST) os is loading ...\n") - 1;
    int i;

    serial_init();
    
    for (i = 0; i < StrLen; i++)
    {
        serial_putc((int)*(p+i));
    }

L_spin:
    goto L_spin;
	return 0;
}

