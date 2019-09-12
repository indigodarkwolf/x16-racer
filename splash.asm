; !ifdef SPLASH_ASM !eof
; SPLASH_ASM=1

!src "vera.inc"
!src "system.inc"

!ifndef SPLASH_ADDR { SPLASH_ADDR=0 }

;=================================================
;=================================================
; 
;   Code
;
;-------------------------------------------------
;
; Do a splash screen with my logo.
; Return to caller when done.
;
splash_do:
    ; Copy the logo into video memory
    +VERA_SET_ADDR SPLASH_ADDR
    +SYS_STREAM_OUT Splash_logo, VERA_data

    +VERA_SET_SPRITE 0
    +VERA_WRITE <(SPLASH_ADDR >> 5), >((SPLASH_ADDR >> 5) & $0F)
    +VERA_WRITE (320-32)
    +VERA_WRITE 0
    +VERA_WRITE (240-32)
    +VERA_WRITE 0
    +VERA_WRITE %00000100
    +VERA_WRITE %10100000
    rts

!src "system.asm"