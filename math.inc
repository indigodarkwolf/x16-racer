.ifndef MATH_INC
MATH_INC=1

.include "system.inc"

;=================================================
; MATH_INIT
;   Initialize the math lib.
;-------------------------------------------------
; INPUTS:   (none)
;-------------------------------------------------
; MODIFIES: A,X,Y
; 
.macro MATH_INIT
    jsr math_init
.endmacro

;=================================================
; MOD
;   Module the accumulator by a value.
;-------------------------------------------------
; INPUTS:   .v  Divisor of the modulo
;
;-------------------------------------------------
; MODIFIES: A
; 
.macro MOD v
.local @sub
@sub:
    sec
    sbc #v
    bcs @sub
    adc #v
.endmacro

;=================================================
; ADD_16
;   16-bit version of "dst = lhs + rhs"
;-------------------------------------------------
; INPUTS:   dst     Destination memory address
;           lhs     Left-hand-side parameter
;           rhs     Right-hand-side parameter
;
;-------------------------------------------------
; MODIFIES: A
; 
.macro ADD_16 dst, lhs, rhs
    clc
    .repeat 2, i
    lda lhs+i
    adc rhs+i
    sta dst+i
    .endrep
.endmacro

;=================================================
; ADD_24
;   24-bit version of "dst = lhs + rhs"
;-------------------------------------------------
; INPUTS:   dst     Destination memory address
;           lhs     Left-hand-side parameter
;           rhs     Right-hand-side parameter
;
;-------------------------------------------------
; MODIFIES: A
; 
.macro ADD_24 dst, lhs, rhs
    clc
    .repeat 3, i
    lda lhs+i
    adc rhs+i
    sta dst+i
    .endrep
.endmacro

;=================================================
; BGE_16
;   16-bit version of "IF lhs >= rhs GOTO label"
;
;-------------------------------------------------
; INPUTS:   lhs     The "left-hand-side" of the comparison
;           rhs     The "right-hand-side" of the comparison
;           label   The branch destination
;
;-------------------------------------------------
; MODIFIES: A
; 
.macro BGE_16 lhs, rhs, label
.local @no_branch
    lda lhs
    cmp rhs
    lda lhs+1
    sbc rhs+1
    bcs label
@no_branch:
.endmacro

;=================================================
; BGE_24
;   24-bit version of "IF lhs >= rhs GOTO label"
;
;-------------------------------------------------
; INPUTS:   lhs     The "left-hand-side" of the comparison
;           rhs     The "right-hand-side" of the comparison
;           label   The branch destination
;
;-------------------------------------------------
; MODIFIES: A
; 
.macro BGE_24 lhs, rhs, label
.local @no_branch
    lda lhs
    cmp rhs
    lda lhs+1
    sbc rhs+1
    lda lhs+2
    sbc rhs+2
    bcs label
@no_branch:
.endmacro

;=================================================
; BLT_16
;   16-bit version of "IF lhs < rhs GOTO label"
;
;-------------------------------------------------
; INPUTS:   lhs     The "left-hand-side" of the comparison
;           rhs     The "right-hand-side" of the comparison
;           label   The branch destination
;
;-------------------------------------------------
; MODIFIES: A
; 
.macro BLT_16 lhs, rhs, label
.local @no_branch
    lda lhs
    cmp rhs
    lda lhs+1
    sbc rhs+1
    bcc label
@no_branch:
.endmacro

;=================================================
; BLT_24
;   24-bit version of "IF lhs < rhs GOTO label"
;
;-------------------------------------------------
; INPUTS:   lhs     The "left-hand-side" of the comparison
;           rhs     The "right-hand-side" of the comparison
;           label   The branch destination
;
;-------------------------------------------------
; MODIFIES: A
; 
.macro BLT_24 lhs, rhs, label
.local @no_branch
    lda lhs
    cmp rhs
    lda lhs+1
    sbc rhs+1
    lda lhs+2
    sbc rhs+2
    bcc label
@no_branch:
.endmacro

