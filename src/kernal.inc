.ifndef KERNAL_INC
KERNAL_INC=1

;=================================================
;=================================================
; 
;   C64-compatible kernal calls
;
;-------------------------------------------------
;
; Channel I/O
;
; $FF90: SETMSG – set verbosity 
; $FFB7: READST – return status byte 
; $FFBA: SETLFS – set LA, FA and SA 
; $FFBD: SETNAM – set filename 
; $FFC0: OPEN – open a channel 
; $FFC3: CLOSE – close a channel 
; $FFC6: CHKIN – set channel for character input 
; $FFC9: CHKOUT – set channel for character output 
; $FFCC: CLRCHN – restore character I/O to screen/keyboard 
; $FFCF: BASIN – get character 
; $FFD2: BSOUT – write character 
; $FFD5: LOAD – load a file into memory 
; $FFD8: SAVE – save a file from memory 
; $FFE7: CLALL – close all channels
;
;
; Commodore Peripheral Bus
;
; $FFB4: TALK – send TALK command 
; $FFB1: LISTEN – send LISTEN command 
; $FFAE: UNLSN – send UNLISTEN command 
; $FFAB: UNTLK – send UNTALK command 
; $FFA8: IECOUT – send byte to serial bus 
; $FFA5: IECIN – read byte from serial bus 
; $FFA2: SETTMO – set timeout 
; $FF96: TKSA – send TALK secondary address 
; $FF93: SECOND – send LISTEN secondary address
;
;
; Memory
;
; $FF9C: MEMBOT – read/write address of start of usable RAM 
; $FF99: MEMTOP – read/write address of end of usable RAM
;
;
; Time
;
; $FFDE: RDTIM – read system clock 
; $FFDB: SETTIM – write system clock 
; $FFEA: UDTIM – advance clock
;
;
; Other
;
; $FFE1: STOP – test for STOP key 
; $FFE4: GETIN – get character from keyboard 
; $FFED: SCREEN – get the screen resolution 
; $FFF0: PLOT – read/write cursor position 
; $FFF3: IOBASE – return start of I/O area
;
;

;
; Channel I/O
;

;=================================================
; KERNAL_SETMSG
;   Set system error display switch at memory address $009D.
;-------------------------------------------------
; INPUTS:   value    Switch value.
;
;-------------------------------------------------
; OUTPUTS:  (none)
;-------------------------------------------------
; MODIFIES: A
; 
.macro KERNAL_SETMSG value
    lda #value
    jsr $FF90
.endmacro

;=================================================
; KERNAL_READST
;   Fetch status of current input/output device, value of ST variable. (For RS232, status is cleared.)
;-------------------------------------------------
; INPUTS:   (none)
;-------------------------------------------------
; OUTPUTS:  value    Device status.
;
;-------------------------------------------------
; MODIFIES: A
; 
.macro KERNAL_READST value
    jsr $FFB7
.endmacro

;=================================================
; KERNAL_SETLFS
;   Set file parameters
;-------------------------------------------------
; INPUTS:   logical_num         Logical number
;           device_num          Device number
;           secondary_address   Secondary address
;
;-------------------------------------------------
; OUTPUTS:  (none)
;-------------------------------------------------
; MODIFIES: A, X, Y
; 
.macro KERNAL_SETLFS logical_num, device_num, secondary_address
    lda #logical_num
    ldx #device_num
    ldy #secondary_address
    jsr $FFBA
.endmacro

;=================================================
; KERNAL_SETNAM
;   Set file name parameters
;-------------------------------------------------
; INPUTS:   name_len    Length of filename
;           name_addr   Address of filename in memory
;
;-------------------------------------------------
; OUTPUTS:  (none)
;-------------------------------------------------
; MODIFIES: A, X, Y
; 
.macro KERNAL_SETNAM name_len, name_addr
    lda #name_len
    ldx #<name_addr
    ldy #>name_addr
    jsr $FFBD
.endmacro

;=================================================
; KERNAL_OPEN
;   Open file. (Must call SETLFS and SETNAM beforehands.)
;-------------------------------------------------
; INPUTS:   (none)
;-------------------------------------------------
; OUTPUTS:  (none)
;-------------------------------------------------
; MODIFIES: A, X, Y
; 
.macro KERNAL_OPEN
    jsr $FFC0
.endmacro

