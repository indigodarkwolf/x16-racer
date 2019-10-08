.ifndef RACE_ASM
RACE_ASM=1

.include "vera.inc"
.include "system.inc"
.include "graphics.inc"

.include "assets/mountains.inc"
.include "assets/font_courier_new.inc"
.include "assets/forest.inc"
.include "assets/forest-inner.inc"
.include "assets/car.inc"
.include "assets/road.inc"
.include "assets/pillar.inc"
.include "assets/wheel.inc"

.include "assets/licenses.inc"

RACE_MOUNTAINS_BG_ADDR=0
RACE_MOUNTAINS_BG_SIZE=128*64*2

RACE_FOREST_BG_ADDR=(RACE_MOUNTAINS_BG_ADDR + RACE_MOUNTAINS_BG_SIZE)
RACE_FOREST_BG_SIZE=128*64*2

RACE_MOUNTAINS_BG_TILES_ADDR=(RACE_FOREST_BG_ADDR + RACE_FOREST_BG_SIZE)
RACE_MOUNTAINS_BG_TILES_SIZE=(mountain_end - mountain)

RACE_FONT_TILES_ADDR=(RACE_MOUNTAINS_BG_TILES_ADDR + RACE_MOUNTAINS_BG_TILES_SIZE)
RACE_FONT_TILES_SIZE=(font_courier_new_end - font_courier_new)

RACE_FOREST_BG_TILES_ADDR=(RACE_FONT_TILES_ADDR + RACE_FONT_TILES_SIZE)
RACE_FOREST_BG_TILES_SIZE=(forest_end - forest)

RACE_FOREST_INNER_BG_TILES_ADDR=(RACE_FOREST_BG_TILES_ADDR + RACE_FOREST_BG_TILES_SIZE)
RACE_FOREST_INNER_BG_TILES_SIZE=(forest_inner_end - forest_inner)

RACE_CAR_ADDR=((RACE_FOREST_INNER_BG_TILES_ADDR + RACE_FOREST_INNER_BG_TILES_SIZE))
RACE_CAR_SIZE=(car_end - car)

ROAD_ADDR=((RACE_CAR_ADDR + RACE_CAR_SIZE))
ROAD_SIZE=(road_end - road)

PILLAR_ADDR=((ROAD_ADDR + ROAD_SIZE))
PILLAR_SIZE=(pillar_end - pillar)

WHEEL0_ADDR=((PILLAR_ADDR + PILLAR_SIZE))
WHEEL0_SIZE=(wheel_01_00 - wheel_00_00)

WHEEL1_ADDR=((WHEEL0_ADDR + WHEEL0_SIZE))
WHEEL1_SIZE=(wheel_end - wheel_01_00)

LICENSE_0_SIZE=(license_0_end - license_0)
LICENSE_1_SIZE=(license_1_end - license_1)
LICENSE_2_SIZE=(license_2_end - license_2)
LICENSE_3_SIZE=(license_3_end - license_3)
LICENSE_4_SIZE=(license_4_end - license_4)
LICENSE_5_SIZE=(license_5_end - license_5)
LICENSE_6_SIZE=(license_6_end - license_6)

;=================================================
; RACE_STREAM_ROW
;   Stream a row of 8 tilemap entries to VRAM,
;   assuming the source pattern is 8 tiles wide
;-------------------------------------------------
; INPUTS:   start  Start of the tilemap pattern
;           row    Row number to stream
;
;-------------------------------------------------
; MODIFIES: A, X, Y, $FF
; 
.macro RACE_STREAM_ROW start, row
.local @stream
    lda #(128/8)
@stream:
    pha    
    SYS_STREAM_OUT (start + (16 * row)), VERA_data, 16
    pla
    sec
    sbc #1
    cmp #0
    bne @stream
.endmacro

;=================================================
; WRAP_X_TO_SCREEN_24
;   Given some 24-bit X coordinate in 16.8 fixed point,
;   for a 64x64 sprite, check whether it's on-screen and,
;   if not, wrap it to the other side
;
;   This is because I don't want to wait for the thing to
;   go the entire numerical range off the screen. I'm 
;   programming to a 16-sprite limit due to r31's limits,
;   so I don't have the sprites to spare. Besides, it's
;   wasteful to be updating positions on sprites that
;   can't be seen, and I've only got so many CPU clocks.
;-------------------------------------------------
; INPUTS:   pos     Memory address of the 24-bit coordinate
;
;-------------------------------------------------
; MODIFIES: A, pos
; 
.macro WRAP_X_TO_SCREEN_24 pos
.local @offscreen
.local @onscreen

    ADD_24 Temp, pos, Wrap_amount