;=================================================
; MUL_BEGIN
;   Begin a block of multiplication calls.
;   This ensures that the proper block of himem
;   is banked in to support math lib calls.
;   multi-byte addition and subtraction does not
;   
;-------------------------------------------------
; INPUTS:   (none)
;-------------------------------------------------
; MODIFIES: A
; 
.macro MUL_BEGIN
    SYS_SET_BANK MATH_TABLES_BANK
.endmacro

;=================================================
; MUL_8_8
;   8-bit version of dst = lhs * rhs, 
;   truncating the result down to 8 bits in the
;   event of an overflow.
;   
;-------------------------------------------------
; INPUTS:   dst     Destination memory address
;           lhs     Left-hand-side parameter
;           rhs     Right-hand-side parameter
;-------------------------------------------------
; MODIFIES: A, X, Y
; 
.macro MUL_8_8 dst, lhs, rhs
    lda lhs
    ldy rhs
    jsr mul_8
    stx dst
.endmacro

;=================================================
; ADDMUL_8_8
;   8-bit version of dst += lhs * rhs, 
;   truncating the result down to 8 bits in the
;   event of an overflow.
;   
;-------------------------------------------------
; INPUTS:   dst     Destination memory address
;           lhs     Left-hand-side parameter
;           rhs     Right-hand-side parameter
;-------------------------------------------------
; MODIFIES: A, X, Y
; 
.macro ADDMUL_8_8 dst, lhs, rhs
    lda lhs
    ldy rhs
    jsr mul_8
    txa
    clc
    adc dst
    sta dst
.endmacro

;=================================================
; MUL_8_16
;   8-bit version of dst = lhs * rhs
;   stores the value in a 16-bit destination,
;   so overflow is impossible.
;   
;-------------------------------------------------
; INPUTS:   dst     Destination memory address
;           lhs     Left-hand-side parameter
;           rhs     Right-hand-side parameter
;-------------------------------------------------
; MODIFIES: A, X, Y
; 
.macro MUL_8_16 dst, lhs, rhs
    lda lhs
    ldy rhs
    jsr mul_8
    stx dst
    sta dst+1
.endmacro

;=================================================
; ADDMUL_8_16
;   8-bit version of dst += lhs * rhs
;   stores the value in a 16-bit destination,
;   so overflow is impossible with the multiply.
;   
;-------------------------------------------------
; INPUTS:   dst     Destination memory address
;           lhs     Left-hand-side parameter
;           rhs     Right-hand-side parameter
;-------------------------------------------------
; MODIFIES: A, X, Y
; 
.macro ADDMUL_8_16 dst, lhs, rhs
    lda lhs
    ldy rhs
    jsr mul_8
    tay
    txa
    clc
    adc dst
    sta dst
    tya
    adc dst+1
    sta dst+1
.endmacro

;=================================================
; MUL_16_16
;   16-bit version of dst = lhs * rhs, 
;   truncating the result down to 16 bits in the
;   event of an overflow.
;   
;-------------------------------------------------
; INPUTS:   dst     Destination memory address
;           lhs     Left-hand-side parameter
;           rhs     Right-hand-side parameter
;-------------------------------------------------
; MODIFIES: A, X, Y
; 
.macro MUL_16_16 dst, lhs, rhs
    MUL_8_16 dst, lhs, rhs
    ADDMUL_8_8 dst+1, lhs, rhs+1
    ADDMUL_8_8 dst+1, lhs+1, rhs
.endmacro

;=================================================
; ADDMUL_16_16
;   16-bit version of dst += lhs * rhs, 
;   truncating the result down to 16 bits in the
;   event of an overflow.
;   
;-------------------------------------------------
; INPUTS:   dst     Destination memory address
;           lhs     Left-hand-side parameter
;           rhs     Right-hand-side parameter
;-------------------------------------------------
; MODIFIES: A, X, Y
; 
.macro ADDMUL_16_16 dst, lhs, rhs
    ADDMUL_8_16 dst, lhs, rhs
    ADDMUL_8_8 dst+1, lhs, rhs+1
    ADDMUL_8_8 dst+1, lhs+1, rhs