;=================================================
; KERNAL_CLOSE
;   Close file.
;-------------------------------------------------
; INPUTS:   logical_num     Logical number
;
;-------------------------------------------------
; OUTPUTS:  (none)
;-------------------------------------------------
; MODIFIES: A, X, Y
; 
.macro KERNAL_CLOSE logical_num
    lda #logical_num
    jsr $FFC3
.endmacro

;=================================================
; KERNAL_CHKIN
;   Define file as default input. (Must call OPEN beforehands.)
;-------------------------------------------------
; INPUTS:   logical_num     Logical number
;
;-------------------------------------------------
; OUTPUTS:  (none)
;-------------------------------------------------
; MODIFIES: A, X
; 
.macro KERNAL_CHKIN logical_num
    ldx #logical_num
    jsr $FFC6
.endmacro

;=================================================
; KERNAL_CHKOUT
;   Define file as default input. (Must call OPEN beforehands.)
;-------------------------------------------------
; INPUTS:   logical_num     Logical number
;
;-------------------------------------------------
; OUTPUTS:  (none)
;-------------------------------------------------
; MODIFIES: A, X
; 
.macro KERNAL_CHKOUT logical_num
    ldx #logical_num
    jsr $FFC9
.endmacro

;=================================================
; KERNAL_CLRCHN
;   Close default input/output files (for serial bus, send UNTALK and/or UNLISTEN); restore default input/output to keyboard/screen.
;-------------------------------------------------
; INPUTS:   (none)
;-------------------------------------------------
; OUTPUTS:  (none)
;-------------------------------------------------
; MODIFIES: A, X
; 
.macro KERNAL_CLRCHN
    jsr $FFCC
.endmacro

;=================================================
; KERNAL_BASIN
;   AKA CHRIN
;   Read byte from default input (for keyboard, read a line from the screen). (If not keyboard, must call OPEN and CHKIN beforehands.)
;-------------------------------------------------
; INPUTS:   (none)
;-------------------------------------------------
; OUTPUTS:  A
;-------------------------------------------------
; MODIFIES: (none)
; 
.macro KERNAL_BASIN
    jsr $FFCF
.endmacro

;=================================================
; KERNAL_BSOUT
;   AKA CHROUT
;   Write byte to default output. (If not screen, must call OPEN and CHKOUT beforehands.)
;-------------------------------------------------
; INPUTS:   A
;-------------------------------------------------
; OUTPUTS:  (none)
;-------------------------------------------------
; MODIFIES: A, Y
; 
.macro KERNAL_BSOUT
    jsr $FFD2
.endmacro

;=================================================
; KERNAL_LOAD
;   Load or verify file. (Must call SETLFS and SETNAM beforehands.)
;-------------------------------------------------
; INPUTS:   verify  Do verify
;           addr    Load address (if secondary address = 0)
;-------------------------------------------------
; OUTPUTS:  Carry   0 = No errors, 1 = Error; A = KERNAL error code (if Carry = 1); 
;           X/Y     Address of last byte loaded/verified (if Carry = 0).
;-------------------------------------------------
; MODIFIES: A, X, Y
; 
.macro KERNAL_LOAD  verify, addr
    lda #verify
    ldx #<addr
    ldy #>addr
    jsr $FFD5
.endmacro

;=================================================
; KERNAL_SAVE
;   Save file. (Must call SETLFS and SETNAM beforehands.)
;-------------------------------------------------
; INPUTS:   zp_ptr          Address of zero page register holding start address of memory area to save
;           end_address     End address of memory area.
;-------------------------------------------------
; OUTPUTS:  Carry:  0 = No errors, 1 = Error; 
;           A:      KERNAL error code (if Carry = 1).
;-------------------------------------------------
; MODIFIES: A, X, Y
; 
.macro KERNAL_SAVE zp_ptr, end_address
    lda #zp_ptr
    ldx #<(end_address+1)
    ldy #>(end_address+1)
    jsr $FFD8
.endmacro

;=================================================
; KERNAL_CLALL
;   Clear file table; call CLRCHN.
;-------------------------------------------------
; INPUTS:   (none)
;-------------------------------------------------
; OUTPUTS:  (none)
;-------------------------------------------------
; MODIFIES: A, X
; 
.macro KERNAL_CLALL
    jsr $FFE7
.endmacro

;
; Commodore Peripheral Bus
;

;=================================================
; KERNAL_TALK 
;   send TALK command
;-------------------------------------------------
; INPUTS:   device      Device number (4-31)
;-------------------------------------------------
; OUTPUTS:  (none)
;-------------------------------------------------
; MODIFIES: A
;
.macro KERNAL_TALK device
    lda #device
    jsr $FFB4
