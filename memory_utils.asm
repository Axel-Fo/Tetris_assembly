 /*
 * memory_utils.asm
 * All macros and subroutines that modify memory are defined below.
 *   Author: GROUPE 91
 */ 

; Macro pour initialiser un bloc mémoire à une valeur spécifiée, valeur de z modifiée
; Usage: INIT_MEMORY(adresse_debut, taille, valeur)
.macro INIT_MEMORY
    ldi loop, @1
    ldi r17, @2
    ldi zl, low(@0)
    ldi zh, high(@0)

init_loop:
    st Z+, r17
    dec loop
    brne init_loop

.endm

; Macro pour load un pixel en mémoire à une adresse (z), valeur de z modifiée de 3
; Usage: LOAD_RGB(Green, Red, Blue)
.macro LOAD_RGB
    
	ldi green, @0        
    st Z+, green                 
    ldi red, @1            
    st Z+, red              
    ldi blue, @2 
    st Z+, blue          

.endm

; Macro pour copier un bloc mémoire à un endroit spécifié, valeur de z modifiée
; Usage: COPY_MEMORY(adresse_du_copié, adresse_du_collé, nbr_pix)
.macro COPY_MEMORY 

	ldi zl, low(@1)
    ldi zh, high(@1)

	ldi yl, low(@0)
    ldi yh, high(@0)
	
	ldi loop, @2
		copy_loop:
			
			rcall copy_rgb
			dec loop
			brne copy_loop

.endm 

; Macro pour add deux bloc mémoire 
; Usage: ADD_MEMORY(adresse_du_dest, adresse_du_add)
.macro ADD_MEMORY
    ; Initialiser pointeurs
    ldi zl, low(@0)
    ldi zh, high(@0)

    ldi yl, low(@1)
    ldi yh, high(@1)

    ldi loop, 64*3

loop_add:
    ld  r16, Z+
    ld  r17, Y+ 
    add r16, r17
	sbiw zl, 1
    st  z+, r16

    dec loop
    brne loop_add

.endm

; Macro pour shift à droit un carré mémoire de 8*9 pixel (1 pixel = 3 octet)
; valeur de z,y modifiée
; Usage: MEMORY_SHIFT_RIGHT(adresse_du_right_shift)
.macro MEMORY_SHIFT_RIGHT
	
	ldi zl, low(@0 + 216)
    ldi zh, high(@0 + 216)

    ldi yl, low(@0 + 213)
    ldi yh, high(@0 + 213)

	ldi loop2, 9 ; 9 lignes
	memory_shift_right_loop:
		ldi loop, 21; copie les 3*7 octet des 7 pixel
		octet_loop:
			ld r16, -Y
			st -Z, r16

		dec loop
		brne octet_loop

		ldi loop, 3; met à 0 le nouveau pixel
		zero_loop:
			ld r16, -Y ;juste pour dec y
			ldi r16, 0x00
			st -Z, r16

		dec loop
		brne zero_loop
	dec loop2
	brne memory_shift_right_loop

.endm

; Macro pour shift à droit un carré mémoire de 8*9 pixel (1 pixel = 3 octet)
; valeur de z,y modifiée
; Usage: MEMORY_SHIFT_LEFT(adresse_du_left_shift)
.macro MEMORY_SHIFT_LEFT
	
	ldi zl, low(@0)
    ldi zh, high(@0)

    ldi yl, low(@0 + 3)
    ldi yh, high(@0 + 3)

	ldi loop2, 9 ; 9 lignes
	memory_shift_left_loop:
		ldi loop, 21; copie les 3*7 octet des 7 pixel
		octet_loop:
			ld r16, Y+
			st Z+, r16

		dec loop
		brne octet_loop

		ldi loop, 3; met à 0 le nouveau pixel
		zero_loop:
			ld r16, Y+ ;juste pour inc y
			ldi r16, 0x00
			st Z+, r16

		dec loop
		brne zero_loop
	dec loop2
	brne memory_shift_left_loop

.endm
; Macro pour decendre un carré mémoire de 8*9 pixel (1 pixel = 3 octet) de une ligne
; Usage: MEMORY_SHIFT_DOWN(adresse_du_down_shift,nbr de lingnes(registre))
.macro MEMORY_SHIFT_DOWN
    
	mov c0,loop
	mov w, @1
	ldi loop,24
	mul loop, w
	mov loop,r0
	;ldi loop, 216
	mov r24, loop
	

    ldi xl, low(@0)
    ldi xh, high(@0)
	ADDX loop; met à l'adresse max

	subi loop, 24
	mov r23, loop
	;ADDI loop, 24

    ldi yl, low(@0)
    ldi yh, high(@0)
	ADDY loop; met à l'adresse de 'avant dernière ligne

