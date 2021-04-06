.include "math.inc"
.include "kernal.inc"

SQUARES_OVER_FOUR_TABLE = $A000
SQUARES_OVER_FOUR_TABLE_LO = $A000
SQUARES_OVER_FOUR_TABLE_HI = $A200

SIN360_TABLE = $A400
SIN360_TABLE_LO = $A400
SIN360_TABLE_HI = $A500

SIN45_TABLE = $A400
SIN45_TABLE_LO = $A400
SIN45_TABLE_HI = $A500

COS45_TABLE = $A600
COS45_TABLE_LO = $A600
COS45_TABLE_HI = $A700

; SOF = Square Over Four
SOF_SUM_LOW = SQUARES_OVER_FOUR_TABLE_LO
SOF_SUM_HIGH = SQUARES_OVER_FOUR_TABLE_HI
SOF_DIFF_LOW = SQUARES_OVER_FOUR_TABLE_LO - $0100
SOF_DIFF_HIGH = SQUARES_OVER_FOUR_TABLE_HI - $0100

.define MATH_TABLES_NAME "math.seq"

.data
MATH_TABLES_STR: .asciiz MATH_TABLES_NAME

.code
.proc math_init
    SYS_SET_BANK MATH_TABLES_BANK

    ; Load tables into himem
    SYS_FILE_LOAD MATH_TABLES_STR, .strlen(MATH_TABLES_NAME), $A000
    ; KERNAL_SETLFS 1, 8, 0
    ; KERNAL_SETNAM .strlen(MATH_TABLES_NAME), MATH_TABLES_STR
    ; KERNAL_LOAD 0, $A000

    rts
.endproc

;=================================================
; mul_8
;   Multiply A and X, storing the results in A and X.
;   Based on xy = (x^2 + y^2 - (x-y)^2)/2
;
;-------------------------------------------------
; INPUTS:   A   Lhs
;           Y   Rhs
;
;-------------------------------------------------
; OUTPUTS:  X   Low-byte
;           A   High-byte
;
;-------------------------------------------------
; MODIFIES: A, X, Y, 
;           PTR_SOF_SUM_LOW, 
;           PTR_SOF_SUM_HIGH,
;           PTR_SOF_DIFF_LOW, 
;           PTR_SOF_DIFF_HIGH,
;-------------------------------------------------
;   This uses a table-lookup technique based on the
;   equation:
;
;       x * y = ((x + y)^2 - (x - y)^2)/4
;
;   Starting at $A000, there is a table of 512
;   "squares divided by 4", (0^2)/4 through 
;   (255^2)/4, separated into the low bytes from
;   $A000-$A1FF and the high bytes from $A200-A3FF.
;   By choosing an appropriate index into this
;   table, we greatly reduce the number of cycles
;   required for computation.
;
;   This method is extremely similar to one documented by
;   Neil Parker at http://nparker.llx.com/a2/mult.html.
;   They claim to require at worst 38 cycles, but I
;   count 38 best-case, 42 worst-case. That would make
;   this 16 cycles slower in the best-case, and 20
;   cycles slower in the worst-case. However, this
;   method only requires 1KB in tables instead of 2KB.
;
;   The cost difference comes from three places. 
;   
;   First, Parker's technique indexes into the 
;   "difference" array at an offset, whereas this
;   performs sbc to avoid offsetting the array (in fact, 
;   this avoids needing the "difference" array at all,
;   halving the memory requirements). This also means 
;   ensuring the carry bit is set for the subtract.
;   This is 5-7 cycles' difference, depending on whether
;   Parker's technique would have crossed a page boundary
;   when indexing arrays.
;
;   Second, Parker's technique does not require the 
;   values of the A and Y registers to be sorted. This 
;   is 9-15 cycles' difference, depending on whether
;   the A and Y are properly sorted at call-time.
;
;   Third, my technique assumes that we are never
;   multiplying by zero, sadly, so there is a special-
;   case branch to cope with that. 2-4 cycles there.
;
;   Pedantry:
;   You'll notice the counts above aren't directly
;   reflected in the counts per each section of code
;   below. I've tried to be accurate, but the final
;   implementation is playing with a few other minor
;   optimizations to amortize various costs. I recycle
;   PTR_SOF_SUM_LOW as a temp variable for sorting
;   and/or swapping, which means we only pay the extra
;   cost of the write to TMP if we then discover it was
;   incorrect. I let a multiply-by-zero continue until
;   the subtract, then use the result of subtract as my
;   comparison against zero, so testing for the special
;   case of zero is only 2-4 cycles.
;
;   A best-case cost should be 51 cycles, a worst-case 
;   should be 62 cycles. Multiply-by-zero should cost
;   19-20 cycles, depending on branches crossing page
;   boundaries.
;
;   2020-06-26: 
;   Adding a new optimization - self-modifying code.
;   This comes from the "seriously fast multiplication"
;   described at:
;   https://codebase64.org/doku.php?id=base%3Aseriously_fast_multiplication
;
;   Instead of keeping external pointers that need to be
;   dereferenced, let's put them in code. What do you mean,
;   "we need to modify them"? Of course we do, and we will.
;   And the CPU will never know the difference. It's not
;   like we're running with protected memory, after all!
;   <maniacal laughing ensues>
;
;   The technique doesn't actually save us any runtime, 
;   unfortunately. In fact, it's going to be 2 or 4 clocks 
;   slower. Phooey. But we free up ZP variables that had
;   been permanently in use, so there's that.
;
.code
.proc mul_8
    TMP = s0+1
    sta TMP                         ; 4
    cpy TMP                         ; 4
    bcs sorted                     ; 2/3/4
    tya                             ; 2
    ldy TMP                         ; 4
    ; We now know Y >= A.
    sec                             ; 2
    sta s0+1                        ; 4     = 11/12 or 22
