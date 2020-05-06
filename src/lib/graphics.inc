.ifndef GRAPHICS_INC
GRAPHICS_INC=1

;=================================================
; GRAPHICS_FADE_OUT
;   Fade out graphics to black
;-------------------------------------------------
; INPUTS:   (none)
;
;-------------------------------------------------
; MODIFIES: A, X, Y, $FB-$FF
; 
.macro GRAPHICS_FADE_OUT
    jsr graphics_fade_out
.endmacro

;=================================================
; GRAPHICS_FADE_IN
;   Fade in graphics to a set of palette colors
;-------------------------------------------------
; INPUTS:   palette_data   Final desired color data
;           first_color    First color index in the above
;           last_color     Last color index in the above
;
;-------------------------------------------------
; MODIFIES: A, X, Y, $FB-$FF
; 
.macro GRAPHICS_FADE_IN palette_data, first_color, last_color
    lda #<palette_data
    sta $FA
    lda #>palette_data
    sta $FB
    lda #first_color
    sta $FC
    lda #last_color
    sta $FD

    jsr graphics_fade_in
.endmacro

;=================================================
; GRAPHICS_STREAM_OUT_DATA
;   Stream out a block of data to a location in VRAM
;-------------------------------------------------
; INPUTS:   src	    Source data
;			dst	    Destination start location
;			size	Numbers of bytes to stream out (max 64KiB-1)
;
;-------------------------------------------------
; MODIFIES: A, X, Y, $FB, $FC
; 
.macro GRAPHICS_STREAM_OUT_DATA src, dst, size
    VERA_SET_ADDR dst
    ldy #<(size)
    ldx #>(size)
    lda #<src
    sta $FB
    lda #>src
    sta $FC
    jsr graphics_stream_out_data
.endmacro

;=================================================
; GRAPHICS_STREAM_OUT_RLE
;   Stream out a block of rle-deflated data to a location in VRAM
;-------------------------------------------------
; INPUTS:   src	Source data
;			dst	Destination start location
;			size	Numbers of bytes to stream out (max 64KiB - 1)
;
;-------------------------------------------------
; MODIFIES: A, X, Y, $FB, $FC
;
.macro GRAPHICS_STREAM_OUT_RLE src, dst, size
    VERA_SET_ADDR dst
    ldy #<(size)
    ldx #>(size)
    lda #<src
    sta $FB
    lda #>src
    sta $FC
    jsr graphics_stream_out_rle
.endmacro

.endif ; GRAPHICS_INC