.endmacro

;=================================================
; KERNAL_LISTEN 
;   send LISTEN command
;-------------------------------------------------
; INPUTS:   device      Device number (4-31)
;-------------------------------------------------
; OUTPUTS:  (none)
;-------------------------------------------------
; MODIFIES: A, X
;
.macro KERNAL_LISTEN device
    lda device
    jsr $FFB1
.endmacro

;=================================================
; KERNAL_UNLISTEN 
;   send UNLISTEN command
;-------------------------------------------------
; INPUTS:   device      Device number (4-31)
;-------------------------------------------------
; OUTPUTS:  (none)
;-------------------------------------------------
; MODIFIES: A
;
.macro KERNAL_UNLISTEN device
    lda device
    jsr $FFAE
.endmacro

;=================================================
; KERNAL_UNTALK 
;   send UNTALK command
;-------------------------------------------------
; INPUTS:   device      Device number (4-31)
;-------------------------------------------------
; OUTPUTS:  (none)
;-------------------------------------------------
; MODIFIES: A
;
.macro KERNAL_UNTALK device
    lda #device
    jsr $FFAB
.endmacro

;=================================================
; KERNAL_IECOUT 
;   send byte to serial bus 
;-------------------------------------------------
; INPUTS:   data        byte to send
;-------------------------------------------------
; OUTPUTS:  (none)
;-------------------------------------------------
; MODIFIES: A
;
.macro KERNAL_IECOUT data
    lda #data
    jsr $FFA8
.endmacro

;=================================================
; KERNAL_IECIN 
;   read byte from serial bus 
;-------------------------------------------------
; INPUTS:   (none)
;-------------------------------------------------
; OUTPUTS:  (none)
;-------------------------------------------------
; MODIFIES: A, X
;
.macro KERNAL_IECIN
    jsr $FFA5
.endmacro

;=================================================
; KERNAL_SETTMO 
;   set timeout 
;-------------------------------------------------
; INPUTS:   enable      0 to disable timeout, 1 to enable timeout
;-------------------------------------------------
; OUTPUTS:  (none)
;-------------------------------------------------
; MODIFIES: A
;
.macro KERNAL_SETTMO enable
    .if enable=0
        lda #0
    .else
        lda #$80
    .endif
    jsr $FFA2
.endmacro

;=================================================
; KERNAL_TKSA 
;   send TALK secondary address 
;-------------------------------------------------
; INPUTS:   command     Command/secondary address
;-------------------------------------------------
; OUTPUTS:  (none)
;-------------------------------------------------
; MODIFIES: A
;
.macro KERNAL_TKSA command
    lda #command
    jsr $FF96
.endmacro

;=================================================
; KERNAL_SECOND 
;   send LISTEN secondary address
;-------------------------------------------------
; INPUTS:   command     Command/secondary address
;-------------------------------------------------
; OUTPUTS:  (none)
;-------------------------------------------------
; MODIFIES: A
;
.macro KERNAL_SECOND command
    lda #command
    jsr $FF93
.endmacro

;
; Memory
;

;=================================================
; KERNAL_MEMBOT_GET
;   read address of start of usable RAM 
;-------------------------------------------------
; INPUTS:   (none)
;-------------------------------------------------
; OUTPUTS:  (none)
;-------------------------------------------------
; MODIFIES: X, Y
;
.macro KERNAL_MEMBOT_GET device
    sec
    jsr $FF9C
.endmacro

;=================================================
; KERNAL_MEMBOT_SET
;   write address of start of usable RAM 
;-------------------------------------------------
; INPUTS:   address     New address
;-------------------------------------------------
; OUTPUTS:  (none)
;-------------------------------------------------
; MODIFIES: X, Y
;
.macro KERNAL_MEMBOT_SET address
    ldx #<address
    ldy #>address
    clc
    jsr $FF9C
.endmacro


;=================================================
; KERNAL_MEMTOP_GET 
;   read address of end of usable RAM
;-------------------------------------------------
; INPUTS:   (none)
;-------------------------------------------------
; OUTPUTS:  (none)
;-------------------------------------------------
; MODIFIES: X, Y
;
.macro KERNAL_MEMTOP_GET device
    sec
    jsr $FF99
.endmacro