; TODO: This is basically a BGE (branch greater-or-equal) Temp, Screen_width, @onscreen
;       with some .macro BGE lhs, rhs, branch_target
    lda Temp+2
    cmp Screen_width+2
    bcc @offscreen
    bne @onscreen
    lda Temp+1
    cmp Screen_width+1
    bcs @onscreen
@offscreen:
    lda Temp
    sta pos
    lda Temp+1
    sta pos+1
    lda Temp+2
    sta pos+2
@onscreen:
.endmacro

;=================================================
;=================================================
; 
;   Code
;
;-------------------------------------------------
;
; Do a RACE screen with my logo.
; Return to caller when done.
;
race_do:
    VERA_DISABLE_ALL

    ; I've already spent a lot of memory on assets, and don't want to bother with file I/O just yet
    ; or image compression (though the splash logo could *majorly* benefit from RLE encoding, let me
    ; tell you).
    ;
    ; So instead of doing a nice, clean, block copy of pre-calculated tilemap data into VRAM, I'm
    ; breaking it up into chunks of assembly because that's smaller.

    ; The mountains background tilemap, with some art credits in the sky
    VERA_SET_ADDR RACE_MOUNTAINS_BG_ADDR
    SYS_STREAM Race_mountains_map, VERA_data, (256*2+56)

    SYS_STREAM_OUT license_1, VERA_data, LICENSE_1_SIZE
    SYS_STREAM Race_mountains_map, VERA_data, (256 - 56 - LICENSE_1_SIZE + 58)
    SYS_STREAM_OUT license_2, VERA_data, LICENSE_2_SIZE
    SYS_STREAM Race_mountains_map, VERA_data, (256 - 58 - LICENSE_2_SIZE + 60)
    SYS_STREAM_OUT license_3, VERA_data, LICENSE_3_SIZE
    SYS_STREAM Race_mountains_map, VERA_data, (256 - 60 - LICENSE_3_SIZE)

    SYS_STREAM Race_mountains_map, VERA_data, (256*3+128)

    SYS_STREAM_OUT license_4, VERA_data, LICENSE_4_SIZE
    SYS_STREAM Race_mountains_map, VERA_data, (256 - 128 - LICENSE_4_SIZE + 130)
    SYS_STREAM_OUT license_5, VERA_data, LICENSE_5_SIZE
    SYS_STREAM Race_mountains_map, VERA_data, (256 - 130 - LICENSE_5_SIZE + 132)
    SYS_STREAM_OUT license_6, VERA_data, LICENSE_6_SIZE
    SYS_STREAM Race_mountains_map, VERA_data, (256 - 132 - LICENSE_6_SIZE)

    SYS_STREAM Race_mountains_map, VERA_data, (256*11)
    .repeat 8, i
        RACE_STREAM_ROW Race_mountains_map, i
    .endrep
    SYS_STREAM Race_mountains_map, VERA_data, 256*30
    
    ; The forest background tilemap
    VERA_SET_ADDR RACE_FOREST_BG_ADDR
    SYS_STREAM Race_mountains_map, VERA_data, 256*28
    .repeat 8, i
        RACE_STREAM_ROW Race_forest_map, i
    .endrep
    .repeat 8, i
        RACE_STREAM_ROW Race_forest_inner_map, i
    .endrep
    .repeat 8, i
        RACE_STREAM_ROW Race_forest_inner_map, i
    .endrep
    .repeat 8, i
        RACE_STREAM_ROW Race_forest_inner_map, i
    .endrep

    ; Tile data
    VERA_STREAM_OUT_DATA mountain, RACE_MOUNTAINS_BG_TILES_ADDR, RACE_MOUNTAINS_BG_TILES_SIZE
    VERA_STREAM_OUT_DATA font_courier_new, RACE_FONT_TILES_ADDR, RACE_FONT_TILES_SIZE
    VERA_STREAM_OUT_DATA forest, RACE_FOREST_BG_TILES_ADDR, RACE_FOREST_BG_TILES_SIZE
    VERA_STREAM_OUT_DATA forest_inner, RACE_FOREST_INNER_BG_TILES_ADDR, RACE_FOREST_INNER_BG_TILES_SIZE
    VERA_STREAM_OUT_DATA car, RACE_CAR_ADDR, RACE_CAR_SIZE
    VERA_STREAM_OUT_DATA road, ROAD_ADDR, ROAD_SIZE
    VERA_STREAM_OUT_DATA pillar, PILLAR_ADDR, PILLAR_SIZE
    VERA_STREAM_OUT_DATA wheel_00_00, WHEEL0_ADDR, WHEEL0_SIZE
    VERA_STREAM_OUT_DATA wheel_01_00, WHEEL1_ADDR, WHEEL1_SIZE

    ; Palette data
    VERA_STREAM_OUT_DATA mountain_palette, VRAM_palette0, 16*2
    VERA_STREAM_OUT_DATA forest_palette, VRAM_palette1, 16*2
    VERA_STREAM_OUT_DATA car_palette, VRAM_palette2, 16*2
    VERA_STREAM_OUT_DATA road_palette, VRAM_palette3, 6*2
    VERA_STREAM_OUT_DATA pillar_palette, VRAM_palette4, 16*2
    VERA_STREAM_OUT_DATA wheel_palette, VRAM_palette5, 16*2
    VERA_STREAM_OUT_DATA Race_credits_palette_start, VRAM_palette6, 3*2
    ; VERA_STREAM_OUT_DATA font_courier_new_palette, VRAM_palette6, 3*2  ; It's a secret to everyone!

