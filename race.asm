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

RACE_CAR_ADDR=SPRITE_ALIGN(RACE_FOREST_BG_TILES_ADDR + RACE_FOREST_BG_TILES_SIZE)
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
    SYS_STREAM Race_mountains_map, VERA_data, 128*12*2
    .repeat 8, i
        RACE_STREAM_ROW Race_mountains_map, i
    .endrep
    SYS_STREAM Race_mountains_map, VERA_data, 128*40*2
    
    ; VERA_STREAM_OUT Race_forest_map, RACE_FOREST_BG_ADDR, RACE_FOREST_BG_SIZE
    VERA_SET_ADDR RACE_FOREST_BG_ADDR
    SYS_STREAM Race_forest_map, VERA_data, 128*20
    .repeat 8, i
        RACE_STREAM_ROW Race_forest_map, i
    .endrep
    SYS_STREAM Race_forest_map, VERA_data, 128*32

    VERA_STREAM_OUT mountain, RACE_MOUNTAINS_BG_TILES_ADDR, RACE_MOUNTAINS_BG_TILES_SIZE
    VERA_STREAM_OUT forest, RACE_FOREST_BG_TILES_ADDR, RACE_FOREST_BG_TILES_SIZE
    VERA_STREAM_OUT car, RACE_CAR_ADDR, RACE_CAR_SIZE
    VERA_STREAM_OUT mountain_palette, VRAM_palette0, 16*2
    VERA_STREAM_OUT forest_palette, VRAM_palette1, 16*2
    VERA_STREAM_OUT car_palette, VRAM_palette2, 16*2

__race__setup_scene:
    VERA_CONFIGURE_TILE_LAYER 0, 0, 3, 0, 0, 2, 1, RACE_MOUNTAINS_BG_ADDR, RACE_MOUNTAINS_BG_TILES_ADDR
    VERA_CONFIGURE_TILE_LAYER 1, 0, 3, 0, 0, 2, 1, RACE_FOREST_BG_ADDR, RACE_FOREST_BG_TILES_ADDR

    VERA_SET_SPRITE 0
    VERA_CONFIGURE_SPRITE RACE_CAR_ADDR, 0, (320-32), (240-32), 0, 0, 1, 2, 3, 2
    VERA_SET_SPRITE 1
    VERA_CONFIGURE_SPRITE RACE_CAR_ADDR, 0, (320-64), (240-64), 0, 0, 1, 1, 3, 2
    VERA_SET_SPRITE 2
    VERA_CONFIGURE_SPRITE RACE_CAR_ADDR, 0, (320), (240-64), 0, 0, 1, 0, 3, 2

__race__begin:
    VERA_ENABLE_ALL

    lda #0
    jsr sys_wait_for_frame
    
    jmp *

__race__cleanup:
    VERA_DISABLE_SPRITES
    rts

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
            .word yi*8 + xi + 1
        .endrep
    .endrep

.include "system.asm"
.endif ; RACE_ASM