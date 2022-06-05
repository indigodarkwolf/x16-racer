.ifndef KERNAL_X16_INC
KERNAL_X16_INC=1

;=================================================
;=================================================
;
;   X16 New API kernal calls
;
;-------------------------------------------------
;
; IEEE
;
; $FF44: MACPTR - read multiple bytes from the peripheral bus
;
; Memory
;
;
; Clock
;
; $FF4D: clock_set_date_time - set date and time
; $FF50: clock_get_date_time - get date and time
;
; Mouse
;
; $FF68: mouse_config - configure mouse pointer
; $FF71: mouse_scan - query mouse
; $FF6B: mouse_get - get state of mouse
;
; Joystick
;
; $FF53: joystick_scan - query joysticks 
; $FF56: joystick_get - get state of one joystick
;
; I2C
;
; $FEC6: i2c_read_byte - read a byte from an I2C device 
; $FEC9: i2c_write_byte - write a byte to an I2C device
;
; Sprites
;
; $FEF0: sprite_set_image - set the image of a sprite 
; $FEF3: sprite_set_position - set the position of a sprite
;
; Framebuffer
;
; $FEF6: FB_init - enable graphics mode 
; $FEF9: FB_get_info - get screen size and color depth 
; $FEFC: FB_set_palette - set (parts of) the palette 
; $FEFF: FB_cursor_position - position the direct-access cursor 
; $FF02: FB_cursor_next_line - move direct-access cursor to next line
; $FF05: FB_get_pixel - read one pixel, update cursor 
; $FF08: FB_get_pixels - copy pixels into RAM, update cursor 
; $FF0B: FB_set_pixel - set one pixel, update cursor 
; $FF0E: FB_set_pixels - copy pixels from RAM, update cursor 
; $FF11: FB_set_8_pixels - set 8 pixels from bit mask (transparent), update cursor 
; $FF14: FB_set_8_pixels_opaque - set 8 pixels from bit mask (opaque), update cursor 
; $FF17: FB_fill_pixels - fill pixels with constant color, update cursor 
; $FF1A: FB_filter_pixels - apply transform to pixels, update cursor 
; $FF1D: FB_move_pixels - copy horizontally consecutive pixels to a different position
;
; Graphics
;
; $FF20: GRAPH_init - initialize graphics 
; $FF23: GRAPH_clear - clear screen 
; $FF26: GRAPH_set_window - set clipping region 
; $FF29: GRAPH_set_colors - set stroke, fill and background colors 
; $FF2C: GRAPH_draw_line - draw a line 
; $FF2F: GRAPH_draw_rect - draw a rectangle (optionally filled) 
; $FF32: GRAPH_move_rect - move pixels 
; $FF35: GRAPH_draw_oval - draw an oval or circle 
; $FF38: GRAPH_draw_image - draw a rectangular image 
; $FF3B: GRAPH_set_font - set the current font 
; $FF3E: GRAPH_get_char_size - get size and baseline of a character 
; $FF41: GRAPH_put_char - print a character
;
; Console
;
; $FEDB: console_init - initialize console mode 
; $FEDE: console_put_char - print character to console 
; $FED8: console_put_image - draw image as if it was a character 
; $FEE1: console_get_char - get character from console 
; $FED5: console_set_paging_message - set paging message or disable paging
;
; Other
;
; $FEE4: memory_fill - fill memory region with a byte value 
; $FEE7: memory_copy - copy memory region 
; $FEEA: memory_crc - calculate CRC16 of memory region 
; $FEED: memory_decompress - decompress LZSA2 block 
; $FF74: fetch - read a byte from any RAM or ROM bank
; $FF77: stash - write a byte to any RAM bank
; $FECF: entropy_get - get 24 random bits 
; $FF44: monitor - enter machine language monitor 
; $FF47: enter_basic - enter BASIC 
; $FF5F: screen_set_mode - set screen mode 
; $FF62: screen_set_charset - activate 8x8 text mode charset
;
; JSRFAR
;
; $FF6E: JSRFAR
;
;

