.ifndef GRAPHICS_INC
GRAPHICS_INC=1

.globalzp Gfx_idle_flag
.globalzp Gfx_palette_ptr
.globalzp Gfx_palette_start
.globalzp Gfx_palette_end

.global graphics_init
.global graphics_decrement_palette
.global graphics_increment_palette
.global graphics_apply_palette
.global graphics_fade_out
.global graphics_fade_in
.global graphics_apply_sprites
.global graphics_do_frame


GRAPHICS_TABLES_BANK = $02

PALETTE_PTR = $FA

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
    sta Gfx_palette_ptr
    lda #>palette_data
    sta Gfx_palette_ptr+1
    lda #first_color
    sta Gfx_palette_start
    lda #last_color
    sta Gfx_palette_end

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
    sta Gfx_palette_ptr
    lda #>palette_data
    sta Gfx_palette_ptr+1
    lda #first_color
    sta Gfx_palette_start
    lda #last_color
    sta Gfx_palette_end

    jsr graphics_increment_palette
.endmacro

;=================================================
; GRAPHICS_DECREMENT_PALETTE
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