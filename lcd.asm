 /*
 * lcd.asm
 *   Author: COURS
 */ 

; === definitions ===
.equ	LCD_IR	= 0x8000	; address LCD instruction reg
.equ	LCD_DR	= 0xc000	; address LCD data register

; === subroutines ===
LCD_wr_ir:
; in	w (byte to write to LCD IR)
	lds	u, LCD_IR		; read IR to check busy flag  (bit7)
	JB1	u,7,LCD_wr_ir	; Jump if Bit=1 (still busy)
	rcall	lcd_4us		; delay to increment DRAM addr counter
	sts	LCD_IR, w		; store w in IR
	ret
lcd_4us:
	rcall	lcd_2us		; recursive call		
lcd_2us:
	nop					; rcall(3) + nop(1) + ret(4) = 8 cycles (2us)
	ret

LCD:
LCD_putc:
	JK	r18,CR,LCD_cr	; Jump if r18=CR
	JK	r18,LF,LCD_lf	; Jump if r18=LF
LCD_wr_dr:
; in	r18 (byte to write to LCD DR)
	lds	w, LCD_IR		; read IR to check busy flag  (bit7)
	JB1	w,7,LCD_wr_dr	; Jump if Bit=1 (still busy)
	rcall	lcd_4us		; delay to increment DRAM addr counter
	sts	LCD_DR, r18		; store r18 in DR
	ret	
LCD_clear:		JW	LCD_wr_ir, 0b00000001		; clear display
LCD_home:		JW	LCD_wr_ir, 0b00000010		; return home
LCD_cursor_left:	JW	LCD_wr_ir, 0b00010000	; move cursor to left
LCD_cursor_right:	JW	LCD_wr_ir, 0b00010100	; move cursor to right
LCD_display_left:	JW	LCD_wr_ir, 0b00011000	; shifts display to left
LCD_display_right:	JW	LCD_wr_ir, 0b00011100	; shifts display to right
LCD_blink_on:		JW	LCD_wr_ir, 0b00001101	; Display=1,Cursor=0,Blink=1
LCD_blink_off:		JW	LCD_wr_ir, 0b00001100	; Display=1,Cursor=0,Blink=0
LCD_cursor_on:		JW	LCD_wr_ir, 0b00001110	; Display=1,Cursor=1,Blink=0
LCD_cursor_off:		JW	LCD_wr_ir, 0b00001100	; Display=1,Cursor=0,Blink=0
LCD_init:
	in	w,MCUCR					; enable access to ext. SRAM
	sbr	w,(1<<SRE)+(1<<SRW10)
	out	MCUCR,w
	CW	LCD_wr_ir, 0b00000001	; clear display
	CW	LCD_wr_ir, 0b00000110	; entry mode set (Inc=1, Shift=0)
	CW	LCD_wr_ir, 0b00001100	; Display=1,Cursor=0,Blink=0	
	CW	LCD_wr_ir, 0b00111000	; 8bits=1, 2lines=1, 5x8dots=0
	ret

LCD_pos:
; in	r18 = position (0x00..0x0f first line, 0x40..0x4f second line)
	mov	w,r18
	ori	w,0b10000000
	rjmp	LCD_wr_ir

LCD_cr:
; moving the cursor to the beginning of the line (carriage return)
	lds	w, LCD_IR			; read IR to check busy flag  (bit7)
	JB1	w,7,LCD_cr			; Jump if Bit=1 (still busy)
	andi	w,0b01000000	; keep bit6 (begin of line 1/2)
	ori	w,0b10000000		; write address command
	rcall	lcd_4us			; delay to increment DRAM addr counter
	sts	LCD_IR,w			; store in IR
	ret

LCD_lf:
; moving the cursor to the beginning of the line 2 (line feed)
	push	r18				; safeguard r18
	ldi	r18,$40				; load position $40 (begin of line 2)
	rcall	LCD_pos			; set cursor position
	pop	r18					; restore r18
	ret

putdec:
; put decimal value 
; in 	a0	(value to convert)
;	putc 	(address of a routine to "write" the character)

	mov	u,r18			; number to convert is kept in u

	ldi	r18,'0'-1		; preload a0 (digit)
	ldi	w,100			; load the "hundreds"
_putdec2:	
	inc	r18
	sub	u,w				; subtract 100
	brsh	_putdec2	; until the result is negative
	add	u,w				; undo the last substraction
	rcall	LCD_putc		; display the digit2

	ldi	r18,'0'-1		; preaload a0 (digit)
	ldi	w,10			; load the "tens"
_putdec1:	
	inc	r18
	sub	u,w				; subtract 10
	brsh	_putdec1	; until the result is negative
	add	u,w				; undo the last substraction
	rcall	LCD_putc		; display digit1
	ldi	r18,'0'	
	add	r18,u
	rcall	LCD_putc		; display digit0
	ret