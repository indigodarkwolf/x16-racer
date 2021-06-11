.ifndef MATH_INC
MATH_INC=1

.include "util.inc"
.include "x16/system.inc"

.global math_init
.global cos_8
.global sin_8
.global mul_8
.global div_8
.global div_16

MATH_TABLES_BANK = $01

;=================================================
;=================================================
;
;   Cheatsheet / Quick Reference
;
;-------------------------------------------------
;
;   There are _8, _16, and _24 bit variants (little-endian)
;   of the following macros:
;
;   Unary math ops: (DST, SRC)
;       NEG     Negate a signed value
;
;   Binary math ops: (DST, LHS, RHS)
;       ADD     Unsigned add
;       SUB     Unsigned subtract
;
;   Binary comparison ops: (LHS, RHS, LABEL)
;       BNE     Branch if not equal
;       BEQ     Branch if equal
;       BGE     Branch if greater or equal to
;       BLT     Branch if less than
;
;   Modulo: (VALUE)
;       MOD     Accumulator = Accumulator % VALUE
;
;   Multiplication ops: (DST, LHS, RHS)
;       MUL_8_8
;       MUL_8_16
;       MUL_16_16
;       MUL_16_24
;       MUL_16_32
;       MUL_24_24
;       MUL_24_32
;       MUL_24_48
;
;   Additive multiplication ops: (DST, LHS, RHS)
;       ADDMUL_8_8
;       ADDMUL_8_16
;       ADDMUL_16_16
;       ADDMUL_16_24
;       ADDMUL_16_32
;       ADDMUL_24_24
;       ADDMUL_24_32
;       ADDMUL_24_48
;

;=================================================
;=================================================
;
;   Additional Info
;
;-------------------------------------------------
;
;   About MOD:
;
;   MOD is modulo operation implemented as a psuedo-op
;   on the accumulator and requires an undecorated 
;   immediate value. (ACC = ACC % VALUE)
;
;   Beware that is the slowest, most painfully naive 
;   modulo you can imagine.
;
;
;   About multiplication:
;   
;   MUL macros implement little-endian unsigned integer 
;   multiplication (DST = LHS * RHS).
;
;   The first number in the macro is the bit-size of the 
;   source values (LHS, RHS); the second number is the 
;   bit-size of the destination.
;
;   They require calling MATH_INIT at least once before use,
;   and use RAM bank $01. Additionally, call MUL_BEGIN before
;   any set of multiplication, to ensure that the proper RAM bank is
;   present. MUL macros do not support operating on values
;   in banked memory.
;
;   ADDMUL macros implement little-endian unsigned integer
;   multiplication, added to the destination
;   (DST += LSH * RHS). These are slightly faster if you
;   know your destination is already zeroed out, or other-
;   wise would add a single value to the destination. They
;   are essentially a convenient by-product of the MUL
;   implementations.
;
;
;   About trigonometry:
;
;   sin_8 and cos_8 implement the sine and cosine
;   of the accumulator, which is assumed to be the 
;   unsigned 0.8 fixed point ratio of Tau (2 * Pi).
;   Examples: 
;   0 = 0 degrees or radians
;   255 = 358.59375 degrees or approx. 6.25864 radians.
;
;   Results are returned in the form of a signed 8.8
;   fixed point value in the range [-1, 1], with the
;   low byte in the accumulator and the high byte in 
;   the X register. 
;   Examples:
;   $0001 = 1/256
;   $FFFF = -1/256.
;
;
;   About performance:
;
;   MUL macros use a table-based approach that tries to
;   balance memory consumption with speed. The fastest
;   MUL implementations use 2KB of memory and run in
;   38-42 cycles, mine uses 1KB but run in 51-62 cycles.
;
;   sin_8 and cos_8 are written as table lookups, but the 
;   tables were generated with the plan to write higher
;   precision trigonometry with a 0.16 input. As a result
;   they are "a little slow" due to extra branching,
;   negation, or subtraction from 1.
;

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
; NEG_8
;   8-bit version of "dst = -src"
;-------------------------------------------------
; INPUTS:   dst     Destination memory address
;           src     (Optional) Source parameter, distination if omitted
;
;-------------------------------------------------
; MODIFIES: A
; 
.macro NEG_8 dst, src
    .ifblank src
        clc
        lda dst
        eor #$ff
        adc #1
        sta dst
    .else
        clc
        lda src
        eor #$ff
        adc #1
        sta dst
    .endif
.endmacro

;=================================================
; NEG_16
;   16-bit version of "dst = -src"
;-------------------------------------------------
; INPUTS:   dst     Destination memory address
;           src     (Optional) Source parameter, distination if omitted
;
;-------------------------------------------------
; MODIFIES: A
; 
.macro NEG_16 dst, src
    .ifblank src
        clc
        .repeat 2, i
        lda dst+i
        eor #$ff
        .if i = 0
            adc #1
        .else
            adc #0
        .endif
        sta dst+i
        .endrep
    .else
        clc
        .repeat 2, i
        lda src+i
        eor #$ff
        .if i = 0
            adc #1
        .else
            adc #0
        .endif
        sta dst+i
        .endrep
    .endif
.endmacro

;=================================================
; NEG_24
;   24-bit version of "dst = -src"
;-------------------------------------------------
; INPUTS:   dst     Destination memory address
;           src     (Optional) Source parameter, distination if omitted
;
;-------------------------------------------------
; MODIFIES: A
; 
.macro NEG_24 dst, src
    .ifblank src
        clc
        .repeat 3, i
        lda dst+i
        eor #$ff
        .if i = 0
            adc #1
        .else
            adc #0
        .endif
        sta dst+i
        .endrep
    .else
        clc
        .repeat 3, i
        lda src+i
        eor #$ff
        .if i = 0
            adc #1
        .else
            adc #0
        .endif
        sta dst+i
        .endrep
    .endif
.endmacro

;=================================================
;=================================================
;
; Addition and subtraction macros
;
;=================================================

