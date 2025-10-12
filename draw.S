.section ".text.draw"

.globl	drawPixel                     
drawPixel:                              
  // y * pitch + (x << 2 ~~ x * 4) as there are 4 bytes in each cell 
	adrp	x8, pitch
  ldr	  w8, [x8, :lo12:pitch]
  mul	  w8, w8, w1
	add	  w8, w8, w0, lsl #2 


  // Find colour from pallete 
  and	  x9, x2, #0x0f
	adrp	x10, vgapal
	add	  x10, x10, :lo12:vgapal

	ldr	  w9, [x10, x9, lsl #2] // (<< 2 as 4 bytes per int)

  // Write to framebuffer 
	adrp	x10, fb
	ldr	  x10, [x10, :lo12:fb]
	str	  w9, [x10, w8, sxtw]

	ret

