.include "map.inc"

.include "vera.inc"

.data
View_x: .byte $00
View_y: .byte $00
TL_bank: .byte $00

.code
.proc map_incr_view_x
    ; Each bank contains a 128x32 subset of the map, in the same pattern as VRAM.
    ; 


    ; Banks 0-7, then, contain the left half of the map, while 8-15 contain the
    ; right half of the map.
    ;
    ; Conveniently, this means View_x %A0000000, View_y %BBB00000 can be merged
    ; to create the bank number of our top-left corner: TL_bank %0000ABBB
    ;
    lda View_x
    rol
    lda View_y
    ror
    lsr
    lsr
    lsr
    lsr
    sta TL_bank

    ; Our starting bank for copying new data, then, is (TL_bank ^ 8)
    ;
    eor #$08

    clc
    adc #MAP_BANK_START
    sta SYS_BANK_RAM

    ; If View_x is %ABBBBBBB and View_y is %CCDDDDDD, the start address within
    ; VRAM is %0000 00DDDDDD BBBBBBB0
    lda View_x
    asl
    sta VERA_addr_low
    lda View_y
    and #$3F
    sta VERA_addr_high
    lda #$90 ; Stride setting of $9 (256 bytes)
    sta VERA_addr_bank

    VERA_SET_CTRL 1

    lda View_x
    asl
    ora #1
    sta VERA_addr_low
    lda View_y
    and #$3F
    sta VERA_addr_high
    lda #$90 ; Stride setting of $9 (256 bytes)
    sta VERA_addr_bank
    
    VERA_SET_CTRL 0

    ; If View_x is %ABBBBBBB and View_y is %CCCDDDDD, the start address within 
    ; the bank is %011DDDDD BBBBBBB0
    lda View_x
    asl
    sta l0+1
    ora #1
    sta l1+1

    lda View_y
    and #$1F
    adc #$A0
    sta l0+2
    sta l1+2

    ldx #64

l0: lda $A000
    sta VERA_data
l1: lda $A000
    sta VERA_data2

    dex
    beq return

    ; The next byte to copy is 256 bytes from the current.
    inc l0+2
    inc l1+2

    ; Check whether we've run past the end of the bank
    lda #$C0
    cmp l0+2
    bne l0

    ; We need to preserve bit $08, but otherwise the next bank is (TL_bank + 1) & $07
    lda TL_bank
    and $08
    sta $FF

    lda TL_bank
    clc
    adc #1
    and #$07
    ora $FF
    adc #MAP_BANK_START
    sta SYS_BANK_RAM

    lda #$A0
    sta l0+2
    sta l1+2

    lda VERA_addr_high
    and #%00111111
    sta VERA_addr_high

    VERA_SET_CTRL 1

    lda VERA_addr_high
    and #%00111111
    sta VERA_addr_high

    VERA_SET_CTRL 0

    bra l0

return:
    inc View_x
    rts
.endproc

.proc map_incr_view_y
    ; Each bank contains a 128x32 subset of the map, in the same data pattern as 
    ; VRAM.
    ; Banks 0-7, then, contain the left half of the map, while 8-15 contain the
    ; right half of the map.
    ;
    ; Conveniently, this means View_x %A0000000, View_y %BBB00000 can be merged
    ; to create the bank number of our top-left corner: TL_bank %0000ABBB
    ; 
    ; However: Unlike map_incr_view_x, we can't just exclusive-or 8.
    ; We need to "add 2" to Y's contribution and then mask off 
    ; bits before adding X, so we're going to do a little more juggling than we 
    ; used to. Thankfully, this isn't hard, we'll just add %01000000 to Y, which
    ; is like adding 2 to TL_bank, and then preserve the intermediate value in
    ; one of the other registers while we setup the carry bit with View_x.
    ;
    lda View_y
    clc
    adc #$40
    tax
    lda View_x
    rol
    txa
    ror
    lsr
    lsr
    lsr
    lsr

    clc
    adc #MAP_BANK_START
    sta SYS_BANK_RAM

    ; If View_x is %ABBBBBBB and View_y is %CCDDDDDD, the start address within
    ; VRAM is %0000 00DDDDDD BBBBBBB0
    lda View_x
    asl
    sta VERA_addr_low
    lda View_y
    and #$3F
    sta VERA_addr_high
    lda #$10 ; Stride setting of $1 (1 bytes)
    sta VERA_addr_bank

    ; If View_x is %ABBBBBBB and View_y is %CCCDDDDD, the start address within 
    ; the bank is %011DDDDD BBBBBBB0
    lda View_x
    asl
    tay
    lda View_y
    and #$1F
    adc #$A0
    sta ld+2

    ldx #0 ; "256"

ld: lda $A000,y
    sta VERA_data
    dex
    beq return
    iny
    bne ld

    ; We hit the end of a row, continue in next bank
    lda SYS_BANK_RAM
    sec
    sbc #MAP_BANK_START
    clc
    adc #8
    and #$0F
    clc
    adc #MAP_BANK_START
    sta SYS_BANK_RAM

    ; But wrap VERA to the beginning of the row
    dec VERA_addr_high

    bra ld

return:
    inc View_y
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