shift_down_loop:
    ld r16, -Y
    st -x, r16

    dec loop
    brne shift_down_loop

    ; Mettre les 24 premiers octets à zéro
    ldi loop, 24
    ldi xl, low(@0)
    ldi xh, high(@0)
    ldi r16, 0

zero_fill:
    st x+, r16
    dec loop
    brne zero_fill

	mov loop, c0

.endm


; Macro pour charger un carré (2*2)pixel dans les deux lignes de 8 pixel à l'adresse donné
; Usage: MEMORY_ADD_SQUARE(adresse_du_carré)
.macro MEMORY_ADD_SQUARE
	
	INIT_MEMORY @0, 8*2*3, 0x00
	
	; LED 4 et 5 de la 1ère ligne
    ldi zl, low(@0 + 9) 
    ldi zh, high(@0 + 9)                

	ldi loop, 2
	call loop_square

    ; LED 4 et 5 de la 2ème ligne
    ldi zl, low(@0 + 33) 
    ldi zh, high(@0 + 33)              

	ldi loop, 2
	call loop_square; call car la macro peut être très loin
.endm

;boucle pour mettre une barre de 2 du carré
loop_square:
		LOAD_RGB 0x01, 0x0F, 0x01
		dec loop
		brne loop_square
ret

; Macro pour charger un Z horizontal (2*2)pixel dans les deux lignes de 8 pixel à l'adresse donné
; Usage: MEMORY_ADD_Z_H(adresse_du_z)
.macro MEMORY_ADD_Z_H
	
	INIT_MEMORY @0, 8*2*3, 0x00
	
	; LED 4 et 5 de la 1ère ligne
    ldi zl, low(@0 + 9) 
    ldi zh, high(@0 + 9)                

	ldi loop, 2
	call loop_z_h

    ; LED 3 et 4 de la 2ème ligne
    ldi zl, low(@0 + 33) 
    ldi zh, high(@0 + 33)              

	ldi loop, 1
	call loop_z_h
.endm
;boucle pour mettre une barre de 2 du carré
loop_z_h:
		LOAD_RGB 0x0F, 0x01, 0x01
		dec loop
		brne loop_z_h
ret

; Macro pour charger une barre verticale dans les trois lignes de 8 pixel à l'adresse donné
; Usage: MEMORY_ADD_BARRE(adresse_du_z)
.macro MEMORY_ADD_BARRE
	
	INIT_MEMORY @0, 8*3*3, 0x00
	
	; LED 4 de la 1ère ligne
    ldi zl, low(@0 + 9) 
    ldi zh, high(@0 + 9)                
		
	LOAD_RGB 0x01, 0x0F, 0x0F

    ; LED 4 de la 2ème ligne
    ldi zl, low(@0 + 33) 
    ldi zh, high(@0 + 33)              
	LOAD_RGB 0x01, 0x0F, 0x0F

	; LED 4 de la 3ème ligne
    ldi zl, low(@0 + 57) 
    ldi zh, high(@0 + 57)              
	LOAD_RGB 0x01, 0x0F, 0x0F


.endm

.macro MEMORY_ADD_T
	
	INIT_MEMORY @0, 8*2*3, 0x00
	
	; LED 4, 5 et 6 de la 1ère ligne
    ldi zl, low(@0 + 9) 
    ldi zh, high(@0 + 9)                

	ldi loop, 3
	call loop_t

    ; LED 5 de la 2ème ligne
    ldi zl, low(@0 + 36) 
    ldi zh, high(@0 + 36)              
	LOAD_RGB 0x01, 0x01, 0x0F


.endm

loop_t:
		LOAD_RGB 0x01, 0x01, 0x0F
		dec loop
		brne loop_t
ret

;Sous routine pour copier le RGB pointer par y à l'endroit pointé par z
copy_rgb:
	ld green, y+
    ld red, y+
    ld blue, y+
	st z+, green
	st z+, red
	st z+, blue
ret

; Macro pour set un flag en memoire data
; Usage: SET_COLL_FLAG(adresse_du_flag)
.macro SET_FLAG
    ldi r16, 1
    sts @0, r16
.endm

; Macro pour clear un flag en memoire data
; Usage: CLR_FLAG(adresse_du_flag)
.macro CLR_FLAG
    ldi r16, 0
    sts @0, r16
.endm

