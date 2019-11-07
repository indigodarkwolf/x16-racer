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

.endif ; .ifndef YM2151_INC