__race__setup_scene:
    VERA_CONFIGURE_TILE_LAYER 0, 1, 3, 0, 0, 2, 1, RACE_MOUNTAINS_BG_ADDR, RACE_MOUNTAINS_BG_TILES_ADDR
    VERA_CONFIGURE_TILE_LAYER 1, 1, 3, 0, 0, 2, 1, RACE_FOREST_BG_ADDR, RACE_FOREST_BG_TILES_ADDR

    VERA_SET_SPRITE 0
    VERA_CONFIGURE_SPRITE WHEEL0_ADDR, 0, (297), (320), 0, 0, 1, 5, 1, 1
    VERA_CONFIGURE_SPRITE WHEEL0_ADDR, 0, (328), (320), 0, 0, 1, 5, 1, 1

    VERA_CONFIGURE_SPRITE RACE_CAR_ADDR, 0, (288), (304), 0, 0, 1, 2, 3, 2

    .repeat 11, i
    VERA_CONFIGURE_SPRITE ROAD_ADDR, 0, (64 * i), (288), 0, 0, 1, 3, 3, 3
    .endrep

    VERA_CONFIGURE_SPRITE PILLAR_ADDR, 0, (64), (352), 0, 0, 1, 4, 3, 3
    VERA_CONFIGURE_SPRITE PILLAR_ADDR, 0, (64), (416), 0, 0, 1, 4, 3, 3

    ; These were just tests of the palettes

    ; VERA_SET_SPRITE 1
    ; VERA_CONFIGURE_SPRITE RACE_CAR_ADDR, 0, (320-64), (240-64), 0, 0, 1, 1, 3, 2
    ; VERA_SET_SPRITE 2
    ; VERA_CONFIGURE_SPRITE RACE_CAR_ADDR, 0, (320), (240-64), 0, 0, 1, 0, 3, 2

__race__begin:
    lda #1
    jsr sys_wait_for_frame

    SYS_SET_IRQ race_irq_first
    cli

    jmp *

__race__cleanup:
    VERA_DISABLE_SPRITES
    rts

; Since I'm doing a *lot* of work without waiting for frames (due to having everything turned off),
; I may be mid-frame when I turn things on. So instead of just doing that any time, do it in a
; one-off IRQ that flows sets and then continues into the real IRQ, so that we'll ideally avoid
; screen-tearing on the first frame.
;
; Overthinking? Whatever, low-hanging fruit at this point.

