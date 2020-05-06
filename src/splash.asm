.ifndef SPLASH_ASM
SPLASH_ASM=1

.include "lib/x16/x16.inc"
.include "lib/graphics.inc"
.include "lib/system.inc"

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
splash_do: DEBUG_LABEL splash_do
    ; Copy the logo into video memory
    VERA_SET_CTRL 0

    GRAPHICS_STREAM_OUT_RLE Splash_logo, SPLASH_ADDR, (Splash_logo_end - Splash_logo)

    VERA_DISABLE_ALL
    VERA_ENABLE_SPRITES

__splash__setup_sprite:
    VERA_SET_SPRITE 0
.if GIANT_SPLASH = 1
    VERA_CONFIGURE_SPRITE SPLASH_ADDR, 0, (320-32), (240-32), 0, 0, 1, 0, 3, 3
.else
    VERA_CONFIGURE_SPRITE SPLASH_ADDR, 0, (320-16), (240-16), 0, 0, 1, 0, 2, 2
.endif
    GRAPHICS_FADE_IN Splash_palette, 0, 1

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