;=================================================
; ADD_BYTES
;   n-byte version of "dst = lhs + rhs"
;-------------------------------------------------
; INPUTS:   dst     Destination memory address
;           lhs     Left-hand-side parameter
;           rhs     Right-hand-side parameter
;
;-------------------------------------------------
; MODIFIES: A
; 
.macro ADD_BYTES dst, lhs, rhs, bytes
.ifblank dst
    .error "ADD_BYTES missing parameter: dst"
.endif
.ifblank lhs
    .error "ADD_BYTES missing parameter: lhs"
.endif
.ifblank rhs
    .error "ADD_BYTES missing parameter: rhs"
.endif
.ifblank bytes
    .error "ADD_BYTES missing parameter: bytes"
.endif
.if IMM(dst)
    .error "destination of ADD_BYTES cannot be immediate"
.endif
    clc
    .repeat bytes, i
        lda lhs+i
        adc rhs+i
        sta dst+i
    .endrep
.endmacro

;=================================================
; ADD_8
;   8-bit version of "dst = lhs + rhs"
;-------------------------------------------------
; INPUTS:   dst     Destination memory address
;           lhs     Left-hand-side parameter
;           rhs     Right-hand-side parameter
;
;-------------------------------------------------
; MODIFIES: A
; 
.macro ADD_8 dst, lhs, rhs
.ifblank dst
    .error "ADD_8 missing parameter: dst"
.endif
.ifblank lhs
    .error "ADD_8 missing parameter: lhs"
.endif
.ifblank rhs
    .error "ADD_8 missing parameter: rhs"
.endif
.if IMM(dst)
    .error "destination of ADD_8 cannot be immediate"
.endif
.scope
add_8:
    ADD_BYTES dst, lhs, rhs, 1
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
.ifblank dst
    .error "ADD_16 missing parameter: dst"
.endif
.ifblank lhs
    .error "ADD_16 missing parameter: lhs"
.endif
.ifblank rhs
    .error "ADD_16 missing parameter: rhs"
.endif
.if IMM(dst)
    .error "destination of ADD_16 cannot be immediate"
.endif
.scope
add_16:
    ADD_BYTES dst, lhs, rhs, 2
.endscope
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
.ifblank dst
    .error "ADD_24 missing parameter: dst"
.endif
.ifblank lhs
    .error "ADD_24 missing parameter: lhs"
.endif
.ifblank rhs
    .error "ADD_24 missing parameter: rhs"
.endif
.if IMM(dst)
    .error "destination of ADD_24 cannot be immediate"
.endif
.scope
add_24:
    ADD_BYTES dst, lhs, rhs, 3
.endscope
.endmacro

;=================================================
; ADDI_BYTES
;   n-byte version of "dst = lhs + rhs"
;-------------------------------------------------
; INPUTS:   dst     Destination memory address
;           lhs     Left-hand-side parameter
;           rhs     Right-hand-side parameter
;
;-------------------------------------------------
; MODIFIES: A
; 
.macro ADDI_BYTES dst, lhs, rhs, bytes
.ifblank dst
    .error "ADDI_BYTES missing parameter: dst"
.endif
.ifblank lhs
    .error "ADDI_BYTES missing parameter: lhs"
.endif
.ifblank rhs
    .error "ADDI_BYTES missing parameter: rhs"
.endif
.ifblank bytes
    .error "ADDI_BYTES missing parameter: bytes"
.endif
    clc
    .repeat bytes, i
        lda lhs+i
        adc #(((rhs) >> (8 * i)) & $FF)
        sta dst+i
    .endrep
.endmacro

;=================================================
; ADDI_8
;   8-bit version of "dst = lhs + rhs"
;-------------------------------------------------
; INPUTS:   dst     Destination memory address
;           lhs     Left-hand-side parameter
;           rhs     Right-hand-side parameter
;
;-------------------------------------------------
; MODIFIES: A
; 
.macro ADDI_8 dst, lhs, rhs
.ifblank dst
    .error "ADDI_8 missing parameter: dst"
.endif
.ifblank lhs
    .error "ADDI_8 missing parameter: lhs"
.endif
.ifblank rhs
    .error "ADDI_8 missing parameter: rhs"
.endif
.scope
addi_8:
    ADDI_BYTES dst, lhs, rhs, 1
.endscope
.endmacro

;=================================================
; ADDI_16
;   16-bit version of "dst = lhs + rhs"
;-------------------------------------------------
; INPUTS:   dst     Destination memory address
;           lhs     Left-hand-side parameter
;           rhs     Right-hand-side parameter
;
;-------------------------------------------------
; MODIFIES: A
; 
.macro ADDI_16 dst, lhs, rhs
.ifblank dst
    .error "ADDI_16 missing parameter: dst"
.endif
.ifblank lhs
    .error "ADDI_16 missing parameter: lhs"
.endif
.ifblank rhs
    .error "ADDI_16 missing parameter: rhs"
.endif
.if IMM(dst)
    .error "destination of ADDI_16 cannot be immediate"
.endif
.scope
addi_16:
    ADDI_BYTES dst, lhs, rhs, 2
.endscope
.endmacro

;=================================================
; ADDI_24
;   24-bit version of "dst = lhs + rhs"
;-------------------------------------------------
; INPUTS:   dst     Destination memory address
;           lhs     Left-hand-side parameter
;           rhs     Right-hand-side parameter
;
;-------------------------------------------------
; MODIFIES: A
; 
.macro ADDI_24 dst, lhs, rhs
.ifblank dst
    .error "ADDI_24 missing parameter: dst"
.endif
.ifblank lhs
    .error "ADDI_24 missing parameter: lhs"
.endif
.ifblank rhs
    .error "ADDI_24 missing parameter: rhs"
.endif
.if IMM(dst)
    .error "destination of ADDI_24 cannot be immediate"
.endif
.scope
addi_24:
    ADDI_BYTES dst, lhs, rhs, 3
.endscope
.endmacro


;=================================================
; SUB_BYTES
;   n-byte version of "dst = lhs - rhs"
;-------------------------------------------------
; INPUTS:   dst     Destination memory address
;           lhs     Left-hand-side parameter
;           rhs     Right-hand-side parameter
;
;-------------------------------------------------
; MODIFIES: A
; 
.macro SUB_BYTES dst, lhs, rhs, bytes
.ifblank dst
    .error "SUB_BYTES missing parameter: dst"
