#include "io.h"

volatile unsigned int __attribute__((aligned(16))) mbox[36];

void mmio_write(long reg, unsigned int val) { *(volatile unsigned int *)reg = val; }
unsigned int mmio_read(long reg) { return *(volatile unsigned int *)reg; }

enum {
    VIDEOCORE_MBOX = (PERIPHERAL_BASE + 0x0000B880),
    MBOX_READ      = (VIDEOCORE_MBOX + 0x0),
    MBOX_POLL      = (VIDEOCORE_MBOX + 0x10),
    MBOX_SENDER    = (VIDEOCORE_MBOX + 0x14),
    MBOX_STATUS    = (VIDEOCORE_MBOX + 0x18),
    MBOX_CONFIG    = (VIDEOCORE_MBOX + 0x1C),
    MBOX_WRITE     = (VIDEOCORE_MBOX + 0x20),
    MBOX_RESPONSE  = 0x80000000,
    MBOX_FULL      = 0x80000000,
    MBOX_EMPTY     = 0x40000000
};

unsigned int mbox_call(unsigned char ch)
{
    unsigned int r = ((unsigned int)((long) &mbox) &~ 0xF) | (ch & 0xF);

    while (mmio_read(MBOX_STATUS) & MBOX_FULL);
    
    mmio_write(MBOX_WRITE, r);

    while (1) {
        while (mmio_read(MBOX_STATUS) & MBOX_EMPTY);

        if (r == mmio_read(MBOX_READ)) return mbox[1]==MBOX_RESPONSE;
           
    }
    return 0;
}
