
.ifndef VERA_INC
VERA_INC=1

.include "system.inc"

;=================================================
;=================================================
;
;   Memory-mapped registers
;
;-------------------------------------------------

.ifdef MACHINE_C64
	VERA_base = $df00
.else
	VERA_base = $9f20
.endif

VERA_addr_low   = VERA_base+0
VERA_addr_high  = VERA_base+1
VERA_addr_bank  = VERA_base+2
VERA_data       = VERA_base+3
VERA_data2      = VERA_base+4
VERA_ctrl       = VERA_base+5
VERA_irq_ctrl   = VERA_base+6
VERA_irq        = VERA_base+7

VRAM_composer  = $F0000
VRAM_palette   = $F1000
VRAM_layer1    = $F2000
VRAM_layer2    = $F3000
VRAM_sprinfo   = $F4000
VRAM_sprdata   = $F5800

VRAM_palette0  = $F1000 + (2*16)*0
VRAM_palette1  = $F1000 + (2*16)*1
VRAM_palette2  = $F1000 + (2*16)*2
VRAM_palette3  = $F1000 + (2*16)*3
VRAM_palette4  = $F1000 + (2*16)*4
VRAM_palette5  = $F1000 + (2*16)*5
VRAM_palette6  = $F1000 + (2*16)*6
VRAM_palette7  = $F1000 + (2*16)*7
VRAM_palette8  = $F1000 + (2*16)*8
VRAM_palette9  = $F1000 + (2*16)*9
VRAM_palette10 = $F1000 + (2*16)*10
VRAM_palette11 = $F1000 + (2*16)*11
VRAM_palette12 = $F1000 + (2*16)*12
VRAM_palette13 = $F1000 + (2*16)*13
VRAM_palette14 = $F1000 + (2*16)*14
VRAM_palette15 = $F1000 + (2*16)*15

VROM_petscii   = $1F000

;=================================================
;=================================================
;
;   Macros
;
;-------------------------------------------------

;=================================================
; VERA_SELECT_ADDR
;   Select which address channel to configure (VERA_data vs. VERA_data2)
;-------------------------------------------------
; INPUTS:   addr	0 for VERA_data
;					1 for VERA_data2
;
;-------------------------------------------------
; MODIFIES: A
; 
.macro VERA_SELECT_ADDR addr
	lda #addr
	sta VERA_ctrl
.endmacro

;=================================================
; VERA_SET_ADDR (multiple)
;   Set the current address channel's address
;-------------------------------------------------
; INPUTS:   addr			VRAM address to set to
;			[stride = 1]	Address stride/auto-increment
;
;-------------------------------------------------
; MODIFIES: A
; 
.macro VERA_SET_ADDR addr, stride
	.ifnblank stride
		lda #((^addr) | (stride << 4))
	.else
		lda #(^addr) | $10
	.endif

	sta VERA_addr_bank
	lda #(>addr)
	sta VERA_addr_high
	lda #(<addr)
	sta VERA_addr_low
.endmacro

;=================================================
; VERA_WRITE (multiple)
;   Write values to VERA_data.
;	If more than 8 values are needed, consider 
;	the SYS_STREAM_* family.
;-------------------------------------------------
; INPUTS:   v0 - v7	Values to write
;
;-------------------------------------------------
; MODIFIES: A
; 
.macro VERA_WRITE v0, v1, v2, v3, v4, v5, v6, v7
	.ifblank v0
		.exitmacro
	.else
		lda #v0
		sta VERA_data
	.endif

	.if .paramcount > 1
		VERA_WRITE v1, v2, v3, v4, v5, v6, v7
	.endif
.endmacro

;=================================================
; VPEEK
;   It's... VPEEK(), but in assembly.
;-------------------------------------------------
; INPUTS:   addr	VRAM address to read from.
;
;-------------------------------------------------
; MODIFIES: A
; 
.macro VPEEK addr
	VERA_SET_ADDR addr
	lda VERA_data
.endmacro

;=================================================
; VERA_ENABLE_LAYER
;   Enable the specified layer
;-------------------------------------------------
; INPUTS:   layer	Which layer to enable
;
;-------------------------------------------------
; MODIFIES: A
; 
.macro VERA_ENABLE_LAYER layer
	VERA_SET_ADDR (VRAM_layer1 + (layer << 4)), 0
	lda VERA_data
	ora #$01
	sta VERA_data
.endmacro

;=================================================
; VERA_DISABLE_LAYER
;   Disable the specified layer
;-------------------------------------------------
; INPUTS:   layer	Which layer to enable
;
;-------------------------------------------------
; MODIFIES: A
; 
.macro VERA_DISABLE_LAYER layer
	VERA_SET_ADDR (VRAM_layer1 + (layer << 4)), 0
	lda VERA_data
	and #$FE
	sta VERA_data
