.ifndef RACE_ASM
RACE_ASM=1

.include "vera.inc"
.include "system.inc"
.include "graphics.inc"

.include "assets/mountains.inc"
.include "assets/forest.inc"
.include "assets/car.inc"
.include "assets/road.inc"

RACE_MOUNTAINS_BG_ADDR=0
RACE_MOUNTAINS_BG_SIZE=128*64*2

RACE_FOREST_BG_ADDR=(RACE_MOUNTAINS_BG_ADDR + RACE_MOUNTAINS_BG_SIZE)
RACE_FOREST_BG_SIZE=128*64*2

RACE_MOUNTAINS_BG_TILES_ADDR=(RACE_FOREST_BG_ADDR + RACE_FOREST_BG_SIZE)
RACE_MOUNTAINS_BG_TILES_SIZE=(mountain_end - mountain)

RACE_FOREST_BG_TILES_ADDR=(RACE_MOUNTAINS_BG_TILES_ADDR + RACE_MOUNTAINS_BG_TILES_SIZE)
RACE_FOREST_BG_TILES_SIZE=(forest_end - forest)

RACE_CAR_ADDR=((RACE_FOREST_BG_TILES_ADDR + RACE_FOREST_BG_TILES_SIZE))
RACE_CAR_SIZE=(car_end - car)

ROAD_ADDR=((RACE_CAR_ADDR + RACE_CAR_SIZE))
ROAD_SIZE=(road_end - road)

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

    ; The mountains background tilemap
    VERA_SET_ADDR RACE_MOUNTAINS_BG_ADDR
    SYS_STREAM Race_mountains_map, VERA_data, (256*12)
    .repeat 8, i
        RACE_STREAM_ROW Race_mountains_map, i
    .endrep
    SYS_STREAM Race_mountains_map, VERA_data, 128*40*2
    
    ; The forest background tilemap
    VERA_SET_ADDR RACE_FOREST_BG_ADDR
    SYS_STREAM Race_mountains_map, VERA_data, 256*18
    .repeat 8, i
        RACE_STREAM_ROW Race_forest_map, i
    .endrep
    SYS_STREAM Race_mountains_map, VERA_data, 256*34

    ; Tile data
    VERA_STREAM_OUT mountain, RACE_MOUNTAINS_BG_TILES_ADDR, RACE_MOUNTAINS_BG_TILES_SIZE
    VERA_STREAM_OUT forest, RACE_FOREST_BG_TILES_ADDR, RACE_FOREST_BG_TILES_SIZE
    VERA_STREAM_OUT car, RACE_CAR_ADDR, RACE_CAR_SIZE
    VERA_STREAM_OUT road, ROAD_ADDR, ROAD_SIZE

    ; Palette data
    VERA_STREAM_OUT mountain_palette, VRAM_palette0, 16*2
    VERA_STREAM_OUT forest_palette, VRAM_palette1, 16*2
    VERA_STREAM_OUT car_palette, VRAM_palette2, 16*2
    VERA_STREAM_OUT road_palette, VRAM_palette3, 6*2

__race__setup_scene:
    VERA_CONFIGURE_TILE_LAYER 0, 1, 3, 0, 0, 2, 1, RACE_MOUNTAINS_BG_ADDR, RACE_MOUNTAINS_BG_TILES_ADDR
    VERA_CONFIGURE_TILE_LAYER 1, 1, 3, 0, 0, 2, 1, RACE_FOREST_BG_ADDR, RACE_FOREST_BG_TILES_ADDR

    VERA_SET_SPRITE 0
    VERA_CONFIGURE_SPRITE RACE_CAR_ADDR, 0, (320-32), (224), 0, 0, 1, 2, 3, 2

    .repeat 11, i
    VERA_CONFIGURE_SPRITE ROAD_ADDR, 0, (64 * i), (240-32), 0, 0, 1, 3, 3, 3
    .endrep

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
.macro ADD_24 dst, lhs, rhs
    clc
    .repeat 3, i
    lda lhs+i
    adc rhs+i
    sta dst+i
    .endrep
.endmacro

.macro VERA_SET_LAYER_SCROLL_X layer, src
.if layer = 0
    VERA_SET_ADDR (VRAM_layer1+6), 1
.else
    VERA_SET_ADDR (VRAM_layer2+6), 1
.endif
    lda src
    sta VERA_data
    lda src+1
    and #$0F
    sta VERA_data
.endmacro

.macro VERA_SET_LAYER_SCROLL_Y layer, src
.if layer = 0
    VERA_SET_ADDR (VRAM_layer1+8), 1
.else
    VERA_SET_ADDR (VRAM_layer2+8), 1
.endif
    lda src
    sta VERA_data
    lda src+1
    and #$0F
    sta VERA_data
.endmacro

.macro VERA_SET_SPRITE_POS_X sprite, src
    VERA_SET_ADDR (VRAM_sprdata + (8 * sprite) + 2), 1
    lda src
    sta VERA_data
    lda src+1
    and #$03
    sta VERA_data
.endmacro

.macro VERA_SET_SPRITE_POS_Y sprite, src
    VERA_SET_ADDR (VRAM_sprdata + (8 * sprite) + 4), 1
    lda src
    sta VERA_data
    lda src+1
    and #$03
    sta VERA_data
.endmacro

    ADD_24 Mountains_pos, Mountains_pos, Mountains_speed
    ADD_24 Forest_pos, Forest_pos, Forest_speed

    VERA_SET_LAYER_SCROLL_X 0, Mountains_pos+1
    VERA_SET_LAYER_SCROLL_X 1, Forest_pos+1

    .repeat 11, i
    ADD_24 Road0_pos+(3*i), Road0_pos+(3*i), Roads_speed
    .endrep

.macro WRAP_X_TO_SCREEN_24 pos
.local @offscreen
.local @onscreen

    ADD_24 Temp, pos, Wrap_amount

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

    .repeat 11, i
    WRAP_X_TO_SCREEN_24 Road0_pos+(3*i)
    .endrep

    .repeat 11, i
    VERA_SET_SPRITE_POS_X (i+1), Road0_pos+(3*i)+1
    .endrep

    VERA_END_IRQ
    SYS_END_IRQ

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

Wrap_amount: .byte $00, $C0, $02   ; 704 pixels (640+64)
Screen_width: .byte $00, $80, $02   ; 640 pixels

Temp: .byte $00, $00, $00

Roads_speed: .word $F776
    .byte $FF

; Roads_speed: .word $0000
;      .byte $00

HFLIP=(1 << 10)
VFLIP=(1 << 11)

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

.include "system.asm"
.endif ; RACE_ASM