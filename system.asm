; !ifdef SYSTEM_ASM !eof
; SYSTEM_ASM=1

!src "system.inc"
!src "vera.inc"

;=================================================
;=================================================
;
;   Random number generation
;
;-------------------------------------------------
;
; This random number generation routine is based
; on a linear feedback shift register, or LFSR.
; It's a common technique for generating complex
; sequences of values.
;
; This specific implementation is based on:
; https://wiki.nesdev.com/w/index.php/Random_number_generator/Linear_feedback_shift_register_(advanced)
;

;=================================================
; sys_rand
;   Generate an 8-bit random number.
;-------------------------------------------------
; INPUTS:   Sys_rand_mem
;
;-------------------------------------------------
; MODIFIES: A, X, Sys_rand_mem
; 

sys_rand:
    ldx #8
    lda Sys_rand_mem
-   asl
    rol Sys_rand_mem+1
    rol Sys_rand_mem+2
    bcc +
    eor #$1B
+   dex
    bne -
    sta Sys_rand_mem
    cmp #0
    rts

;=================================================
; sys_inc_frame
;   Wait for a new frame
;-------------------------------------------------
; INPUTS:   (none)
;
;-------------------------------------------------
; MODIFIES: A, X, $
; 

sys_wait_for_frame:
    ldx Sys_frame
    inx

    +SYS_SET_IRQ sys_inc_frame
    cli

    ; Tight loop until next frame
-   cpx Sys_frame
    bne -

    sei
    rts

;=================================================
; sys_inc_new_frame
;   Increment a value when a new frame arrives
;-------------------------------------------------
; INPUTS:   (none)
;
;-------------------------------------------------
; MODIFIES: New_frame
; 
sys_inc_frame:
    inc Sys_frame
    +VERA_END_IRQ
    +SYS_END_IRQ