.section ".text.draw"

.global	drawPixel                     
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

.global drawRect
drawRect:
  stp x29, x30, [sp, #-16]! 
  mov x29, sp 

  mov   w20, w0    // x1
  mov   w21, w1    // y1
  mov   w22, w2    // x2
  mov   w23, w3    // y2
  mov   w24, w5

  mov   w2, w4    // attr

drawRect_y:
  cmp   w1, w23
  b.gt  drawRect_end

  mov   w0, w20   // current x

drawRect_x:
  cmp   w0, w22
  b.gt  drawRect_x_end
  
  cbnz  w24, drawRect_draw //fill 

  cmp   w0, w20
  b.eq  drawRect_draw
  cmp   w0, w22
  b.eq  drawRect_draw
  cmp   w1, w21
  b.eq  drawRect_draw
  cmp   w1, w23
  b.eq  drawRect_draw

  add   w0, w0, #1
  b drawRect_x

drawRect_draw:
  add   w0, w0, #1
  bl drawPixel
  b drawRect_x

drawRect_x_end:
  add   w1, w1, #1
  b drawRect_y

drawRect_end:
  ldp x29, x30, [sp], #16
  ret
