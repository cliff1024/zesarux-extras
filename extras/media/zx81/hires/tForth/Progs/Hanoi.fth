CR
.( TOWERS OF HANOI GAME ) CR
.( BY RICARDO F. LOPES - 2006 ) CR CR

.( USE KEYS 1, 2 AND 3 TO PLAY ) CR
.( TYPE HANOI WHEN READY ) CR

: TASK ;

HEX 1E 461C C!  461B EXECUTE  \ Disable the character board, to compile the game
                              \ for a standard zx81.

\ ACE PLOT routine
\ Plots pixel (x, y) with plot mode n.
\ n = 0       unplot
\     1       plot
\     2       move
\     3       change

CODE PLOT  ( x y n -- )
  C5 C,              \ push bc
  D9 C,              \ exx
  C1 C,              \ pop bc         ; n
  D1 C,              \ pop de         ; y
  FD C, 73 C, 36 C,  \ ld (iy+$36),e  ; YCOORD
  3E C, 2C C,        \ ld a,$2C       ; 44-y
  93 C,              \ sub e          ;
  1F C,              \ rra            ; (44-y)/2
  CB C, 11 C,        \ rl c           ; n*2+cy
  D1 C,              \ pop de         ; x
  FD C, 73 C, 37 C,  \ ld (iy+$37),e  ; XCOORD
  CB C, 3B C,        \ srl e          ; x/2
  CB C, 11 C,        \ rl c           ; (n*2)*2
  47 C,              \ ld b,a
  7B C,              \ ld a,e
  04 C,              \ inc b          ; range 1 to 24
  21 C, 4071 ,       \ ld hl,$4071    ; Dfile-33
  11 C, 21 ,         \ ld de,$21      ; (y/2)*33
  19 C,              \ add hl,de      ; 
  10 C, FD C,        \ djnz -3        ; 
  5F C,              \ ld e,a         ; (y/2)*33+x/2
  19 C,              \ add hl,de      ; 
  7E C,              \ ld a,(hl)
  07 C,              \ rlca
  FE C, 10 C,        \ cp $10
  7E C,              \ ld a,(hl)
  38 C, 01 C,        \ jr c,+1
  AF C,              \ xor a
  5F C,              \ ld e,a
  16 C, 87 C,        \ ld d,$87
  79 C,              \ ld a,c
  2F C,              \ cpl
  E6 C, 03 C,        \ and $03
  47 C,              \ ld b,a
  28 C, 07 C,        \ jr z,+7
  2F C,              \ cpl
  C6 C, 02 C,        \ add a,$02
  CE C, 03 C,        \ adc a,$03
  57 C,              \ ld d,a
  43 C,              \ ld b,e
  79 C,              \ ld a,c
  0F C,              \ rrca
  0F C,              \ rrca
  0F C,              \ rrca
  9F C,              \ sbc a,a
  CB C, 59 C,        \ bit 3,c
  20 C, 04 C,        \ jr nz,+4
  AB C,              \ xor e
  07 C,              \ rlca
  9F C,              \ sbc a,a
  A8 C,              \ xor b
  A2 C,              \ and d
  AB C,              \ xor e
  77 C,              \ ld (hl),a
  D9 C,              \ exx
  C1 C,              \ pop bc
  NEXT               \ jp NEXT
DECIMAL

\ Output n spaces
: SPACES  ( n -- )  
   ?DUP IF 0 DO SPACE LOOP THEN ;
\ Copy nth cell to top
: PICK  ( Xn .. X1 n -- Xn .. X1 Xn)
      2* SP@ + @ ;
\ Leave greater of two numbers
: MAX  ( n1 n2 -- n3)
   2DUP <
   IF SWAP
   THEN
   DROP ;
\ Leave lesser of two numbers
: MIN  ( n1 n2 -- n3)
   2DUP >
   IF SWAP
   THEN
   DROP ;


0 VARIABLE MOV#  ( Move count )
: MOV+1 ( Increment move count )  MOV# @ 1+ MOV# ! ;

