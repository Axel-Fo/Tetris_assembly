 /*
 * lcd_routine.asm
 * toutes les sous routines utiles pour le LCD
 *   Author: GROUPE 91
 */ 
 .include "lcd.asm"
 .include "eeprom.asm"

;==== SET SCREEN 1 ====
;affiche "ENTER YOUR NAME:" en ligne 1 et place le curseur en ligne 2
;utilise registre : 18,19,20,x,z
set_screen1:
	rcall LCD_init

	ldi xl, 0x10
	ldi xh, 0x00
	ldi	zl, low(2*str0)	; load pointer to string
	ldi	zh, high(2*str0)
	rcall	LCD_putstring
	ldi r19, 0x40
	mov r18,r19
	rcall LCD_pos
	ldi r20, 0
	rcall ECRITURE
	mov r18, r19
	rcall LCD_pos
	ret

;==== SET SCREEN 2 ====
; affiche "last score:" et le last score avec son nom
;utilise registre : 18,19,25,x,z
set_screen2:
	rcall LCD_clear
	ldi	zl, low(2*str1)	; load pointer to string
	ldi	zh, high(2*str1)
	rcall	LCD_putstring
	ldi r19, 0x40
	mov r18,r19
	rcall LCD_pos
	ldi r25, 5
	ldi xl, 0x00
	ldi xh, 0x00
loop_name:
	rcall eeprom_load
	rcall LCD_put1
	dec r25
	brne loop_name
	rcall eeprom_load
	rcall putdec
	ret

;==== SET SCREEN 3 ====
; affiche "score:" et le score de la partie 
;utilise registre : 18,19,x,z
set_screen3:
	rcall LCD_clear
	ldi	zl, low(2*str2)	; load pointer to string
	ldi	zh, high(2*str2)
	rcall	LCD_putstring
	ldi r19, 0x40
	mov r18,r19
	rcall LCD_pos
	lds r18, score
	ldi xl, 0x05
	ldi xh, 0x00
	rcall eeprom_store
	rcall putdec
	ret

;==== writing ====
; lis les boutons-poussoirs et renvois vers leur sous-routines 
;utilise registre : 18,23
writing:
	in	r18,PIND			; read switches
	ldi r23,0b11111101
	cp r18, r23
	brne PC+2
	rcall plus_letter
	ldi r23,0b11111011
	cp r18, r23
	brne PC+2
	rcall moins_letter
	ldi r23,0b11110111
	cp r18, r23
	brne PC+2
	rcall	LCD_put0
	ldi r23,0b11101111
	cp r18, r23
	brne PC+2
	rcall	reset_name	
	wait_MS 200
	ret

;==== plus_letter ====
; incrémente les lettre lors de l'écritue du nom
;utilise registre : 18,19, r20
plus_letter:
	ADDI r20, 1
	rcall ECRITURE
	mov r18, r19
	rcall LCD_pos
	ret

;==== moins_letter ====
; décrémente les lettre lors de l'écritue du nom
;utilise registre : 18,19, r20
moins_letter:
	subi r20, 1
	rcall ECRITURE
	mov r18, r19
	rcall LCD_pos
	ret

;==== reset_name ====
; efface le nom et replace le curseur au début de la ligne
reset_name:
	rcall LCD_clear
	rcall set_screen1
	ret

;==== LCD_put0 ====
; écris le nom et le store dans la EEPROM
;utilise registre : 18,19, r20, x
LCD_put0:
	rcall ECRITURE
	inc r19
	mov r18, r19
	rcall LCD_pos
	mov r18, r20
	rcall eeprom_store
	inc xl
	ldi r20, 0
	rcall ECRITURE
	mov r18, r19
	rcall LCD_pos
	ret

;==== LCD_put1 ====
; écris le last name
;utilise registre : 18,19, r20, x
LCD_put1:
	mov r20,r18
	rcall ECRITURE
	inc r19
	mov r18, r19
	rcall LCD_pos
	inc xl
	ret

;==== ECRITURE ====
; écris une lettre
;utilise registre : r0, r1, r18, r20, z
ECRITURE:
	ldi	zl, low(2*hextb)
	ldi	zh, high(2*hextb)
	add zl, r20
	clr r1
	adc zh, r1
	lpm
	mov r18,r0
	rcall LCD_putc
	ret

;==== LCD_putstring ====
; écris un texte
;utilise registre : r0, r18, z
LCD_putstring:
; in	z 
	lpm 			; load program memory into r0
	tst	 r0		; test for end of string
	breq done	 
	mov	 r18, r0	; load argument
	rcall	LCD_putc
	adiw	zl,1 		; increase pointer address
	rjmp	LCD_putstring 		; restart until end of string
done:	ret

