.section ".text.mailbox"

.equ MBOX_STATUS, 47256
.equ MBOX_WRITE,  47264
.equ MBOX_READ,   47232
.equ MAILBOX_RESPONSE, -2147483648    
.equ PERIPHERAL_BASE, 65024

.global mbox_call 
  
mbox_call:                              // @mbox_call
// %bb.0:
  // Push Stack Frame 
  stp	  x29, x30, [sp, #-32]!         
	stp	  x20, x19, [sp, #16]
  
  mov	  x29, sp 

  // Load mbox address 
  adrp  x8, mbox 
  add   x8, x8, :lo12:mbox 

  // Get 4 LSB of request 
  and   w19, w0 , #0xf 

  // Create 'r' value; 28-bit addres and 4 bit value 
  orr   w19, w19, w8

  mov   w20, MBOX_STATUS 
	movk	w20, PERIPHERAL_BASE, lsl #16

//Wait for mbox to be writeable 
mbox_full:                            
	mov   w0, w20 
  bl	mmio_read
	tbnz	w0, #31, mbox_full

// Write Request 
	mov   w0, MBOX_WRITE 
  movk  w0, PERIPHERAL_BASE, lsl #16
	mov   w1, w19
	bl	  mmio_write

// Wait for mailbox to be readable 
mbox_empty:                             
	mov   w0, w20
  bl	  mmio_read
	tbnz	w0, #30, mbox_empty

  // Read mailbox 
	mov	  w0, MBOX_READ 
  movk  w0, PERIPHERAL_BASE, lsl #16
	bl	  mmio_read
  
  // Check if reply is to our message 
	cmp	  w19, w0
	b.ne	mbox_empty 
	
  // Get response code 
  adrp	x8, mbox+4
	ldr	  w8, [x8, :lo12:mbox+4] 

  // Return 1 if valid 
	mov	  w9, MAILBOX_RESPONSE            
	cmp	  w8, w9
	cset	w0, eq

  //Load Stack Frame and return
	ldp	  x20, x19, [sp, #16]             // 16-byte Folded Reload
	ldp	  x29, x30, [sp], #32             // 16-byte Folded Reload
	ret

.bss
  .global mbox 

  .p2align 4
  mbox:
    .zero 144 
    .size mbox, 144
    
    .addrsig
    .addrsig_sym mbox
