;=================================================
;=================================================
; 
;   Headers
;
;-------------------------------------------------

.include "controls.inc"
.include "graphics.inc"
.include "x16/kernal64.inc"
.include "x16/kernalx16.inc"
.include "math.inc"
.include "map.inc"
.include "x16/system.inc"
.include "x16/vera.inc"
.include "x16/ym2151.inc"

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
    SYS_INIT_BANK
    SYS_INIT_IRQ
    SYS_RAND_SEED $34, $56, $fe
    X16_MOUSE_CONFIG 0

    jsr controls_initialize

    X16_I2C_WRITE_BYTE I2C_DEVICE_SMC, SMC_POWER_LED, $FF

    jsr graphics_init
    jsr math_init
    ; MUL_BEGIN
    ; MUL_24_24 Test_dst, Test_lhs, Test_rhs

    YM2151_WRITE $20, $c0 ; Master channel config: C0 = L&R volume ON, no feedback, user OP algorithm 0
    YM2151_WRITE $58, $01 ; Fine detune / phase multiplier: $01 no .\detune and multiplier = 1
    YM2151_WRITE $98, $1F ; Key-scale / Attack Rate: $1f = no keyscale / max attack rate
    YM2151_WRITE $B8, $0d ; Amplitude mod ENABLE / decay rate 1: no AM, Decay = 13
    YM2151_WRITE $F8, $F6 ; sustain level/release rate: hi-nibble is sustain, lo-nibble is release
    YM2151_WRITE $28, $3A ; Set freq to lo note
    YM2151_WRITE $08, $00 ; release previous note
    YM2151_WRITE $08, $40 ; play note

    jsr test_map_draw_column

    jsr bitmap_do
    jsr splash_do
    X16_I2C_WRITE_BYTE I2C_DEVICE_SMC, SMC_POWER_LED, $0
    X16_I2C_WRITE_BYTE I2C_DEVICE_SMC, SMC_ACTIVITY_LED, $FF
    jsr race_do

    jmp *
