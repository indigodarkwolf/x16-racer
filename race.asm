.ifndef RACE_ASM
RACE_ASM=1

.include "vera.inc"
.include "system.inc"
.include "graphics.inc"

.include "assets/mountains.inc"
.include "assets/forest.inc"
.include "assets/car.inc"

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
    ; Copy data into video memory
    VERA_SELECT_ADDR 0

    ; VERA_STREAM_OUT Race_mountains_map, RACE_MOUNTAINS_BG_ADDR, RACE_MOUNTAINS_BG_SIZE
    VERA_SET_ADDR RACE_MOUNTAINS_BG_ADDR
    SYS_STREAM Race_mountains_map, VERA_data, (256*12)
    .repeat 8, i
        RACE_STREAM_ROW Race_mountains_map, i
    .endrep
    SYS_STREAM Race_mountains_map, VERA_data, 128*40*2
    
    ; VERA_STREAM_OUT Race_forest_map, RACE_FOREST_BG_ADDR, RACE_FOREST_BG_SIZE
    VERA_SET_ADDR RACE_FOREST_BG_ADDR
    SYS_STREAM Race_mountains_map, VERA_data, 256*18
    .repeat 8, i
        RACE_STREAM_ROW Race_forest_map, i
    .endrep
    SYS_STREAM Race_mountains_map, VERA_data, 256*34

    VERA_STREAM_OUT mountain, RACE_MOUNTAINS_BG_TILES_ADDR, RACE_MOUNTAINS_BG_TILES_SIZE
    VERA_STREAM_OUT forest, RACE_FOREST_BG_TILES_ADDR, RACE_FOREST_BG_TILES_SIZE

    VERA_SET_ADDR RACE_CAR_ADDR
    VERA_STREAM_OUT car, RACE_CAR_ADDR, RACE_CAR_SIZE

    VERA_STREAM_OUT mountain_palette, VRAM_palette0, 16*2
    VERA_STREAM_OUT forest_palette, VRAM_palette1, 16*2
    VERA_STREAM_OUT car_palette, VRAM_palette2, 16*2

__race__setup_scene:
    VERA_CONFIGURE_TILE_LAYER 0, 1, 3, 0, 0, 2, 1, RACE_MOUNTAINS_BG_ADDR, RACE_MOUNTAINS_BG_TILES_ADDR
    VERA_CONFIGURE_TILE_LAYER 1, 1, 3, 0, 0, 2, 1, RACE_FOREST_BG_ADDR, RACE_FOREST_BG_TILES_ADDR

    VERA_SET_SPRITE 0
    VERA_CONFIGURE_SPRITE RACE_CAR_ADDR, 0, (320-32), (240-32), 0, 0, 1, 2, 3, 2
    VERA_SET_SPRITE 1
    VERA_CONFIGURE_SPRITE RACE_CAR_ADDR, 0, (320-64), (240-64), 0, 0, 1, 1, 3, 2
    VERA_SET_SPRITE 2
    VERA_CONFIGURE_SPRITE RACE_CAR_ADDR, 0, (320), (240-64), 0, 0, 1, 0, 3, 2

__race__begin:
    ; VERA_ENABLE_SPRITES
    ; VERA_ENABLE_LAYER 0
    ; VERA_ENABLE_LAYER 1

    ; VERA_ENABLE_ALL

    ; lda #1
    ; jsr sys_wait_for_frame

    SYS_SET_IRQ race_irq
    cli

    jmp *

__race__cleanup:
    VERA_DISABLE_SPRITES
    rts

race_irq:
    clc
    lda Mountains_pos
    adc Mountains_speed
    sta Mountains_pos
    lda Mountains_pos+1
    adc Mountains_speed+1
    sta Mountains_pos+1

    clc
    lda Forest_pos
    adc Forest_speed
    sta Forest_pos
    lda Forest_pos+1
    adc Forest_speed+1
    sta Forest_pos+1

    VERA_SET_ADDR (VRAM_layer1+6), 1
    lda Mountains_pos
    and #$F0
    lsr
    lsr
    lsr
    lsr
    sta Swap
    lda Mountains_pos+1
    and #$0F
    asl
    asl
    asl
    asl
    adc Swap
    sta VERA_data

    lda Mountains_pos+1
    and #$F0
    asl
    asl
    asl
    asl
    sta VERA_data

    VERA_SET_ADDR (VRAM_layer2+6), 1
    lda Forest_pos
    and #$F0
    lsr
    lsr
    lsr
    lsr
    sta Swap
    lda Forest_pos+1
    and #$0F
    asl
    asl
    asl
    asl
    adc Swap
    sta VERA_data

    lda Forest_pos+1
    and #$F0
    asl
    asl
    asl
    asl
    sta VERA_data

    VERA_END_IRQ
    SYS_END_IRQ

Mountains_pos: .word $0000
Forest_pos: .word $0000

Mountains_speed: .word $0008
Forest_speed: .word $0023

Swap: .byte $00

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