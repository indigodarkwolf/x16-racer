.ifndef SPLASH_ASM
SPLASH_ASM=1

.include "vera.inc"
.include "system.inc"
.include "graphics.inc"

.ifndef SPLASH_ADDR 
    SPLASH_ADDR=0
.endif

GIANT_SPLASH=1

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

    VERA_STREAM_OUT Splash_logo, SPLASH_ADDR, (Splash_logo_end - Splash_logo)

    ; VERA_SET_ADDR SPLASH_ADDR    
    ; ldy #<(Splash_logo_end - Splash_logo)
    ; ldx #>(Splash_logo_end - Splash_logo)
    ; lda #<Splash_logo
    ; sta $FB
    ; lda #>Splash_logo
    ; sta $FC
    ; jsr vera_stream_out_data

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

Splash_palette:
    .word $0000, $0FFF
Splash_palette_end:

; .include "system.asm"
.endif ; SPLASH_ASM