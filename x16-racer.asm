!symbollist "x16-racer.sym"

;=================================================
;=================================================
; 
;   Headers
;
;-------------------------------------------------

!src "vera.inc"
!src "system.inc"

;=================================================
; Macros
;
;-------------------------------------------------

DEFAULT_SCREEN_ADDR = 0
DEFAULT_SCREEN_SIZE = (128*64)*2

;=================================================
; MOD
;   Module the accumulator by a value.
;-------------------------------------------------
; INPUTS:   .v  Divisor of the modulo
;
;-------------------------------------------------
; MODIFIES: A
; 
!macro MOD .v {
-   sec
    sbc #.v
    bcs -
    adc #.v
}

    +SYS_HEADER_0801

;=================================================
;=================================================
; 
;   main code
;
;-------------------------------------------------
start:
    +SYS_RAND_SEED $34, $56, $fe

    jsr graphics_fade_out

    ;
    ; Palette memory should now be all 0s, or a black screen.
    ; If only the composer gave us a brightness setting, I could
    ; have used that. Mei banfa.
    ;

    +VERA_SELECT_ADDR 0

    +VERA_SET_ADDR VRAM_layer1
    +VERA_WRITE ($01 << 5) | $01            ; Mode 1 (256-color text), enabled
    +VERA_WRITE %00000110                   ; 8x8 tiles, 128x64 map
    +VERA_WRITE <(DEFAULT_SCREEN_ADDR >> 2) ; Map indices at VRAM address 0
    +VERA_WRITE >(DEFAULT_SCREEN_ADDR >> 2) ; 
    +VERA_WRITE <(VROM_petscii >> 2)        ; Tile data immediately after map indices
    +VERA_WRITE >(VROM_petscii >> 2)        ; Tile data immediately after map indices
    +VERA_WRITE 0, 0, 0, 0                  ; Hscroll and VScroll to 0

!zn __start__clear_video_memory {
__start__clear_video_memory:
    +VERA_SET_ADDR DEFAULT_SCREEN_ADDR, 2
    +VERA_SELECT_ADDR 1
    +VERA_SET_ADDR DEFAULT_SCREEN_ADDR+1, 2
    +VERA_SELECT_ADDR 0

    ldx #0
    ldy #0

.yloop:
    tya
    pha
.xloop:
    txa
    pha

    lda #0
    sta VERA_data
    sta VERA_data2

    pla
    tax
    dex
    bne .xloop

    pla
    tay
    dey
    bne .yloop
}

!zn __start__fill_text_buffer_with_random_chars {
__start__fill_text_buffer_with_random_chars:
    +VERA_SET_ADDR DEFAULT_SCREEN_ADDR, 2

    ldx #128
    ldy #64

.yloop:
    tya
    pha
.xloop:
    txa

    jsr sys_rand
    and #$7F
    tay

    lda Petscii_table,Y
    sta VERA_data

    tax
    dex
    bne .xloop

    pla
    tay
    dey
    bne .yloop
}

!zn __start__offset_palette_of_each_column {
__start__offset_palette_of_each_column:
    +VERA_SET_ADDR DEFAULT_SCREEN_ADDR+1, 2

    lda #128

.xloop:
    pha

    jsr sys_rand
    ; If we're about to assign palette index 0 (background), increment to 1
    cmp #0
    beq +
    clc
    adc #1
+   sta VERA_data

    pla
    sec
    sbc #1
    bne .xloop
}

!zn __start__fill_palette_of_remaining_chars {
__start__fill_palette_of_remaining_chars:
    +VERA_SET_ADDR DEFAULT_SCREEN_ADDR+1, 2
    +VERA_SELECT_ADDR 1
    +VERA_SET_ADDR DEFAULT_SCREEN_ADDR+257, 2
    +VERA_SELECT_ADDR 0

    ldx #127
    ldy #64

.yloop:
    tya
    pha
.xloop:
    txa
    pha

    lda VERA_data
    clc
    adc #1
    ; If we're about to assign palette index 0 (background), increment to 1
    cmp #0
    bne +
    clc
    adc #1
+   sta VERA_data2

    pla
    tax
    dex
    bne .xloop

    pla
    tay
    dey
    bne .yloop
}

    lda #<Matrix_palette
    sta $FB
    lda #>Matrix_palette
    sta $FC
    lda #((Matrix_palette_end - Matrix_palette) >> 1)
    sta $FD
    jsr graphics_fade_in

    +SYS_SET_IRQ irq_handler
    cli

    jmp *

    ; +VERA_RESET

;=================================================
;=================================================
; 
;   IRQ Handlers
;
;-------------------------------------------------

;=================================================
; irq_handler
;   This is essentially my "do_frame". Several others have been doing this as well.
;   Since the IRQ is triggered at the beginning of the VGA/NTSA front porch, we don't
;   get the benefit of the entire VBLANK, but it's still useful as a "do this code
;   once per frame" function.
;-------------------------------------------------
; INPUTS: (none)
;
;-------------------------------------------------
; MODIFIES: A, X, Y, VRAM_palette
; 
irq_handler:
    ; Increment which palette index we're starting at
    lda Palette_cycle_index
    clc
    adc #1
    ; Skip index zero, that's the background, we want to leave it black.
    adc #0
    sta Palette_cycle_index