.endmacro

;=================================================
; MUL_16_24
;   16-bit version of dst = lhs * rhs, 
;   truncating the result down to 24 bits in the
;   event of an overflow.
;   
;-------------------------------------------------
; INPUTS:   dst     Destination memory address
;           lhs     Left-hand-side parameter
;           rhs     Right-hand-side parameter
;-------------------------------------------------
; MODIFIES: A, X, Y
; 
.macro MUL_16_24 dst, lhs, rhs
    stz dst+2
    MUL_8_16 dst, lhs, rhs
    ADDMUL_8_16 dst+1, lhs, rhs+1
    ADDMUL_8_16 dst+1, lhs+1, rhs
    ADDMUL_8_8 dst+2, lhs+1, rhs+1
.endmacro

;=================================================
; ADDMUL_16_24
;   16-bit version of dst = lhs * rhs, 
;   truncating the result down to 24 bits in the
;   event of an overflow.
;   
;-------------------------------------------------
; INPUTS:   dst     Destination memory address
;           lhs     Left-hand-side parameter
;           rhs     Right-hand-side parameter
;-------------------------------------------------
; MODIFIES: A, X, Y
; 
.macro ADDMUL_16_24 dst, lhs, rhs
    ADDMUL_8_16 dst, lhs, rhs
    ADDMUL_8_16 dst+1, lhs, rhs+1
    ADDMUL_8_16 dst+1, lhs+1, rhs
    ADDMUL_8_8 dst+2, lhs+1, rhs+1
.endmacro

;=================================================
; MUL_16_32
;   16-bit version of dst = lhs * rhs, 
;   stores the value in a 32-bit destination,
;   so overflow is impossible with the multiply.
;   
;-------------------------------------------------
; INPUTS:   dst     Destination memory address
;           lhs     Left-hand-side parameter
;           rhs     Right-hand-side parameter
;-------------------------------------------------
; MODIFIES: A, X, Y
; 
.macro MUL_16_32 dst, lhs, rhs
    stz dst+2
    stz dst+3
    MUL_8_16 dst, lhs, rhs
    ADDMUL_8_16 dst+1, lhs, rhs+1
    ADDMUL_8_16 dst+1, lhs+1, rhs
    ADDMUL_8_16 dst+2, lhs+1, rhs+1
.endmacro

;=================================================
; ADDMUL_16_32
;   16-bit version of dst += lhs * rhs, 
;   stores the value in a 32-bit destination,
;   so overflow is impossible with the multiply.
;   
;-------------------------------------------------
; INPUTS:   dst     Destination memory address
;           lhs     Left-hand-side parameter
;           rhs     Right-hand-side parameter
;-------------------------------------------------
; MODIFIES: A, X, Y
; 
.macro ADDMUL_16_32 dst, lhs, rhs
    ADDMUL_8_16 dst, lhs, rhs
    ADDMUL_8_16 dst+1, lhs, rhs+1
    ADDMUL_8_16 dst+1, lhs+1, rhs
    ADDMUL_8_16 dst+2, lhs+1, rhs+1
.endmacro

;=================================================
; MUL_24_24
;   24-bit version of dst = lhs * rhs, 
;   truncating the result down to 24 bits in the
;   event of an overflow.
;   
;-------------------------------------------------
; INPUTS:   dst     Destination memory address
;           lhs     Left-hand-side parameter
;           rhs     Right-hand-side parameter
;-------------------------------------------------
; MODIFIES: A, X, Y
; 
.macro MUL_24_24 dst, lhs, rhs
    MUL_16_24 dst, lhs, rhs
    ADDMUL_8_8 dst+2, lhs, rhs+2
    ADDMUL_8_8 dst+2, lhs+2, rhs
.endmacro

