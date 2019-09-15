; !ifdef SPLASH_ASM !eof
; SPLASH_ASM=1

!src "vera.inc"
!src "system.inc"
!src "graphics.inc"

!ifndef SPLASH_ADDR { SPLASH_ADDR=0 }

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
    +VERA_SELECT_ADDR 0
    +VERA_SET_ADDR SPLASH_ADDR

    ldy #<(Splash_logo_end - Splash_logo)
    ldx #>(Splash_logo_end - Splash_logo)
    lda #<Splash_logo
    sta $FB
    lda #>Splash_logo
    sta $FC
    jsr VERA_stream_out_data

    +VERA_SET_ADDR VRAM_layer1, 0
    lda VERA_data
    and #$FE
    sta VERA_data

    +VERA_SET_ADDR VRAM_layer2, 0
    lda VERA_data
    and #$FE
    sta VERA_data

    +VERA_SET_ADDR VRAM_sprinfo
    lda #1
    sta VERA_data

__splash__setup_sprite:
    +VERA_SET_SPRITE 0
    +VERA_CONFIGURE_SPRITE SPLASH_ADDR, 1, (320-32), (240-32), 0, 0, 1, 0, 2, 2

    +GRAPHICS_FADE_IN Splash_palette, 2

    lda #60
    jsr sys_wait_for_frame

    jsr graphics_fade_out

    +VERA_SELECT_ADDR 0
    +VERA_SET_ADDR VRAM_sprinfo, 1
    +VERA_WRITE 0

    rts

Splash_palette:
    !le16 $0000, $0FFF
Splash_palette_end:

; !src "system.asm"