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
.endscope
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
