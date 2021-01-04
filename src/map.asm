.include "map.inc"

.include "math.inc"
.include "vera.inc"

.data
; Tile coordinate of map window's top-left corner
View_x: .word $0001
View_y: .word $0001

; Associated streaming grid coordinate of map window's top-left corner
Grid_x: .byte $00
Grid_y: .byte $00

; Associated bank coordinates of map window's top-left corner
Bank_x: .byte $00
Bank_y: .byte $00

TILEMAP_L0 = $00000
TILEMAP_L1 = $04000

MAP_BANK_WIDTH = 4
MAP_BANK_HEIGHT = 4
MAP_BANK_MASK = $0F

.code
.proc test_map_draw_column
    SYS_INIT_BANK
    SYS_INIT_IRQ
    SYS_RAND_SEED $34, $56, $fe
    SYS_CONFIGURE_MOUSE 0

    lda #(MAP_BANK_START)
    sta SYS_BANK_RAM

    ldy #0
    ldx #16

    lda #0
    sta store_page+1

store_bank:
    lda #$A0
    sta c0+2
    lda #$B0
    sta c1+2
store_page:
    lda #0
store_byte:
c0: sta $A000,y
c1: sta $B000,y
    dey
    bne store_byte
    inc store_page+1
    inc c0+2
    inc c1+2
    lda #$c0
    cmp c1+2
    bne store_page
    dex
    beq exit
    inc SYS_BANK_RAM
    bra store_bank

exit:
    jsr map_reset_view
    SYS_SET_IRQ do_irq
inf_loop:
    wai
    jmp inf_loop

dpad_last_state: .byte $00, $00, $00
dpad_state: .byte $00, $00, $00
dpad_pressed: .byte $00, $00, $00

do_irq:
    SYS_POLLJOY
    SYS_GETJOY 0
    sta dpad_last_state
    stx dpad_last_state+1
    sty dpad_last_state+2
    SYS_SET_IRQ repeat_irq
    VERA_END_VBLANK_IRQ
    SYS_END_IRQ
    SYS_ABORT_IRQ

repeat_irq:
    SYS_POLLJOY
    SYS_GETJOY 0
    sta dpad_state
    stx dpad_state+1
    sty dpad_state+2

.repeat 3,i
    lda dpad_last_state+i
    eor #$FF
    and dpad_state+i
    sta dpad_pressed+i
.endrep

    lda dpad_pressed
check_right:
    ror
    bcc check_left
    pha
    jsr map_incr_view_x

    lda VERA_l0_hscroll_l
    clc
    adc #8
    sta VERA_l0_hscroll_l
    lda VERA_l0_hscroll_h
    adc #0
    sta VERA_l0_hscroll_h

    lda VERA_l1_hscroll_l
    clc
    adc #8
    sta VERA_l1_hscroll_l
    lda VERA_l1_hscroll_h
    adc #0
    sta VERA_l1_hscroll_h

    pla
check_left:
    ror
    bcc check_down
    pha
    jsr map_decr_view_x

    lda VERA_l0_hscroll_l
    sec
    sbc #8
    sta VERA_l0_hscroll_l
    lda VERA_l0_hscroll_h
    sbc #0
    sta VERA_l0_hscroll_h

    lda VERA_l1_hscroll_l
    sec
    sbc #8
    sta VERA_l1_hscroll_l
    lda VERA_l1_hscroll_h
    sbc #0
    sta VERA_l1_hscroll_h

    pla
    jmp done
check_down:
    ror
    bcc check_up
    pha
    jsr map_incr_view_y

    lda VERA_l0_vscroll_l
    clc
    adc #8
    sta VERA_l0_vscroll_l
    lda VERA_l0_vscroll_h
    adc #0
    sta VERA_l0_vscroll_h

    lda VERA_l1_vscroll_l
    clc
    adc #8
    sta VERA_l1_vscroll_l
    lda VERA_l1_vscroll_h
    adc #0
    sta VERA_l1_vscroll_h

    pla