.endif
.ifblank lhs
    .error "SUB_BYTES missing parameter: lhs"
.endif
.ifblank rhs
    .error "SUB_BYTES missing parameter: rhs"
.endif
.ifblank bytes
    .error "SUB_BYTES missing parameter: bytes"
.endif
.if IMM(dst)
    .error "destination of SUB_BYTES cannot be immediate"
.endif

    sec
    .repeat bytes, i
        lda lhs+i
        sbc rhs+i
        sta dst+i
    .endrep
.endmacro

;=================================================
; SUB_8
;   8-bit version of "dst = lhs - rhs"
;-------------------------------------------------
; INPUTS:   dst     Destination memory address
;           lhs     Left-hand-side parameter
;           rhs     Right-hand-side parameter
;
;-------------------------------------------------
; MODIFIES: A
; 
.macro SUB_8 dst, lhs, rhs
.ifblank dst
    .error "SUB_8 missing parameter: dst"
.endif
.ifblank lhs
    .error "SUB_8 missing parameter: lhs"
.endif
.ifblank rhs
    .error "SUB_8 missing parameter: rhs"
.endif
.if IMM(dst)
    .error "destination of SUB_8 cannot be immediate"
.endif
.scope
sub_8:
    SUB_BYTES dst, lhs, rhs, 1
.endscope
.endmacro

;=================================================
; SUB_16
;   16-bit version of "dst = lhs - rhs"
;-------------------------------------------------
; INPUTS:   dst     Destination memory address
;           lhs     Left-hand-side parameter
;           rhs     Right-hand-side parameter
;
;-------------------------------------------------
; MODIFIES: A
; 
.macro SUB_16 dst, lhs, rhs
.ifblank dst
    .error "SUB_16 missing parameter: dst"
.endif
.ifblank lhs
    .error "SUB_16 missing parameter: lhs"
.endif
.ifblank rhs
    .error "SUB_16 missing parameter: rhs"
.endif
.if IMM(dst)
    .error "destination of SUB_16 cannot be immediate"
.endif
.scope
sub_16:
    SUB_BYTES dst, lhs, rhs, 2
.endscope
.endmacro

;=================================================
; SUB_24
;   24-bit version of "dst = lhs - rhs"
;-------------------------------------------------
; INPUTS:   dst     Destination memory address
;           lhs     Left-hand-side parameter
;           rhs     Right-hand-side parameter
;
;-------------------------------------------------
; MODIFIES: A
; 
.macro SUB_24 dst, lhs, rhs
.ifblank dst
    .error "SUB_24 missing parameter: dst"
.endif
.ifblank lhs
    .error "SUB_24 missing parameter: lhs"
.endif
.ifblank rhs
    .error "SUB_24 missing parameter: rhs"
.endif
.if IMM(dst)
    .error "destination of SUB_24 cannot be immediate"
.endif
.scope
sub_24:
    SUB_BYTES dst, lhs, rhs, 3
.endscope
.endmacro


;=================================================
; SUBI_BYTES
;   n-byte version of "dst = lhs - rhs"
;-------------------------------------------------
; INPUTS:   dst     Destination memory address
;           lhs     Left-hand-side parameter
;           rhs     Right-hand-side parameter
;
;-------------------------------------------------
; MODIFIES: A
; 
.macro SUBI_BYTES dst, lhs, rhs, bytes
.ifblank dst
    .error "SUBI_BYTES missing parameter: dst"
.endif
.ifblank lhs
    .error "SUBI_BYTES missing parameter: lhs"
.endif
.ifblank rhs
    .error "SUBI_BYTES missing parameter: rhs"
.endif
.ifblank bytes
    .error "SUBI_BYTES missing parameter: bytes"
.endif
.if IMM(dst)
    .error "destination of SUBI_BYTES cannot be immediate"
.endif

    sec
    .repeat bytes, i
        lda lhs+i
        sbc #(((rhs) >> (8 * i)) & $FF)
        sta dst+i
    .endrep
.endmacro

;=================================================
; SUBI_8
;   8-bit version of "dst = lhs - rhs"
;-------------------------------------------------
; INPUTS:   dst     Destination memory address
;           lhs     Left-hand-side parameter
;           rhs     Right-hand-side parameter
;
;-------------------------------------------------
; MODIFIES: A
; 
.macro SUBI_8 dst, lhs, rhs
.ifblank dst
    .error "SUBI_8 missing parameter: dst"
.endif
.ifblank lhs
    .error "SUBI_8 missing parameter: lhs"
.endif
.ifblank rhs
    .error "SUBI_8 missing parameter: rhs"
.endif
.if IMM(dst)
    .error "destination of SUBI_8 cannot be immediate"
.endif
.scope
subi_8:
    SUBI_BYTES dst, lhs, rhs, 1
.endscope
.endmacro

;=================================================
; SUBI_16
;   16-bit version of "dst = lhs - rhs"
;-------------------------------------------------
; INPUTS:   dst     Destination memory address
;           lhs     Left-hand-side parameter
;           rhs     Right-hand-side parameter
;
;-------------------------------------------------
; MODIFIES: A
; 
.macro SUBI_16 dst, lhs, rhs
.ifblank dst
    .error "SUBI_16 missing parameter: dst"
.endif
.ifblank lhs
    .error "SUBI_16 missing parameter: lhs"
.endif
.ifblank rhs
    .error "SUBI_16 missing parameter: rhs"
.endif
.if IMM(dst)
    .error "destination of SUBI_16 cannot be immediate"
.endif
.scope
subi_16:
    SUBI_BYTES dst, lhs, rhs, 2
.endscope
.endmacro

;=================================================
; SUBI_24
;   24-bit version of "dst = lhs - rhs"
;-------------------------------------------------
; INPUTS:   dst     Destination memory address
;           lhs     Left-hand-side parameter
;           rhs     Right-hand-side parameter
;
;-------------------------------------------------
; MODIFIES: A
; 
.macro SUBI_24 dst, lhs, rhs
.ifblank dst
    .error "SUBI_24 missing parameter: dst"
