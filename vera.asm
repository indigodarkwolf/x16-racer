; !ifdef VERA_ASM !eof
; VERA_ASM=1

;==============================================
; vera_stream_out_data
; Stream out a block of memory to VERA_data
;----------------------------------------------
; INPUT: X   - number of pages to stream
;        Y   - number of bytes to stream
;        $FB - low byte of starting address
;        $FC - high byte of starting address
;----------------------------------------------
; Modifies: A, X, Y, $FC
;
vera_stream_out_data:
    tya
    pha
    ; If no pages to copy, skip to bytes
    txa
    cmp #0
    tax
    beq .no_blocks

    ; Copy X pages to VERA_data
    ldy #0
.loop:
    lda ($FB),Y
    sta VERA_data
    iny
    bne .loop

    inc $FC
    dex
    bne .loop

.no_blocks:
    ; Copy X bytes to VERA_data
    pla
    tax
    ldy #0
.loop2:
    lda ($FB),Y
    sta VERA_data
    iny
    dex
    bne .loop2
    rts
