.section ".text.io"

.global mmio_write 
mmio_write:
  str   w1, [x0]
  ret 

.global mmio_read
mmio_read:
  ldr   w0, [x0]
  ret 


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
