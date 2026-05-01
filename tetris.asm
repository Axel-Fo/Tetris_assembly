/*
 * tetris.asm
 * le code principale du jeu
 *   Author: GROUPE 91
 */ 
.include "led_64.asm" ;le perif utilisé
.include "random.asm"
.include "memory_utils.asm"


start_game:
	
	;met tout les params de la data seg à 0
	rcall	led_64_init 
	rcall   init_screen
	rcall   init_moving_shape
	rcall   init_test_collide_moving
	rcall   init_test_collide_screen
	CLR_FLAG nbr_shape
	CLR_FLAG score
	CLR_FLAG end
	CLR_FLAG pause

	rcall   load_new_piece

main_game:
	rcall display_screen_and_moving

	; pour debug avec les boutons:
	/*in r17, PIND
    
		sbrc r17, 3 
		rjmp button_right_not_pressed
		rcall move_right
		rcall display_screen_and_moving

	button_right_not_pressed:

		sbrc r17, 4
		rjmp button_left_not_pressed
		rcall move_left
		rcall display_screen_and_moving

	button_left_not_pressed:*/

ldi main_loop_count, 255
main_game_loop:
	ldi up,0
	ldi down,0
	rcall encoder
	tst up
	breq no_move
	
	brpl right
	brmi left



left:
	rcall move_left
	rcall display_screen_and_moving
	rjmp no_move

right:
	rcall move_right
	rcall display_screen_and_moving
no_move:
	WAIT_MS	2
	dec main_loop_count
	brne main_game_loop

	rcall move_down
	rcall display_screen_and_moving
	
	rcall clear_line
	rcall display_screen_and_moving

	rcall clear_line; 2 appelles car il peut y avoir 2 lignes a clear
	rcall display_screen_and_moving

	pause_loop:; si le jeu est en pause on attend une deuxième intéruption pour repartir
	lds r16, pause
	tst r16
	brne pause_loop

	WAIT_MS	10

	lds r16, end ; si end = 1 on termine le jeu
	tst r16
	breq continue

	ret

continue:

	jmp main_game

;==== AFFICHAGE COMPLET ====
; affiche le screen et le moving shape
;utilise registre : green, red, bleu, r13,r14,r15
display_screen_and_moving:
    ; Initialiser pointeurs
    ldi zl, low(screen)
    ldi zh, high(screen)

    ldi yl, low(moving_shape)
    ldi yh, high(moving_shape)

    ldi loop, 64

display_loop:
    ; Lire pixel de screen
    ld green, Z+
    ld red, Z+
    ld blue, Z+

    ; Lire pixel de moving_shape
    ld r13, Y+
    ld r14, Y+
    ld r15, Y+

    ; Additionner screen + moving
    add green, r13
    add red, r14
    add blue, r15

    rcall led_64_write

    dec loop
    brne display_loop

    ; Quand fini, reset des LEDs
    rcall led_64_reset

    ret
;==== MOVE LEFT ====
; bouge la moving shape à gauche si pas de collision si collision retourne
;utilise registre : 16
move_left:
	
	rcall load_test_collide_moving
	rcall load_test_collide_screen

	MEMORY_SHIFT_LEFT test_collide_moving
	
	rcall collision ; pour la collision avec les autre pièces

	;on verif après chaque test
	lds r16, collision_flag
	tst r16                   
	brne collision_left; si =! 0 saut à collisoion_left
	
	rcall test_side_collide_left ; pour la collision avec le bord

;on verif après chaque test
	lds r16, collision_flag
	tst r16                   
	brne collision_left; si =! 0 saut à collisoion_left

	MEMORY_SHIFT_LEFT moving_shape; pas de collision on bouge

	collision_left: ; si il y a une collision on annule de deplacement

	ret

; pour tester les collisions à gauche appeler dans move_left
; utilise r16 r24 et r1 (tjrs à 0)
test_side_collide_left: ; pour pouvoir aller à gauche la ligne de gauche doit être vide
	ldi zl, low(moving_shape)
    ldi zh, high(moving_shape)

	; Réinitialiser collision_flag à 0
    CLR_FLAG collision_flag
	
	ldi loop, 8 ; 8 lignes

	collision_left_loop:
    ld r16, Z
    tst r16
    breq PC+5 ; car la macro SET_FLAG à 2 lignes
	SET_FLAG collision_flag
	ret

    ; sinon on avance Z de 24 octets (pour lire la ligne suivante)
    ldi r24, 24
	clr r1
    add zl, r24
    adc zh, r1  ; si besoin ajoute la carry (r1=0)
	dec loop
	brne collision_left_loop
    ret  