check_up:
    ror
    bcc done
    pha
    jsr map_decr_view_y

    lda VERA_l0_vscroll_l
    sec
    sbc #8
    sta VERA_l0_vscroll_l
    lda VERA_l0_vscroll_h
    sbc #0
    sta VERA_l0_vscroll_h

    lda VERA_l1_vscroll_l
    sec
    sbc #8
    sta VERA_l1_vscroll_l
    lda VERA_l1_vscroll_h
    sbc #0
    sta VERA_l1_vscroll_h

    pla
done:

.repeat 3,i
    lda dpad_state+i
    sta dpad_last_state+i
.endrep
    VERA_END_VBLANK_IRQ
    SYS_END_IRQ
    SYS_ABORT_IRQ
.endproc

.proc map_incr_view_x
    lda Bank_x
    inc
    and #$03
    sta Bank_x
    jsr map_draw_column

    ADD_16 View_x, View_x, #1
    lda View_x
    rol
    lda View_x+1
    rol
    sta Grid_x
    and #$03
    sta Bank_x

    rts
.endproc

.proc map_decr_view_x
    SUB_16 View_x, View_x, #1
    lda View_x
    rol
    lda View_x+1
    rol
    sta Grid_x
    and #$03
    sta Bank_x

    jsr map_draw_column
    rts
.endproc

.proc map_incr_view_y
    lda Bank_y
    inc
    inc
    and #$03
    sta Bank_y
    jsr map_draw_row

    ADD_16 View_y, View_y, #1
    ; Grid Y is View_y / 32
    lda View_y
    ; 4 rols to get the top 3 bits is faster than 5 lsrs
    rol
    rol
    rol
    rol
    sta Grid_y
    lda View_y+1
    asl
    asl
    asl
    ora Grid_y
    sta Grid_y

    and #$03
    sta Bank_y
    rts
.endproc

.proc map_decr_view_y
    SUB_16 View_y, View_y, #1
    ; Grid Y is View_y / 32
    lda View_y
    ; 4 rols to get the top 3 bits is faster than 5 lsrs
    rol
    rol
    rol
    rol
    sta Grid_y
    lda View_y+1
    asl
    asl
    asl
    ora Grid_y
    sta Grid_y

    and #$03
    sta Bank_y

    jsr map_draw_row
    rts
.endproc

;=================================================
; map_draw_column
;   Copy a column of tile data from banked memory
;   into VRAM.
;-------------------------------------------------
; MODIFIES: A,X,Y
; 
.proc map_draw_column
    ; Each bank contains a 128x32 square of the map, 
    ;   ordered left-to-right, top-to-bottom.
    ; The tilemap in VRAM is 128x64.
    ; If View_x and View_y are 0, then we've placed
    ;   the box [0, 0]-[127, 63] into VRAM.

    ; We should partially assemble the copy address into a0 and a1,
    ; but before adding #$A0 to the high byte of each, we should copy
    ; it to the VERA_addr_x

    ; uint32_t start_vram    = ((View_x * 2) % 256) + ((View_y * 256) % 64);
    ; uint16_t start_address = ((View_x * 2) % 256) + ((View_y * 256) % 32);
    ; uint8_t start_bank     = (((View_x / 128) % 4) + (View_y / 32)) % MAP_BANK_WIDTH;

    ; The copy is split into even bytes and odd bytes, the evens written to VERA_data0
    ; and the odds to VERA_data1.

    lda View_x
    asl
    sta a0+1    ; Setting low byte of X for our copy address
    inc
    sta a1+1    ; Setting low byte of X for our copy address + 1
    lda View_y
    and #$3F    ; modulo 64 since VRAM is 64 rows tall - we'll fix up the value for Banked RAM later.
    sta a0+2    ; Setting high byte of X for our copy address
    sta a1+2    ; Setting high byte of X for our copy address

    VERA_SET_CTRL 0
    ; ADD_16 VERA_addr, a0+1, #TILEMAP_L0
    clc
    lda a0+1
    adc #(TILEMAP_L0 & $FF)
    sta VERA_addr
    lda a0+2
    adc #((TILEMAP_L0 >> 8) & $FF)
    sta VERA_addr+1

    lda #$90    ; Auto-increment 256 bytes
    adc #0      ; Carry from the high byte
    sta VERA_addr_bank

    VERA_SET_CTRL 1
    ; ADD_16 VERA_addr, a1+1, #TILEMAP_L0
    clc
    lda a1+1
    adc #(TILEMAP_L0 & $FF)
    sta VERA_addr
    lda a1+2
    adc #((TILEMAP_L0 >> 8) & $FF)
    sta VERA_addr+1

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