.endif
.ifblank lhs
    .error "SUBI_24 missing parameter: lhs"
.endif
.ifblank rhs
    .error "SUBI_24 missing parameter: rhs"
.endif
.if IMM(dst)
    .error "destination of SUBI_24 cannot be immediate"
.endif
.scope
subi_24:
    SUBI_BYTES dst, lhs, rhs, 3
.endscope
.endmacro

;=================================================
;=================================================
;
; Comparison macros
;
;=================================================


;=================================================
; BNE_BYTES
;   n-byte version of "IF lhs != rhs GOTO label"
;-------------------------------------------------
; INPUTS:   lhs     Left-hand-side parameter
;           rhs     Right-hand-side parameter
;           label   Destination label if condition is true
;
;-------------------------------------------------
; MODIFIES: A
; 
.macro BNE_BYTES lhs, rhs, label, bytes
.ifblank lhs
    .error "BNE_BYTES missing parameter: lhs"
.endif
.ifblank rhs
    .error "BNE_BYTES missing parameter: rhs"
.endif
.ifblank label
    .error "BNE_BYTES missing parameter: label"
.endif
.ifblank bytes
    .error "BNE_BYTES missing parameter: bytes"
.endif
.if IMM(label)
    .error "label of BNE_BYTES cannot be immediate"
.endif
.local no_branch
    .repeat bytes, i
    lda lhs+i
    cmp rhs+i
    bne label
    .endrep
no_branch:
.endmacro



;=================================================
; BNE_8
;   8-bit version of "IF lhs != rhs GOTO label"
;
;-------------------------------------------------
; INPUTS:   lhs     The "left-hand-side" of the comparison
;           rhs     The "right-hand-side" of the comparison
;           label   The branch destination
;
;-------------------------------------------------
; MODIFIES: A
; 
.macro BNE_8 lhs, rhs, label
.ifblank lhs
    .error "BNE_8 missing parameter: lhs"
.endif
.ifblank rhs
    .error "BNE_8 missing parameter: rhs"
.endif
.ifblank label
    .error "BNE_8 missing parameter: label"
.endif
.ifblank bytes
    .error "BNE_8 missing parameter: bytes"
.endif
.if IMM(label)
    .error "label of BNE_8 cannot be immediate"
.endif
.scope
bne_8:
    BNE_BYTES lhs, rhs, label, 1
.endscope
.endmacro


;=================================================
; BNE_16
;   16-bit version of "IF lhs != rhs GOTO label"
;
;-------------------------------------------------
; INPUTS:   lhs     The "left-hand-side" of the comparison
;           rhs     The "right-hand-side" of the comparison
;           label   The branch destination
;
;-------------------------------------------------
; MODIFIES: A
; 
.macro BNE_16 lhs, rhs, label
.ifblank lhs
    .error "BNE_16 missing parameter: lhs"
.endif
.ifblank rhs
    .error "BNE_16 missing parameter: rhs"
.endif
.ifblank label
    .error "BNE_16 missing parameter: label"
.endif
.ifblank bytes
    .error "BNE_16 missing parameter: bytes"
.endif
.if IMM(label)
    .error "label of BNE_16 cannot be immediate"
.endif
.scope
bne_16:
    BNE_BYTES lhs, rhs, label, 2
.endscope
.endmacro

;=================================================
; BNE_24
;   24-bit version of "IF lhs != rhs GOTO label"
;
;-------------------------------------------------
; INPUTS:   lhs     The "left-hand-side" of the comparison
;           rhs     The "right-hand-side" of the comparison
;           label   The branch destination
;
;-------------------------------------------------
; MODIFIES: A
; 
.macro BNE_24 lhs, rhs, label
.ifblank lhs
    .error "BNE_24 missing parameter: lhs"
.endif
.ifblank rhs
    .error "BNE_24 missing parameter: rhs"
.endif
.ifblank label
    .error "BNE_24 missing parameter: label"
.endif
.ifblank bytes
    .error "BNE_24 missing parameter: bytes"
.endif
.if IMM(label)
    .error "label of BNE_24 cannot be immediate"
.endif
.scope
bne_24:
    BNE_BYTES lhs, rhs, label, 3
.endscope
.endmacro


;=================================================
; BNEI_BYTES
;   n-byte version of "IF lhs != rhs GOTO label"
;-------------------------------------------------
; INPUTS:   lhs     Left-hand-side parameter
;           rhs     Right-hand-side parameter
;           label   Destination label if condition is true
;
;-------------------------------------------------
; MODIFIES: A
; 
.macro BNEI_BYTES lhs, rhs, label, bytes
.ifblank lhs
    .error "BNEI_BYTES missing parameter: lhs"
.endif
.ifblank rhs
    .error "BNEI_BYTES missing parameter: rhs"
.endif
.ifblank label
    .error "BNEI_BYTES missing parameter: label"
.endif
.ifblank bytes
    .error "BNEI_BYTES missing parameter: bytes"
.endif
.if IMM(label)
    .error "label of BNEI_BYTES cannot be immediate"
.endif
.local no_branch
    .repeat bytes, i
        lda lhs+i
        cmp #(((rhs) >> (8 * i)) & $FF)
        bne label
    .endrep
no_branch:
.endmacro



;=================================================
; BNEI_8
;   8-bit version of "IF lhs != rhs GOTO label"
;
;-------------------------------------------------
; INPUTS:   lhs     The "left-hand-side" of the comparison
;           rhs     The "right-hand-side" of the comparison
;           label   The branch destination
;
;-------------------------------------------------
; MODIFIES: A
; 
.macro BNEI_8 lhs, rhs, label
.ifblank lhs
    .error "BNEI_8 missing parameter: lhs"
.endif
.ifblank rhs
    .error "BNEI_8 missing parameter: rhs"
.endif
.ifblank label
    .error "BNEI_8 missing parameter: label"
.endif
.ifblank bytes
    .error "BNEI_8 missing parameter: bytes"
