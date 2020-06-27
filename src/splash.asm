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

.if GIANT_SPLASH = 1
CENTER_X=(320-32)
CENTER_Y=(240-32)
.else
CENTER_X=(320-16)
CENTER_Y=(240-16)
.endif

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
.code
splash_do:
    ; Copy the logo into video memory
    VERA_SET_CTRL 0

    VERA_STREAM_OUT_RLE Splash_logo, SPLASH_ADDR, (Splash_logo_end - Splash_logo)

    VERA_DISABLE_ALL
    VERA_ENABLE_SPRITES

__splash__setup_sprite:
    VERA_SET_SPRITE 0
.if ::GIANT_SPLASH = 1
    VERA_CONFIGURE_SPRITE ::SPLASH_ADDR, 0, ::CENTER_X,       ::CENTER_Y,      0, 0, 0, 0, 3, 3

    VERA_CONFIGURE_SPRITE ::SPLASH_ADDR, 0, (::CENTER_X-32),  (::CENTER_Y+16), 0, 0, 1, 1, 3, 3
    VERA_CONFIGURE_SPRITE ::SPLASH_ADDR, 0, (::CENTER_X+32),  (::CENTER_Y+16), 0, 0, 1, 2, 3, 3
    VERA_CONFIGURE_SPRITE ::SPLASH_ADDR, 0, (::CENTER_X),     (::CENTER_Y-32), 0, 0, 1, 3, 3, 3

    VERA_CONFIGURE_SPRITE ::SPLASH_ADDR, 0, (::CENTER_X-32),  (::CENTER_Y-16), 0, 0, 1, 4, 3, 3
    VERA_CONFIGURE_SPRITE ::SPLASH_ADDR, 0, (::CENTER_X+32),  (::CENTER_Y-16), 0, 0, 1, 5, 3, 3
    VERA_CONFIGURE_SPRITE ::SPLASH_ADDR, 0, (::CENTER_X),     (::CENTER_Y+32), 0, 0, 1, 6, 3, 3
.else
    VERA_CONFIGURE_SPRITE ::SPLASH_ADDR, 0, (::CENTER_X),     (::CENTER_Y),    0, 0, 0, 0, 2, 2
    
    VERA_CONFIGURE_SPRITE ::SPLASH_ADDR, 0, (::CENTER_X-16),  (::CENTER_Y+8),  0, 0, 1, 1, 3, 3
    VERA_CONFIGURE_SPRITE ::SPLASH_ADDR, 0, (::CENTER_X+16),  (::CENTER_Y+8),  0, 0, 1, 2, 3, 3
    VERA_CONFIGURE_SPRITE ::SPLASH_ADDR, 0, (::CENTER_X),     (::CENTER_Y-16), 0, 0, 1, 3, 3, 3

    VERA_CONFIGURE_SPRITE ::SPLASH_ADDR, 0, (::CENTER_X-16),  (::CENTER_Y-8),  0, 0, 1, 4, 3, 3
    VERA_CONFIGURE_SPRITE ::SPLASH_ADDR, 0, (::CENTER_X+16),  (::CENTER_Y-8),  0, 0, 1, 5, 3, 3
    VERA_CONFIGURE_SPRITE ::SPLASH_ADDR, 0, (::CENTER_X),     (::CENTER_Y+16), 0, 0, 1, 6, 3, 3
.endif
    ; GRAPHICS_FADE_IN Splash_palette, 0, (16*7)

    lda #0
    sta Sys_frame

    SYS_SET_IRQ splash_spin
    cli

    lda #3
@wait:
    cmp Splash_state
        ; 0 Fade-in
        ; 1 Spiraling in/out
        ; 2 Fade-out
        ; 3 Done
    bne @wait
    sei
    VERA_DISABLE_SPRITES

    rts

