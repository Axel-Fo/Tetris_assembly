/*
 * Random.asm
 * pour le random du jeu
 *   Author: GROUPE 91
 */ 
init_random:
	; TODO: use EEPROM for seed
	ldi w, 0x00
	sts	random, w
ret

; uses r16, r0, r1
; Linear congruential generator
random_byte:
	lds r0, random
	ldi w, 45 ; 4* un nnr premier (11) + 1
	mul r0, w
	ldi w, 213; doit être impaire 
	add r0, w
	sts random, r0 
ret

; on trouve dans r1 une val random 1 and 4
random_1_4:
	rcall random_byte	; r0 à un random byte
	ldi w, 4
	mul r0, w
	inc r1
ret