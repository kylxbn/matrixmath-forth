( Kyle_MatrixMath )
( FORTH Port from C# )
( Yay! )

\ ------------------------ MEMORY ALLOCATION ---------------------------

CREATE MATRIX_A        100 FLOATS ALLOT
CREATE MATRIX_A_WIDTH  1   CELLS  ALLOT
CREATE MATRIX_A_HEIGHT 1   CELLS  ALLOT
CREATE MATRIX_B        100 FLOATS ALLOT
CREATE MATRIX_B_WIDTH  1   CELLS  ALLOT
CREATE MATRIX_B_HEIGHT 1   CELLS  ALLOT
CREATE MATRIX_C        100 FLOATS ALLOT
CREATE MATRIX_C_WIDTH  1   CELLS  ALLOT
CREATE MATRIX_C_HEIGHT 1   CELLS  ALLOT
CREATE MATRIX_T        100 FLOATS ALLOT
CREATE MATRIX_T_WIDTH  1   CELLS  ALLOT
CREATE MATRIX_T_HEIGHT 1   CELLS  ALLOT

CREATE F_TOTAL         1   FLOATS ALLOT

0 MATRIX_A_WIDTH !
0 MATRIX_A_HEIGHT !
0 MATRIX_B_WIDTH !
0 MATRIX_B_HEIGHT !
0 MATRIX_C_WIDTH !
0 MATRIX_C_HEIGHT !
0 MATRIX_T_WIDTH !
0 MATRIX_T_HEIGHT !

CREATE SBUF 64 ALLOT

VARIABLE A
VARIABLE B
VARIABLE C
VARIABLE D
VARIABLE E
VARIABLE F
VARIABLE G

\ --------------------- TERMINAL IO & MISC ------------------------------------

: READ_LINE
    0 A !
    0 SBUF !
    BEGIN
        KEY DUP DUP
        47 > SWAP 58 < AND
        IF
            DUP EMIT
            SBUF A @ + !
            A @ 1+ A !
            0
        ELSE
            DROP
            1
        THEN
    UNTIL
    SBUF
    A @
    CR
;

: VAL
    A !                ( A <- string length )
    B !                ( B <- string address )
    B @ A @ + C !      ( C <- string next char )
    1 D !              ( D <- multiplier )
    0                  ( start value )
    B @ C @ 1-
    DO
        I @ 255 AND    ( s char -- )
        48 -           ( s num -- )
        D @            ( s num mul -- )
        * +            ( s+num*mul -- )
        D @ 10 * D !
    -1 +LOOP
;

: TO_FLOAT
    A !            ( A <- string length )
    B !            ( B <- string address )
    B @ A @ + C !    ( C <- string next char )
    1 D !          ( D <- multiplier )
    0              ( start value )
    B @ C @ 1-
    DO
        I @ 255 AND  ( s char -- )
        48 -           ( s num -- )
        D @            ( s num mul -- )
        * +            ( s+num*mul -- )
        D @ 10 * D !
    -1 +LOOP
;

: PAGE 0 30 DO CR LOOP ;

\ ----------------------- MATRIX ROUTINES ----------------------

: SET_MATRIX_A
    MATRIX_A_WIDTH @ * + FLOATS MATRIX_A + F!
;

: SET_MATRIX_B
    MATRIX_B_WIDTH @ * + FLOATS MATRIX_B + F!
;

: SET_MATRIX_C
    MATRIX_C_WIDTH @ * + FLOATS MATRIX_C + F!
;

: SET_MATRIX_T
    MATRIX_T_WIDTH @ * + FLOATS MATRIX_T + F!
;

: GET_MATRIX_A
    MATRIX_A_WIDTH @ * + FLOATS MATRIX_A + F@
;

: GET_MATRIX_B
    MATRIX_B_WIDTH @ * + FLOATS MATRIX_B + F@
;

: GET_MATRIX_C
    MATRIX_C_WIDTH @ * + FLOATS MATRIX_C + F@
;

: GET_MATRIX_T
    MATRIX_T_WIDTH @ * + FLOATS MATRIX_T + F@
;

: DRAW_MATRIX_A
    CR
    MATRIX_A_HEIGHT @ 0 DO
        ." [ "
        MATRIX_A_WIDTH @ 0 DO
            I J GET_MATRIX_A F.
        LOOP
        ." ]" CR
    LOOP
    CR
;

: DRAW_MATRIX_B
    CR
    MATRIX_B_HEIGHT @ 0 DO
        ." [ "
        MATRIX_B_WIDTH @ 0 DO
            I J GET_MATRIX_B F.
        LOOP
        ." ]" CR
    LOOP
    CR
;

: DRAW_MATRIX_C
    CR
    MATRIX_C_HEIGHT @ 0 DO
        ." [ "
        MATRIX_C_WIDTH @ 0 DO
            I J GET_MATRIX_C F.
        LOOP
        ." ]" CR
    LOOP
    CR
;

: DRAW_MATRIX_T
    CR
    MATRIX_T_HEIGHT @ 0 DO
        ." [ "
        MATRIX_T_WIDTH @ 0 DO
            I J GET_MATRIX_T F.
        LOOP
        ." ]" CR
    LOOP
    CR
;

: ADD_MATRIX
    MATRIX_A_HEIGHT @ MATRIX_B_HEIGHT @ =
    MATRIX_A_WIDTH @ MATRIX_B_WIDTH @ = AND
    IF
        MATRIX_A_HEIGHT @ MATRIX_C_HEIGHT !
        MATRIX_A_WIDTH @ MATRIX_C_WIDTH !
        MATRIX_A_HEIGHT @ 0 DO
            MATRIX_A_WIDTH @ 0 DO
                I J GET_MATRIX_A
                I J GET_MATRIX_B F+
                I J SET_MATRIX_C
            LOOP
        LOOP
    ELSE
        0 MATRIX_C_HEIGHT !
        0 MATRIX_C_WIDTH !
    THEN
;

: SUBTRACT_MATRIX
    MATRIX_A_HEIGHT @ MATRIX_B_HEIGHT @ =
    MATRIX_A_WIDTH @ MATRIX_B_WIDTH @ = AND
    IF
        MATRIX_A_HEIGHT @ MATRIX_C_HEIGHT !
        MATRIX_A_WIDTH @ MATRIX_C_WIDTH !
        MATRIX_A_HEIGHT @ 0 DO
            MATRIX_A_WIDTH @ 0 DO
                I J GET_MATRIX_A
                I J GET_MATRIX_B F-
                I J SET_MATRIX_C
            LOOP
        LOOP
    ELSE
        0 MATRIX_C_HEIGHT !
        0 MATRIX_C_WIDTH !
    THEN
;

: VECTOR_MULTIPLY_MATRIX
    MATRIX_A_WIDTH @ MATRIX_B_HEIGHT @ =
    IF
        MATRIX_B_WIDTH @ MATRIX_C_WIDTH !
        MATRIX_A_HEIGHT @ MATRIX_C_HEIGHT !
        MATRIX_A_HEIGHT @ 0 DO
            MATRIX_B_WIDTH @ 0 DO
                0e0 F_TOTAL F!
                MATRIX_B_HEIGHT @ 0 DO
                    I K GET_MATRIX_A
                    J I GET_MATRIX_B F*
                    F_TOTAL F@ F+ F_TOTAL F!
                LOOP
                F_TOTAL F@ I J SET_MATRIX_C
            LOOP
        LOOP
    ELSE
        0 MATRIX_C_HEIGHT !
        0 MATRIX_C_WIDTH !
    THEN
;

\ ------------------------- OUTPUT MENU -----------------------

: SHOW_MATRIX_A
    PAGE
    MATRIX_A_WIDTH @ 0= MATRIX_A_HEIGHT @ 0= OR
    IF
        ." Matrix A not initialized"
    ELSE
        ." Matrix A:" CR CR
        DRAW_MATRIX_A
    THEN
    KEY DROP
;

: SHOW_MATRIX_B
    PAGE
    MATRIX_B_WIDTH @ 0= MATRIX_B_HEIGHT @ 0= OR
    IF
        ." Matrix B not initialized"
    ELSE
        ." Matrix B:" CR CR
        DRAW_MATRIX_B
    THEN
    KEY DROP
;

: SHOW_MATRIX_C
    PAGE
    MATRIX_C_WIDTH @ 0= MATRIX_C_HEIGHT @ 0= OR
    IF
        ." Matrix C not initialized"
    ELSE
        ." Matrix C:" CR CR
        DRAW_MATRIX_C
    THEN
    KEY DROP
;

: OUTPUT_MENU
    BEGIN
        PAGE
        10 SPACES ." OUTPUT MENU" CR
        CR
        4 SPACES ." A. Show Matrix A" CR
        4 SPACES ." B. Show Matrix B" CR
        4 SPACES ." C. Show Matrix C" CR
        4 SPACES ." X. Exit program" CR
        CR
        ." Please enter your choice: "
        KEY
        DUP [CHAR] a = IF SHOW_MATRIX_A ELSE
        DUP [CHAR] b = IF SHOW_MATRIX_B ELSE
        DUP [CHAR] c = IF SHOW_MATRIX_C ELSE
        DUP [CHAR] x = IF ELSE
                          PAGE
                          ." Invalid selection"
                          KEY
                          DROP
        THEN THEN THEN THEN
        [CHAR] x =
    UNTIL
;

\ ------------------- MATH MENU --------------------------

: MATH_MENU
    BEGIN
        PAGE
        10 SPACES ." MATH MENU" CR
        CR
        4 SPACES ." A. C <- A + B" CR
        4 SPACES ." S. C <- A - B" CR
        4 SPACES ." V. C <- A . B" CR
        4 SPACES ." X. Exit program" CR
        CR
        ." Please enter your choice: "
        KEY
        DUP [CHAR] a = IF ADD_MATRIX SHOW_MATRIX_C ELSE
        DUP [CHAR] s = IF SUBTRACT_MATRIX SHOW_MATRIX_C ELSE
        DUP [CHAR] v = IF VECTOR_MULTIPLY_MATRIX SHOW_MATRIX_C ELSE
        DUP [CHAR] x = IF ELSE
                          PAGE
                          ." Invalid selection"
                          KEY
                          DROP
        THEN THEN THEN THEN
        [CHAR] x =
    UNTIL
;

\ --------------------------- INPUT MENU ----------------------------------

: CREATE_MATRIX_A
    PAGE
    ." Matrix A Width: "
    READ_LINE VAL MATRIX_A_WIDTH !
    ." Matrix A Height: "
    READ_LINE VAL MATRIX_A_HEIGHT !
    MATRIX_A_HEIGHT @ 0 DO
        MATRIX_A_WIDTH @ 0 DO
            0e0 I J SET_MATRIX_C
        LOOP
    LOOP
    CR
    ." Matrix A  [ "
    MATRIX_A_WIDTH @ . ." x " MATRIX_A_HEIGHT @ .
    ." ] successfully created."
    KEY
    DROP
;

: CREATE_MATRIX_B
    PAGE
    ." Matrix B Width: "
    READ_LINE VAL MATRIX_B_WIDTH !
    ." Matrix B Height: "
    READ_LINE VAL MATRIX_B_HEIGHT !
    MATRIX_B_HEIGHT @ 0 DO
        MATRIX_B_WIDTH @ 0 DO
            0e0 I J SET_MATRIX_B
        LOOP
    LOOP
    CR
    ." Matrix B  [ "
    MATRIX_B_WIDTH @ . ." x " MATRIX_B_HEIGHT @ .
    ." ] successfully created."
    KEY
    DROP
;

: EDIT_MATRIX_A
    PAGE
    MATRIX_A_HEIGHT @ 0= MATRIX_A_WIDTH @ 0= OR
    IF
        ." Matrix A is not initialized."
    ELSE
        MATRIX_A_HEIGHT @ 0 DO
            MATRIX_A_WIDTH @ 0 DO
                PAGE
                ." Edit Matrix A:"
                DRAW_MATRIX_A
                ." [ " I 1+ . [CHAR] , EMIT SPACE J 1+ . ." ] = "
                READ_LINE >FLOAT I J SET_MATRIX_A
            LOOP
        LOOP
        PAGE
        ." Matrix A successfully edited."
    THEN
    KEY DROP
;

: EDIT_MATRIX_B
    PAGE
    MATRIX_B_HEIGHT @ 0= MATRIX_B_WIDTH @ 0= OR
    IF
        ." Matrix B is not initialized."
    ELSE
        MATRIX_B_HEIGHT @ 0 DO
            MATRIX_B_WIDTH @ 0 DO
                PAGE
                ." Edit Matrix B:"
                DRAW_MATRIX_B
                ." [ " I 1+ . [CHAR] , EMIT SPACE J 1+ . ." ] = "
                READ_LINE >FLOAT I J SET_MATRIX_B
            LOOP
        LOOP
        PAGE
        ." Matrix B successfully edited."
    THEN
    KEY DROP
;

: INPUT_MENU
    BEGIN
        PAGE
        10 SPACES ." INPUT MENU" CR
        CR
        4 SPACES ." Q. Create Matrix A" CR
        4 SPACES ." W. Create Matrix B" CR
        4 SPACES ." A. Edit Matrix A" CR
        4 SPACES ." S. Edit Matrix B" CR
        4 SPACES ." D. Edit Matrix A's cell" CR
        4 SPACES ." F. Edit Matrix B's cell" CR
        4 SPACES ." X. Back to main menu" CR
        CR
        ." Please enter your choice: "
        KEY
        DUP [CHAR] q = IF CREATE_MATRIX_A ELSE
        DUP [CHAR] w = IF CREATE_MATRIX_B ELSE
        DUP [CHAR] a = IF EDIT_MATRIX_A ELSE
        DUP [CHAR] s = IF EDIT_MATRIX_B ELSE
        DUP [CHAR] x = IF ELSE
                          PAGE
                          ." Invalid selection"
                          KEY
                          DROP
        THEN THEN THEN THEN THEN
        [CHAR] x =
    UNTIL
;

\ -------------------------------MAIN MENU -------------------------------

: MAIN_MENU
    BEGIN
        PAGE
        10 SPACES ." MATRIX MATH" CR
        CR
        4 SPACES ." I. Input menu" CR
        4 SPACES ." M. Math menu" CR
        4 SPACES ." O. Output menu" CR
        4 SPACES ." T. Transfer menu" CR
        4 SPACES ." A. About this program" CR
        4 SPACES ." X. Exit program" CR
        CR
        ." Please enter your choice: "
        KEY
        DUP [CHAR] i = IF INPUT_MENU ELSE
        DUP [CHAR] m = IF MATH_MENU ELSE
        DUP [CHAR] o = IF OUTPUT_MENU ELSE
        DUP [CHAR] x = IF ELSE
                          PAGE
                          ." Invalid selection"
                          KEY
                          DROP
        THEN THEN THEN THEN
        [CHAR] x =
    UNTIL
;

\ ------------------- ROUTINE ------------------------
