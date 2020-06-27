.ifndef YM2151_INC
YM2151_INC=1

;=================================================
;=================================================
;
;   Memory-mapped registers
;
;-------------------------------------------------

YM2151_base = $9FE0

YM2151_addr = YM2151_base + 0
YM2151_data = YM2151_base + 1

YM2151_key_control = $08
YM2151_noise = $0F
YM2151_master_config = $20
YM2151_freq = $28
YM2151_key_fraction = $30
YM2151_modulation_sensitivity = $38


;=================================================
;=================================================
;
;   Macros
;
;-------------------------------------------------

;=================================================
; YM2151_WRITE
;   Write a value to the YM2151
;-------------------------------------------------
; INPUTS:   register    Which register to write to
;			value       Value to write to the register
;
;-------------------------------------------------
; MODIFIES: A
; 
.macro YM2151_WRITE register, value
	lda #register
	sta YM2151_addr
    lda #value
    sta YM2151_data
.endmacro

;=================================================
; YM2151_STREAM_OUT_PATCH_DATA
;   Select which address channel to configure (VERA_data vs. VERA_data2)
;-------------------------------------------------
; INPUTS:   addr	start address of patch data
;			len		length of patch data in bytes
;
;-------------------------------------------------
; MODIFIES: A
; 
.macro YM2151_STREAM_OUT_PATCH_DATA addr, len
.local @loop
    ldy #0
@loop:
    lda addr,y
    sta YM2151_addr
    iny
	lda addr,y
	sta YM2151_data
    iny
    cpy #len
    bne @loop
.endmacro

;=================================================
; YM2151_PLAY_NOTE
;   Select which address channel to configure (VERA_data vs. VERA_data2)
;-------------------------------------------------
; INPUTS:   voice	which voice (0-7)
;			note	which note
;
;-------------------------------------------------
; MODIFIES: A
; 
.macro YM2151_PLAY_NOTE voice, note
    lda #(YM2151_voice0_freq+voice)
    sta YM2151_addr
	lda #note & $7F
	sta YM2151_data
    iny
    cpy #len
    bne @loop
.endmacro




.endif ; .ifndef YM2151_INC