.segment "INIT"
.segment "ONCE"
.segment "CODE"
.data
start_data:
.code

;=================================================
;=================================================
; 
;   Headers
;
;-------------------------------------------------

.include "graphics.inc"
.include "kernal.inc"
.include "math.inc"
.include "system.inc"
.include "vera.inc"
.include "ym2151.inc"

.include "bitmap.inc"
.include "race.inc"
.include "splash.inc"

;=================================================
; Macros
;
;-------------------------------------------------

DEFAULT_SCREEN_ADDR = 0
DEFAULT_SCREEN_SIZE = (128*64)*2

;=================================================
;=================================================
; 
;   main code
;
;-------------------------------------------------
.data
Test_lhs: .byte $03, $00, $00, $00
Test_rhs: .byte $01, $02, $03, $00
Test_dst: .byte $00, $00, $00, $00

.segment "STARTUP"
start:
    SUB_8 Test_dst, Test_lhs, Test_rhs
    SUB_8 Test_dst, Test_lhs, #3
    SUB_8 Test_dst, #2, Test_rhs
    SUB_8 Test_dst, #2, #3

    SYS_INIT_BANK
    SYS_INIT_IRQ
    SYS_RAND_SEED $34, $56, $fe
    SYS_CONFIGURE_MOUSE 0

    jsr graphics_init
    jsr math_init
    ; MUL_BEGIN
    ; MUL_24_24 Test_dst, Test_lhs, Test_rhs

    ; YM2151_WRITE $20, $c0 ; Master channel config: C0 = L&R volume ON, no feedback, user OP algorithm 0
    ; YM2151_WRITE $58, $01 ; Fine detune / phase multiplier: $01 no .\detune and multiplier = 1
    ; YM2151_WRITE $98, $1F ; Key-scale / Attack Rate: $1f = no keyscale / max attack rate
    ; YM2151_WRITE $B8, $0d ; Amplitude mod ENA / 1st decay rate: no AM, Decay = 13
    ; YM2151_WRITE $F8, $F6 ; sustain level/release rate: hi-nibble is sustain, lo-nibble is release
    ; YM2151_WRITE $28, $3A ; Set freq to lo note
    ; YM2151_WRITE $08, $00 ; release previous note
    ; YM2151_WRITE $08, $40 ; play note

    jsr bitmap_do
    lda #2
    jsr graphics_fade_out
    jsr splash_do
    jsr race_do

    jmp *
