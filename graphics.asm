.ifndef GRAPHICS_ASM
GRAPHICS_ASM=1

.include "vera.inc"

;=================================================
;=================================================
;
;   General-purpose graphics routines
;
;-------------------------------------------------

.data
Gfx_all_palettes_at_full:
Gfx_all_palettes_cleared: .byte $00
Gfx_fade_palette_addr: .word $0000
Gfx_fade_palette_count: .byte $00

.code
GFX_PALETTE = $6E

;=================================================
; graphics_decrement_palette
;   Fade the palette one step towards black
;-------------------------------------------------
; INPUTS:   (none)
;
;-------------------------------------------------
; MODIFIES: A, X, Y, Gfx_all_palettes_cleared
;
.proc graphics_decrement_palette
    ; This is an optimistic flag: have we cleared the entire palette? 
    ; We'll falsify if not.
    lda #1
    sta Gfx_all_palettes_cleared

    lda #<Gfx_palette
    sta GFX_PALETTE
    lda #>Gfx_palette
    sta GFX_PALETTE+1

    ; The first thing I'm doing is trying to spin through the palette until there's work to be done.
    ; If we can quickly determine the whole palette is done, then bonus, we didn't have to do a lot
    ; of work.
    ; 
    ; But also, there's a that optimistic flag, and it's senseless to clear it more than once, so we'll
    ; scan through data until we find work, then clear the flag, then do work and not worry about the flag
    ; again.
    ;
    ; So if you imagine one loop that does everything, what I've done is cloned it, deleted all the actual work
    ; from one, and the optimstic flag from the other, and I use the section under "has_work" to bridge from
    ; one clone to the other.

    ; 512 bytes in the palette = 2 pages
    ldy #2
check_256_bytes:
    phy
    ldy #0

check_for_work:
    lda (GFX_PALETTE),y
    ; Don't need to decrement if already #0 (black)
    cmp #0
    bne has_work

    iny
    bne check_for_work

    inc GFX_PALETTE+1

    ply
    dey
    bne check_256_bytes

    ; If we get here, we had no work to do. Huzzah! So much time saved.
    rts

has_work:
    tax
    lda #0
    sta Gfx_all_palettes_cleared
    bra continue_with_work

decrement_256_bytes:
    phy
    ldy #0

decrement_byte:
    lda (GFX_PALETTE),y
    cmp #0
    beq next_byte

    ; The first byte is %ggggbbbb, so we need to decrement 
    ; each half if not 0. Instead of complex assembly to do that, I'm just 
    ; going to precompute to a table and do a lookup of the next value.
    ;
    ; The second byte is %0000rrrr, but since I did a table for the first
    ; byte, and the table results are good for this too, I do the same
    ; thing for the second.

    tax
continue_with_work:
    lda Gfx_palette_decrement_table,x
    sta (GFX_PALETTE),y

next_byte:
    iny
    bne decrement_byte

    inc GFX_PALETTE+1

    ply
    dey
    bne decrement_256_bytes

    rts
.endproc

;=================================================
; graphics_increment_palette
;   Fade the palette one step towards a set of desired values
;-------------------------------------------------
; INPUTS:   $FB-$FC Address of intended palette
;           $FD     Number of colors in palette (0 for all 256)
;
;-------------------------------------------------
; MODIFIES: A, X, Y, $FE-$FF, Gfx_all_palettes_at_full
; 
.proc graphics_increment_palette
    lda $FB
    sta $FE
    lda $FC
    sta $FF
    ; This is an optimistic flag: have we cleared the entire palette? 
    ; We'll falsify if not.
    lda #1
    sta Gfx_all_palettes_at_full

    lda #<Gfx_palette
    sta GFX_PALETTE
    lda #>Gfx_palette
    sta GFX_PALETTE+1

    ldy #0 ; 256 colors in palette
check_palette_entry:
    lda (GFX_PALETTE),y
    ; Don't need to increment if already at target value
    cmp ($FE),y
    bne has_work_gb

    inc $FE
    bne :+
    inc $FF
:
    inc GFX_PALETTE
    bne :+
    inc GFX_PALETTE+1
:
    lda (GFX_PALETTE),y
    ; Don't need to increment if already at target value
    cmp ($FE),y
    bne has_work_r

    iny
    cpy $FD
    bne check_palette_entry

    rts


has_work_gb:
    tax
    lda #0
    sta Gfx_all_palettes_at_full
    bra continue_gb

has_work_r:
    tax
    lda #0
    sta Gfx_all_palettes_at_full
    txa
    bra continue_r


    ; The first byte is %ggggbbbb, which means we have to increment these separately.
    ; We're going to xor with the intended color. This gives us some bits like %aaaabbbb
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

