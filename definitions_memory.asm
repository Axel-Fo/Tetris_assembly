/*
 * definitions_memory.asm
 * definition of all used memory
 *   Author: GROUPE 91
 */ 

 ; ************** ZONE DE DONNEES **************
.DSEG ; on ecrit ce qui suit dans la memoire de donnée

screen: .byte 64*3  ;écran 64 LEDs * 3 octets
moving_shape: .byte 64*3  ;écran 64 LEDs * 3 octets pour la pièce qui tomble
test_collide_screen: .byte 72*3 ; ajout d'un bord
test_collide_moving: .byte 72*3 ; pour pouvoir simuler les déplacement
collision_flag: .byte 1
nbr_shape: .byte 1
random: .byte 1
score: .byte 1
pause: .byte 1 ; = 1 si pause
end: .byte 1 ; = 1 si perdu

.CSEG; pour pouvoir l'include dans un fichier de programme
.org 0x0045 ; après les interupts

; pour debug on peux choisir la suite des pièces qui arrivent
liste_shape: ;seq de pièce
    .db 1, 2, 1, 3, 2, 4, 4, 3, 1 , 2
    .db 1, 3, 1, 4
    .db 0 ; 0 pour la fin
str0:
.db	"ENTER YOUR NAME:",0

str1:
.db	"LAST SCORE: ",0

str2:
.db	"SCORE: ",0

hextb:
.db	"ABCDEFGHIJKLMNOPQRSTUVWXYZ ",0

valeurs:
.db "0123456789"