;=================================================
;
;   X16 New API register map
;
;-------------------------------------------------


r0 = $02
r0L = $02
r0H = $03
r1 = $04
r1L = $04
r1H = $05
r2 = $06
r2L = $06
r2H = $07
r3 = $08
r3L = $08
r3H = $09
r4 = $0A
r4L = $0A
r4H = $0B
r5 = $0C
r5L = $0C
r5H = $0D
r6 = $0E
r6L = $0E
r6H = $0F
r7 = $10
r7L = $10
r7H = $11
r8 = $12
r8L = $12
r8H = $13
r9 = $14
r9L = $14
r9H = $15
r10 = $16
r10L = $16
r10H = $17
r11 = $18
r11L = $18
r11H = $19
r12 = $1A
r12L = $1A
r12H = $1B
r13 = $1C
r13L = $1C
r13H = $1D
r14 = $1E
r14L = $1E
r14H = $1F
r15 = $20
r15L = $20
r15H = $21

;
; IEEE
;
X16_macptr := $FF44 ; MACPTR - read multiple bytes from the peripheral bus

;=================================================
; X16_MACPTR
;   read multiple bytes from the peripheral bus
;-------------------------------------------------
; INPUTS:   num_bytes   Number of bytes to read (0 to let kernal decide)
;           dest_addr   destination address to write to
;-------------------------------------------------
; OUTPUTS:  X           Number of bytes read (low byte)
;           Y           Number of bytes read (high byte)
;           Carry       0 Bytes successfully read
;                       1 MACPTR not supported, call ACPTR instead
;-------------------------------------------------
; MODIFIES: A, X, Y
;
.macro X16_MACPTR num_bytes, dest_addr
    lda #num_bytes
    ldx #<dest_addr
    ldy #>dest_addr
    jsr X16_macptr
.endmacro

;
; Memory
;

X16_memory_fill := $FEE4
X16_memory_copy := $FEE7
X16_memory_crc := $FEEA
X16_memory_decompress := $FEED
X16_fetch := $FF74
X16_stash := $FF77

;=================================================
; X16_MEMORY_FILL
;   Fill a memory region with a byte value.
;   If the start address is $9F00-$9FFF, all bytes
;   will be written to the start address.
;-------------------------------------------------
; INPUTS:   r0      start address
;           r1      size
;           A       byte value to fill with
;-------------------------------------------------
; OUTPUTS:  (none)
;-------------------------------------------------
; MODIFIES: A, X, Y
;
.macro X16_MEMORY_FILL start_address, size, value
    lda #<start_address 
    sta r0L
    lda #>start_address
    sta r0H
    lda #<size
    sta r1L
    lda #>size
    sta r1H
    lda #value
    jsr X16_memory_fill
.endmacro

;=================================================
; X16_MEMORY_COPY
;   Copy a memory region to a different region.
;   If the source address is $9F00-$9FFF, all bytes
;   will be read from the start address.
;   If the target address is $9F00-$9FFF, all bytes
;   will be written to the target address.
;-------------------------------------------------
; INPUTS:   r0      start address
;           r1      target adress
;           r2      num bytes
;-------------------------------------------------
; OUTPUTS:  (none)
;-------------------------------------------------
; MODIFIES: A, X, Y
;
.macro X16_MEMORY_COPY start_address, target_address, num_bytes
    lda #<start_address 
    sta r0L
    lda #>start_address
    sta r0H
    lda #<target_address
    sta r1L
    lda #>target_address
    sta r1H
    lda #<num_bytes
    sta r2L
    lda #>num_bytes
    sta r2H
    jsr X16_memory_copy
.endmacro

;
; Clock
;
X16_clock_set_date_time := $FF4D
X16_clock_get_date_time := $FF50