;=================================================
; KERNAL_MEMTOP_SET
;   write address of end of usable RAM
;-------------------------------------------------
; INPUTS:   address      New address
;-------------------------------------------------
; OUTPUTS:  (none)
;-------------------------------------------------
; MODIFIES: X, Y
;
.macro KERNAL_MEMTOP_SET address
    ldx #<address
    ldy #>address
    clc
    jsr $FF99
.endmacro

;
; Time
;

;=================================================
; KERNAL_RDTIM 
;   read system clock 
;-------------------------------------------------
; INPUTS:   (none)
;-------------------------------------------------
; OUTPUTS:  A   Bank byte
;           X   High byte 
;           Y   Low byte
;-------------------------------------------------
; MODIFIES: A, X, Y
;
.macro KERNAL_RDTIM
    jsr $FFDE
.endmacro

;=================================================
; KERNAL_SETTIM 
;   write system clock 
;-------------------------------------------------
; INPUTS:   new_time    New time (in jiffies)
;-------------------------------------------------
; OUTPUTS:  (none)
;-------------------------------------------------
; MODIFIES: A, X, Y
;
.macro KERNAL_SETTIM new_time
    lda #^new_time
    ldx #>new_time
    ldy #<new_time
    jsr $FFDB
.endmacro

;=================================================
; KERNAL_UDTIM 
;   advance clock
;-------------------------------------------------
; INPUTS:   (none)
;-------------------------------------------------
; OUTPUTS:  (none)
;-------------------------------------------------
; MODIFIES: A, X
;
.macro KERNAL_UDTIM
    jsr $FFEA
.endmacro


;
; Other
;

;=================================================
; KERNAL_STOP 
;   test for STOP key 
;-------------------------------------------------
; INPUTS:   (none)
;-------------------------------------------------
; OUTPUTS:  Z flag      If set, a key was pressed during UDTIM
;-------------------------------------------------
; MODIFIES: A, X
;
.macro KERNAL_STOP
    jsr $FFE1
.endmacro

;=================================================
; KERNAL_GETIN 
;   get character from keyboard 
;-------------------------------------------------
; INPUTS:   (none)
;-------------------------------------------------
; OUTPUTS:  A       Next in buffer (0 if buffer empty)
;-------------------------------------------------
; MODIFIES: A, X, Y
;
.macro KERNAL_GETIN
    jsr $FFE4
.endmacro

;=================================================
; KERNAL_SCREEN 
;   get the screen resolution 
;-------------------------------------------------
; INPUTS:   (none)
;-------------------------------------------------
; OUTPUTS:  X       Columns in screen
;           Y       Rows in screen
;-------------------------------------------------
; MODIFIES: X, Y
;
.macro KERNAL_SCREEN
    jsr $FFED
.endmacro

;=================================================
; KERNAL_PLOT 
;   read/write cursor position 
;-------------------------------------------------
; INPUTS:   cursor_x        New x position for cursor
;           cursor_y        New y position for cursor
;-------------------------------------------------
; OUTPUTS:  (none)
;-------------------------------------------------
; MODIFIES: A, X, Y
;
.macro KERNAL_PLOT cursor_x, cursor_y
    ldx #cursor_x
    ldy #cursor_y
    jsr $FFF0
.endmacro

;=================================================
; KERNAL_IOBASE 
;   return start of I/O area
;-------------------------------------------------
; INPUTS:   (none)
;-------------------------------------------------
; OUTPUTS:  X           low-byte of I/O area address
;           y           high-byte of I/O area address
;-------------------------------------------------
; MODIFIES: X, Y
;
.macro KERNAL_IOBASE device
    jsr $FFF3
.endmacro



;=================================================
;=================================================
; 
;   X16-extension kernal calls
;
;-------------------------------------------------
;
; $FF90: SETMSG – set verbosity 
; $FFB7: READST – return status byte 
; $FFBA: SETLFS – set LA, FA and SA 
; $FFBD: SETNAM – set filename 
; $FFC0: OPEN – open a channel 
; $FFC3: CLOSE – close a channel 
; $FFC6: CHKIN – set channel for character input 
; $FFC9: CHKOUT – set channel for character output 
; $FFCC: CLRCHN – restore character I/O to screen/keyboard 
; $FFCF: BASIN – get character 
; $FFD2: BSOUT – write character 
; $FFD5: LOAD – load a file into memory 
; $FFD8: SAVE – save a file from memory 
; $FFE7: CLALL – close all channels
;


.endif ; KERNAL_INC