;==== MOVE RIGHT ====
; bouge la moving shape à droite si pas de collision si collision retourne
;utilise registre : 16
;sous routine très proche de MOVE LEFT
move_right:
	
	rcall load_test_collide_moving
	rcall load_test_collide_screen

	MEMORY_SHIFT_RIGHT test_collide_moving
	
	rcall collision ; pour la collision avec les autre pièces

	;on verif après chaque test
	lds r16, collision_flag
	tst r16                   
	brne collision_right; si =! 0 saut à collisoion_right
	
	rcall test_side_collide_right ; pour la collision avec le bord

;on verif après chaque test
	lds r16, collision_flag
	tst r16                   
	brne collision_right; si =! 0 saut à collisoion_right

	MEMORY_SHIFT_RIGHT moving_shape; pas de collision on bouge

	collision_right: ; si il y a une collision on annule de deplacement

	ret

; pour tester les collisions à droite appeler dans move_right
; utilise r16 r24 et r1 (tjrs à 0)
test_side_collide_right: 
	ldi zl, low(moving_shape + 21) ; cette fois ci on regarde de l'autre coté 
    ldi zh, high(moving_shape + 21)

	; Réinitialiser collision_flag à 0
    CLR_FLAG collision_flag
	
	ldi loop, 8 ; 8 lignes

	collision_right_loop:
    ld r16, Z
    tst r16
    breq PC +5 ; car la macro SET_FLAG à 2 lignes
	SET_FLAG collision_flag
	ret

    ; sinon on avance Z de 24 octets (pour lire la ligne suivante)
    ldi r24, 24
	clr r1
    add zl, r24
    adc zh, r1  ; si besoin ajoute la carry (r1=0)
	dec loop
	brne collision_right_loop
    ret  


;==== MOVE DOWN ====
; bouge la moving shape vers le bas si pas de collision 
;si collision ajoute dans screen la moving shape
;utilise registre : 16
move_down:
	
	rcall load_test_collide_moving
	rcall load_test_collide_screen

	ldi r16, 9
	MEMORY_SHIFT_DOWN test_collide_moving, r16
	
	rcall collision

	; Lire la valeur du flag
	lds r16, collision_flag
	tst r16
	breq no_down_collision; si = 0 saut à no_collisoion

	; Si collision_flag = 1 :
	rcall handle_down_collision
	rjmp fin

	no_down_collision:
	ldi r16, 9
	MEMORY_SHIFT_DOWN moving_shape, r16

	fin:

ret

;==== COLLISION ====
; test les collisions entre test_collide_screen et test_collide_moving 
;et met à jours collision_flag
;utilise registre : 18,19
collision:
    
	; Initialisation des pointeurs Z et Y
    ldi zl, low(test_collide_screen)
    ldi zh, high(test_collide_screen)
    
    ldi yl, low(test_collide_moving)
    ldi yh, high(test_collide_moving)

    ; Réinitialiser collision_flag à 0
    CLR_FLAG collision_flag

    ldi loop, 72*3      ; nombre d'octets à tester

	collision_loop:
		ld r18, Z+
		ld r19, Y+

		tst r18
		breq skip_flag

		tst r19
		breq skip_flag

		SET_FLAG collision_flag
		ret

	skip_flag:
		dec loop
		brne collision_loop
	
ret

;==== HANDLE DOWN COLLISION ====
; lors d'une collision on ajoute la moving shape dans le screen et load une nouvelle forme dans moving_shape 
; si collision fin de jeu
;utilise registre : 16
handle_down_collision:
	rcall add_to_screen


	rcall init_moving_shape
	rcall load_new_piece

	rcall load_test_collide_moving
	rcall load_test_collide_screen

	rcall collision

	lds r16, collision_flag
	tst r16
	breq no_collision

	rcall display_screen_and_moving
	rcall game_over

	no_collision:
ret
;==== GAME OVER ====
;fin de jeu
;utilise registre : 16
game_over:
	rcall add_to_screen
	WAIT_MS	450

	rcall init_moving_shape
	rcall init_screen
	ldi r16, 1
	sts end,r16