increment_palette_entry:
    lda (GFX_PALETTE),y
    ; Don't need to increment if already at target value
    cmp ($FE),y
    beq next_byte

    tax
continue_gb:
    eor ($FE),y
    cmp #$10
    bcc low_nibble

    txa
    clc
    adc #$10
    tax
low_nibble:
    eor ($FE),y
    and #$0F
    beq :+
    inx
:
    txa

    sta (GFX_PALETTE),y

next_byte:
    ; Y holds the number of colors we've copied, so increment our starting address here instead.
    ; we'll still increment Y at the bottom.
    inc $FE
    bne :+
    inc $FF
:   
    inc GFX_PALETTE
    bne :+
    inc GFX_PALETTE+1
:

    lda (GFX_PALETTE),y
    ; Don't need to increment if already at target value
    cmp ($FE),y
    beq next_palette_entry

continue_r:
    ; The second byte is %0000rrrr, which means we can get away with just an increment
    clc
    adc #1
    sta (GFX_PALETTE),y

next_palette_entry:
    iny
    cpy $FD
    bne increment_palette_entry

    rts
.endproc

;=================================================
; graphics_apply_palette
;   Apply the current palette to the VERA
;-------------------------------------------------
; INPUTS:   (none)
;
;-------------------------------------------------
; MODIFIES: A, X, Y
; 
.proc graphics_apply_palette
    VERA_SET_CTRL 0
    VERA_SET_PALETTE 0
    VERA_SET_CTRL 1
    VERA_SET_PALETTE 8

    ldy #0
stream_byte:
    lda Gfx_palette_0,y
    sta VERA_data
    lda Gfx_palette_8,y
    sta VERA_data2
    iny
    bne stream_byte

    rts
.endproc

;=================================================
; graphics_fade_out
;   Use palette decrementing to fade out the screen to black.
;-------------------------------------------------
; INPUTS:   (none)
;
;-------------------------------------------------
; MODIFIES: A, X, Y
; 
.proc graphics_fade_out
    jsr graphics_decrement_palette
    jsr graphics_apply_palette
    jsr sys_wait_one_frame

    lda Gfx_all_palettes_cleared
    cmp #0
    beq graphics_fade_out

    rts
.endproc

;=================================================
; graphics_fade_in
;   Use palette incmenting to fade in the screen from black.
;-------------------------------------------------
; INPUTS:   $FB-$FC Address of intended palette
;           $FD     Number of colors in the intended palette (0 for all 256)
;
;-------------------------------------------------
; MODIFIES: A, X, Y, $FE-$FF
; 
.proc graphics_fade_in
    jsr graphics_increment_palette
    jsr graphics_apply_palette
    jsr sys_wait_one_frame

    lda Gfx_all_palettes_at_full
    cmp #0
    beq graphics_fade_in

    rts
.endproc

;=================================================
;=================================================
;
;   Tables and constants
;
;-------------------------------------------------
.data
Gfx_palette_decrement_table:
    ;     $X0, $X1, $X2, $X3, $X4, $X5, $X6, $X7, $X8, $X9, $XA, $XB, $XC, $XD, $XE, $XF
    .byte $00, $00, $01, $02, $03, $04, $05, $06, $07, $08, $09, $0A, $0B, $0C, $0D, $0E    ; $0X
    .byte $00, $00, $01, $02, $03, $04, $05, $06, $17, $18, $19, $1A, $1B, $1C, $1D, $1E    ; $1X
    .byte $10, $10, $11, $12, $13, $14, $15, $16, $17, $18, $19, $1A, $2B, $2C, $2D, $2E    ; $2X
    .byte $20, $20, $21, $22, $23, $24, $25, $26, $27, $28, $29, $2A, $2B, $2C, $3D, $3E    ; $3X
    .byte $30, $30, $31, $32, $33, $34, $35, $36, $37, $38, $39, $3A, $3B, $3C, $3D, $4E    ; $4X
    .byte $40, $40, $41, $42, $43, $44, $45, $46, $47, $48, $49, $4A, $4B, $4C, $4D, $4E    ; $5X
    .byte $50, $50, $51, $52, $53, $54, $55, $56, $57, $58, $59, $5A, $5B, $5C, $5D, $5E    ; $6X
    .byte $60, $60, $61, $62, $63, $64, $65, $66, $67, $68, $69, $6A, $6B, $6C, $6D, $6E    ; $7X
    .byte $70, $71, $71, $72, $73, $74, $75, $76, $77, $78, $79, $7A, $7B, $7C, $7D, $7E    ; $8X
    .byte $80, $81, $81, $82, $83, $84, $85, $86, $87, $88, $89, $8A, $8B, $8C, $8D, $8E    ; $9X
    .byte $90, $91, $91, $92, $93, $94, $95, $96, $97, $98, $99, $9A, $9B, $9C, $9D, $9E    ; $AX
    .byte $A0, $A1, $A1, $A2, $A3, $A4, $A5, $A6, $A7, $A8, $A9, $AA, $AB, $AC, $AD, $AE    ; $BX
    .byte $B0, $B1, $B2, $B2, $B3, $B4, $B5, $B6, $B7, $B8, $B9, $BA, $BB, $BC, $BD, $BE    ; $CX
    .byte $C0, $C1, $C2, $C2, $C3, $C4, $C5, $C6, $C7, $C8, $C9, $CA, $CB, $CC, $CD, $CE    ; $DX
    .byte $D0, $D1, $D2, $D3, $D3, $D4, $D5, $D6, $D7, $D8, $D9, $DA, $DB, $DC, $DD, $DE    ; $EX
    .byte $E0, $E1, $E2, $E3, $E4, $E4, $E5, $E6, $E7, $E8, $E9, $EA, $EB, $EC, $ED, $EE    ; $FX

