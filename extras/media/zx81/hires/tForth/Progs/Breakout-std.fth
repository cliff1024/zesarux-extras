\                 ==========================
\                 Breakout - by Colin Dooley
\                 ==========================
\
\ Listing from Popular Computing Weekly 17-23 March, 1983, Vol 2, No 11
\ Ported from Jupiter ACE to ZX81 Toddy Forth by
\ Kelly A. Murta - JAN/2010.
\
\ This program is a version of the standard breakout game. The
\ player must keep bouncing the ball back to the top of the
\ screen in order to demolish the wall. He has 5 balls to do
\ this, one being lost every time he misses. The player controls
\ the movement of his bat by pressing 5 to move it to the left
\ and 8 to move it to the right. 
\
\ For those interested, here is a list of the items on the stack
\ during the game:
\ (TOS), the position of the ball on the screen, the X
\ displacement at each move, the Y displacement at each move,
\ the score, your position on line 21 of the screen.

CR CR .( BREAKOUT - BY COLIN DOOLEY)
CR .( TYPE BREAKOUT TO PLAY)
CR .( CONTROL KEYS: 5 LEFT)
CR .(               8 RIGHT)
CR

: TASK ;

HEX
CODE INKEY  ( -- b)
  C5 C,          \        push bc      ;save old TOS
  D5 C,          \        push de      ;save IP
  CD C, 02BB ,   \        call $2BB    ;KEYBOARD
  7D C,          \        ld a,l
  3C C,          \        inc a
  28 C, 0A C,    \        jr z,INK1
  44 C,          \        ld b,h
  4D C,          \        ld c,l
  CD C, 07BD ,   \        call $7BD    ;DECODE
  11 C, 4347 ,   \        ld de,$4347  ;K_UNSHIFT - $7E
  19 C,          \        add hl,de
  7E C,          \        ld a,(hl)
  06 C, 00 C,    \ INK1:  ld b,0       ;put the key code in BC
  4F C,          \        ld c,a       ;
  D1 C,          \        pop de       ;restore IP
  NEXT           \        jp NEXT

CODE PICK  ( Xn .. X1 X0 n -- Xn .. X1 X0 Xn)      ( copy nth cell to top )
  CB C, 21 C,    \ sla c           ;2*
  CB C, 10 C,    \ rl b            ;
  60 C,          \ ld h,b
  69 C,          \ ld l,c
  39 C,          \ add hl,sp
  4E C,          \ ld c,(hl)       ;get element to be PICK'ed
  23 C,          \ inc hl          ;
  46 C,          \ ld b,(hl)       ;
  NEXT           \ jp NEXT

\ Rotate nth cell to top
CODE ROLL ( Xn .. X1 X0 n -- Xn-1 .. X1 X0 Xn )
  C5 C,          \ push  bc
  D9 C,          \ exx                   ;save IP
  C1 C,          \ pop   bc
  CB C, 21 C,    \ sla   c               ;2*
  CB C, 10 C,    \ rl    b               ;
  03 C,          \ inc   bc              ;1+
  60 C,          \ ld    h,b
  69 C,          \ ld    l,c
  0B C,          \ dec   bc              ;bytes count to be moved
  39 C,          \ add   hl,sp
  E5 C,          \ push  hl              ;destination
  C5 C,          \ push  bc
  56 C,          \ ld    d,(hl)          ;get element to be ROLL'ed
  2B C,          \ dec   hl              ;
  5E C,          \ ld    e,(hl)          ;
  2B C,          \ dec   hl              ;HL = origin
  C1 C,          \ pop   bc
  EB C,          \ ex    de,hl
  E3 C,          \ ex    (sp),hl
  EB C,          \ ex    de,hl
  78 C,          \ ld    a,b
  B1 C,          \ or    c               ; count=0?
  28 C, 02 C,    \ jr    z,+2            ; 
  ED C, B8 C,    \ lddr
  D9 C,          \ exx                   ;restore IP
  C1 C,          \ pop   bc              ;get TOS
  E1 C,          \ pop   hl              ;adjust SP
  NEXT           \ jp NEXT

\ Drive the ZON-X81 sound device.
CODE SND ( n1 n2 -- )            ( Write n1 to AY register n2 )
  79 C,          \ ld a,c
  D3 C, DF C,    \ out ($df),a
  E1 C,          \ pop hl
  7D C,          \ ld a,l
  D3 C, 0F C,    \ out ($0f),a
  C1 C,          \ pop bc
  NEXT           \ jp NEXT