ret
;==== CLEAR LINE ====
;vide les lignes qui sont pleine
;utilise registre : 18,8
clear_line:

	ldi zl, low(screen + 192)
    ldi zh, high(screen + 192)


	ldi loop, 8
	
	check_line_loop:

		ldi loop2,8*3
		check_pix_loop:
			ld r18, -Z

			tst r18
			breq skip_line
			dec loop2
			brne check_pix_loop

		MEMORY_SHIFT_DOWN screen, loop ; ligne pleine on shift tt vers le bas et écrase la ligne 
		lds r8, score
		inc r8
		sts score,r8

; si on voit un 0 on peu skipe le reste de la ligne
	skip_line:
		subi loop2, 1
		sub zl,loop2
		clr r1
		sbc zh, r1
		dec loop
		brne check_line_loop


ret

;==== LOAD NEW PIECE ====
;charge la pièce suivante dans moving shape
;utilise registre : 1,22,20,15
load_new_piece:
    
	;pour forcer manueleemnet des pièces bien pour debug
	/*; Charger l'index
    lds r15, nbr_shape


    ldi zl, low(liste_shape * 2)
    ldi zh, high(liste_shape * 2)
	clr r1
    add zl, r15
    adc zh, r1

	;on lit la liste
    lpm r22, Z*/
	; pour le random
	rcall random_1_4
	mov r22, r1

    ; Appeler la forme correspondante
    cpi r22, 1
    breq load_1
    cpi r22, 2
    breq load_2
    cpi r22, 3
    breq load_3
    cpi r22, 4
    breq load_4
	.
	.; si plus de formes
	.
    rjmp continue_inc

load_1:
    rcall load_square
    rjmp continue_inc
load_2:
    rcall load_z_h
    rjmp continue_inc
load_3:
    rcall load_t
    rjmp continue_inc
load_4:
	rcall load_barre
	rjmp continue_inc
; ...

continue_inc:
    inc r15
    sts nbr_shape, r15

	;si on est arriver au bout de la liste de forme (=0) on se remet au début
    ldi ZL, low(liste_shape * 2)
    ldi ZH, high(liste_shape * 2)
    add ZL, r15
    adc ZH, r1
    lpm r20, Z;prochaine valeur

    tst r20
    brne end_piece

    ; Sinon on remet l’index à 0
    ldi r21, 0
    sts nbr_shape, r21

end_piece:
    ret

;========== MANIPULATION MEMOIRE ==========
;les sous routines suivantes utilise les macro de memory_utils.asm
;fais de cette manière pour avoir de 'abstraction sur l'accès mémoire

;==== ADD TO SCREEN ====

add_to_screen:
	ADD_MEMORY  screen, moving_shape
ret

;==== INIT SCREEN ====

init_screen:
	INIT_MEMORY screen, 64*3, 0x00
ret

;==== INIT MOVING SHAPE ====

init_moving_shape:
	INIT_MEMORY moving_shape, 64*3, 0x00
ret

;==== INIT TEST COLLIDE MOVING ====

init_test_collide_moving:
	INIT_MEMORY test_collide_moving, 72*3, 0x00
ret

;==== INIT TEST COLLIDE SCREEN ====

init_test_collide_screen:
	INIT_MEMORY test_collide_screen, 72*3, 0x00
ret

;==== LOAD SQUAR ====

load_square:
	INIT_MEMORY moving_shape, 64*3, 0x00
	MEMORY_ADD_SQUARE moving_shape
ret
;==== LOAD Z HORIZONTAL ====
load_z_h:
	INIT_MEMORY moving_shape, 64*3, 0x00
	MEMORY_ADD_Z_H moving_shape
ret
;==== LOAD T HORIZONTAL ====
load_t:
	INIT_MEMORY moving_shape, 64*3, 0x00
	MEMORY_ADD_T moving_shape

ret
;==== LOAD BARRE VERTICAL ====
load_barre:
	INIT_MEMORY moving_shape, 64*3, 0x00
	MEMORY_ADD_BARRE moving_shape 

ret
;==== LOAD TEST COLLIDE MOVING ====
load_test_collide_moving:
	INIT_MEMORY test_collide_moving, 72*3, 0x00
	COPY_MEMORY moving_shape, test_collide_moving, 64

ret
;==== LOAD TEST COLLIDE SCREEN ====
load_test_collide_screen:
	
	INIT_MEMORY test_collide_screen, 72*3, 0x00 
	COPY_MEMORY screen, test_collide_screen, 64
	
	; la zone mémoire test_collide a une bordure (derniere ligne) à 0x0F, 0x0F, 0x0F
	INIT_MEMORY test_collide_screen + 64*3, 8*3, 0x0F

ret