;=================================================
; X16_CLOCK_SET_DATE_AND_TIME
;   set date and time 
;-------------------------------------------------
; INPUTS:   r0L     year (1900-based)
;           r0H     month (1-12)
;           r1L     day (1-31)
;           r1H     hours (0-23)
;           r2L     minutes (0-59)
;           r2H     seconds (0-59)
;           r3L     jiffies (0-59)
;-------------------------------------------------
; OUTPUTS:  (none)
;-------------------------------------------------
; MODIFIES: A, X, Y
;
.macro X16_CLOCK_SET_DATE_AND_TIME
    jsr X16_clock_set_date_time
.endmacro

;=================================================
; X16_CLOCK_GET_DATE_AND_TIME
;   set date and time 
;-------------------------------------------------
; INPUTS:   (none)
;-------------------------------------------------
; OUTPUTS:  r0L     year (1900-based)
;           r0H     month (1-12)
;           r1L     day (1-31)
;           r1H     hours (0-23)
;           r2L     minutes (0-59)
;           r2H     seconds (0-59)
;           r3L     jiffies (0-59)
;-------------------------------------------------
; MODIFIES: A, X, Y
;
.macro X16_CLOCK_GET_DATE_AND_TIME
    jsr X16_clock_get_date_time
.endmacro

;
; Mouse
;
X16_mouse_config := $FF68
X16_mouse_scan := $FF71
X16_mouse_get := $FF6B

;=================================================
; X16_MOUSE_CONFIG
;   Query the mouse and save its state.
;-------------------------------------------------
; INPUTS:   shape: Mouse shape (0 = disabled)
;-------------------------------------------------
; OUTPUTS:  (none)
;-------------------------------------------------
; MODIFIES: A, X, Y
;
.macro X16_MOUSE_CONFIG shape
    lda #shape
    jsr X16_mouse_config
.endmacro

;=================================================
; X16_MOUSE_SCAN
;   Query the mouse and save its state.
;-------------------------------------------------
; INPUTS:   (none)
;-------------------------------------------------
; OUTPUTS:  (none)
;-------------------------------------------------
; MODIFIES: A, X, Y
;
.macro X16_MOUSE_SCAN
    jsr X16_mouse_scan
.endmacro

;=================================================
; X16_MOUSE_GET
;   Get the state of the mouse
;-------------------------------------------------
; INPUTS:   out_zp  ZP offset to start writing X, Y coordinates to. (4 bytes total)
;-------------------------------------------------
; OUTPUTS:  (X)+0   X coordinate (uint16_t)
;           (X)+2   Y coordinate (uint16_t)
;           A       Button state flags:
;                       $1 left button
;                       $2 right button
;                       $4 middle button
;-------------------------------------------------
; MODIFIES: A, X, Y
;
.macro X16_MOUSE_GET out_zp
    ldx #out_zp
    jsr X16_mouse_get
.endmacro


;
; Joystick
;
X16_joystick_scan := $FF53
X16_joystick_get := $FF56

;=================================================
; X16_JOYSTICK_SCAN
;   Query joysticks
;-------------------------------------------------
; INPUTS:   (none)
;-------------------------------------------------
; OUTPUTS:  (none)
;-------------------------------------------------
; MODIFIES: A, X, Y
;
.macro X16_JOYSTICK_SCAN
    jsr X16_joystick_scan
.endmacro

;=================================================
; X16_JOYSTICK_GET
;   Get the state of one of the joysticks 
;-------------------------------------------------
; INPUTS:   stick   Which joystick to get (0-4)
;-------------------------------------------------
; OUTPUTS:  A       button flags:
;                       $80:    B
;                       $40:    Y
;                       $20:    Select
;                       $10:    Start
;                       $08:    Up
;                       $04:    Down
;                       $02:    Left
;                       $01:    Right
;           X       button flags:
;                       $80:    A
;                       $40:    X
;                       $20:    L
;                       $10:    R
;                       $08:    1
;                       $04:    1
;                       $02:    1
;                       $01:    1
;           Y       $00 if joystick is present
;                   $FF if joystick is not present
;-------------------------------------------------
; MODIFIES: A, X, Y
;
.macro X16_JOYSTICK_GET stick
    lda #stick
    jsr X16_joystick_get
.endmacro

