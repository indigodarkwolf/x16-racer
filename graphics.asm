; !ifdef GRAPHICS_ASM !eof
; GRAPHICS_ASM=1

!src "vera.inc"

;=================================================
;=================================================
;
;   General-purpose graphics routines
;
;-------------------------------------------------

;=================================================
; graphics_fade_out
;   Use palette decrementing to fade out the screen to black.
;-------------------------------------------------
; INPUTS:   (none)
;
;-------------------------------------------------
; MODIFIES: A, X, Y
; 
graphics_fade_out:
    ; This is an optimistic flag: have we cleared the entire palette? 
    ; We'll falsify if not.
    lda #1
    sta Gfx_all_palettes_cleared

    +VERA_SELECT_ADDR 0
    +VERA_SET_PALETTE 0
    +VERA_SELECT_ADDR 1
    +VERA_SET_PALETTE 0

    ldy #0 ; 256 colors in the palette

.decrement_palette_entry:
    lda VERA_data
    ; Don't need to decrement if already #0 (black)
    cmp #0
    beq +

    ; The first byte is %ggggbbbb, so we need to decrement 
    ; each half if not 0. Instead of complex assembly to do that, I'm just 
    ; going to precompute to a table and do a lookup of the next value.
    ; And since I did it that way for the first byte, do it the same
    ; way for the second as well since that answer is good for both.
    tax

    lda #0
    sta Gfx_all_palettes_cleared

    lda Gfx_palette_decrement_table, X
+   sta VERA_data2

    lda VERA_data

    ; Still don't need to decrement 0.
    cmp #0
    beq +

    tax

    lda #0
    sta Gfx_all_palettes_cleared

    lda Gfx_palette_decrement_table, X
+   sta VERA_data2

    dey
    bne .decrement_palette_entry

    jsr sys_wait_one_frame

    lda Gfx_all_palettes_cleared
    cmp #0
    beq graphics_fade_out

    rts


;=================================================
; graphics_fade_in
;   Use palette incmenting to fade in the screen from black.
;-------------------------------------------------
; INPUTS:   $FB-$FC Address of intended palette
;           $FD     Number of colors in palette (0 for all 256)
;
;-------------------------------------------------
; MODIFIES: A, X, Y, $FB-$FF
; 
graphics_fade_in:
    lda $FB
    sta $FE
    lda $FC
    sta $FF
    ; This is an optimistic flag: have we cleared the entire palette? 
    ; We'll falsify if not.
    lda #1
    sta Gfx_all_palettes_cleared

    +VERA_SELECT_ADDR 0
    +VERA_SET_PALETTE 0
    +VERA_SELECT_ADDR 1
    +VERA_SET_PALETTE 0

    ldy #0 ; 256 colors in palette

.increment_palette_entry
    lda VERA_data
    ; Don't need to increment if already at target value
    cmp ($FE), Y
    beq .store_gb

    tax

    lda #0
    sta Gfx_all_palettes_cleared

    ; The first byte is %ggggbbbb, which means we have to increment these separately.
    ; We're going to xor with the the intended color. This gives us some bits like %aaaabbbb
    ; where any 'b' bits set mean we increment the bottom half, then any 'a' bits set mean we
    ; increment the top half.
    ;   --- I'm a little proud of realizing how much branching an XOR saves me, because I'm
    ;       a hack and I was literally staring at C++ code that did this:
    ;       
    ;       unsigned short increment(unsigned short color, unsigned short target) {
    ;           color = ((color & 0xF0) < (target & 0xF0)) ? color + 0x10 : color;
    ;           color = ((color & 0x0F) < (target & 0x0F)) ? color + 0x01 : color;
    ;           return color;
    ;       }
    ;
    ;       Yeah. What a waste of electricity compared to:
    ;
    ;       unsigned short increment(unsigned short color, unsigned short target) {
    ;           unsigned short bit_diff = color ^ target
    ;           if(bit_diff >= 0x10) color += 0x10;
    ;           if(bit_diff & 0x0F) color += 0x01;
    ;       }

    txa
    eor ($FE), Y
    cmp #$10
    bcc +
    txa
    clc
    adc #$10
    tax
