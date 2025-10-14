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
  stp   x29, x30, [sp, #-16]! 
  mov   x29, sp 

  mov   w20, w0    // x1
  mov   w21, w1    // y1
  mov   w22, w2    // x2
  mov   w23, w3    // y2
  mov   w24, w5    // fill

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
  ldp   x29, x30, [sp], #16
  ret

.global drawLine 
drawLine:
  stp   x29, x30, [sp, #-16]! 
  mov   x29, sp 

  mov   w20, w0    // x1
  mov   w21, w1    // y1
  mov   w22, w2    // x2
  mov   w23, w3    // y2
  
  mov   w2, w4 

  sub   w24, w22, w20 // dx 
  sub   w25, w23, w21 // dy 
  
  add   w26, w25, w25 // p = 2dy...
  sub   w26, w26, w24 //     -dx 

drawLine_loop: 
  cmp   w0, w22 
  b.gt  drawLine_end
  
  bl    drawPixel 
  
  add   w0, w0, #1 

  cmp   w26, #0 
  b.ge  drawLine_p  
  
  add   w26, w26, w25 
  add   w26, w26, w25 

  b     drawLine_loop 
drawLine_p:
  add   w1, w1, #1 
  add   w26, w26, w25 
  add   w26, w26, w25 
  sub   w26, w26, w24 
  sub   w26, w26, w24 
  
  b     drawLine_loop 

drawLine_end:
  ldp   x29, x30, [sp], #16
  ret

.global drawCircle 
drawCircle: 
  stp   x29, x30, [sp, #-16]! 
  mov   x29, sp 
  
  mov   w20, w0   // a (x0)  
  mov   w21, w1   // b (y0)
 
  mov   w22, w2   // x = radius 
  eor   w23, w23, w23 // y = 0 

  eor   w24, w24, w24 // err = 0 
  
  mov   w2, w3 //attr 

drawCircle_loop:
  cmp   w22, w23 
  b.lt  drawCircle_end

drawCircle_draw:
  // a - y, b + x 
  sub   w0, w20, w23 
  add   w1, w21, w22 
  bl    drawPixel 
  // a + y, b + x 
  add   w0, w20, w23 
  add   w1, w21, w22 
  bl    drawPixel 
  // a - x, b + y 
  sub   w0, w20, w22
  add   w1, w21, w23 
  bl    drawPixel 
  // a + x, b + y
  add   w0, w20, w22 
  add   w1, w21, w23 
  bl    drawPixel 
  
  // a - y, b - x 
  sub   w0, w20, w23 
  sub   w1, w21, w22 
  bl    drawPixel 
  // a + y, b - x 
  add   w0, w20, w23 
  sub   w1, w21, w22 
  bl    drawPixel 
  // a - x, b - y 
  sub   w0, w20, w22
  sub   w1, w21, w23 
  bl    drawPixel 
  // a + x, b - y
  add   w0, w20, w22 
  sub   w1, w21, w23 
  bl    drawPixel 

  eor   w25, w25, w25 
  cmp   w24, w25 
  b.lt  drawCircle_err 
  sub   w22, w22, #1  
  sub   w24, w24, w22 
  sub   w24, w24, w22  
  sub   w24, w24, #1 
  
  b     drawCircle_loop 
drawCircle_err: 
  add   w23, w23, #1 
  add   w24, w24, w23 
  add   w24, w24, w23  
  add   w24, w24, #1 
  b     drawCircle_loop 

drawCircle_end:
  ldp   x29, x30, [sp], #16
  ret  