;
; Palette cycle for the letters glowing and stuff
;

    ; Set the starting address of the VRAM palette we're going to cycle
    asl ; Palette_cycle_index * 2 == Address offset into palette memory
    ; adc #<(VRAM_palette) ; We happen to know that #<(VRAM_palette) is 0. Being able to skip this also preserves Carry in case it was set
    sta VERA_addr_low
    lda #<(VRAM_palette >> 8)
    adc #0  ; Add carry bit for indices 128-255
    sta VERA_addr_high
    lda #<(VRAM_palette >> 16) | (1 << 4)
    sta VERA_addr_bank

    lda #<Matrix_palette
    sta $FB
    lda #>Matrix_palette
    sta $FC

    ldx Palette_cycle_index
    ldy #0

-   lda ($FB),Y
    sta VERA_data
    iny
    lda ($FB),Y
    sta VERA_data
    iny
    inx
    bne +
    +VERA_SET_PALETTE 0, 1
+   cpy #(Matrix_palette_end - Matrix_palette)
    bne -

;
; Palette cycle (redux) for double-density!
;
    lda Palette_cycle_index
    adc #128
    clc

    ; Set the starting address of the VRAM palette we're going to cycle
    asl ; Palette_cycle_index * 2 == Address offset into palette memory
    ; adc #<(VRAM_palette) ; We happen to know that #<(VRAM_palette) is 0. Being able to skip this also preserves Carry in case it was set
    sta VERA_addr_low
    lda #<(VRAM_palette >> 8)
    adc #0  ; Add carry bit for indices 128-255
    sta VERA_addr_high
    lda #<(VRAM_palette >> 16) | (1 << 4)
    sta VERA_addr_bank

    lda #<Matrix_palette
    sta $FB
    lda #>Matrix_palette
    sta $FC

    lda Palette_cycle_index
    adc #128
    tax
    ldy #0

-   lda ($FB),Y
    sta VERA_data
    iny
    lda ($FB),Y
    sta VERA_data
    iny
    inx
    bne +
    +VERA_SET_PALETTE 0, 1
+   cpy #(Matrix_palette_end - Matrix_palette)
    bne -

    +SYS_END_IRQ

;=================================================
;=================================================
; 
;   Miscellaneous data copying
;
;-------------------------------------------------
;
; I wasn't sure what to do with this. I already have
; SYS_STREAM_OUT, but I basically needed it for 
; a source address and quantity of data that can
; only be determined at run-time. I'm I'll eventually
; convert this into some kind of other 
; SYS_STREAM_OUT-like macro, so that I can
; easily declare function definitions for a variety
; of fixed destinations, and then come back and do 
; the same for fixed sources with runtime destinations
; and of course a function to just handle everything
; being runtime data.
;

;==============================================
; VERA_stream_out_data
; Stream out a block of memory to VERA_data
;----------------------------------------------
; INPUT: X   - number of pages to stream
;        Y   - number of bytes to stream
;        $FB - low byte of starting address
;        $FC - high byte of starting address
;----------------------------------------------
; Modifies: A, X, Y, $FC
;
VERA_stream_out_data:
    tya
    pha
    ; If no pages to copy, skip to bytes
    txa
    cmp #0
    tax
    beq @no_blocks

    ; Copy X pages to VERA_data
    ldy #0
@loop:
    lda ($FB),Y
    sta VERA_data
    iny
    bne @loop

    inc $FC
    dex
    bne @loop

@no_blocks:
    ; Copy X bytes to VERA_data
    pla
    tax
    ldy #0
@loop2:
    lda ($FB),Y
    sta VERA_data
    iny
    dex
    bne @loop2
    rts

;=================================================
;=================================================
; 
;   Libs
;
;-------------------------------------------------
!src "system.asm"
!src "graphics.asm"

;=================================================
;=================================================
; 
;   Data
;
;-------------------------------------------------
Petscii_table:
    !for i,1,$60 {
        !byte i
    }
    !for i,0,$20 {
        !byte i+$A0
    }

Matrix_palette:
    !le16 $0000, $0000, $0020, $0020, $0030, $0030, $0040, $0040
    !le16 $0050, $0050, $0060, $0060, $0070, $0070, $0080, $0080
    !le16 $0090, $0090, $00A0, $00A0, $00B0, $00B0, $00C0, $00C0
    !le16 $00D0, $00D0, $00E0, $00E0, $00F0, $00F0, $08FC
Matrix_palette_end:
Matrix_palette_rev:
    !le16 $0000, $0000, $08FC, $00F0, $00F0, $00E0, $00E0, $00D0
    !le16 $00D0, $00C0, $00C0, $00B0, $00B0, $00A0, $00A0, $0090
    !le16 $0090, $0080, $0080, $0070, $0070, $0060, $0060, $0050
    !le16 $0050, $0040, $0040, $0030, $0030, $0020, $0020
Matrix_palette_rev_end:

;=================================================
;=================================================
;
;   Variables
;
;-------------------------------------------------
!src "x16-racer_vars.asm"
!src "graphics_vars.asm"
!src "system_vars.asm"

    +SYS_FOOTER