column_bank_set:
    ; Banks are 4x4
    lda Bank_y
    asl
    asl
    ora Bank_x

    clc
    adc #MAP_BANK_START
    sta SYS_BANK_RAM

    ; Now copy a vertical strip of data.

    ldx #64 ; x contains the number of cells we have to copy
find_64_minus_y:
    lda View_y 
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
check_tilemap_y:
    dey
    bne inc_addr

    ; Ran past bottom of tilemap, wrap to top
    VERA_SET_CTRL 0
    lda VERA_addr_high
    sec
    sbc #64
    sta VERA_addr_high
    tay
    VERA_SET_CTRL 1
    sty VERA_addr_high
    ldy #64

inc_addr:
    lda a0+2
    inc
    cmp #$c0
    bne store_addr

    ; Increment bank to next row
column_inc_bank:
    lda SYS_BANK_RAM
    sec
    sbc #MAP_BANK_START
    clc
    adc #MAP_BANK_WIDTH
    and #MAP_BANK_MASK
    clc
    adc #MAP_BANK_START
    sta SYS_BANK_RAM

    lda #$A0
store_addr:
    sta a0+2
    sta a1+2
    bra do_copy

done:
    rts
.endproc

;=================================================
; map_draw_row
;   Copy a row of tile data from banked memory
;   into VRAM.
;-------------------------------------------------
; MODIFIES: A,X,Y
; 
.proc map_draw_row
    ; Each bank contains a 128x32 square of the map, 
    ;   ordered left-to-right, top-to-bottom.
    ; The tilemap in VRAM is 128x64.
    ; If View_x and View_y are 0, then we've placed
    ;   the box [0, 0]-[127, 63] into VRAM.

    ; We should partially assemble the copy address into a0 and a1,
    ; but before adding #$A0 to the high byte of each, we should copy
    ; it to the VERA_addr_x

    ; uint32_t start_vram    = ((View_x * 2) % 256) + ((View_y * 256) % 64);
    ; uint16_t start_address = ((View_x * 2) % 256) + ((View_y * 256) % 32);
    ; uint8_t start_bank     = (((View_x / 128) % 4) + (View_y / 32)) % MAP_BANK_WIDTH;

    ; The copy is split into even bytes and odd bytes, the evens written to VERA_data0
    ; and the odds to VERA_data1.

    lda View_x
    asl
    sta a0+1    ; Setting low byte of X for our copy address
    inc
    sta a1+1    ; Setting low byte of X for our copy address + 1
    lda View_y
    and #$3F    ; modulo 64 since VRAM is 64 rows tall - we'll fix up the value for Banked RAM later.
    sta a0+2    ; Setting high byte of X for our copy address
    sta a1+2    ; Setting high byte of X for our copy address

    VERA_SET_CTRL 0
    ; ADD_16 VERA_addr, a0+1, #TILEMAP_L0
    clc
    lda a0+1
    adc #(TILEMAP_L0 & $FF)
    sta VERA_addr
    lda a0+2
    adc #((TILEMAP_L0 >> 8) & $FF)
    sta VERA_addr+1

    lda #$20    ; Auto-increment 2 bytes
    adc #0      ; Carry from the high byte
    sta VERA_addr_bank

    VERA_SET_CTRL 1
    ; ADD_16 VERA_addr, a1+1, #TILEMAP_L0
    clc
    lda a1+1
    adc #(TILEMAP_L0 & $FF)
    sta VERA_addr
    lda a1+2
    adc #((TILEMAP_L0 >> 8) & $FF)
    sta VERA_addr+1

    lda #$20    ; Auto-increment 2 bytes
    adc #0      ; Carry from the high byte
    sta VERA_addr_bank

    lda a0+2
    ora #$A0    ; Properly would be to `and #$1F` then add #$A0,
                ; but $20 will be set by the add and the rest of 
                ; the high nibble will be 0 anyways. 
                ; "Save the frames, kill the animals."
    sta a0+2
    sta a1+2

