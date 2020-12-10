.include "map.inc"

.include "math.inc"
.include "vera.inc"

.data
View_x: .word $0000
View_y: .word $0000
TL_bank: .byte $00

TILEMAP_L0 = $00000
TILEMAP_L1 = $04000

MAP_BANK_WIDTH = 4
MAP_BANK_HEIGHT = 4
MAP_BANK_MASK = $0F

.code
.proc map_incr_view_x
    ; Each bank contains a 128x32 square of the map, 
    ;   ordered left-to-right, top-to-bottom.
    ; The tilemap in VRAM is 128x64.
    ; If View_x and View_y are 0, then we've placed
    ;   the box [0, 0]-[127, 63] into VRAM.

    ; We need to copy (View_x + 128) % 256 into VRAM at the
    ; location of (View_x % 128)

    ; TODO: I forgot that it's fast to use VERA's separate Data0 and Data1,
    ; and more to the point, forgot about writing the second byte when
    ; we're doing columns.
    ; We should partially assemble the copy address into a0 and a1,
    ; but before adding #$A0 to the high byte of each, we should copy
    ; it to the VERA_addr_x

    lda View_x
    asl
    sta a0+1    ; Setting low byte of X for our copy address
    inc
    sta a1+1    ; Setting low byte of X for our copy address
    lda View_y
    and #$3F    ; modulo 64 since VRAM is 64 rows tall
    rol
    sta a0+2    ; Setting high byte of X for our copy address
    sta a1+2    ; Setting high byte of X for our copy address

    VERA_SET_ADDR 0
    ADD_16 VERA_addr, a0+1, #TILEMAP_L0
    lda #$90    ; Auto-increment 256 bytes
    adc #0      ; Carry from the high byte
    sta VERA_addr_bank

    VERA_SET_ADDR 1
    ADD_16 VERA_addr, a1+1, #TILEMAP_L0
    lda #$90    ; Auto-increment 256 bytes
    adc #0      ; Carry from the high byte
    sta VERA_addr_bank

    lda a0+2
    ora #$A0    ; Properly would be to `and #$1F` then add #$A0,
                ; but $20 will be set by the add and the rest of 
                ; the high nibble will be 0 anyways. 
                ; "Save the frames, kill the animals."
    sta a0+2
    sta a1+2

    ; View_x 0000000A A0000000
    ; View_y 00000000 0BB00000
    ; Bank = MAP_BANK_START + 0000BBAA
    
    lda View_y
    rol
    rol
    rol
    rol ; a contains 0000?0BB
    tax
    lda View_x+1
    ror
    txa
    rol ; a contains 000?0BBA
    tax
    lda View_x
    rol
    txa
    rol ; a contains 00?0BBAA
    and #$0F
    clc
    adc #MAP_BANK_START
    sta SYS_BANK_RAM

    ; Now copy a vertical strip of data.

    ldx #64 ; x contains the number of cells we have to copy
    lda View_y 
    tay ; y contains the current y coordinate
    and #$1F
    asl
    ora a0+2 ; Adding in the X carried into the high byte for memory address
    clc
    adc #$A0
    sta a0+2 ; Setting the high byte of the start address
    sta a1+2 ; Setting the high byte of the start address
    tya
    and #$3F
    eor #$FF
    adc #65
    tay ; y contains rows until VRAM address needs be rolled to first row of tilemap
        ; (64 - (y % 64))

do_copy:
a0: lda $A000
    sta VERA_data
a1: lda $A001
    sta VERA_data2
    dex
    beq done

    ; Not done copying yet
    dey
    bne inc_addr

    ; Ran past bottom of tilemap, wrap to top
    lda VERA_addr_high
    sbc #64
    sta VERA_addr_high
    ldy #64

inc_addr:
    lda a0+2
    inc
    cmp #$c0
    bne store_addr

    ; Increment bank to next row
    lda SYS_BANK_RAM
    sec
    sbc MAP_BANK_START
    clc
    adc MAP_BANK_WIDTH
    and #MAP_BANK_MASK
    clc
    adc MAP_BANK_START
    sta SYS_BANK_RAM

    lda #$A0
store_addr:
    sta a0+2
    sta a1+2
    bra do_copy

