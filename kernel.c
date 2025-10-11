#include "io.h"
#include "fb.h"

void main() {
    fb_init();

    drawRect(150,150,400,400,0x07,0);

    drawString(100,100,"Hello quab squab!",0x0f);

    while (1);
}