CODE NORMAL
  3E C, 1E C,    \ ld a,$30
  ED C, 47 C,    \ ld i,a
  NEXT           \ jp NEXT


\ Turns off all sound on all channels, A,B and C
: SNDOFF  ( -- )
   FF 7 SND ;

\ "Simulate" the BEEP command of Jupiter ACE
: BEEP ( c n -- )
   SWAP 0 SND
    0 1 SND
   FE 7 SND
   0F 8 SND
   0 DO LOOP SNDOFF ;

: AT  ( n1 n2 -- )
   SWAP 21 * + 4092 +
   43BB ! ;
: SPACES  ( n -- )
   ?DUP IF 0 DO SPACE LOOP THEN ;
DECIMAL
: MAX  ( n1 n2 -- n3)
   2DUP <
   IF SWAP
   THEN
   DROP ;
: MIN  ( n1 n2 -- n3)
   2DUP >
   IF SWAP
   THEN
   DROP ;

\ MOVE: Increases or decreases the number on top of the stack,
\ depending on the key pressed.
: MOVE
   INKEY DUP 53 = SWAP
   56 = OVER OR
   IF
       IF  1-
       ELSE  1+
       THEN
   ELSE  DROP
   THEN
   1 MAX 29 MIN ;

\ YOUMOVE: Moves and redraws your bat.
: YOUMOVE
   INKEY
   IF  4 ROLL DUP 21 SWAP AT
       2 SPACES MOVE DUP
       21 SWAP AT  ." %%"
       4 ROLL 4 ROLL
       4 ROLL 4 ROLL
   ELSE
       50 0 DO LOOP
   THEN ;

\ CHECK: Checks if the ball has gone off the bottom of the
\ screen (its position is greater than 17248), if so it decreases
\ the number of balls and continues if there are any left.
: CHECK
   DUP 17248 >
   IF  0 SWAP C! 16560 C@
       DUP 28 =
       IF  12 11 AT ." game�over" 
           50 200 DO I 1 BEEP -1 +LOOP
           BEGIN KEY 13 = UNTIL CLS ABORT
       ELSE  1- 16560 C! 16828 16436
             C@ 1 AND +
             200 50 DO I 1 BEEP LOOP
       THEN
   THEN ;

\ BALLDRAW: Checks if the ball has hit a brick (increasing your
\ score if so) and draws the ball.
: BALLDRAW
   DUP C@ 138 =
   IF  ROT NEGATE ROT ROT 3
       ROLL 1+ 0 8 AT
       DUP . 3 ROLL
       3 ROLL 3 ROLL
       60 150 BEEP
   THEN
   52 OVER C! ;

400 VARIABLE S 

\ DRAW: Initialises the screen and draws the walls.
: DRAW
   CLS 0 1 AT ." SCORE: 0              BALLS: 5"
   4 0 AT 32 5 * 0
   DO  ." ~"
   LOOP
   1 0 AT ." {"
   30 0 DO ." �"
        LOOP
   ." &"
   23 2 DO
           I 0 AT ." �"
           I 31 AT ." '"
        LOOP ;

\ BALLMOVE: Checks if the ball has hit anything and adjusts its
\ direction, then moves it.
: BALLMOVE
   0 OVER C! 2DUP
   + C@ DUP 0 =
   SWAP 138 = OR 0=
   IF  SWAP NEGATE SWAP
   255 100 BEEP
   THEN
   DUP 3 PICK + C@
   DUP 0 = SWAP 138
   = OR 0=
   IF  ROT NEGATE ROT ROT
   255 100 BEEP
   THEN
   2DUP + 3 PICK
   + C@ DUP 0 =
   SWAP 138 = OR 0=
   IF  ROT NEGATE ROT NEGATE ROT
   255 100 BEEP
   THEN  OVER 3 PICK + +
   BALLDRAW ;

\ BREAKOUT: Plays the game 
: BREAKOUT
   NORMAL
   8 0 33 1
   16828 DRAW 21 8 AT ." %%"
   KEY DROP
   BEGIN
      YOUMOVE BALLMOVE
      YOUMOVE CHECK
      S @ 0 DO LOOP
      0
   UNTIL ;

\ SPEED: Sets the speed of the game by adjusting the variable S.
\ Typing a number then SPEED sets the speed, 0 being the
\ fastest, 1000 being slow
: SPEED
   S ! ;
 