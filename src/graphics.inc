.ifndef GRAPHICS_INC
GRAPHICS_INC=1

.global Gfx_idle_flag

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
    lda #2
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

    lda #2
    jsr graphics_fade_in
.endmacro

;=================================================
; GRAPHICS_INCREMENT_PALETTE
;   Fade in graphics by one step to a set of palette colors
;-------------------------------------------------
; INPUTS:   palette_data   Final desired color data
;           first_color    First color index in the above
;           last_color     Last color index in the above
;
;-------------------------------------------------
; MODIFIES: A, X, Y, $FB-$FF
; 
.macro GRAPHICS_INCREMENT_PALETTE palette_data, first_color, last_color
    lda #<palette_data
    sta $FA
    lda #>palette_data
    sta $FB
    lda #first_color
    sta $FC
    lda #last_color
    sta $FD

    jsr graphics_increment_palette
.endmacro

;=================================================
; GRAPHICS_DeCREMENT_PALETTE
;   Fade out graphics by one step
;-------------------------------------------------
; INPUTS:   (None)
;
;-------------------------------------------------
; MODIFIES: A, X, Y
; 
.macro GRAPHICS_DECREMENT_PALETTE
    jsr graphics_decrement_palette
.endmacro

.endif ; GRAPHICS_INC