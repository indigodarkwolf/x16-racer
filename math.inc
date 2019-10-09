.ifndef MATH_INC
MATH_INC=1

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

.endif ; .ifndef MATH_INC