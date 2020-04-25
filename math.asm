.include "math.inc"
.include "kernal.inc"

MATH_TABLES_BANK = $00
SQUARES_OVER_FOUR_TABLE = $A000
LO_SQUARES_OVER_FOUR_TABLE_LO = $A000
HI_SQUARES_OVER_FOUR_TABLE_LO = $A100
LO_SQUARES_OVER_FOUR_TABLE_HI = $A200
HI_SQUARES_OVER_FOUR_TABLE_HI = $A300

; SOF = Square Over Four
PTR_SOF_SUM_LOW = $7C
PTR_SOF_SUM_HIGH = $7E
PTR_SOF_DIFF_LOW = $78
PTR_SOF_DIFF_HIGH = $7A

.define MATH_TABLES_NAME "MATH_TABLES.SEQ"

.data
MATH_TABLES_STR: .asciiz MATH_TABLES_NAME

.code
.proc math_init
    SYS_SET_BANK MATH_TABLES_BANK

    ; Load tables into himem
    KERNAL_SETLFS 1, 1, 0
    KERNAL_SETNAM .strlen(MATH_TABLES_NAME), MATH_TABLES_STR
    KERNAL_LOAD 0, $A000

    ; Setup ZP pointers
    lda #>LO_SQUARES_OVER_FOUR_TABLE_LO
    sta PTR_SOF_SUM_LOW+1
    lda #(>LO_SQUARES_OVER_FOUR_TABLE_LO)-1
    sta PTR_SOF_DIFF_LOW+1

    lda #>LO_SQUARES_OVER_FOUR_TABLE_HI
    sta PTR_SOF_SUM_HIGH+1
    lda #(>LO_SQUARES_OVER_FOUR_TABLE_HI)-1
    sta PTR_SOF_DIFF_HIGH+1
    rts
.endproc

; init_squares_over_four_table:
;     SYS_SET_BANK MATH_TABLES_BANK

;     lda #<LO_SQUARES_OVER_FOUR_TABLE_LO
;     sta PTR_SOF_SUM_LOW
;     lda #>LO_SQUARES_OVER_FOUR_TABLE_LO
;     sta PTR_SOF_SUM_LOW+1

;     lda #<LO_SQUARES_OVER_FOUR_TABLE_HI
;     sta PTR_SOF_SUM_HIGH
;     lda #>LO_SQUARES_OVER_FOUR_TABLE_HI
;     sta PTR_SOF_SUM_HIGH+1

;     ldy #0
;     ldx #0
;     lda #0

;     sta $00
;     sta $01
;     sta $02
;     sta $03

; @next:
;     clc
;     lda $02
;     adc $00
;     sta $02
;     sta (PTR_SOF_SUM_LOW),y
;     lda $03
;     adc $01
;     sta $03
;     sta (PTR_SOF_SUM_HIGH),y
;     iny
;     clc
;     lda $02
;     adc $00
;     sta $02
;     sta (PTR_SOF_SUM_LOW),y
;     lda $03
;     adc $01
;     sta $03
;     sta (PTR_SOF_SUM_HIGH),y
;     iny
;     clc
;     lda #1
;     adc $00
;     sta $00
;     lda #0
;     adc $01
;     sta $01
;     cpy #0
;     bne @next

;     inc PTR_SOF_SUM_LOW+1
;     inc PTR_SOF_SUM_HIGH+1

; @next2:
;     clc
;     lda $02
;     adc $00
;     sta $02
;     sta (PTR_SOF_SUM_LOW),y
;     lda $03
;     adc $01
;     sta $03
;     sta (PTR_SOF_SUM_HIGH),y
;     iny
;     clc
;     lda $02
;     adc $00
;     sta $02
;     sta (PTR_SOF_SUM_LOW),y
;     lda $03
;     adc $01
;     sta $03
;     sta (PTR_SOF_SUM_HIGH),y
;     iny
;     clc
;     lda #1
;     adc $00
;     sta $00
;     lda #0
;     adc $01
;     sta $01
;     cpy #0
;     bne @next2

;     rts

;=================================================
; mul_x
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
;   
;

.code

.proc mul_8
    TMP = PTR_SOF_SUM_LOW
    sta TMP                         ; 3
    cpy TMP                         ; 3
    bcs @sorted                     ; 2/3/4
    tya                             ; 2
    ldy TMP                         ; 3
    ; We now know Y >= A.
    sec                             ; 2
    sta PTR_SOF_SUM_LOW             ; 3     = 9/10 or 18
@sorted:                            
    sta PTR_SOF_SUM_HIGH            ; 3
    lda #0                          ; 2
    sbc PTR_SOF_SUM_LOW             ; 3
    bcs @multiplying_zero           ; 2/3/4
    sta PTR_SOF_DIFF_LOW            ; 3
    sta PTR_SOF_DIFF_HIGH           ; 3
    sec                             ; 2
    lda (PTR_SOF_SUM_LOW),y         ; 5/6
    sbc (PTR_SOF_DIFF_LOW),y        ; 6     (will always cross a page boundary)
    tax                             ; 2
    lda (PTR_SOF_SUM_HIGH),y        ; 5/6
    sbc (PTR_SOF_DIFF_HIGH),y       ; 6     (will always cross a page boundary)
    rts                             ;       = 11-12 or 42-44
@multiplying_zero:
    tax                             ; 2
    rts
.endproc