.endif
.if IMM(label)
    .error "label of BNEI_8 cannot be immediate"
.endif
.scope
bnei_8:
    BNEI_BYTES lhs, rhs, label, 1
.endscope
.endmacro


;=================================================
; BNEI_16
;   16-bit version of "IF lhs != rhs GOTO label"
;
;-------------------------------------------------
; INPUTS:   lhs     The "left-hand-side" of the comparison
;           rhs     The "right-hand-side" of the comparison
;           label   The branch destination
;
;-------------------------------------------------
; MODIFIES: A
; 
.macro BNEI_16 lhs, rhs, label
.ifblank lhs
    .error "BNEI_16 missing parameter: lhs"
.endif
.ifblank rhs
    .error "BNEI_16 missing parameter: rhs"
.endif
.ifblank label
    .error "BNEI_16 missing parameter: label"
.endif
.ifblank bytes
    .error "BNEI_16 missing parameter: bytes"
.endif
.if IMM(label)
    .error "label of BNEI_16 cannot be immediate"
.endif
.scope
bnei_16:
    BNEI_BYTES lhs, rhs, label, 2
.endscope
.endmacro

;=================================================
; BNEI_24
;   24-bit version of "IF lhs != rhs GOTO label"
;
;-------------------------------------------------
; INPUTS:   lhs     The "left-hand-side" of the comparison
;           rhs     The "right-hand-side" of the comparison
;           label   The branch destination
;
;-------------------------------------------------
; MODIFIES: A
; 
.macro BNEI_24 lhs, rhs, label
.ifblank lhs
    .error "BNEI_24 missing parameter: lhs"
.endif
.ifblank rhs
    .error "BNEI_24 missing parameter: rhs"
.endif
.ifblank label
    .error "BNEI_24 missing parameter: label"
.endif
.ifblank bytes
    .error "BNEI_24 missing parameter: bytes"
.endif
.if IMM(label)
    .error "label of BNEI_24 cannot be immediate"
.endif
.scope
bnei_24:
    BNEI_BYTES lhs, rhs, label, 3
.endscope
.endmacro


;=================================================
; BEQ_BYTES
;   n-byte version of "IF lhs == rhs GOTO label"
;-------------------------------------------------
; INPUTS:   lhs     Left-hand-side parameter
;           rhs     Right-hand-side parameter
;           label   Destination label if condition is true
;
;-------------------------------------------------
; MODIFIES: A
; 
.macro BEQ_BYTES lhs, rhs, label, bytes
.ifblank lhs
    .error "BEQ_BYTES missing parameter: lhs"
.endif
.ifblank rhs
    .error "BEQ_BYTES missing parameter: rhs"
.endif
.ifblank label
    .error "BEQ_BYTES missing parameter: label"
.endif
.ifblank bytes
    .error "BEQ_BYTES missing parameter: bytes"
.endif
.if IMM(label)
    .error "label of BEQ_BYTES cannot be immediate"
.endif
.local no_branch
.repeat bytes, i
    lda lhs+i
    cmp rhs+i
    .if i < (bytes - 1)
        bne no_branch
    .else
        beq label
    .endrep
.endrep
no_branch:
.endmacro


;=================================================
; BEQ_8
;   8-bit version of "IF lhs == rhs GOTO label"
;
;-------------------------------------------------
; INPUTS:   lhs     The "left-hand-side" of the comparison
;           rhs     The "right-hand-side" of the comparison
;           label   The branch destination
;
;-------------------------------------------------
; MODIFIES: A
; 
.macro BEQ_8 lhs, rhs, label
.ifblank lhs
    .error "BEQ_8 missing parameter: lhs"
.endif
.ifblank rhs
    .error "BEQ_8 missing parameter: rhs"
.endif
.ifblank label
    .error "BEQ_8 missing parameter: label"
.endif
.if IMM(label)
    .error "label of BEQ_8 cannot be immediate"
.endif
.scope
beq_8:
    BEQ_BYTES lhs, rhs, label, 1
.endscope
.endmacro

;=================================================
; BEQ_16
;   16-bit version of "IF lhs == rhs GOTO label"
;
;-------------------------------------------------
; INPUTS:   lhs     The "left-hand-side" of the comparison
;           rhs     The "right-hand-side" of the comparison
;           label   The branch destination
;
;-------------------------------------------------
; MODIFIES: A
; 
.macro BEQ_16 lhs, rhs, label
.ifblank lhs
    .error "BEQ_16 missing parameter: lhs"
.endif
.ifblank rhs
    .error "BEQ_16 missing parameter: rhs"
.endif
.ifblank label
    .error "BEQ_16 missing parameter: label"
.endif
.if IMM(label)
    .error "label of BEQ_16 cannot be immediate"
.endif
.scope
beq_16:
    BEQ_BYTES lhs, rhs, label, 2
.endscope
.endmacro

;=================================================
; BEQ_24
;   24-bit version of "IF lhs == rhs GOTO label"
;
;-------------------------------------------------
; INPUTS:   lhs     The "left-hand-side" of the comparison
;           rhs     The "right-hand-side" of the comparison
;           label   The branch destination
;
;-------------------------------------------------
; MODIFIES: A
; 
.macro BEQ_24 lhs, rhs, label
.ifblank lhs
    .error "BEQ_24 missing parameter: lhs"
.endif
.ifblank rhs
    .error "BEQ_24 missing parameter: rhs"
.endif
.ifblank label
    .error "BEQ_24 missing parameter: label"
.endif
.if IMM(label)
    .error "label of BEQ_24 cannot be immediate"
.endif
.scope
beq_24:
    BEQ_BYTES lhs, rhs, label, 3
.endscope
.endmacro


;=================================================
; BEQI_BYTES
;   n-byte version of "IF lhs == rhs GOTO label"
;-------------------------------------------------
; INPUTS:   lhs     Left-hand-side parameter
;           rhs     Right-hand-side parameter
;           label   Destination label if condition is true
;
;-------------------------------------------------
; MODIFIES: A
; 
.macro BEQI_BYTES lhs, rhs, label, bytes
.ifblank lhs
    .error "BEQI_BYTES missing parameter: lhs"