Gfx_palette:
Gfx_palette_0: .word $0000,$0fff,$0800,$0afe,$0c4c,$00c5,$000a,$0ee7,$0d85,$0640,$0f77,$0333,$0777,$0af6,$008f,$0bbb
Gfx_palette_1: .word $0000,$0111,$0222,$0333,$0444,$0555,$0666,$0777,$0888,$0999,$0aaa,$0bbb,$0ccc,$0ddd,$0eee,$0fff
Gfx_palette_2: .word $0211,$0433,$0644,$0866,$0a88,$0c99,$0fbb,$0211,$0422,$0633,$0844,$0a55,$0c66,$0f77,$0200,$0411
Gfx_palette_3: .word $0611,$0822,$0a22,$0c33,$0f33,$0200,$0400,$0600,$0800,$0a00,$0c00,$0f00,$0221,$0443,$0664,$0886
Gfx_palette_4: .word $0aa8,$0cc9,$0feb,$0211,$0432,$0653,$0874,$0a95,$0cb6,$0fd7,$0210,$0431,$0651,$0862,$0a82,$0ca3
Gfx_palette_5: .word $0fc3,$0210,$0430,$0640,$0860,$0a80,$0c90,$0fb0,$0121,$0343,$0564,$0786,$09a8,$0bc9,$0dfb,$0121
Gfx_palette_6: .word $0342,$0463,$0684,$08a5,$09c6,$0bf7,$0120,$0241,$0461,$0582,$06a2,$08c3,$09f3,$0120,$0240,$0360
Gfx_palette_7: .word $0480,$05a0,$06c0,$07f0,$0121,$0343,$0465,$0686,$08a8,$09ca,$0bfc,$0121,$0242,$0364,$0485,$05a6
Gfx_palette_8: .word $06c8,$07f9,$0020,$0141,$0162,$0283,$02a4,$03c5,$03f6,$0020,$0041,$0061,$0082,$00a2,$00c3,$00f3
Gfx_palette_9: .word $0122,$0344,$0466,$0688,$08aa,$09cc,$0bff,$0122,$0244,$0366,$0488,$05aa,$06cc,$07ff,$0022,$0144
Gfx_palette_10: .word $0166,$0288,$02aa,$03cc,$03ff,$0022,$0044,$0066,$0088,$00aa,$00cc,$00ff,$0112,$0334,$0456,$0668
Gfx_palette_11: .word $088a,$09ac,$0bcf,$0112,$0224,$0346,$0458,$056a,$068c,$079f,$0002,$0114,$0126,$0238,$024a,$035c
Gfx_palette_12: .word $036f,$0002,$0014,$0016,$0028,$002a,$003c,$003f,$0112,$0334,$0546,$0768,$098a,$0b9c,$0dbf,$0112
Gfx_palette_13: .word $0324,$0436,$0648,$085a,$096c,$0b7f,$0102,$0214,$0416,$0528,$062a,$083c,$093f,$0102,$0204,$0306
Gfx_palette_14: .word $0408,$050a,$060c,$070f,$0212,$0434,$0646,$0868,$0a8a,$0c9c,$0fbe,$0211,$0423,$0635,$0847,$0a59
Gfx_palette_15: .word $0c6b,$0f7d,$0201,$0413,$0615,$0826,$0a28,$0c3a,$0f3c,$0201,$0403,$0604,$0806,$0a08,$0c09,$0f0b

.code
.endif ; GRAPHICS_ASM