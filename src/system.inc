.ifndef SYSTEM_INC
SYSTEM_INC=1

.include "kernal.inc"

SYS_BANK_ROM = $9F60
SYS_BANK_RAM = $9F61

KERNAL_joystick_scan = $FF53
KERNAL_joystick_get = $FF56
KERNAL_MOUSE = $FF68

BUTTON_SNES_A       = (1 << 7)
BUTTON_SNES_X       = (1 << 6)
BUTTON_SNES_L       = (1 << 5)
BUTTON_SNES_R       = (1 << 4)

BUTTON_SNES_B       = (1 << 7)
BUTTON_SNES_Y       = (1 << 6)
BUTTON_SNES_SELECT  = (1 << 5)
BUTTON_SNES_START   = (1 << 4)

BUTTON_NES_A       = (1 << 7)
BUTTON_NES_B       = (1 << 6)
BUTTON_NES_SELECT  = (1 << 5)
BUTTON_NES_START   = (1 << 4)

BUTTON_JOY_UP    = (1 << 3)
BUTTON_JOY_DOWN  = (1 << 2)
BUTTON_JOY_LEFT  = (1 << 1)
BUTTON_JOY_RIGHT = (1 << 0)

ZP_COPY_SRC = $7E
ZP_COPY_DST = $7C
ZP_COPY_SIZE = $7A

.global Sys_frame
.global Sys_irq_redirect
.global Sys_rand_mem
.global Sys_rom_original

.global sys_wait_for_frame

;=================================================
;=================================================
; 
;   Kernal API wrappers
;
;-------------------------------------------------

;=================================================
; SYS_FILE_LOAD
;   Load a file into memory.
;-------------------------------------------------
; INPUTS:   fname_addr  Memory address containing the filename string
;           fname_len   Length of the filename string
;           load_addr   (Optional) Address to load into
;
;-------------------------------------------------
; MODIFIES: A, X, Y
; 
.macro SYS_FILE_LOAD fname_addr, fname_len, load_addr
    .ifblank load_addr
        KERNAL_SETLFS 1, 8, 1
        KERNAL_SETNAM fname_len, fname_addr
        KERNAL_LOAD 0, 0
    .else
        KERNAL_SETLFS 1, 8, 0
        KERNAL_SETNAM fname_len, fname_addr
        KERNAL_LOAD 0, load_addr
    .endif
.endmacro


;=================================================
; SYS_FILE_VLOAD
;   Load a file into VRAM.
;-------------------------------------------------
; INPUTS:   fname_addr  Memory address containing the filename string
;           fname_len   Length of the filename string
;           load_addr   VRAM address to load into
;
;-------------------------------------------------
; MODIFIES: A, X, Y
; 
.macro SYS_FILE_VLOAD fname_addr, fname_len, load_addr
    KERNAL_SETLFS 1, 8, 0
    KERNAL_SETNAM fname_len, fname_addr
    KERNAL_LOAD ((^load_addr)+2), (load_addr & $ffff)
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
; INPUTS:   (none)
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
; INPUTS:   address    Label or address of IRQ handler
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
.endmacro

;=================================================
; SYS_ABORT_IRQ
;   Restore registers and return control to 
;   interrupted process.
;-------------------------------------------------
; INPUTS:   (none)
;
;-------------------------------------------------
; MODIFIES: A, X, Y
; 
.macro SYS_ABORT_IRQ
    ply
    plx
    pla
    rti
.endmacro

;=================================================
;=================================================
; 
;   Bank swapping
;
;-------------------------------------------------

;=================================================
; SYS_INIT_BANK
;   Initialize bank swapping by stowing the original
;   ROM bank into a dedicated place in memory.
;-------------------------------------------------
; INPUTS:   (none)
;
;-------------------------------------------------
; MODIFIES: A
; 
.macro SYS_INIT_BANK
    lda SYS_BANK_ROM
    sta Sys_rom_original

    lda #0
    sta SYS_BANK_ROM
.endmacro

;=================================================
; SYS_RESTORE_BANK
;   Restore the ROM bank to where it was before clobbering it.
;-------------------------------------------------
; INPUTS:   (none)
;
;-------------------------------------------------
; MODIFIES: A
; 
.macro SYS_RESTORE_BANK
    lda Sys_rom_original
    sta SYS_BANK_ROM
.endmacro

;=================================================
; SYS_SET_BANK
;   Set the current bank of high memory
;-------------------------------------------------
; INPUTS:   bank    Bank to set to.
;
;-------------------------------------------------
; MODIFIES: A
; 
.macro SYS_SET_BANK bank
    lda #bank
    sta SYS_BANK_RAM
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
; INPUTS:   v0, v1, v2  Seed values
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

.macro SYS_POLLJOY
    jsr KERNAL_joystick_scan
.endmacro

.macro SYS_GETJOY id
    lda #id
    jsr KERNAL_joystick_get
.endmacro

.macro SYS_CONFIGURE_MOUSE enabled, scale
    lda #enabled
    .if enabled <> 0
        ldx #scale
    .endif
    jsr KERNAL_MOUSE
.endmacro

.endif ; SYSTEM_INC