.endif
.ifblank rhs
    .error "BEQI_BYTES missing parameter: rhs"
.endif
.ifblank label
    .error "BEQI_BYTES missing parameter: label"
.endif
.ifblank bytes
    .error "BEQI_BYTES missing parameter: bytes"
.endif
.if IMM(label)
    .error "label of BEQI_BYTES cannot be immediate"
.endif
.local no_branch
    .repeat bytes, i
        lda lhs+i
        cmp #(((rhs) >> (8 * i)) & $FF)
        .if i < (bytes - 1)
            bne no_branch
        .else
            beq label
        .endif
    .endrep
no_branch:
.endmacro


;=================================================
; BEQI_8
;   8-bit version of "IF lhs == rhs GOTO label"
;
;-------------------------------------------------
; INPUTS:   lhs     The "left-hand-side" of the comparison
;           rhs     The "right-hand-side" of the comparison
;           label   The branch destination
;
;-------------------------------------------------
; MODIFIES: A
; 
.macro BEQI_8 lhs, rhs, label
.ifblank lhs
    .error "BEQI_8 missing parameter: lhs"
.endif
.ifblank rhs
    .error "BEQI_8 missing parameter: rhs"
.endif
.ifblank label
    .error "BEQI_8 missing parameter: label"
.endif
.if IMM(label)
    .error "label of BEQI_8 cannot be immediate"
.endif
.scope
beqi_8:
    BEQI_BYTES lhs, rhs, label, 1
.endscope
.endmacro

;=================================================
; BEQI_16
;   16-bit version of "IF lhs == rhs GOTO label"
;
;-------------------------------------------------
; INPUTS:   lhs     The "left-hand-side" of the comparison
;           rhs     The "right-hand-side" of the comparison
;           label   The branch destination
;
;-------------------------------------------------
; MODIFIES: A
; 
.macro BEQI_16 lhs, rhs, label
.ifblank lhs
    .error "BEQI_16 missing parameter: lhs"
.endif
.ifblank rhs
    .error "BEQI_16 missing parameter: rhs"
.endif
.ifblank label
    .error "BEQI_16 missing parameter: label"
.endif
.if IMM(label)
    .error "label of BEQI_16 cannot be immediate"
.endif
.scope
beqi_16:
    BEQI_BYTES lhs, rhs, label, 2
.endscope
.endmacro

;=================================================
; BEQI_24
;   24-bit version of "IF lhs == rhs GOTO label"
;
;-------------------------------------------------
; INPUTS:   lhs     The "left-hand-side" of the comparison
;           rhs     The "right-hand-side" of the comparison
;           label   The branch destination
;
;-------------------------------------------------
; MODIFIES: A
; 
.macro BEQI_24 lhs, rhs, label
.ifblank lhs
    .error "BEQI_24 missing parameter: lhs"
.endif
.ifblank rhs
    .error "BEQI_24 missing parameter: rhs"
.endif
.ifblank label
    .error "BEQI_24 missing parameter: label"
.endif
.if IMM(label)
    .error "label of BEQI_24 cannot be immediate"
.endif
.scope
beqi_24:
    BEQI_BYTES lhs, rhs, label, 3
.endscope
.endmacro


;=================================================
; BGE_BYTES
;   n-byte version of "IF lhs >= rhs GOTO label"
;-------------------------------------------------
; INPUTS:   lhs     Left-hand-side parameter
;           rhs     Right-hand-side parameter
;           label   Destination label if condition is true
;
;-------------------------------------------------
; MODIFIES: A
; 
.macro BGE_BYTES lhs, rhs, label, bytes
.ifblank lhs
    .error "BGE_BYTES missing parameter: lhs"
.endif
.ifblank rhs
    .error "BGE_BYTES missing parameter: rhs"
.endif
.ifblank label
    .error "BGE_BYTES missing parameter: label"
.endif
.ifblank bytes
    .error "BGE_BYTES missing parameter: bytes"
.endif
.if IMM(label)
    .error "label of BGE_BYTES cannot be immediate"
.endif
    .repeat bytes, i
        lda lhs+i
        .if i = 0
            cmp rhs+i
        .else
            sbc rhs+i
        .endif
        bcs label
    .endrep
.endmacro


;=================================================
; BGE_8
;   8-bit version of "IF lhs >= rhs GOTO label"
;
;-------------------------------------------------
; INPUTS:   lhs     The "left-hand-side" of the comparison
;           rhs     The "right-hand-side" of the comparison
;           label   The branch destination
;
;-------------------------------------------------
; MODIFIES: A
; 
.macro BGE_8 lhs, rhs, label
.ifblank lhs
    .error "BGE_BYTES missing parameter: lhs"
.endif
.ifblank rhs
    .error "BGE_BYTES missing parameter: rhs"
.endif
.ifblank label
    .error "BGE_BYTES missing parameter: label"
.endif
.if IMM(label)
    .error "label of BGE_BYTES cannot be immediate"
.endif
.scope
bge_8:
    BGE_BYTES lhs, rhs, label, 1
.endscope
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
.ifblank lhs
    .error "BGE_BYTES missing parameter: lhs"
.endif
.ifblank rhs
    .error "BGE_BYTES missing parameter: rhs"
.endif
.ifblank label
    .error "BGE_BYTES missing parameter: label"
.endif
.if IMM(label)
    .error "label of BGE_BYTES cannot be immediate"
.endif
.scope
bge_16:
    BGE_BYTES lhs, rhs, label, 2
.endscope
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
.ifblank lhs
    .error "BGE_BYTES missing parameter: lhs"
.endif
.ifblank rhs
    .error "BGE_BYTES missing parameter: rhs"
.endif
.ifblank label
    .error "BGE_BYTES missing parameter: label"
.endif
.if IMM(label)
    .error "label of BGE_BYTES cannot be immediate"
.endif
.scope
bge_24:
    BGE_BYTES lhs, rhs, label, 3
.endscope
.endmacro