+   eor ($FE), Y
    and #$0F
    beq +
    inx
+   txa
.store_gb:
    sta VERA_data2

    ; Y holds the number of colors we've copied, so increment our starting address here instead.
    ; we'll still increment Y at the bottom.
    inc $FE
    bne +
    inc $FF

+   lda VERA_data
    ; Don't need to increment if already at target value
    cmp ($FE), Y
    beq .store_r

    tax

    lda #0
    sta Gfx_all_palettes_cleared

    ; The second byte is %0000rrrr, which means we can get away with just an increment
    inx
    txa
.store_r
    sta VERA_data2

    iny
    cpy $FD
    bne .increment_palette_entry

    jsr sys_wait_one_frame

__gfx__graphics_fade_in_all_palettes_cleared:
    lda Gfx_all_palettes_cleared
    cmp #1
    beq +
    jmp graphics_fade_in

__gfx__graphics_fade_in_return:
+   rts

;=================================================
;=================================================
;
;   Tables and constants
;
;-------------------------------------------------

Gfx_palette_decrement_table:
    ;     $X0, $X1, $X2, $X3, $X4, $X5, $X6, $X7, $X8, $X9, $XA, $XB, $XC, $XD, $XE, $XF
    !byte $00, $00, $01, $02, $03, $04, $05, $06, $07, $08, $09, $0A, $0B, $0C, $0D, $0E    ; $0X
    !byte $00, $00, $01, $02, $03, $04, $05, $06, $07, $08, $09, $0A, $0B, $0C, $0D, $0E    ; $1X
    !byte $10, $10, $11, $12, $13, $14, $15, $16, $17, $18, $19, $1A, $1B, $1C, $1D, $1E    ; $2X
    !byte $20, $20, $21, $22, $23, $24, $25, $26, $27, $28, $29, $2A, $2B, $2C, $2D, $2E    ; $3X
    !byte $30, $30, $31, $32, $33, $34, $35, $36, $37, $38, $39, $3A, $3B, $3C, $3D, $3E    ; $4X
    !byte $40, $40, $41, $42, $43, $44, $45, $46, $47, $48, $49, $4A, $4B, $4C, $4D, $4E    ; $5X
    !byte $50, $50, $51, $52, $53, $54, $55, $56, $57, $58, $59, $5A, $5B, $5C, $5D, $5E    ; $6X
    !byte $60, $60, $61, $62, $63, $64, $65, $66, $67, $68, $69, $6A, $6B, $6C, $6D, $6E    ; $7X
    !byte $70, $70, $71, $72, $73, $74, $75, $76, $77, $78, $79, $7A, $7B, $7C, $7D, $7E    ; $8X
    !byte $80, $80, $81, $82, $83, $84, $85, $86, $87, $88, $89, $8A, $8B, $8C, $8D, $8E    ; $9X
    !byte $90, $90, $91, $92, $93, $94, $95, $96, $97, $98, $99, $9A, $9B, $9C, $9D, $9E    ; $AX
    !byte $A0, $A0, $A1, $A2, $A3, $A4, $A5, $A6, $A7, $A8, $A9, $AA, $AB, $AC, $AD, $AE    ; $BX
    !byte $B0, $B0, $B1, $B2, $B3, $B4, $B5, $B6, $B7, $B8, $B9, $BA, $BB, $BC, $BD, $BE    ; $CX
    !byte $C0, $C0, $C1, $C2, $C3, $C4, $C5, $C6, $C7, $C8, $C9, $CA, $CB, $CC, $CD, $CE    ; $DX
    !byte $D0, $D0, $D1, $D2, $D3, $D4, $D5, $D6, $D7, $D8, $D9, $DA, $DB, $DC, $DD, $DE    ; $EX
    !byte $E0, $E0, $E1, $E2, $E3, $E4, $E5, $E6, $E7, $E8, $E9, $EA, $EB, $EC, $ED, $EE    ; $FX