;
; I2C
;
X16_i2c_read_byte := $FEC6
X16_i2c_write_byte := $FEC9

I2C_DEVICE_RTC = $6F
I2C_DEVICE_SMC = $42

RTC_SECONDS = 0
RTC_MINUTES = 1
RTC_HOURS = 2
RTC_WEEKDAY = 3
RTC_DAY = 4
RTC_MONTH = 5
RTC_YEAR = 6
RTC_NVRAM = $20

SMC_POWER = 1
SMC_RESET = 2
SMC_NMI = 3
SMC_POWER_LED = 4
SMC_ACTIVITY_LED = 5

;=================================================
; X16_I2C_READ_BYTE
;   read a byte from an I2C 
;-------------------------------------------------
; INPUTS:   device      Device number:
;                           #$6F Real Time Clock
;                           #$42 System Management Controller
;           offset      Offset within device:
;                           RTC:
;                               0           Seconds (bit 7 indicates run-state)
;                               1           Minutes
;                               2           Hours
;                               3           Day of week
;                               4           Day of month
;                               5           Month (bit 4 indicates leap-year)
;                               6           Year
;                               $20-$5F     NVRAM
;                           SMC:
;                               1           Power switch
;                               2           Reset switch
;                               3           NMI
;                               4           Power LED
;                               5           Activity LED
;-------------------------------------------------
; OUTPUTS:  A   Value from device
;           Carry set if an error occured, cleared otherwise 
;-------------------------------------------------
; MODIFIES: A, X, Y
;
.macro X16_I2C_READ_BYTE device, offset
    ldx #device
    ldy #offset
    jsr X16_i2c_read_byte
.endmacro

;=================================================
; X16_I2C_WRITE_BYTE
;   write a byte to an I2C device
;-------------------------------------------------
; INPUTS:   device      Device number:
;                           #$6F Real Time Clock
;                           #$42 System Management Controller
;           offset      Offset within device:
;                           RTC:
;                               0           Seconds (bit 7 indicates run-state)
;                               1           Minutes
;                               2           Hours
;                               3           Day of week
;                               4           Day of month
;                               5           Month (bit 4 indicates leap-year)
;                               6           Year
;                               $20-$5F     NVRAM
;                           SMC:
;                               1           Power switch
;                               2           Reset switch
;                               3           NMI
;                               4           Power LED
;                               5           Activity LED
;           value       Value to write to device
;-------------------------------------------------
; OUTPUTS:  Carry set if an error occured, cleared otherwise 
;-------------------------------------------------
; MODIFIES: A, X, Y
;
.macro X16_I2C_WRITE_BYTE device, offset, value
    ldx #device
    ldy #offset
    lda #value
    jsr X16_i2c_write_byte
.endmacro

;
; Sprites
;
X16_sprite_set_image := $FEF0
X16_sprite_set_position := $FEF3

;=================================================
; X16_SPRITE_SET_IMAGE
;   Set the image of a sprite 
;   Call address: $FEF0
;   Signature: bool sprite_set_image(byte number: .a, width: .x, height: .y, apply_mask: .c, word pixels: r0, word mask: r1, byte bpp: r2L); 
;   Error returns: .C = 1 in case of error
;-------------------------------------------------
; INPUTS:   byte number: .a
;           byte width: .x, 
;           byte height: .y
;           bool apply_mask: .c
;           word pixels: r0
;           word mask: r1
;           byte bpp: r2L
;-------------------------------------------------
; OUTPUTS:  Carry set if an error occured, cleared otherwise 
;-------------------------------------------------
; MODIFIES: A, X, Y
;
.macro X16_SPRITE_SET_IMAGE sprite_id, width, height, mask, pixel_data, mask_data, bpp
    lda #bpp
    sta r2L
    .if mask <> 0
        lda #<mask_data
        sta r1L
        lda #>mask_data
        sta r1H
    .endif
    lda #<pixel_data
    sta r0L
    lda #>pixel_data
    sta r0H
    .if mask <> 0
        sec
    .else
        clc
    .endif
    ldy #height
    ldx #width
    lda #sprite_id
    jsr X16_sprite_set_image
