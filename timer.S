.section ".text.timer"

.equ CPFL, 0x000F
.equ CPFH, 0xDE80

.global wait_msec 
wait_msec: 
  mrs   x20, cntfrq_el0 
  mov   x19, #1000
  sdiv  x20, x20, x19
  mrs   x19, cntpct_el0 
  madd  x20, x0, x20, x19 // Calculate End Time
wait_msec_loop:
  cmp   x19, x20 
  b.gt  wait_msec_end 
  mrs   x19, cntpct_el0 
  b     wait_msec_loop
wait_msec_end:
  ret 

.global start_frame
start_frame:
    mrs   x0, cntpct_el0 
    mov   x1, CPFL
    movk  x1, CPFH, lsl #16 
    add   x0, x0, x1
    str   x0, [sp, #-16]!
    ret

.global end_frame
end_frame:
    adrp  x2, framecount 
    add   x2, x2, :lo12:framecount
    ldr   x1, [x2]
    mov   x0, #1 
    add   x1, x1, x0
    str   x1, [x2]
    ldr   x0, [sp], #16 
end_frame_loop:
    mrs   x1, cntpct_el0 
    cmp   x0, x1 
    b.lt  end_frame_loop
    ret 

.global get_framecount
get_framecount:
    adrp  x1, framecount 
    add   x1, x1, :lo12:framecount
    ldr   x0, [x1]
    ret 
    

.bss 
  .global framecount 
  
  .p2align 4 
  framecount:
    .int 0 