;=================================================
; ADDMUL_24_24
;   24-bit version of dst += lhs * rhs, 
;   truncating the result down to 24 bits in the
;   event of an overflow.
;   
;-------------------------------------------------
; INPUTS:   dst     Destination memory address
;           lhs     Left-hand-side parameter
;           rhs     Right-hand-side parameter
;-------------------------------------------------
; MODIFIES: A, X, Y
; 
.macro ADDMUL_24_24 dst, lhs, rhs
    ADDMUL_16_24 dst, lhs, rhs
    ADDMUL_8_8 dst+2, lhs, rhs+2
    ADDMUL_8_8 dst+2, lhs+2, rhs
.endmacro

;=================================================
; MUL_24_32
;   24-bit version of dst = lhs * rhs, 
;   truncating the result down to 32 bits in the
;   event of an overflow.
;   
;-------------------------------------------------
; INPUTS:   dst     Destination memory address
;           lhs     Left-hand-side parameter
;           rhs     Right-hand-side parameter
;-------------------------------------------------
; MODIFIES: A, X, Y
; 
.macro MUL_24_32 dst, lhs, rhs
    MUL_16_32 dst, lhs, rhs
    ADDMUL_8_16 dst+2, lhs, rhs+2
    ADDMUL_8_16 dst+2, lhs+2, rhs
    ADDMUL_8_8 dst+3, lhs+2, rhs+1
    ADDMUL_8_8 dst+3, lhs+1, rhs+2
.endmacro

;=================================================
; ADDMUL_24_32
;   24-bit version of dst += lhs * rhs, 
;   truncating the result down to 32 bits in the
;   event of an overflow.
;   
;-------------------------------------------------
; INPUTS:   dst     Destination memory address
;           lhs     Left-hand-side parameter
;           rhs     Right-hand-side parameter
;-------------------------------------------------
; MODIFIES: A, X, Y
; 
.macro ADDMUL_24_32 dst, lhs, rhs
    ADDMUL_16_32 dst, lhs, rhs
    ADDMUL_8_16 dst+2, lhs, rhs+2
    ADDMUL_8_16 dst+2, lhs+2, rhs
    ADDMUL_8_8 dst+3, lhs+2, rhs+1
    ADDMUL_8_8 dst+3, lhs+1, rhs+2
.endmacro

;=================================================
; MUL_24_48
;   48-bit version of dst = lhs * rhs, 
;   stores the value in a 48-bit destination,
;   so overflow is impossible with the multiply.
;   
;-------------------------------------------------
; INPUTS:   dst     Destination memory address
;           lhs     Left-hand-side parameter
;           rhs     Right-hand-side parameter
;-------------------------------------------------
; MODIFIES: A, X, Y
; 
.macro MUL_24_48 dst, lhs, rhs
    stz dst+4
    stz dst+5
    MUL_16_32 dst, lhs, rhs
    ADDMUL_8_16 dst+2, lhs, rhs+2
    ADDMUL_8_16 dst+2, lhs+2, rhs
    ADDMUL_8_16 dst+3, lhs+2, rhs+1
    ADDMUL_8_16 dst+3, lhs+1, rhs+2
    ADDMUL_8_16 dst+4, lhs, rhs+2
.endmacro

;=================================================
; ADDMUL_24_48
;   48-bit version of dst += lhs * rhs, 
;   stores the value in a 48-bit destination,
;   so overflow is impossible with the multiply.
;   
;-------------------------------------------------
; INPUTS:   dst     Destination memory address
;           lhs     Left-hand-side parameter
;           rhs     Right-hand-side parameter
;-------------------------------------------------
; MODIFIES: A, X, Y
; 
.macro ADDMUL_24_48 dst, lhs, rhs
    ADDMUL_16_32 dst, lhs, rhs
    ADDMUL_8_16 dst+2, lhs, rhs+2
    ADDMUL_8_16 dst+2, lhs+2, rhs
    ADDMUL_8_16 dst+3, lhs+2, rhs+1
    ADDMUL_8_16 dst+3, lhs+1, rhs+2
    ADDMUL_8_16 dst+4, lhs, rhs+2
.endmacro

.endif ; .ifndef MATH_INC