.endmacro

;=================================================
; X16_SPRITE_SET_POSITION
;   Set the position of a sprite or hide it. 
;   Call address: $FEF3 
;   Signature: void sprite_set_position(byte number: .a, word x: r0, word y: r1);
;   Error returns: None
;-------------------------------------------------
; INPUTS:   byte number: .a
;           word x: r0
;           word y: r1
;-------------------------------------------------
; OUTPUTS:  (none)
;-------------------------------------------------
; MODIFIES: A, X, Y
;
.macro X16_SPRITE_SET_POSITION sprite_id, pos_x, pos_y
    lda #<pos_y
    sta r1L
    lda #>pos_y
    sta r1H
    lda #<pos_x
    sta r0L
    lda #>pos_x
    sta r0H
    lda #sprite_id
    jsr X16_sprite_set_position
.endmacro

;
; Framebuffer
;
X16_FB_init := $FEF6
X16_FB_get_info := $FEF9
X16_FB_set_palette := $FEFC
X16_FB_cursor_position := $FEFF
X16_FB_cursor_next_line := $FF02
X16_FB_get_pixel := $FF05
X16_FB_get_pixels := $FF08
X16_FB_set_pixel := $FF0B
X16_FB_set_pixels := $FF0E
X16_FB_set_8_pixels := $FF11
X16_FB_set_8_pixels_opaque := $FF14
X16_FB_fill_pixels := $FF17
X16_FB_filter_pixels := $FF1A
X16_FB_move_pixels := $FF1D

;=================================================
; X16_FB_INIT
;   Signature: void FB_init(); 
;   Purpose: Enter graphics mode.
;-------------------------------------------------
; INPUTS:   (none)
;-------------------------------------------------
; OUTPUTS:  (none)
;-------------------------------------------------
; MODIFIES: A, X, Y
;
.macro X16_FB_INIT
    jsr X16_FB_init
.endmacro

;=================================================
; X16_FB_GET_INFO
;   Signature: void FB_get_info(out word width: r0, out word height: r1, out byte color_depth: .a); 
;   Purpose: Return the resolution and color depth
;-------------------------------------------------
; INPUTS:   (none)
;-------------------------------------------------
; OUTPUTS:  out word width: r0
;           out word height: r1
;           out byte color_depth: .a
;-------------------------------------------------
; MODIFIES: A, X, Y
;
.macro X16_FB_GET_INFO
    jsr X16_FB_get_info
.endmacro

;=================================================
; X16_FB_SET_PALETTE
;   Signature: void FB_set_palette(word pointer: r0, index: .a, byte count: .x); 
;   Purpose: Set (parts of) the palette
;-------------------------------------------------
; INPUTS:   word pointer: r0
;           byte index: .a
;           byte count: .x
;-------------------------------------------------
; OUTPUTS:  (none)
;-------------------------------------------------
; MODIFIES: A, X, Y
;
.macro X16_FB_SET_PALETTE ptr, index, count
    lda #<ptr
    sta r0L
    lda #>ptr
    sta r0H
    lda #index
    ldx #count
    jsr X16_FB_set_palette
.endmacro

;=================================================
; X16_FB_SET_CURSOR_POSITION
;   Signature: void FB_cursor_position(word x: r0, word y: r1); 
;   Purpose: Position the direct-access cursor
;-------------------------------------------------
; INPUTS:   word x: r0
;           word y: r1
;-------------------------------------------------
; OUTPUTS:  (none)
;-------------------------------------------------
; MODIFIES: A, X, Y
;
.macro X16_FB_SET_CURSOR_POSITION pos_x, pos_y
    lda #<pos_x
    sta r0L
    lda #>pos_x
    sta r0H
    lda #<pos_y
    sta r1L
    lda #>pos_y
    sta r1H
    jsr X16_FB_cursor_position
.endmacro