.endmacro

;=================================================
; VERA_CONFIGURE_TILE_LAYER
;   Apply the given params to a layer.
;-------------------------------------------------
; INPUTS:   layer			Layer (0|1)
;			enable			0: disable layer
;							1: enable layer
;			mode			0: text 1bpp, 16 color f/g
;							1: text 1bpp, 256 color f
;							2: tile 2bpp
;							3: tile 4bpp
;							4: tile 8bpp
;			w16_tiles		(0|1) enable 16-width tiles?
;			h16_tiles		(0|1) enable 16-height tiles?
;			mapw, maph		0: 32 tiles/chars
;							1: 64 tiles/chars
;							2: 128 tiles/chars
;							3: 256 tiles/chars
;			map_base		Start address of map indices (4-byte align)
;			tile_base		Start address of tile indices (4-byte align)
;
;-------------------------------------------------
; MODIFIES: A
; 
.macro VERA_CONFIGURE_TILE_LAYER layer, enable, mode, w16_tiles, h16_tiles, mapw, maph, map_base, tile_base
	VERA_SET_ADDR (VRAM_layer1 + (layer << 4)), 1

	; Mode
	lda #((mode << 5) | enable)
	sta VERA_data

	; Tile and map size
	lda #((h16_tiles << 5) | (w16_tiles << 4) | (maph << 2) | (mapw))
	sta VERA_data

.if (map_base & $FFFFFC) <> map_base
	.error "Map data does not obey alignment rules"
.endif

.if (tile_base & $FFFFFC) <> tile_base
	.error "Tile data does not obey alignment rules"
.endif

	; Map base
	lda #<(map_base >> 2)
	sta VERA_data
	lda #>(map_base >> 2)
	sta VERA_data

	; Tile base
	lda #<(tile_base >> 2)
	sta VERA_data
	lda #>(tile_base >> 2)
	sta VERA_data
.endmacro

;=================================================
; VERA_CONFIGURE_BMP_LAYER
;   Apply the given params to a layer.
;-------------------------------------------------
; INPUTS:   layer			Layer (0|1)
;			mode			5: bitmap 2bpp
;							6: bitmap 4bpp
;							7: bitmap 8bpp
;			h640			(0|1) enable 640p height?
;			palette_offset	Which 16-color palette should it use?
;
;-------------------------------------------------
; MODIFIES: A
; 
.macro VERA_CONFIGURE_BMP_LAYER layer, mode, h640, palette_offset
	VERA_SET_ADDR (VRAM_layer1 + (layer << 4)), 1

	; Mode
	lda #((mode << 5) | 1)
	sta VERA_data

	; Tile and map size
	lda #(h640 << 8)
	sta VERA_data

	; Palette offset
	lda #((layer << 4) | 7)
	sta VERA_addr_low

	lda #((palette_offset) >> 4)
	sta VERA_data
.endmacro

;=================================================
; VERA_ENABLE_SPRITES
;   Enables sprites layer
;-------------------------------------------------
; INPUTS:   (none)
;
;-------------------------------------------------
; MODIFIES: A
; 
.macro VERA_ENABLE_SPRITES
    VERA_SET_ADDR VRAM_sprinfo
    lda #1
    sta VERA_data
.endmacro

;=================================================
; VERA_DISABLE_SPRITES
;   Disables sprites layer
;-------------------------------------------------
; INPUTS:   (none)
;
;-------------------------------------------------
; MODIFIES: A
; 
.macro VERA_DISABLE_SPRITES
    VERA_SET_ADDR VRAM_sprinfo
    lda #0
    sta VERA_data
.endmacro

;=================================================
; VERA_SET_SPRITE
;   Set the current address channel to target
;	an indexed sprite_data entry in VRAM_sprdata
;-------------------------------------------------
; INPUTS:   sprite_index	Sprite index to target
;
;-------------------------------------------------
; MODIFIES: A
; 
.macro VERA_SET_SPRITE sprite_index
	VERA_SET_ADDR (VRAM_sprdata + (sprite_index << 3))
.endmacro

;=================================================
; VERA_CONFIGURE_SPRITE
;   Configure sprite data at the current sprite
;-------------------------------------------------
; INPUTS:   data_addr	Location in VRAM where sprite data exists
;			colors			0: 4bpp
;							1: 8bpp
;			xpos			X-position
;			ypos			Y-position
;			hflip			toggle horizontal flip
;			vflip			toggle verticle flip
;			zdepth			Z-depth of sprite
;			palette_index	16-color-palette index selection
;			width, height	0: 8px
;							1: 16px
;							2: 32px
;							3: 64px
;
;-------------------------------------------------
; MODIFIES: A
; 
.macro VERA_CONFIGURE_SPRITE data_addr, colors, xpos, ypos, hflip, vflip, zdepth, palette_index, width, height
.local DATA_ADDR
DATA_ADDR=(data_addr >> 5)

