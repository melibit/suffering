.section ".text.boot"

.global _start 

_start: 
    // Find PID 
    mrs   x1, mpidr_el1 

    // Halt secondary cores (for now?)
    and   x1, x1, #3
    cbz   x1, init
    
    // HALT 
halt:  
    wfe 
    b     halt
init:  // PID == 1 (boot core) 

    // Setup stack 
    ldr   x1, =_start 
    mov   sp, x1 

    // Setup BSS 
    ldr   x1, =__bss_start 
    ldr   w2, =__bss_size 

    // Loop to clear BSS 
_bss:  
    cbz   w2, test_pattern
    str   xzr, [x1], #8 
    sub   w2, w2, #1 
    cbnz  w2, _bss
    
test_pattern:  
    bl    fb_init
    
    mov   x0, #20
    mov   x1, #20
    ldr   x2, =helloString 
    mov   x3, #15
    bl    drawString

    mov   x0, #150
    mov   x1, #150 
    mov   x2, #400 
    mov   x3, #400 
    mov   x4, #7 
    mov   x5, #0
    bl    drawRect
    
    
    mov   x0, #100
    mov   x1, #100
    ldr   x2, =shortString 
    mov   x3, #15
    bl    drawString
    
    mov   x0, #100
    mov   x1, #150 
    mov   x2, #300 
    mov   x3, #400 
    mov   x4, #7 
    bl    drawLine
    
    mov   x0, #960
    mov   x1, #540 
    mov   x2, #250
    mov   x3, #4 
    mov   x4, #0
    bl    drawCircle  
    

    mov   x0, #960
    mov   x1, #540 
    mov   x2, #150
    mov   x3, #4 
    mov   x4, #0
    bl    drawCircle  
    
    mov   x0, #350
    mov   x1, #650 
    mov   x2, #600 
    mov   x3, #800 
    mov   x4, #4
    mov   x5, #1
    bl    drawRect
     
    //HALT 
    b     halt

.data 
    helloString:
      .string "Hello, Quab Squab!"
    shortString:
      .string "Gabriel, is short lmao"