;=================================================
; X16_FB_CURSOR_NEXT_LINE
;   Signature: void FB_cursor_next_line(word x: r0)
;   Purpose: Move the direct-access cursor to next line
;-------------------------------------------------
; INPUTS:   word x: r0
;-------------------------------------------------
; OUTPUTS:  (none)
;-------------------------------------------------
; MODIFIES: A, X, Y
;
.macro X16_FB_CURSOR_NEXT_LINE
    lda #<pos_x
    sta r0L
    lda #>pos_x
    sta r0H
    jsr X16_FB_cursor_next_line
.endmacro

;=================================================
; X16_FB_GET_PIXEL
;   Signature: byte FB_get_pixel(); 
;   Purpose: Read one pixel, update cursor
;-------------------------------------------------
; INPUTS:   (none)
;-------------------------------------------------
; OUTPUTS:  A
;-------------------------------------------------
; MODIFIES: A, X, Y
;
.macro X16_FB_GET_PIXEL
    jsr X16_FB_get_pixel
.endmacro

;=================================================
; X16_FB_GET_PIXELS
;   Signature: void FB_get_pixels(word ptr: r0, word count: r1); 
;   Purpose: Copy pixels into RAM, update cursor
;-------------------------------------------------
; INPUTS:   word ptr: r0
;           word count: r1
;-------------------------------------------------
; OUTPUTS:  (none)
;-------------------------------------------------
; MODIFIES: A, X, Y
;
.macro X16_FB_GET_PIXELS ptr, count
    lda #<ptr
    sta r0L
    sta #>ptr
    sta r0H
    lda #<count
    sta r1L
    lda #>count
    sta r1H
    jsr X16_FB_get_pixels
.endmacro

;=================================================
; X16_FB_SET_PIXEL
;   Signature: void FB_set_pixel(byte color: .a); 
;   Purpose: Set one pixel, update cursor
;-------------------------------------------------
; INPUTS:   byte color: .a
;-------------------------------------------------
; OUTPUTS:  (none)
;-------------------------------------------------
; MODIFIES: A, X, Y
;
.macro X16_FB_SET_PIXEL color
    lda #color
    jsr X16_FB_set_pixel
.endmacro

;=================================================
; X16_FB_SET_PIXELS
;   Signature: void FB_set_pixels(word ptr: r0, word count: r1); 
;   Purpose: Copy pixels from RAM, update cursor
;-------------------------------------------------
; INPUTS:   word ptr: r0
;           word count: r1
;-------------------------------------------------
; OUTPUTS:  (none)
;-------------------------------------------------
; MODIFIES: A, X, Y
;
.macro X16_FB_SET_PIXELS ptr, count
    lda #<ptr
    sta r0L
    sta #>ptr
    sta r0H
    lda #<count
    sta r1L
    lda #>count
    sta r1H
    jsr X16_FB_set_pixels
.endmacro

;=================================================
; X16_FB_SET_8_PIXELS
;   Signature: void FB_set_8_pixels(byte pattern: .a, byte color: .x); 
;   Purpose: Set 8 pixels from bit mask (transparent), update cursor
;-------------------------------------------------
; INPUTS:   byte pattern: .a
;           byte color: .x
;-------------------------------------------------
; OUTPUTS:  (none)
;-------------------------------------------------
; MODIFIES: A, X, Y
;
.macro X16_FB_SET_8_PIXELS pattern, color
    lda #pattern
    ldx #color
    jsr X16_FB_set_8_pixels
.endmacro

;=================================================
; X16_FB_SET_8_PIXELS_OPAQUE
;   Signature: void FB_set_8_pixels_opaque(byte pattern: .a, byte mask: r0L, byte color1: .x, byte color2: .y); 
;   Purpose: Set 8 pixels from bit mask (opaque), update cursor
;-------------------------------------------------
; INPUTS:   byte pattern: .a
;           byte mask: r0L
;           byte color1: .x
;           byte color2: .y
;-------------------------------------------------
; OUTPUTS:  (none)
;-------------------------------------------------
; MODIFIES: A, X, Y
;
.macro X16_FB_SET_8_PIXELS_OPAQUE pattern, mask, color1, color2
    lda #mask
    sta r0L
    lda #pattern
    ldx #color1
    ldy #color2
    jsr X16_FB_set_8_pixels_opaque