;=================================================
; BGEI_BYTES
;   n-byte version of "IF lhs >= rhs GOTO label"
;-------------------------------------------------
; INPUTS:   lhs     Left-hand-side parameter
;           rhs     Right-hand-side parameter
;           label   Destination label if condition is true
;
;-------------------------------------------------
; MODIFIES: A
; 
.macro BGEI_BYTES lhs, rhs, label, bytes
.ifblank lhs
    .error "BGEI_BYTES missing parameter: lhs"
.endif
.ifblank rhs
    .error "BGEI_BYTES missing parameter: rhs"
.endif
.ifblank label
    .error "BGEI_BYTES missing parameter: label"
.endif
.ifblank bytes
    .error "BGEI_BYTES missing parameter: bytes"
.endif
.if IMM(label)
    .error "label of BGEI_BYTES cannot be immediate"
.endif
    .repeat bytes, i
        lda lhs+i
        .if i = 0
            cmp #(((rhs) >> (8 * i)) & $FF)
        .else
            sbc #(((rhs) >> (8 * i)) & $FF)
        .endif
        bcs label
    .endrep
.endmacro


;=================================================
; BGEI_8
;   8-bit version of "IF lhs >= rhs GOTO label"
;
;-------------------------------------------------
; INPUTS:   lhs     The "left-hand-side" of the comparison
;           rhs     The "right-hand-side" of the comparison
;           label   The branch destination
;
;-------------------------------------------------
; MODIFIES: A
; 
.macro BGEI_8 lhs, rhs, label
.ifblank lhs
    .error "BGEI_BYTES missing parameter: lhs"
.endif
.ifblank rhs
    .error "BGEI_BYTES missing parameter: rhs"
.endif
.ifblank label
    .error "BGEI_BYTES missing parameter: label"
.endif
.if IMM(label)
    .error "label of BGEI_BYTES cannot be immediate"
.endif
.scope
bgei_8:
    BGEI_BYTES lhs, rhs, label, 1
.endscope
.endmacro

;=================================================
; BGEI_16
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
.macro BGEI_16 lhs, rhs, label
.ifblank lhs
    .error "BGEI_BYTES missing parameter: lhs"
.endif
.ifblank rhs
    .error "BGEI_BYTES missing parameter: rhs"
.endif
.ifblank label
    .error "BGEI_BYTES missing parameter: label"
.endif
.if IMM(label)
    .error "label of BGEI_BYTES cannot be immediate"
.endif
.scope
bgei_16:
    BGEI_BYTES lhs, rhs, label, 2
.endscope
.endmacro

;=================================================
; BGEI_24
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
.macro BGEI_24 lhs, rhs, label
.ifblank lhs
    .error "BGEI_BYTES missing parameter: lhs"
.endif
.ifblank rhs
    .error "BGEI_BYTES missing parameter: rhs"
.endif
.ifblank label
    .error "BGEI_BYTES missing parameter: label"
.endif
.if IMM(label)
    .error "label of BGEI_BYTES cannot be immediate"
.endif
.scope
bgei_24:
    BGEI_BYTES lhs, rhs, label, 3
.endscope
.endmacro


;=================================================
; BLT_BYTES
;   n-byte version of "IF lhs < rhs GOTO label"
;-------------------------------------------------
; INPUTS:   lhs     Left-hand-side parameter
;           rhs     Right-hand-side parameter
;           label   Destination label if condition is true
;
;-------------------------------------------------
; MODIFIES: A
; 
.macro BLT_BYTES lhs, rhs, label, bytes
.ifblank lhs
    .error "BGE_BYTES missing parameter: lhs"
.endif
.ifblank rhs
    .error "BGE_BYTES missing parameter: rhs"
.endif
.ifblank label
    .error "BGE_BYTES missing parameter: label"
.endif
.ifblank bytes
    .error "BGE_BYTES missing parameter: bytes"
.endif
.if IMM(label)
    .error "label of BGE_BYTES cannot be immediate"
.endif
    .repeat bytes, i
        lda lhs+i
        .if i = 0
            cmp rhs+i
        .else
            sbc rhs+i
        .endif
        bcc label
    .endrep
.endmacro


;=================================================
; BLT_8
;   8-bit version of "IF lhs < rhs GOTO label"
;
;-------------------------------------------------
; INPUTS:   lhs     The "left-hand-side" of the comparison
;           rhs     The "right-hand-side" of the comparison
;           label   The branch destination
;
;-------------------------------------------------
; MODIFIES: A
; 
.macro BLT_8 lhs, rhs, label
.ifblank lhs
    .error "BGE_BYTES missing parameter: lhs"
.endif
.ifblank rhs
    .error "BGE_BYTES missing parameter: rhs"
.endif
.ifblank label
    .error "BGE_BYTES missing parameter: label"
.endif
.if IMM(label)
    .error "label of BGE_BYTES cannot be immediate"
.endif
.scope
blt_8:
    BLT_BYTES lhs, rhs, label, 1
.endscope
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
.ifblank lhs
    .error "BGE_BYTES missing parameter: lhs"
.endif
.ifblank rhs
    .error "BGE_BYTES missing parameter: rhs"
.endif
.ifblank label
    .error "BGE_BYTES missing parameter: label"
.endif
.if IMM(label)
    .error "label of BGE_BYTES cannot be immediate"
.endif
.scope
blt_16:
    BLT_BYTES lhs, rhs, label, 2
.endscope
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
.ifblank lhs
    .error "BGE_BYTES missing parameter: lhs"
.endif
.ifblank rhs
    .error "BGE_BYTES missing parameter: rhs"
.endif
.ifblank label
    .error "BGE_BYTES missing parameter: label"
.endif
.if IMM(label)
    .error "label of BGE_BYTES cannot be immediate"
.endif
.scope
blt_24:
    BLT_BYTES lhs, rhs, label, 3
.endscope
.endmacro


;=================================================
; BLTI_BYTES
;   n-byte version of "IF lhs < rhs GOTO label"
;-------------------------------------------------
; INPUTS:   lhs     Left-hand-side parameter
;           rhs     Right-hand-side parameter
;           label   Destination label if condition is true
;
;-------------------------------------------------
; MODIFIES: A
; 
.macro BLTI_BYTES lhs, rhs, label, bytes
.ifblank lhs
    .error "BGE_BYTES missing parameter: lhs"