row_bank_set:
    ; Banks are 4x4
    lda Bank_y
    asl
    asl
    ora Bank_x

    clc
    adc #MAP_BANK_START
    sta SYS_BANK_RAM

    ; Now copy a vertical strip of data.

    ldx #128 ; x contains the number of cells we have to copy
find_128_minus_x:
    lda View_x
    and #$7F
    eor #$FF
    adc #129
    tay ; y contains rows until VRAM address needs be rolled to first column of tilemap
        ; (128 - (x % 128))

do_copy:
a0: lda $A000
    sta VERA_data
a1: lda $A001
    sta VERA_data2
    dex
    beq done

    ; Not done copying yet
check_tilemap_y:
    dey
    bne row_inc_addr

    ; Ran past right edge of tilemap, wrap to left
    VERA_SET_CTRL 0
    lda VERA_addr_high
    sec
    sbc #1
    sta VERA_addr_high
    tay
    VERA_SET_CTRL 1
    sty VERA_addr_high
    ldy #128

row_inc_addr:
    lda a1+1
    clc
    adc #2
    sta a1+1
    lda a0+1
    clc
    adc #2
    sta a0+1
    bne do_copy

    ; Increment bank to next column, using SYS_BANK_RAM as a temp
row_inc_bank:
    lda Bank_x
    inc
    and #(MAP_BANK_WIDTH-1)
    sta SYS_BANK_RAM
    lda Bank_y
    asl
    asl
    ora SYS_BANK_RAM
    clc
    adc #MAP_BANK_START
    sta SYS_BANK_RAM

    lda #$A0
    bra do_copy

done:
    rts
.endproc

.proc map_reset_view
    stz View_x
    stz View_y
    stz Grid_x
    stz Grid_y
    stz Bank_x
    stz Bank_y

    lda #MAP_BANK_START
    sta SYS_BANK_RAM

    VERA_SET_CTRL 0
    VERA_SET_ADDR TILEMAP_L0, 1

    VERA_SET_CTRL 1
    VERA_SET_ADDR (TILEMAP_L0+$1000), 1

    stz VERA_l0_base+VERA_layer_hscroll_l
    stz VERA_l0_base+VERA_layer_hscroll_h
    stz VERA_l0_base+VERA_layer_vscroll_l
    stz VERA_l0_base+VERA_layer_vscroll_h

    stz VERA_l1_base+VERA_layer_hscroll_l
    stz VERA_l1_base+VERA_layer_hscroll_h
    stz VERA_l1_base+VERA_layer_vscroll_l
    stz VERA_l1_base+VERA_layer_vscroll_h

    lda #$A0
    sta a0+2
    lda #$B0
    sta a1+2

    ldx #0
copy_byte:
a0: lda $A000,x
    sta VERA_data
a1: lda $B000,x
    sta VERA_data2
    inx
    bne copy_byte
    inc a0+2
    inc a1+2
    lda a1+2
    cmp #$c0
    bne copy_byte

    lda #$A0
    sta a0+2
    lda #$B0
    sta a1+2

    lda SYS_BANK_RAM
    cmp #MAP_BANK_START
    bne return
    clc
    adc #MAP_BANK_WIDTH
    sta SYS_BANK_RAM

    VERA_SET_CTRL 0
    VERA_SET_ADDR (TILEMAP_L0+$2000), 1

    VERA_SET_CTRL 1
    VERA_SET_ADDR (TILEMAP_L0+$3000), 1
    bra copy_byte

return:
    VERA_SET_CTRL 0
    VERA_SET_ADDR 0, 1
    VERA_SET_CTRL 1
    VERA_SET_ADDR 0, 1
    rts
.endproc