done:
    ADD_16 View_x, View_x, #1
    rts
.endproc

.proc map_incr_view_y
    ; Each bank contains a 128x32 square of the map, 
    ;   ordered left-to-right, top-to-bottom.
    ; The tilemap in VRAM is 128x64.
    ; If View_x and View_y are 0, then we've placed
    ;   the box [0, 0]-[127, 63] into VRAM.

    ; We need to copy (View_x + 128) % 256 into VRAM at the
    ; location of (View_x % 128)

    VERA_SET_CTRL 0
    ; VERA_SET_ADDR ((View_x % 128) * 2)
    lda View_x
    asl
    sta VERA_addr_low
    sta a0+1    ; Stealing low byte of X for our copy address
    inc
    sta a1+1    ; Stealing low byte of X for our copy address
    lda #0
    rol
    sta VERA_addr_high
    sta a0+2    ; Stealing high byte of X for our copy address
    sta a1+2    ; Stealing high byte of X for our copy address
    lda #$90 ; auto-increment 256 bytes
    sta VERA_addr_bank

    ; View_x 0000000A A0000000
    ; View_y 00000000 0BB00000
    ; Bank = MAP_BANK_START + 0000BBAA
    
    lda View_y
    rol
    rol
    rol
    rol ; a contains 0000?0BB
    tax
    lda View_x+1
    ror
    txa
    rol ; a contains 000?0BBA
    tax
    lda View_x
    rol
    txa
    rol ; a contains 00?0BBAA
    and #$0F
    clc
    adc #MAP_BANK_START
    sta SYS_BANK_RAM

    ; Now copy a vertical strip of data.

    ldx #64 ; x contains the number of cells we have to copy
    lda View_y 
    tay ; y contains the current y coordinate
    and #$1F
    asl
    ora a0+2 ; Adding in the X carried into the high byte for memory address
    clc
    adc #$A0
    sta a0+2 ; Setting the high byte of the start address
    sta a1+2 ; Setting the high byte of the start address
    tya
    and #$3F
    eor #$FF
    adc #65
    tay ; y contains rows until VRAM address needs be rolled to first row of tilemap
        ; (64 - (y % 64))

do_copy:
a0: lda $A000
    sta VERA_data
a1: lda $A001
    sta VERA_data
    dex
    beq done

    ; Not done copying yet
    dey
    bne inc_addr

    ; Ran past bottom of tilemap, wrap to top
    lda VERA_addr_high
    sbc #64
    sta VERA_addr_high
    ldy #64

inc_addr:
    lda a0+2
    inc
    cmp #$c0
    bne store_addr

    ; Increment bank to next row
    lda SYS_BANK_RAM
    sec
    sbc MAP_BANK_START
    clc
    adc MAP_BANK_WIDTH
    and #MAP_BANK_MASK
    clc
    adc MAP_BANK_START
    sta SYS_BANK_RAM

    lda #$A0
store_addr:
    sta a0+2
    sta a1+2
    bra do_copy

done:
    ADD_16 View_x, View_x, #1
    rts
.endproc

.proc map_reset_view
    lda MAP_BANK_START
    sta SYS_BANK_RAM

    stz VERA_addr_low
    stz VERA_addr_high
    lda #$20
    sta VERA_addr_bank

    VERA_SET_CTRL 1

    stz VERA_addr_low
    lda #16
    sta VERA_addr_high
    lda #$20
    sta VERA_addr_bank

    VERA_SET_CTRL 0

    lda #$A0
    sta l0+2
    lda #$B0
    sta l1+2

    ldx #2  ; 2 banks
    ldy #0  ; "256" bytes

l0: lda $A000, y
    sta VERA_data
l1: lda $B000, y
    sta VERA_data2

    iny
    bne l0

    inc l0+2
    inc l1+2

    lda #$B0
    cmp l0+2
    bne l0

    dex
    beq return

    lda VERA_addr_high
    clc
    adc #16
    sta VERA_addr_high

    VERA_SET_CTRL 1

    lda VERA_addr_high
    clc
    adc #16
    sta VERA_addr_high

    VERA_SET_CTRL 0
    bra l0

return:
    stz View_x
    stz View_y
    rts
.endproc