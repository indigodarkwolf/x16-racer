.ifndef BITMAP_ASM
BITMAP_ASM=1

.include "debug.inc"
.include "vera.inc"
.include "system.inc"
.include "graphics.inc"
.include "math.inc"

.code
.proc bitmap_do
    DEBUG_LABEL bitmap_do
    VERA_SET_SCALE 64
    VERA_CONFIGURE_BMP_LAYER 0, 3, 0, 0, 0
    VERA_DISABLE_LAYER 1
    VERA_ENABLE_LAYER 0

    jsr clear_bitmap

    jsr generate_sin_curve
    jsr scale_data
    jsr offset_data
    jsr draw_curve

    jsr generate_cos_curve
    jsr scale_data
    jsr offset_data
    jsr draw_curve

    lda #16
    jsr sys_wait_for_frame

    VERA_SET_SCALE 128

    rts
.endproc

.proc generate_sin_curve
    DEBUG_LABEL generate_sin_curve
    lda #0
    ldx #0
    ldy #0
loop:
    pha

    jsr sin_8
    ; lda #0
    ; ldx #0

    tay
    txa

    plx

    sta Sin_test_lo, x

    tya
    sta Sin_test_hi, x

    inx
    txa
    bne loop

    rts
.endproc

.proc generate_cos_curve
    lda #0
    ldx #0
    ldy #0
loop:
    pha

    jsr cos_8
    ; lda #0
    ; ldx #0

    tay
    txa

    plx

    sta Sin_test_lo, x

    tya
    sta Sin_test_hi, x

    inx
    txa
    bne loop

    rts
.endproc

.proc scale_data
DEBUG_LABEL scale_data
    ldx #0
loop:
    lda Sin_test_hi, x
    ror
    ror Sin_test_lo, x
    ror
    ror Sin_test_lo, x
    lda Sin_test_hi, x
    rol ; Preserve sign bit into carry
    ror Sin_test_hi, x
    lda Sin_test_hi, x
    rol ; Preserve sign bit into carry
    ror Sin_test_hi, x

    inx
    bne loop

    rts
.endproc

.proc offset_data
DEBUG_LABEL offset_data
    ldx #0
loop:
    lda #160
    adc Sin_test_lo, x
    sta Sin_test_lo, x
    lda #0
    adc Sin_test_hi, x
    sta Sin_test_hi, x

    inx
    bne loop

    rts
.endproc

.proc clear_bitmap
    VERA_SET_CTRL 0
    VERA_SET_ADDR 0, 1
    lda #<320
    sta $02
    lda #>320
    sta $03
    stz $04
    stz $05

loop_320:
    ldy #0
loop_240:
    VERA_WRITE 0
    iny
    cpy #240
    bne loop_240
    clc
    lda $04
    adc #1
    sta $04
    lda $05
    adc #0
    sta $05
    DEBUG_LABEL loop_320_check
    BLT_16 $04, $02, loop_320

    rts
.endproc

.proc draw_curve
    DEBUG_LABEL draw_curve
    ldy #0

    VERA_SET_CTRL 0
    stz VERA_addr_low
    stz VERA_addr_high
    stz VERA_addr_bank

loop:
    clc
    lda Sin_test_lo,y
    adc VERA_addr_low
    sta VERA_addr_low

    lda Sin_test_hi,y
    adc VERA_addr_high
    sta VERA_addr_high

    lda #0
    adc VERA_addr_bank
    sta VERA_addr_bank

    lda #1
    sta VERA_data

    sec
    lda VERA_addr_low
    sbc Sin_test_lo,y
    sta VERA_addr_low

    lda VERA_addr_high
    sbc Sin_test_hi,y
    sta VERA_addr_high

    lda VERA_addr_bank
    sbc #0
    sta VERA_addr_bank

    clc
    lda #<320
    adc VERA_addr_low
    sta VERA_addr_low

    lda #>320
    adc VERA_addr_high
    sta VERA_addr_high

    lda #0
    adc VERA_addr_bank
    sta VERA_addr_bank

    iny
    cpy #240
    bne loop

    rts
.endproc

.data
Sin_test_lo:
.repeat 256
.byte 160
.endrep

Sin_test_hi:
.repeat 256
.byte 0
.endrep
.endif