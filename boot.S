.section ".text.boot"

.global _start 

_start: 
    // Find PID 
    mrs   x1, mpidr_el1 

    // Halt secondary cores (for now?)
    and   x1, x1, #3
    cbz   x1, 2f 
    
    // HALT 
1:  wfe 
    b     1b 
2:  // PID == 1 (boot core) 

    // Setup stack 
    ldr   x1, =_start 
    mov   sp, x1 

    // Setup BSS 
    ldr   x1, =__bss_start 
    ldr   w2, =__bss_size 

    // Loop to clear BSS 
3:  cbz   w2, 4f 
    str   xzr, [x1], #8 
    sub   w2, w2, #1 
    cbnz  w2, 3b
    
4:  bl    fb_init

    mov   x0, #150
    mov   x1, #150 
    mov   x2, #400 
    mov   x3, #400 
    mov   x4, #7 
    bl    drawRect
    
    
    mov   x0, #100 
    mov   x1, #100 
    ldr   x2, =helloString 
    mov   x3, #15
    bl    drawString
  
    //HALT 
    b     1b 

.data 
    helloString:
      .string "Hello, Quab Squab!"
