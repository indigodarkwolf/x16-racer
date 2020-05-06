.ifndef YM2151_ASM
YM2151_ASM=1

.include "system.inc"
.include "ym2151.inc"

;=================================================
;=================================================
; 
;   Code
;
;-------------------------------------------------

;=================================================
; YM2151_STREAM_OUT
;   Synchronously stream out a block of data to the
;   YM2151, in "patch data" format:
;       .byte PORT_NUMBER
;       .byte VALUE
;-------------------------------------------------
; INPUTS:   ZP_COPY_SRC     Source address of patch data
;			ZP_COPY_SIZE    Low-byte of size to copy
;           X               Hi-byte of size to copy
;
;-------------------------------------------------
; MODIFIES: A,X,Y
; 
ym2151_stream_out_large:
    ldy #0
.byte_loop:
    lda (ZP_COPY_SRC),Y
    sta YM2151_addr
    iny
    lda (ZP_COPY_SRC),Y
    sta YM2151_data
    iny
    bne .byte_loop
    inc ZP_COPY_SRC+1
    dex
    bne .byte_loop
    ldx ZP_COPY_SIZE
    bne ym2151_stream_out_small
    rts
ym2151_stream_out_small:
    ldy #0
.byte_loop:
    lda (ZP_COPY_SRC),Y
    sta YM2151_addr
    iny
    lda (ZP_COPY_SRC),Y
    sta YM2151_data
    iny
    dex
    dex
    bne .byte_loop
    rts

.endif ; .ifndef YM2151_ASM