race_irq_first:
    ; I'm not sure what I'm blowing up with this macro just yet. It's supposed to be a faster
    ; way of toggling layers and sprites on, by taking advantage of the fact that the "enabled"
    ; bit is the most significant bit of byte 0 on both layers and the sprite info, and that
    ; there are all mapped $1000 bytes apart from each other. Until I solve that, I have to
    ; go the "slow" way. 
    ;
    ; Listen to that, it's the world's smallest fiddle, playing "my heart cries out for you."
    ; It's playing for me.
    ;
    ; VERA_ENABLE_ALL

    VERA_ENABLE_LAYER 0
    VERA_ENABLE_LAYER 1
    VERA_ENABLE_SPRITES
    SYS_SET_IRQ race_irq

race_irq:
    lda VERA_irq
    and #1 ; Check for vsync bit
    bne @do_irq
    jmp @irq_done

@do_irq:
    jsr KERNAL_GETJOY

    ; Update car position
    lda KERNAL_JOY1
    tax

    and #BUTTON_JOY_UP
    bne @button_up_end
    ADD_24 Car_pos_y, Car_pos_y, Car_move_speed_neg
@button_up_end:
    txa
    and #BUTTON_JOY_DOWN
    bne @button_down_end
    ADD_24 Car_pos_y, Car_pos_y, Car_move_speed
@button_down_end:
    txa
    and #BUTTON_JOY_LEFT
    bne @button_left_end
    ADD_24 Car_pos_x, Car_pos_x, Car_move_speed_neg
@button_left_end:
    txa
    and #BUTTON_JOY_RIGHT
    bne @button_right_end
    ADD_24 Car_pos_x, Car_pos_x, Car_move_speed
@button_right_end:

    ; Update tire positions
    ADD_24 Tire0_pos_x, Car_pos_x, Tire0_offset_x
    ADD_24 Tire0_pos_y, Car_pos_y, Tire0_offset_y

    ADD_24 Tire1_pos_x, Car_pos_x, Tire1_offset_x
    ADD_24 Tire1_pos_y, Car_pos_y, Tire1_offset_y

    ; Update the car and tires' sprite positions
    VERA_SET_SPRITE_POS_X 0, Tire0_pos_x+1
    VERA_SET_SPRITE_POS_X 1, Tire1_pos_x+1
    VERA_SET_SPRITE_POS_X 2, Car_pos_x+1

    VERA_SET_SPRITE_POS_Y 0, Tire0_pos_y+1
    VERA_SET_SPRITE_POS_Y 1, Tire1_pos_y+1
    VERA_SET_SPRITE_POS_Y 2, Car_pos_y+1

    ; Scroll the background layers
    ADD_24 Mountains_pos, Mountains_pos, Mountains_speed
    ADD_24 Forest_pos, Forest_pos, Forest_speed

    VERA_SET_LAYER_SCROLL_X 0, Mountains_pos+1
    VERA_SET_LAYER_SCROLL_X 1, Forest_pos+1

    ; Update the roads' positions based on their speed
    .repeat 13, i
    ADD_24 Road0_pos+(3*i), Road0_pos+(3*i), Roads_speed
    .endrep

    ; Wrap any roads that went offscreen
    .repeat 13, i
    WRAP_X_TO_SCREEN_24 Road0_pos+(3*i)
    .endrep

    ; Apply positions to the roads' sprites
    .repeat 13, i
    VERA_SET_SPRITE_POS_X (i+3), Road0_pos+(3*i)+1
    .endrep

    ; Update the wheel sprite to suggest spinning, using a bit to select between
    ; two sprite graphics
    ADD_16 Wheel_state, Wheel_state, Wheel_speed

    lda Wheel_state+1
    and #$01
    beq @set_wheel0

    VERA_SET_ADDR (VRAM_sprdata)
    lda #((WHEEL1_ADDR >> 5) & $FF)
    sta VERA_data
    lda #(WHEEL1_ADDR >> 13)
    sta VERA_data

    VERA_SET_ADDR (VRAM_sprdata + 8)
    lda #((WHEEL1_ADDR >> 5) & $FF)
    sta VERA_data
    lda #(WHEEL1_ADDR >> 13)
    sta VERA_data
    jmp @wheels_end

