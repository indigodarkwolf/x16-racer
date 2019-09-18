; !ifdef RACE_ASM !eof
; RACE_ASM=1

!src "vera.inc"
!src "system.inc"
!src "graphics.inc"

!macro ALIGN ~.val, .bits { 
    !set .val=(((.val) + ((1 << .bits) - 1)) & ($FFFFFFFF - ((1 << .bits) - 1))) 
}


RACE_SKY_MOUNTAINS_BG_ADDR=0
RACE_SKY_MOUNTAINS_BG_SIZE=128*64*2

RACE_FOREST_BG_ADDR=(RACE_SKY_MOUNTAINS_BG_ADDR + RACE_SKY_MOUNTAINS_BG_SIZE)
RACE_FOREST_BG_SIZE=128*64*2

RACE_SKY_MOUNTAINS_BG_TILES_ADDR=(RACE_FOREST_BG_ADDR + RACE_FOREST_BG_SIZE)
RACE_SKY_MOUNTAINS_BG_TILES_SIZE=((4 * 8) * 4) ; 4 tiles

RACE_FOREST_BG_TILES_ADDR=(RACE_SKY_MOUNTAINS_BG_TILES_ADDR + RACE_SKY_MOUNTAINS_BG_TILES_SIZE)
RACE_FOREST_BG_TILES_SIZE=((4 * 8) * 2) ; 2 tiles

;RACE_CAR_ADDR=(((RACE_FOREST_BG_ADDR+RACE_FOREST_BG_SIZE) + ((1 << 9) - 1)) & ($FFFFFF - ((1 << 9) - 1)))
RACE_CAR_ADDR=(RACE_FOREST_BG_ADDR+RACE_FOREST_BG_SIZE)
+ALIGN ~RACE_CAR_ADDR, 9

RACE_CAR_SIZE=((32 * 64) * 0)

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
    ; Copy the logo into video memory
    +VERA_SELECT_ADDR 0

    +VERA_CONFIGURE_TILE_LAYER 0, 0, 3, 0, 0, 2, 1, RACE_SKY_MOUNTAINS_BG_ADDR, RACE_SKY_MOUNTAINS_BG_TILES_ADDR
    +VERA_CONFIGURE_TILE_LAYER 1, 0, 3, 0, 0, 2, 1, RACE_FOREST_BG_ADDR, RACE_FOREST_BG_TILES_ADDR

__race__setup_scene:
    +VERA_SET_SPRITE 0
    +VERA_CONFIGURE_SPRITE RACE_CAR_ADDR, 1, (320-16), (240-16), 0, 0, 1, 0, 2, 2

__race__begin:
    +VERA_ENABLE_LAYER 0
    +VERA_ENABLE_LAYER 1
    +VERA_ENABLE_SPRITES
__race__cleanup:
    +VERA_DISABLE_SPRITES
    rts

Race_mountains_palette:
    !le16 $0000, $0888, $088E, $0DDD, $0EEE, $0FFF
Race_palette_end:
Race_forest_palette:
    !le16 $0000, $0888, $088E, $0DDD, $0EEE, $0FFF
Race_forest_palette_end:

Race_tiles:
Race_mountains_tiles:
Race_mountains_blank_tile:
    !byte $00, $00, $00, $00
    !byte $00, $00, $00, $00
    !byte $00, $00, $00, $00
    !byte $00, $00, $00, $00
    !byte $00, $00, $00, $00
    !byte $00, $00, $00, $00
    !byte $00, $00, $00, $00
    !byte $00, $00, $00, $00

Race_mountains_tile_sky:
    !byte $22, $22, $22, $22
    !byte $22, $22, $22, $22
    !byte $22, $22, $22, $22
    !byte $22, $22, $22, $22
    !byte $22, $22, $22, $22
    !byte $22, $22, $22, $22
    !byte $22, $22, $22, $22
    !byte $22, $22, $22, $22

Race_mountains_tile_sky_cloud:
    !byte $22, $22, $22, $22
    !byte $22, $22, $44, $42
    !byte $22, $44, $44, $44
    !byte $24, $44, $44, $44
    !byte $44, $44, $44, $44
    !byte $44, $44, $44, $44
    !byte $24, $44, $44, $44
    !byte $22, $24, $44, $24

Race_mountains_tile_mountain:
    !byte $22, $22, $22, $22
    !byte $22, $22, $22, $21
    !byte $22, $22, $22, $11
    !byte $22, $22, $21, $11
    !byte $22, $22, $11, $11
    !byte $22, $21, $11, $11
    !byte $22, $11, $11, $11
    !byte $21, $11, $11, $11
Race_mountains_tiles_end:

Race_forest_tiles:
Race_forest_blank_tile:
    !byte $00, $00, $00, $00
    !byte $00, $00, $00, $00
    !byte $00, $00, $00, $00
    !byte $00, $00, $00, $00
    !byte $00, $00, $00, $00
    !byte $00, $00, $00, $00
    !byte $00, $00, $00, $00
    !byte $00, $00, $00, $00

Race_forest_tile_top:
    !byte $44, $44, $44, $44
    !byte $44, $44, $44, $44
    !byte $44, $44, $44, $44
    !byte $44, $44, $44, $44
    !byte $44, $44, $44, $44
    !byte $44, $44, $44, $44
    !byte $44, $44, $44, $44
    !byte $44, $44, $44, $44
Race_forest_tiles_end:

Race_car:
Race_car_end:

Race_mountains_map: ; In column-major order
!for i, 1, 80 {
    !le16 $0001, $0001, $0001, $0001, $0001, $0001, $0001, $0001, $0001, $0001, $0001, $0001, $0001, $0001, $0001, $0001, $0001, $0001, $0001, $0001, $0003, $0003, $0003, $0003, $0003, $0003, $0003, $0003, $0003, $0003, $0003, $0003, $0003, $0003, $0003, $0003, $0003, $0003, $0003, $0003, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
}
Race_mountains_map_end:
Race_forest_map:
!for i, 1, 80 {
    !le16 $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0001, $0001, $0001, $0001, $0001, $0001, $0001, $0001, $0001, $0001, $0001, $0001, $0001, $0001, $0001, $0001, $0001, $0001, $0001, $0001
}
Race_forest_map_end:

; !src "system.asm"