.endif
.ifblank rhs
    .error "BGE_BYTES missing parameter: rhs"
.endif
.ifblank label
    .error "BGE_BYTES missing parameter: label"
.endif
.ifblank bytes
    .error "BGE_BYTES missing parameter: bytes"
.endif
.if IMM(label)
    .error "label of BGE_BYTES cannot be immediate"
.endif
    .repeat bytes, i
        lda lhs+i
        .if i = 0
            cmp #((DECAY(rhs) >> (8 * i)) & $FF)
        .else
            sbc #((DECAY(rhs) >> (8 * i)) & $FF)
        .endif
        bcc label
    .endrep
.endmacro


;=================================================
; BLTI_8
;   8-bit version of "IF lhs < rhs GOTO label"
;
;-------------------------------------------------
; INPUTS:   lhs     The "left-hand-side" of the comparison
;           rhs     The "right-hand-side" of the comparison
;           label   The branch destination
;
;-------------------------------------------------
; MODIFIES: A
; 
.macro BLTI_8 lhs, rhs, label
.ifblank lhs
    .error "BGE_BYTES missing parameter: lhs"
.endif
.ifblank rhs
    .error "BGE_BYTES missing parameter: rhs"
.endif
.ifblank label
    .error "BGE_BYTES missing parameter: label"
.endif
.if IMM(label)
    .error "label of BGE_BYTES cannot be immediate"
.endif
.scope
blti_8:
    BLTI_BYTES lhs, rhs, label, 1
.endscope
.endmacro

;=================================================
; BLTI_16
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
.macro BLTI_16 lhs, rhs, label
.ifblank lhs
    .error "BGE_BYTES missing parameter: lhs"
.endif
.ifblank rhs
    .error "BGE_BYTES missing parameter: rhs"
.endif
.ifblank label
    .error "BGE_BYTES missing parameter: label"
.endif
.if IMM(label)
    .error "label of BGE_BYTES cannot be immediate"
.endif
.scope
blti_16:
    BLTI_BYTES lhs, rhs, label, 2
.endscope
.endmacro

;=================================================
; BLTI_24
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
.macro BLTI_24 lhs, rhs, label
.ifblank lhs
    .error "BGE_BYTES missing parameter: lhs"
.endif
.ifblank rhs
    .error "BGE_BYTES missing parameter: rhs"
.endif
.ifblank label
    .error "BGE_BYTES missing parameter: label"
.endif
.if IMM(label)
    .error "label of BGE_BYTES cannot be immediate"
.endif
.scope
blti_24:
    BLTI_BYTES lhs, rhs, label, 3
.endscope
.endmacro


;=================================================
;=================================================
;
; Multiplication macros
;
;=================================================


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


;=================================================
;=================================================
;
; Interleaved array macros
;
;=================================================
; These functions are similar to the above, except
; that they expect the data types to be in arrays
; where the lowest byte of the array's data types
; are all in one block of memory, the next byte of
; the array's data types are all in another block
; of memory, and so on for as many bytes are in
; the datatype. 
;
; I'm told this data layout is common in 6502 
; programming, which makes sense because the 8-bit
; word size and 8-bit index registers, and generally
; limited instruction set, makes it difficult to
; work with 16-, 24-, 32-bit types if each element
; is kept contiguous instead of being parallelized 
; by byte.
; 


;=================================================
; ILA_ADD_16
;   16-bit version of "dst = lhs + rhs"
;
;   Multi-byte array version, which assumes the bytes
;   of dst, lhs, and rhs are stored in separate arrays
;   each containing one byte of the variable.
;   dstr, lstr, rstr are the "stride" of these arrays,
;   the distance between one byte and the next.
;
;-------------------------------------------------
; INPUTS:   dst                 Destination memory address
;           dstr                Destrination stride
;           lhs                 Left-hand-side parameter
;           lstr                Lhs stride
;           rhs                 Right-hand-side parameter
;           rstr                Rhs stride
;           (OPTIONAL) count    Number of elements in array (1 if unspecified)
;
;-------------------------------------------------
; MODIFIES: A, X
; 
.macro ILA_ADD_16 dst, dstr, lhs, lstr, rhs, rstr, count
.ifblank count
    clc
    .repeat 2, i
    lda lhs+(i*dstr)
    adc rhs+(i*lstr)
    sta dst+(i*rstr)
    .endrep
.else
    .local loop
    ldx #count
loop:
    .repeat 2, i
    lda lhs+(i*dstr), x
    adc rhs+(i*lstr), x
    sta dst+(i*rstr), x
    .endrep
    dex
    bne loop
.endif
.endmacro

;=================================================
; MBA_ADD_24
;   24-bit version of "dst = lhs + rhs"
;
;   Multi-byte array version, which assumes the bytes
;   of dst, lhs, and rhs are stored in separate arrays
;   each containing one byte of the variable.
;   dstr, lstr, rstr are the "stride" of these arrays,
;   the distance between one byte and the next.
;
;-------------------------------------------------
; INPUTS:   dst                 Destination memory address
;           dstr                Destrination stride
;           lhs                 Left-hand-side parameter
;           lstr                Lhs stride
;           rhs                 Right-hand-side parameter
;           rstr                Rhs stride
;           (OPTIONAL) count    Number of elements in array (1 if unspecified)
;
;-------------------------------------------------
; MODIFIES: A, X
; 
.macro MBA_ADD_24 dst, dstr, lhs, lstr, rhs, rstr, count
.ifblank count
    clc
    .repeat 3, i
    lda lhs+(i*dstr)
    adc rhs+(i*lstr)
    sta dst+(i*rstr)
    .endrep
.else
    .local @loop
    ldx #count
@loop:
    .repeat 3, i
    lda lhs+(i*dstr), x
    adc rhs+(i*lstr), x
    sta dst+(i*rstr), x
    .endrep
    dex
    bne loop
.endif
.endmacro

.endif ; .ifndef MATH_INC