.proc splash_spin
    DEBUG_LABEL splash_update_vera
    VERA_SET_SPRITE_POS_X 1, Box_positions_xy
    VERA_SET_SPRITE_POS_Y 1, Box_positions_xy+2
    VERA_SET_SPRITE_POS_X 2, Box_positions_xy+4
    VERA_SET_SPRITE_POS_Y 2, Box_positions_xy+6
    VERA_SET_SPRITE_POS_X 3, Box_positions_xy+8
    VERA_SET_SPRITE_POS_Y 3, Box_positions_xy+10
    VERA_SET_SPRITE_POS_X 4, Box_positions_xy+12
    VERA_SET_SPRITE_POS_Y 4, Box_positions_xy+14
    VERA_SET_SPRITE_POS_X 5, Box_positions_xy+16
    VERA_SET_SPRITE_POS_Y 5, Box_positions_xy+18
    VERA_SET_SPRITE_POS_X 6, Box_positions_xy+20
    VERA_SET_SPRITE_POS_Y 6, Box_positions_xy+22

    SYS_SET_BANK GRAPHICS_TABLES_BANK
    jsr graphics_apply_palette

    inc Sys_frame

    ; Fade in state
    .scope 
        DEBUG_LABEL splash_fade_in
        lda #0
        cmp Splash_state
        bne fade_in_done

        lda Sys_frame
        and #1
        beq fade_in_done
        GRAPHICS_INCREMENT_PALETTE Splash_palette, 0, (16*7)

        lda Gfx_idle_flag
        cmp #1
        bne fade_in_done
        inc Splash_state
    fade_in_done:
    .endscope

    ; Fade out state
    .scope 
        DEBUG_LABEL splash_fade_out
        lda #2
        cmp Splash_state
        bne palette_done

        lda Sys_frame
        and #1
        beq fade_out_done
        GRAPHICS_DECREMENT_PALETTE

        lda Gfx_idle_flag
        cmp #1
        bne fade_out_done
        inc Splash_state
    fade_out_done:
        VERA_END_VBLANK_IRQ
        SYS_ABORT_IRQ
    .endscope

palette_done:
    DEBUG_LABEL splash_spin
    SUB_24 Box_radial_distance, Box_radial_distance, Box_radial_velocity

    ; Spiraling in/out state
    .scope 
        lda #1
        cmp Splash_state
        bne start_rotate

        ; If Box_radial_distance != 0, continue to rotate
        lda #0
        cmp Box_radial_distance
        bne check_state
        cmp Box_radial_distance+1
        bne check_state
        cmp Box_radial_distance+2
        bne check_state

        NEG_24 Box_radial_velocity
        NEG_8 Box_angular_speed

        VERA_SET_SPRITE_ZDEPTH 0, 1

    check_state:
        DEBUG_LABEL check_state
        BLT_24 Box_radial_distance, Box_radial_distance_max, start_rotate
        inc Splash_state
    start_rotate:
    .endscope


    ldx #0

rotate_box:
    clc
    lda Box_angles, x
    adc Box_angular_speed
    sta Box_angles, x
    inx
    cpx #6
    bne rotate_box

    MUL_BEGIN

    ldx #0

move_box: DEBUG_LABEL splash_move_box
    lda Box_angles, x
    phx

    jsr cos_8
    stx Box_trig_temp
    sta Box_trig_temp+1
    .scope
        and #$80
        beq store_sign
        lda #$ff
    store_sign:
        sta Box_trig_temp+2
    .endscope

    MUL_24_24 Box_position_temp, Box_trig_temp, Box_radial_distance

    pla
    pha
    asl
    asl
    tay

    clc
    lda Box_position_temp+1
    adc #<::CENTER_X
    sta Box_positions_xy,y
    iny
    lda Box_position_temp+2
    adc #>::CENTER_X
    sta Box_positions_xy,y

    plx
    lda Box_angles, x
    phx

    jsr sin_8
    stx Box_trig_temp
    sta Box_trig_temp+1
    .scope
        and #$80
        beq store_sign
        lda #$ff
    store_sign:
        sta Box_trig_temp+2
    .endscope

    MUL_24_24 Box_position_temp, Box_trig_temp, Box_radial_distance

    pla
    pha
    asl
    asl
    tay
    iny
    iny

    clc
    lda Box_position_temp+1
    adc #<::CENTER_Y
    sta Box_positions_xy,y
    iny
    lda Box_position_temp+2
    adc #>::CENTER_Y
    sta Box_positions_xy,y

    plx
    inx
    cpx #6
    beq done
    jmp move_box
done:

    VERA_END_VBLANK_IRQ
    SYS_ABORT_IRQ
.endproc


.data

Splash_state:        .byte $00

Box_angles:         .byte ((1 * 256)/12), ((3 * 256)/12), ((5 * 256)/12), ((7 * 256)/12), ((9 * 256)/12), ((11 * 256)/12)
Box_angular_speed:  .byte $02

Box_radial_velocity: .byte $04, 0, 0
Box_radial_distance: .byte <400, >400, 0
Box_radial_distance_max: .byte <420, >420, 0
Box_trig_temp:       .byte 0, 0, 0
Box_position_temp:   .byte 0, 0, 0

Box_positions_xy: 
    .byte 0, 0, 0, 0
    .byte 0, 0, 0, 0
    .byte 0, 0, 0, 0
    .byte 0, 0, 0, 0
    .byte 0, 0, 0, 0
    .byte 0, 0, 0, 0

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