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
    VERA_SET_CTRL 0

    VERA_STREAM_OUT_RLE Splash_logo, SPLASH_ADDR, (Splash_logo_end - Splash_logo)

    VERA_DISABLE_ALL
    VERA_ENABLE_SPRITES

__splash__setup_sprite:
    VERA_SET_SPRITE 0
.if GIANT_SPLASH = 1
    VERA_CONFIGURE_SPRITE SPLASH_ADDR, 0, (320-32), (240-32), 0, 0, 1, 0, 3, 3

    VERA_CONFIGURE_SPRITE SPLASH_ADDR, 0, (320-32-32), (240-32+16), 0, 0, 1, 1, 3, 3
    VERA_CONFIGURE_SPRITE SPLASH_ADDR, 0, (320-32+32), (240-32+16), 0, 0, 1, 2, 3, 3
    VERA_CONFIGURE_SPRITE SPLASH_ADDR, 0, (320-32), (240-32-32), 0, 0, 1, 3, 3, 3

    VERA_CONFIGURE_SPRITE SPLASH_ADDR, 0, (320-32-32), (240-32-16), 0, 0, 1, 4, 3, 3
    VERA_CONFIGURE_SPRITE SPLASH_ADDR, 0, (320-32+32), (240-32-16), 0, 0, 1, 5, 3, 3
    VERA_CONFIGURE_SPRITE SPLASH_ADDR, 0, (320-32), (240-32+32), 0, 0, 1, 6, 3, 3
.else
    VERA_CONFIGURE_SPRITE SPLASH_ADDR, 0, (320-16), (240-16), 0, 0, 1, 0, 2, 2
    
    VERA_CONFIGURE_SPRITE SPLASH_ADDR, 0, (320-32-16), (240-32+8), 0, 0, 1, 1, 3, 3
    VERA_CONFIGURE_SPRITE SPLASH_ADDR, 0, (320-32+16), (240-32+8), 0, 0, 1, 2, 3, 3
    VERA_CONFIGURE_SPRITE SPLASH_ADDR, 0, (320-32), (240-32-16), 0, 0, 1, 3, 3, 3

    VERA_CONFIGURE_SPRITE SPLASH_ADDR, 0, (320-32-16), (240-32-8), 0, 0, 1, 4, 3, 3
    VERA_CONFIGURE_SPRITE SPLASH_ADDR, 0, (320-32+16), (240-32-8), 0, 0, 1, 5, 3, 3
    VERA_CONFIGURE_SPRITE SPLASH_ADDR, 0, (320-32), (240-32+16), 0, 0, 1, 6, 3, 3
.endif
    GRAPHICS_FADE_IN Splash_palette, 0, (16*7)

    lda #60
    jsr sys_wait_for_frame

    lda #2
    jsr graphics_fade_out

    VERA_DISABLE_SPRITES

    rts

Splash_palette:
    .word $0000, $0FFF, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
    .word $0000, $0F00, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
    .word $0000, $00F0, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
    .word $0000, $000F, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
    .word $0000, $0FF0, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
    .word $0000, $00FF, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
    .word $0000, $0F0F, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
Splash_palette_end:

; .include "system.asm"
.endif ; SPLASH_ASM