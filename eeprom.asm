 /*
 * eeprom.asm
 *   Author: COURS
 */ 


eeprom_store:
; in:	xh:xl 	EEPROM address
;	a0	EEPROM data byte to store

	sbic	EECR,EEWE	; skip if EEWE=0 (wait it EEWE=1)
	rjmp	PC-1		; jump back to previous address
	out	EEARL,xl		; load EEPROM address low	
	out	EEARH,xh		; load EEPROM address high
	out	EEDR,r18			; set EEPROM data register
	brie	eeprom_cli	; if I=1 then temporarily disable interrupts
	sbi	EECR,EEMWE		; set EEPROM Master Write Enable
	sbi	EECR,EEWE		; set EEPROM Write Enable
	ret	
eeprom_cli:
	cli					; disable interrupts
	sbi	EECR,EEMWE		; set EEPROM Master Write Enable
	sbi	EECR,EEWE		; set EEPROM Write Enable
	sei					; enable interrupts
	ret

eeprom_load:
; in:	xh:xl 	EEPROM address
; out:	a0	EEPROM data byte to load

	sbic	EECR,EEWE	; skip if EEWE=0 (wait it EEWE=1)
	rjmp	PC-1		; jump back to previous address
	out	EEARL,xl	
	out	EEARH,xh
	sbi	EECR,EERE		; set EEPROM Read Enable
	in	r18,EEDR			; read data register of EEPROM
	ret

load_store:
	ldi xl, 0x10
	ldi xh, 0x00
	rcall eeprom_load
	ldi xl, 0x00
	rcall eeprom_store
	ldi xl, 0x11
	ldi xh, 0x00
	rcall eeprom_load
	ldi xl, 0x01
	rcall eeprom_store
	ldi xl, 0x12
	ldi xh, 0x00
	rcall eeprom_load
	ldi xl, 0x02
	rcall eeprom_store
	ldi xl, 0x13
	ldi xh, 0x00
	rcall eeprom_load
	ldi xl, 0x03
	rcall eeprom_store
	ldi xl, 0x14
	ldi xh, 0x00
	rcall eeprom_load
	ldi xl, 0x04
	rcall eeprom_store
	ret
