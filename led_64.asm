 /*
 * led_64.asm
 *   Author: COURS
 */ 

; file	ws2812b_4MHz_demo01_S.asm   target ATmegred28L-4MHz-STK300
; purpose send data to ws2812b using 4 MHz MCU and standard I/O port
;         display and paralllel process (blinking LED0)
; usage: buttons on PORTC, ws2812 on PORTD (bit 1)
;        press button 0
;       a pattern is stored into memory and displayed on the array
;       LED0 blinks fast; when button0 is pressed and released, LED1
;       akcnowledges and the pattern displayed on the array moves by
;       one memory location
; warnings: 1/2 timings of pulses in the macros are sensitive
;			2/2 intensity of LEDs is high, thus keep intensities
;				within the range 0x00-0x0f, and do not look into
;				LEDs
; 20220315 AxS

; led_64_WR0	; macro ; arg: void; used: void
; purpose: write an active-high zero-pulse to PD1

; si besoin mettre cli et sei pour bloquer les interuptions
.macro	led_64_WR0
	clr u
	sbi PORTB, 1
	out PORTB, u
	nop
	nop
	;nop	;deactivated on purpose of respecting timings
	;nop
.endm

; led_64_WR1	; macro ; arg: void; used: void
; purpose: write an active-high one-pulse to PD1
.macro	led_64_WR1
	sbi PORTB, 1
	nop
	nop
	cbi PORTB, 1
	;nop	;deactivated on purpose of respecting timings
	;nop

.endm


; led_64_write	; arg: green,red,_blue ; used: r16 (w)
; purpose: write contents of green,red,_blue (24 bit) into ws2812, 1 LED configuring
;     GBR color coding, LSB first

led_64_write:

	ldi w,8
led_64_start_green:
	sbrc green,7
	rjmp	led_64w1
	led_64_WR0			; write a zero
	rjmp	led_64_next_green
led_64w1:
	led_64_WR1
led_64_next_green:
	lsl green
	dec	w
	brne led_64_start_green

	ldi w,8
led_64_start_red:
	sbrc red,7
	rjmp	led_64w1_red
	led_64_WR0			; write a zero
	rjmp	led_64_next_red
led_64w1_red:
	led_64_WR1
led_64_next_red:
	lsl red
	dec	w
	brne led_64_start_red

	ldi w,8
led_64_start_blue:
	sbrc blue,7
	rjmp	led_64w1_blue
	led_64_WR0			; write a zero
	rjmp	led_64_next_blue
led_64w1_blue:
	led_64_WR1
led_64_next_blue:
	lsl blue
	dec	w
	brne led_64_start_blue
	
ret

; led_64_reset	; arg: void; used: r16 (w)
; purpose: reset pulse, configuration becomes effective
led_64_reset:
	cbi PORTB, 1
	WAIT_US	50 	; 50 us are required, NO smaller works
ret

; led_64_ini		; arg: void; used: r16 (w)
; purpose: initialize AVR to support ws2812
led_64_init:
	OUTI	DDRB,0x02
ret
