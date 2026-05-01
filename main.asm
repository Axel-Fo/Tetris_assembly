;
; ProjetApplication.asm
;
; Created: 26.04.2025 11:30:37
; Author : GROUPE 91
;
;==== interrupt table ====
.org 0
	jmp	reset
.org 0x0002
	jmp mettre_pause

;==== interrupt service routines ====

mettre_pause:; si pause = 1 => met à 0 et inv
	
	lds _w,pause
	tst _w
	breq clear
	ldi _w,0
	sts pause, _w
	rjmp return


clear:
	ldi _w,1
	sts pause,_w

return:

reti
;==== les includes ====
;doit être ici pour des problèmes de gestion de mémoire
.include "definitions_memory.asm"
.include "macros.asm"
.include "definitions.asm"
.include "tetris.asm"
.include "angular_enoder.asm"
.include "lcd_routine.asm"



reset:

	OUTI	DDRD, 0x00	; connectbuttons to PORTC, input mode
	LDSP	RAMEND	; Load Stack Pointer (SP)
	OUTI	DDRE, 0x00	; pour l'encodeur angulaire
	OUTI	EIMSK,0b1
	sei
	rcall encoder_init
	rcall set_screen1 ; affiche entre ton nom



main:
rcall writing ;pour écrire son nom.

 WAIT_MS 1; boucle rapide pour bien decoder l'encodeur
 ldi up,0
 rcall encoder
 brtc skip; si on appuie sur l'encodeur on lance le jeu
 rcall set_screen2; affiche le last score avec son nom
 
 call start_game
 
 rcall load_store;pour mettre à jour le nom de l'ancien joueur

 rcall set_screen3; affiche le score
 WAIT_MS 3000 ; on affiche le score 3sec
 rcall set_screen1 ; affiche entre ton nom

 skip:

rjmp main