.if ((DATA_ADDR << 5) <> data_addr)
	.error "Sprite data does not obey alignment rules"
.endif

	VERA_WRITE <DATA_ADDR, >(DATA_ADDR | (colors << 7))
	VERA_WRITE <(xpos & $0FF), >(xpos & $300), <(ypos & $0FF), >(ypos & $300)
	VERA_WRITE	((hflip) | (vflip << 1) | (zdepth << 2))
	VERA_WRITE ((palette_index & $0F) | (width << 4) | (height << 6))
.endmacro

;=================================================
; VERA_SET_PALETTE
;   Set the current address channel to target
;	an indexed palette  entry in VRAM_palette
;-------------------------------------------------
; INPUTS:   palette_index		Palette index to target
;			[.color_offset = 0]	Which color within the palette to target
;
;-------------------------------------------------
; MODIFIES: A
; 
.macro VERA_SET_PALETTE palette_index, color_offset
	.ifblank color_offset
		VERA_SET_ADDR (VRAM_palette + (palette_index << 5))
	.else
		VERA_SET_ADDR (VRAM_palette + (palette_index << 5) + (color_offset << 1))
	.endif
.endmacro

;=================================================
; VERA_STREAM_OUT
;   Stream out a block of data to a location in VRAM
;-------------------------------------------------
; INPUTS:   src	Source data
;			dst	Destination start location
;			size	Numbers of bytes to stream out (max 64KiB)
;
;-------------------------------------------------
; MODIFIES: A, X, Y, $FB, $FC
; 
.macro VERA_STREAM_OUT src, dst, size
    VERA_SET_ADDR dst
    ldy #<(size)
    ldx #>(size)
    lda #<src
    sta $FB
    lda #>src
    sta $FC
    jsr vera_stream_out_data
.endmacro

;=================================================
; VERA_ENABLE_ALL
;   Enables all layers and global sprites
;-------------------------------------------------
; INPUTS:   (none)
;
;-------------------------------------------------
; MODIFIES: A
; 
.macro VERA_ENABLE_ALL
    VERA_SET_ADDR VRAM_layer1, 13
	VERA_SELECT_ADDR 1
    VERA_SET_ADDR VRAM_layer1, 13

	; Layer 0
    lda VERA_data
    ora #$01
	sta VERA_data2

	; Layer 1
    lda VERA_data
    ora #$01
	sta VERA_data2

	;Sprites
    lda VERA_data
    ora #$01
	sta VERA_data2
.endmacro

;=================================================
; VERA_DISABLE_ALL
;   Enables all layers and global sprites
;-------------------------------------------------
; INPUTS:   (none)
;
;-------------------------------------------------
; MODIFIES: A
; 
.macro VERA_DISABLE_ALL
    VERA_SET_ADDR VRAM_layer1, 13
	VERA_SELECT_ADDR 1
    VERA_SET_ADDR VRAM_layer1, 13

	; Layer 0
    lda VERA_data
    and #$FE
	sta VERA_data2

	; Layer 1
    lda VERA_data
    and #$FE
	sta VERA_data2

	;Sprites
    lda VERA_data
    and #$FE
	sta VERA_data2
.endmacro


;=================================================
; VERA_RESET
;   Reset the Vera to its default settings.
;	See official documentation for specifics.
;-------------------------------------------------
; INPUTS:   (none)
;
;-------------------------------------------------
; MODIFIES: A
; 
.macro VERA_RESET
	lda #$80
	sta VERA_ctrl
.endmacro

;=================================================
; VERA_END_IRQ
;   Reset the Vera IRQ flag so that it generates interrupts.
;-------------------------------------------------
; INPUTS:   (none)
;
;-------------------------------------------------
; MODIFIES: A
; 
.macro VERA_END_IRQ
	lda #$1
	sta VERA_irq
.endmacro

;=================================================
; VIDEO_INIT
;   Turn on the video display.
;-------------------------------------------------
; INPUTS:   (none)
;
;-------------------------------------------------
; MODIFIES: A
; 
.macro VIDEO_INIT
	VERA_SELECT_ADDR 0
	VERA_SET_ADDR VRAM_composer, 1
	lda #1
	sta VERA_data ; VGA output
.endmacro

.endif ; VERA_INC
