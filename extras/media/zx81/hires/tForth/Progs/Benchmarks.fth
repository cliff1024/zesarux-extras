CR
.( PCW Forth Benchmarks) CR
.( Dick  Pountain 10th Nov 1982) CR


\ Definitions for Jupiter ACE
\ : SP! HERE 12 + 15419 ! ;  
\ : START ." S" 0 15403 ! ;
\ : EXIT ." E " 15403 @ U. ." FRAMES" ; DECIMAL

HEX
: START ." S" FFFF 4034 ! ;
: EXIT ." E " FFFF 4034 @ - U. ." FRAMES" ; DECIMAL

.( Benchmarks 1) CR
: MAGNIFIER  START 10001 1 DO
        SP! LOOP EXIT ;

: DO-LOOP  START 10001 1 DO
        11 1 DO LOOP
        SP! LOOP EXIT ;

: LITERAL  START 10001 1 DO
       11 1 DO 9 LOOP
       SP! LOOP EXIT ;


.( Benchmarks 2) CR

0 VARIABLE V

: VAR    START 10001 1 DO
        11 1 DO V LOOP
        SP! LOOP EXIT ;

: LITERAL-STORE  START 10001 1 DO
        11 1 DO 9 V ! LOOP
       SP! LOOP EXIT ;

: VARIABLE-FETCH  START 10001 1 DO
       11 1 DO V @ LOOP
       SP! LOOP EXIT ;



.( Benchmarks 3) CR

9 CONSTANT K

: CONST  START 10001 1 DO
      11 1 DO K LOOP
      SP! LOOP EXIT ;

: TDUP  START 10001 1 DO
     11 1 DO 9 DUP LOOP
     SP! LOOP EXIT ;

: INCREMENT  START 10001 1 DO
     11 1 DO 9 1+ LOOP
     SP! LOOP EXIT ;



.( Benchmarks 4) CR

: TEST>  START 10001 1 DO
      11 1 DO 9 9 > LOOP
      SP! LOOP EXIT ;

: TEST<    START 10001 1 DO
      11 1 DO 9 9 < LOOP
      SP! LOOP EXIT ;

: ARITHMETIC  START 10001 1 DO
     9 2 / 3 * 4 + 5 -
     SP! LOOP EXIT ;



.( Benchmarks 5) CR


: WHILE-LOOP  START 10001 1 DO
      1 BEGIN 1+ DUP 11 < WHILE REPEAT
      SP! LOOP EXIT ;

: UNTIL-LOOP  START 10001 1 DO
     20 BEGIN 1- DUP 11 < UNTIL
     SP! LOOP EXIT ;



.( Benchmarks 6) CR

: TEN ;
: NINE TEN ;
: EIGHT NINE ;
: SEVEN EIGHT ;
: SIX SEVEN ;
: FIVE SIX ;
: FOUR FIVE ;
: THREE FOUR ;
: TWO THREE ;
: ONE TWO ;

: DICTIONARY-SEARCH  START 10001 1 DO
     ONE
     SP! LOOP EXIT ;
 