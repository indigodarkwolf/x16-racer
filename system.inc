.ifndef SYSTEM_INC
SYSTEM_INC=1

KERNAL_GETJOY = $FF06
KERNAL_MOUSE = $FF09

KERNAL_JOY1 = $02BC
KERNAL_JOY2 = $02BF

BUTTON_JOY_UP    = (1 << 3)
BUTTON_JOY_DOWN  = (1 << 2)
BUTTON_JOY_LEFT  = (1 << 1)
BUTTON_JOY_RIGHT = (1 << 0)

ZP_COPY_SRC = $7E
ZP_COPY_DST = $7C
ZP_COPY_SIZE = $7A

;=================================================
; SYS_HEADER_0801
;   File header of a PRG loaded at $0801. Includes
;   encoded BASIC commands to start execution
;   without needing a SYS() command.
;-------------------------------------------------
; INPUTS:   (none)
;
;-------------------------------------------------
; MODIFIES: (none)
; 
.macro SYS_HEADER_0801
    .ifdef HEADER_A000_IN_USE
        .warning "SYS_HEADER_A000 already in use. This second call may not do what you think, and may break file size detection."
    .endif

    HEADER_0801_IN_USE=1

;    .org $0801
;    .byte $0b,$08,$01,$00,$9e,$32,$30,$36,$31,$00,$00,$00

    .org $080D

    .segment "STARTUP"
    .segment "INIT"
    .segment "ONCE"
    .segment "CODE"
.endmacro

;=================================================
; SYS_HEADER_A000
;   File header for a file loaded into $0A00. This
;   may include executable code and/or data, but
;   needs to be loaded in separate from the main
;   .PRG because of the address it needs to occupy.
;-------------------------------------------------
; INPUTS:   (none)
;
;-------------------------------------------------
; MODIFIES: (none)
; 
.macro SYS_HEADER_A000
    .ifdef HEADER_0801_IN_USE
        .warning "SYS_HEADER_0801 already in use. This second call may not do what you think, and may break file size detection."
    .endif

    HEADER_A000_IN_USE=1

    .org $0A00

    .segment "STARTUP"
    .segment "INIT"
    .segment "ONCE"
    .segment "CODE"
.endmacro