CREATE T 24 ALLOT  ( Towers array: 3 poles, 8 lines )
: T>     ( pole line -- c-adr )  3 * + T + ;
: RING@  ( pole line -- ring  )  T> C@ ;
: RING!  ( ring pole line --  )  T> C! ;

: INIT ( Initialize game )
 0 MOV# !     ( Reset move count)
 8 0          ( Set rings)
 DO
  7 I -       ( ring size)
  0 I RING!   ( Put all rings in pole 1)
  0 1 I RING! ( empty pole 2)
  0 2 I RING! ( empty pole 3)
 LOOP
;

: .FRAME ( draw poles )
 7 0             ( poles with 7 lines)
 DO
  8 SPACES       ( left margin)
  3 0            ( 3 poles)
  DO
   ." :       "
  LOOP
 LOOP
 32 0            ( bottom line)
 DO
  ASCII - EMIT
 LOOP
 ."         1       2       3"  ( pole labels)
;

: .RING ( ring line pole -- , Draw a ring)
 1+ 16 * 3 PICK - ( x = pole+1 * 16 - ring)
 SWAP 2 * 32 +    ( y = line*2 + 32       )
 ROT 2 * 2+ 0     ( ringsize = ring*2 + 2 )
 DO               ( Plot ring)
  OVER I + OVER
  1 PLOT
 LOOP
 2DROP
;

: SHOW ( Draw everything)
 CLS
 .FRAME CR CR
 ." MOVES: " MOV# @ . ( Show moves)
 3 0                  ( Three Poles)
 DO
  7 0                 ( Seven Lines)
  DO
   J I RING@ ?DUP
   IF                 ( Is there a ring?)
    I J .RING         ( Draw the ring)
   THEN
  LOOP
 LOOP
;

: TOP> ( pole -- pole line , Find free line over the rings in a pole)
 0                  ( dummy previous line)
 8 0                ( check 8 lines )
 DO
  DROP              ( discard previous line)
  I 2DUP RING@ ( Get ring in current line)
  0=
  IF                ( Free line? Done )
   LEAVE
  THEN
 LOOP
;

: END?  ( -- flag , Check for end of game)
 0             ( sum = 0)
 7 0           ( 7 lines)
 DO
  2 I RING@ +  ( Sum all rings in pole 3)
 LOOP
 28 =          ( Game over if sum of rings = 28)
;

: MOV ( from to -- , Move a ring from one pole to another)
 OVER TOP> ?DUP  
 IF         ( Is there a ring in the source?)
  1- RING@  ( Get top ring from source )
  OVER TOP> ?DUP
  IF                   ( Destination not empty?)
   1- RING@            ( Yes, get top ring from destination)
  ELSE                 ( The destination is empty..)
   DROP 8              ( ..assume top destination ring = 8)
  THEN
  OVER >               ( Smaller ring over bigger?)
  IF
   SWAP TOP> RING!     ( Place ring in the destination pole)
   0
   SWAP TOP> 1- RING!  ( Remove ring from source)
   MOV+1               ( Count move)
  ELSE                 ( Invalid move, do nothing)
   DROP 2DROP
  THEN
 ELSE                  ( No rings in source, do nothing)
  DROP 2DROP
 THEN
;

: KEY?  ( -- n , Get user input)
\ BEGIN INKEY 0= UNTIL    ( Wait for key release)
\ BEGIN INKEY ?DUP UNTIL  ( Wait for a keypress)
 KEY
 ASCII 0 - 1 MAX 3 MIN   ( convert key 1-3 to number 1-3)
;

: HANOI ( Main word, execute it to play)
 INIT                          ( Init variables)
 SHOW                          ( Draw screen)
 BEGIN                         ( Main game loop)
  CR ." FROM? " KEY? DUP . 1-  ( Get user "from" input)
  CR ."   TO? " KEY? DUP . 1-  ( Get user "to" input)
  MOV                          ( Move ring as commanded)
  SHOW                         ( Update screen)
  END?                         ( Check for success)
 UNTIL
;

 