sorted:                            
    sta s1+1                        ; 4
    lda #0                          ; 2
    sbc s0+1                        ; 4
    bcs multiplying_zero           ; 2/3/4
    sta d0+1                        ; 4
    sta d1+1                        ; 4
    sec                             ; 2
s0: lda SOF_SUM_LOW,y               ; 4/5
d0: sbc SOF_DIFF_LOW,y              ; 5     (will always cross a page boundary)
    tax                             ; 2
s1: lda SOF_SUM_HIGH,y              ; 4/5
d1: sbc SOF_DIFF_HIGH,y             ; 5     (will always cross a page boundary)
    rts                             ;       = 13-14 or 42-44
multiplying_zero:
    tax                             ; 2
    rts
.endproc

;=================================================
; sin_8
;   Get the sin of the value in the A register, where
;   A is a 0.8 fixed point ratio of 2*Pi (or "Tau" if
;   you're of that religious persuation).
;
;   The result is a signed 8.8 fixed point value in the
;   range [-1, 1], with the low-byte in A and the high-
;   byte in X.
;   
;   Uses a table-based lookup of 256 samples of sin
;   where theta = [0, Pi/4). However, note that the
;   8-bit limit can only access 32 samples.
;
;-------------------------------------------------
; INPUTS:   A   Ratio of Tau
;
;-------------------------------------------------
; OUTPUTS:  A, X
;
;-------------------------------------------------
; MODIFIES: A, X, Y
;
;-------------------------------------------------
.code
.proc sin_8
    tay
    ldx SIN360_TABLE_LO, y
    lda SIN360_TABLE_HI, y
    rts
.endproc

;=================================================
; cos_8
;   Get the cos of the value in the A register, where
;   A is a 0.8 fixed point ratio of 2*Pi (or "Tau" if
;   you're of that religious persuation).
;
;   The result is a signed 8.8 fixed point value in the
;   range [-1, 1], with the low-byte in A and the high-
;   byte in X.
;   
;   Uses a table-based lookup of 256 samples of cos
;   where theta = [0, Pi/4). However, note that the
;   8-bit limit can only access 32 samples.
;
;-------------------------------------------------
; INPUTS:   A   Ratio of Tau
;
;-------------------------------------------------
; OUTPUTS:  A, X
;
;-------------------------------------------------
; MODIFIES: A, X, Y
;
;-------------------------------------------------
.proc cos_8
    clc
    adc #64
    tay
    ldx SIN360_TABLE_LO, y
    lda SIN360_TABLE_HI, y
    rts
.endproc