;=================================================
; SYS_FOOTER
;   File footer for any file. This provides a warning
;   in case the file has exceeded the bounds of
;   the memory into which it is intended to be loaded.
;-------------------------------------------------
; INPUTS:   (none)
;
;-------------------------------------------------
; MODIFIES: (none)
; 
.macro SYS_FOOTER
    .ifndef HEADER_0801_IN_USE
        .ifndef HEADER_A000_IN_USE
            .warning "SYS_HEADER_* macro in use. Add SYS_HEADER_0801 or SYS_HEADER_A000, depending on where you expect to load this file."
        .endif
    .endif

    .ifdef HEADER_0801_IN_USE
        .if * > $9EFF
            .warning "Program size exceeds Fixed RAM space."
        .endif
    .endif

    .ifdef HEADER_A000_IN_USE {
        .if * > $BFFF {
            .warning "Program size exceeds Fixed RAM space."
        .endif
    .endif
.endmacro

;=================================================
;=================================================
; 
;   IRQ Handling
;
;-------------------------------------------------

;=================================================
; SYS_INIT_IRQ
;   Init the system IRQ variables. These keep a copy
;   of the original kernel IRQ vector so that we can
;   invoke it after doing our own interrupt work. This
;   is necessary for various kernel functions like
;   GETJOY.
;-------------------------------------------------
; INPUTS:   .address    Label or address of IRQ handler
;
;-------------------------------------------------
; MODIFIES: A
; 
.macro SYS_INIT_IRQ
    lda $0314
    sta Sys_irq_redirect
    lda $0315
    sta Sys_irq_redirect+1
.endmacro

;=================================================
; SYS_SET_IRQ
;   Set where the kernal should jump to after
;   its own interrupt handling.
;-------------------------------------------------
; INPUTS:   .address    Label or address of IRQ handler
;
;-------------------------------------------------
; MODIFIES: A
; 
.macro SYS_SET_IRQ address
    lda #<address
    sta $0314
    lda #>address
    sta $0315
.endmacro

;=================================================
; SYS_END_IRQ
;   Restore registers and return control to 
;   interrupted process.
;-------------------------------------------------
; INPUTS:   (none)
;
;-------------------------------------------------
; MODIFIES: A, X, Y
; 
.macro SYS_END_IRQ
    jmp (Sys_irq_redirect)
    ; pla
    ; tay
    ; pla
    ; tax
    ; pla
    ; rti
.endmacro

;=================================================
;=================================================
; 
;   Random number generation
;
;-------------------------------------------------

;=================================================
; SYS_RAND_SEED
;   Seed the PRNG implementation with the selected
;   values.
;-------------------------------------------------
; INPUTS:   (none)
;
;-------------------------------------------------
; MODIFIES: A
; 
.macro SYS_RAND_SEED v0, v1, v2
    lda #v0
    sta Sys_rand_mem
    lda #v1
    sta Sys_rand_mem+1
    lda #v2
    sta Sys_rand_mem+2
.endmacro

;=================================================
;=================================================
; 
;   Copy macros
;
;-------------------------------------------------

;=================================================
; SYS_COPY
;   Generic "copy a block of data from A to B" macro
;-------------------------------------------------
; INPUTS:   src    Source address
;           dst    Destination address
;           size   Number of bytes to copy
;
;-------------------------------------------------
; MODIFIES: A, X, Y, $FB-$FF
; 
.macro SYS_COPY src, dst, size
.local @loop
.local @loop2
    lda #<src ;src to $FC $FB 
    sta $FB
    lda #>src
    sta $FC
    lda #<dst ;dst to $FE $FD
    sta $FD
    lda #>dst
    sta $FE
    .if size > $FF
                    ; If we have at least 1 full page to copy, then include the 
                    ; page copy portion which needs a 5th byte to track the number
                    ; of pages to copy.

        lda #(size >> 8) ; number of pages to copy
        sta $FF

        ldy #$00 ; reset y for our loop

@loop:
        lda ($FB),Y ; indirect index source memory address
        sta ($FD),Y ; indirect index dest memory address
        iny
        bne @loop       ; loop until our dest goes over 255

        inc $FC     ; increment high order source memory address
        inc $FE     ; increment high order dest memory address

        dec $FF     ; decrement number of pages remaining
        bne @loop       ; If we still have at least 1 page to copy, go back and copy it
    .endif
    .if (size & $FF) > 0
                    ; If we're not copying exactly some number of pages, include
                    ; the "copy the rest of it" section
        ldy #0
        ldx #<size

@loop2:
        lda ($FB),Y
        sta ($FD),Y
        iny
        dex
        bne @loop2
    .endif
.endmacro

;=================================================
; SYS_STREAM_OUT
;   Copy a block of data starting at a source address, 
;   to exactly one destination address, because it's 
;   memory-mapped IO that will auto-increment its own 
;   destination.
;-------------------------------------------------
; INPUTS:   src    Source address
;           dst    Destination address
;           size   Number of bytes to copy
;
;-------------------------------------------------
; MODIFIES: A, X, Y, $FB-$FC, $FF
; 
.macro SYS_STREAM_OUT src, dst, size
.local @loop
.local @loop2
    lda #<src ;src to $FC $FB 
    sta $FB
    lda #>src
    sta $FC

    .if size > $FF
                    ; If we have at least 1 full page to copy, then include the 
                    ; page copy portion which needs a 5th byte to track the number
                    ; of pages to copy.

        lda #(size >> 8) ; number of pages to copy
        sta $FF

        ldy #$00 ; reset y for our loop

@loop:
        lda ($FB),Y ; indirect index source memory address
        sta dst
        iny
        bne @loop       ; loop until our dest goes over 255

        inc $FC     ; increment high order source memory address

        dec $FF     ; decrement number of pages remaining
        bne @loop       ; If we still have at least 1 page to copy, go back and copy it
    .endif

    .if (size & $FF) > 0 
                    ; If we're not copying exactly some number of pages, include
                    ; the "copy the rest of it" section
        ldy #0
        ldx #(size & $FF)

@loop2:
        lda ($FB),Y
        sta dst
        iny
        dex
        bne @loop2
    .endif
.endmacro

;=================================================
; SYS_STREAM_IN
;   Copy a block of data from exactly one source address, 
;   because it's memory-mapped IO that will auto-increment 
;   its own source, to a destination starting at some address.
;-------------------------------------------------
; INPUTS:   src    Source address
;           dst    Destination address
;           size   Number of bytes to copy
;
;-------------------------------------------------
; MODIFIES: A, X, Y, $FD-$FF
; 
.macro SYS_STREAM_IN src, dst, size
.local @loop
.local @loop2
    lda #<dst ;dst to $FE $FD
    sta $FD
    lda #>dst
    sta $FE

    .if size > $FF
                    ; If we have at least 1 full page to copy, then include the 
                    ; page copy portion which needs a 5th byte to track the number
                    ; of pages to copy.

        lda #(size >> 8) ; number of pages to copy
        sta $FF

        ldy #$00 ; reset y for our loop
@loop:
        lda src
        sta ($FD),Y ; indirect index dest memory address
        iny
        bne @loop   ; loop until our dest goes over 255

        inc $FE     ; increment high order dest memory address

        dec $FF     ; decrement number of pages remaining
        bne @loop   ; If we still have at least 1 page to copy, go back and copy it
    .endif
    .if (size & $FF) > 0
                    ; If we're not copying exactly some number of pages, include
                    ; the "copy the rest of it" section
        ldy #0
        ldx #(size & $FF)

@loop2:
        lda src
        sta ($FD),Y
        iny
        dex
        bne @loop2
    .endif
.endmacro

;=================================================
; SYS_STREAM
;   Copy a block of data from exactly one source address, 
;   because it's memory-mapped IO that will auto-increment 
;   its own source, to exactly one destination address,
;   because it too is memory-mapped IO.
;-------------------------------------------------
; INPUTS:   src    Source address
;           dst    Destination address
;           size   Number of bytes to copy
;
;-------------------------------------------------
; MODIFIES: A, X, Y, $FF
; 
.macro SYS_STREAM src, dst, size
.local @loop
.local @loop2

    .if size > $FF
                    ; If we have at least 1 full page to copy, then include the 
                    ; page copy portion which needs a 5th byte to track the number
                    ; of pages to copy.

        lda #>size ; number of pages to copy
        sta $FF

        ldy #0 ; reset y for our loop

@loop:
        lda src
        sta dst
        iny
        bne @loop       ; loop until our dest goes over 255

        dec $FF         ; decrement number of pages remaining
        bne @loop       ; If we still have at least 1 page to copy, go back and copy it
    .endif
    .if (size & $FF) > 0 
                    ; If we're not copying exactly some number of pages, include
                    ; the "copy the rest of it" section
        ldy #0
        ldx #(size & $FF)

@loop2:
        lda src
        sta dst
        iny
        dex
        bne @loop2
    .endif
.endmacro


;=================================================
;=================================================
; 
;   Kernal calls
;
;-------------------------------------------------

.macro SYS_GETJOY
    jsr KERNAL_GETJOY
.endmacro

.macro SYS_CONFIGURE_MOUSE enabled, scale
    lda #enabled
    .if enabled <> 0
        ldx #scale
    .endif
    jsr KERNAL_MOUSE
.endmacro

.endif ; SYSTEM_INC