@set_wheel0:
    VERA_SET_ADDR (VRAM_sprdata)
    lda #((WHEEL0_ADDR >> 5) & $FF)
    sta VERA_data
    lda #(WHEEL0_ADDR >> 13)
    sta VERA_data

    VERA_SET_ADDR (VRAM_sprdata + 8)
    lda #((WHEEL0_ADDR >> 5) & $FF)
    sta VERA_data
    lda #(WHEEL0_ADDR >> 13)
    sta VERA_data

@wheels_end:
    dec Ticks_until_fade_in
    lda #0
    cmp Ticks_until_fade_in
    beq @credits_fade_in
    jmp @frame_done

@credits_fade_in:
    VERA_SET_ADDR (VRAM_palette6+5), 0
    lda VERA_data
    cmp font_courier_new_palette+5
    beq @frame_done
    clc
    adc #1
    sta VERA_data
    lda #$10
    sta Ticks_until_fade_in

@frame_done:
    VERA_END_IRQ
@irq_done:
    SYS_END_IRQ

;=================================================
;=================================================
; 
;   Variables
;
;-------------------------------------------------

Mountains_pos: .byte $00, $00, $00
Forest_pos: .byte $00, $00, $00

Mountains_speed: .word $0088
    .byte 0
Forest_speed: .word $0233
    .byte 0

Road0_pos: .byte $00, $00, $00
Road1_pos: .byte $00, $40, $00
Road2_pos: .byte $00, $80, $00
Road3_pos: .byte $00, $C0, $00
Road4_pos: .byte $00, $00, $01
Road5_pos: .byte $00, $40, $01
Road6_pos: .byte $00, $80, $01
Road7_pos: .byte $00, $C0, $01
Road8_pos: .byte $00, $00, $02
Road9_pos: .byte $00, $40, $02
RoadA_pos: .byte $00, $80, $02
Pillar0_pos: .byte $00, $80, $02
Pillar1_pos: .byte $00, $80, $02

Car_pos_x: .byte $00, $20, $01
Car_pos_y: .byte $00, $10, $01
Tire0_pos_x: .byte $00, $29, $01
Tire0_pos_y: .byte $00, $20, $01
Tire1_pos_x: .byte $00, $48, $01
Tire1_pos_y: .byte $00, $20, $01

Car_move_speed: .byte $00, $01, $00
Car_move_speed_neg: .byte $00, $FF, $FF

Car_bb_left: .byte $00, $00, $01
Car_bb_right: .byte $00, $40, $01
Car_bb_top: .byte $00, $00, $01
Car_bb_bottom: .byte $00, $20, $01

Tire0_offset_x: .byte $00, $09, $00
Tire0_offset_y: .byte $00, $10, $00
Tire1_offset_x: .byte $00, $28, $00
Tire1_offset_y: .byte $00, $10, $00

Wheel_state: .word $0000
Wheel_speed: .word $0030

Wrap_amount: .byte $00, $C0, $02   ; 704 pixels (640+64)
Screen_width: .byte $00, $80, $02   ; 640 pixels

Temp: .byte $00, $00, $00

Ticks_until_fade_in: .byte $ff

Roads_speed: .word $F776
    .byte $FF

Race_credits_palette_start:
	.word $0000, $00ff, $00ff

Race_mountains_map:
    .word $0000, $0000, $0000, $0001, $0002, $0000, $0000, $0000
    .word $0000, $0003, $0004, $0005, $0006, $0007, $0008, $0000
    .word $0009, $000a, $000b, $000c, $000d, $000e, $000f, $0010
    .word $0011, $0012, $0013, $0014, $0015, $0016, $0017, $0018
    .word $0019, $001a, $001b, $001c, $001d, $001e, $001f, $0020
    .word $0021, $0022, $0023, $0024, $0025, $0026, $0027, $0028
    .word $0029, $002a, $002b, $002c, $002d, $002e, $002f, $0030
    .word $0031, $0032, $0033, $0034, $0035, $0036, $0037, $0038

Race_forest_map:
    .repeat 8, yi
        .repeat 8, xi
            .word ($1000 | (yi*8 + xi + 1))
        .endrep
    .endrep

Race_forest_inner_map:
    .repeat 8, yi
        .repeat 8, xi
            .word ($1000 | (yi*8 + xi + 65))
        .endrep
    .endrep

.include "system.asm"
.endif ; RACE_ASM