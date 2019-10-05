.ifndef SPLASH_ASM
SPLASH_ASM=1

.include "vera.inc"
.include "system.inc"
.include "graphics.inc"

.ifndef SPLASH_ADDR 
    SPLASH_ADDR=0
.endif

GIANT_SPLASH=1

.include "assets/splash-rle.inc"

;=================================================
; VERA_STREAM_OUT_RLE
;   Stream out a block of data to a location in VRAM
;-------------------------------------------------
; INPUTS:   src	Source data
;			dst	Destination start location
;			size	Numbers of bytes to stream out (max 64KiB)
;
;-------------------------------------------------
; MODIFIES: A, X, Y, $FB, $FC
; 
.macro VERA_STREAM_OUT_RLE src, dst, size
    VERA_SET_ADDR dst
    ldy #<(size)
    ldx #>(size)
    lda #<src
    sta $FB
    lda #>src
    sta $FC
    jsr vera_stream_out_rle
.endmacro

;=================================================
;=================================================
; 
;   Code
;
;-------------------------------------------------
;
; Do a splash screen with my logo.
; Return to caller when done.
;
splash_do:
    ; Copy the logo into video memory
    VERA_SELECT_ADDR 0

    VERA_STREAM_OUT_RLE Splash_logo, SPLASH_ADDR, (Splash_logo_end - Splash_logo)

    VERA_SET_ADDR VRAM_layer1, 0
    lda VERA_data
    and #$FE
    sta VERA_data

    VERA_SET_ADDR VRAM_layer2, 0
    lda VERA_data
    and #$FE
    sta VERA_data

    VERA_ENABLE_SPRITES

__splash__setup_sprite:
    VERA_SET_SPRITE 0
.if GIANT_SPLASH = 1
    VERA_CONFIGURE_SPRITE SPLASH_ADDR, 0, (320-32), (240-32), 0, 0, 1, 0, 3, 3
.else
    VERA_CONFIGURE_SPRITE SPLASH_ADDR, 0, (320-16), (240-16), 0, 0, 1, 0, 2, 2
.endif
    GRAPHICS_FADE_IN Splash_palette, 2

    lda #60
    jsr sys_wait_for_frame

    jsr graphics_fade_out

    VERA_DISABLE_SPRITES

    rts

;==============================================
; vera_stream_out_rle
; Stream out a block of rle-compressed memory to VERA_data
;----------------------------------------------
; INPUT: X   - number of rle pages to stream
;        Y   - number of rle bytes to stream
;        $FB - low byte of starting address
;        $FC - high byte of starting address
;----------------------------------------------
; Modifies: A, X, Y, $FC
;
vera_stream_out_rle:
    tya
    pha
    ; If no pages to copy, skip to bytes
    txa
    cmp #0
    beq @no_pages

    ; Copy X pages to VERA_data
    ldy #0
@page_loop:
    pha

@tuple_loop:
    ; First byte is the number of repetitions
    lda ($FB),Y
    tax

    iny

    ; Second byte is the value to stream
    lda ($FB),Y
    iny

@byte_loop:
    sta VERA_data
    dex
    bne @byte_loop

    cpy #0
    bne @tuple_loop

    inc $FC
    pla
    clc
    adc #$FF
    bne @page_loop

@no_pages:
    ; Copy X bytes to VERA_data
    ldy #0

@loop2:
    ; First byte is the number of repetitions
    lda ($FB),Y
    tax
    iny

    ; Second byte is the value to stream
    lda ($FB),Y
    iny
@byte_loop2:
    sta VERA_data
    dex
    bne @byte_loop2

    pla
    clc 
    adc #$FE
    pha
    bne @loop2
    pla
    
    rts



Splash_palette:
    .word $0000, $0FFF
Splash_palette_end:

; .include "system.asm"
.endif ; SPLASH_ASM