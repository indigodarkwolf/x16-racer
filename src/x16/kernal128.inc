.ifndef KERNAL128_INC
KERNAL128_INC=1

;=================================================
;=================================================
;
;   C128-compatible kernal calls
;
;-------------------------------------------------
;
; Directly compatible
;
; $FF4A: CLOSE_ALL - close all files on a device
; $FF59: LKUPLA - search tables for given LA
; $FF5C: LKUPSA - search tables for given SA
; $FF65: PFKEY - program a function key [not yet implemented]
; $FF7D: PRIMM - print string following the caller’s code
;
; Analogous but not compatible
;
; $FF5F: SWAPPER - screen_mode
; $FF62: DLCHR - screen_set_charset
; $FF74: FETCH - fetch
; $FF77: STASH - stash
; 

;=================================================
; KERNAL_CLOSE_ALL
;   close all files on a device.
;-------------------------------------------------
; INPUTS:   device    device number.
;
;-------------------------------------------------
; OUTPUTS:  (none)
;-------------------------------------------------
; MODIFIES: A
; 
.macro KERNAL_CLOSE_ALL device
    lda #device
    jsr CLOSE_ALL
.endmacro

;=================================================
; KERNAL_LKUPLA
;   search tables for given LA
;-------------------------------------------------
; INPUTS:   la      LA to search for
;-------------------------------------------------
; OUTPUTS:  A       LA (if found)
;           X       FA (if found)
;           Y       SA (if found)
;           Carry   0 if found
;                   1 if not found
;-------------------------------------------------
; MODIFIES: A, X, Y, Carry
; 
.macro KERNAL_LKUPLA la
    lda #la
    jsr LKUPLA
.endmacro

;=================================================
; KERNAL_LKUPSA
;   search tables for given SA
;-------------------------------------------------
; INPUTS:   sa      SA to search for
;-------------------------------------------------
; OUTPUTS:  A       LA (if found)
;           X       FA (if found)
;           Y       SA (if found)
;           Carry   0 if found
;                   1 if not found
;-------------------------------------------------
; MODIFIES: A, X, Y, Carry
; 
.macro KERNAL_LKUPSA sa
    ldy #sa
    jsr LKUPSA
.endmacro

;=================================================
; KERNAL_PFKEY
;   program a function key [not yet implemented]
;-------------------------------------------------
; INPUTS:   (none)
;-------------------------------------------------
; OUTPUTS:  (none)
;-------------------------------------------------
; MODIFIES: (none)
; 
.macro KERNAL_PFKEY
.endmacro

;=================================================
; KERNAL_PRIMM
;   print a null-terminated string following the caller’s code
;-------------------------------------------------
; INPUTS:   (none)
;-------------------------------------------------
; OUTPUTS:  (none)
;-------------------------------------------------
; MODIFIES: (none)
; 
.macro KERNAL_PRIMM string
    jsr PRIMM
    .byte string
    .byte $00
.endmacro

.endif ; KERNAL128_INC