.endmacro

;=================================================
; X16_FB_FILL_PIXELS
;   Signature: void FB_fill_pixels(word count: r0, word step: r1, byte color: .a);
;   Purpose: Fill pixels with constant color, update cursor
;-------------------------------------------------
; INPUTS:   word count: r0
;           word step: r1
;           byte color: .a
;-------------------------------------------------
; OUTPUTS:  (none)
;-------------------------------------------------
; MODIFIES: A, X, Y
;
.macro X16_FB_FILL_PIXELS count, step, color
    lda #<count
    sta r0L
    lda #>count
    sta r0H
    lda #<step
    sta r1L
    lda #>step
    sta r1H
    lda color
    jsr X16_FB_fill_pixels
.endmacro

;=================================================
; X16_FB_FILTER_PIXELS
;   Signature: void FB_filter_pixels(word ptr: r0, word count: r1)
;   Purpose: Apply transform to pixels, update cursor
;   Description: This function allows modifying consecutive pixels. 
;       The function pointer will be called for every pixel, with 
;       the color in .a, and it needs to return the new color in .a.
;-------------------------------------------------
; INPUTS:   word ptr: r0
;           word count: r1
;-------------------------------------------------
; OUTPUTS:  (none)
;-------------------------------------------------
; MODIFIES: A, X, Y
;
.macro X16_FB_FILTER_PIXELS ptr, count
    lda #<ptr
    sta r0L
    lda #>ptr
    sta r0H
    lda #<count
    sta r1L
    lda #>count
    sta r1H
    jsr X16_FB_filter_pixels
.endmacro

;=================================================
; X16_FB_MOVE_PIXELS
;   Signature: void FB_move_pixels(word sx: r0, word sy: r1, word tx: r2, word ty: r3, word count: r4)
;   Purpose: Copy horizontally consecutive pixels to a different position
;-------------------------------------------------
; INPUTS:   word sx: r0
;           word sy: r1
;           word tx: r2
;           word ty: r3
;           word count: r4
;-------------------------------------------------
; OUTPUTS:  (none)
;-------------------------------------------------
; MODIFIES: A, X, Y
;
.macro X16_FB_MOVE_PIXELS sx, sy, tx, ty, count
    lda #<sx
    sta r0L
    lda #>sx
    sta r0H
    lda #<sy
    sta r1L
    lda #>sy
    sta r1H
    lda #<tx
    sta r2L
    lda #>tx
    sta r2H
    lda #<ty
    sta r3L
    lda #>ty
    sta r3H
    lda #<count
    sta r4L
    lda #>count
    sta r4H
    jsr X16_FB_move_pixels
.endmacro

;
; Graphics
;
X16_GRAPH_init := $FF20
X16_GRAPH_clear := $FF23
X16_GRAPH_set_window := $FF26
X16_GRAPH_set_colors := $FF29
X16_GRAPH_draw_line := $FF2C
X16_GRAPH_draw_rect := $FF2F
X16_GRAPH_move_rect := $FF32
X16_GRAPH_draw_oval := $FF35
X16_GRAPH_draw_image := $FF38
X16_GRAPH_set_font := $FF3B
X16_GRAPH_get_char_size := $FF3E
X16_GRAPH_put_char := $FF41
;
; Console
;
X16_console_init := $FEDB
X16_console_put_char := $FEDE
X16_console_put_image := $FED8
X16_console_get_char := $FEE1
X16_console_set_paging_message := $FED5
;
; Other
;
X16_entropy_get := $FECF
X16_monitor := $FF44
X16_enter_basic := $FF47
X16_screen_set_mode := $FF5F
X16_screen_set_charset := $FF62
;
; JSRFAR
;
X16_JSRFAR := $FF6E
;


.endif ; KERNAL_X16_INC