.include "controls.inc"
.include "x16/kernalx16.inc"

.segment "LOWMEM"
controls_last_state: .res 3 ; = $0400 ; .byte $00, $00, $00
controls_state:      .res 3 ; $0403 ; .byte $00, $00, $00
controls_pressed:    .res 2 ; .byte $00, $00

handle_b_pressed:         .res 3 ; jmp controls_nop
handle_y_pressed:         .res 3 ; jmp controls_nop
handle_select_pressed:    .res 3 ; jmp controls_nop
handle_start_pressed:     .res 3 ; jmp controls_nop
handle_up_pressed:        .res 3 ; jmp controls_nop
handle_down_pressed:      .res 3 ; jmp controls_nop
handle_left_pressed:      .res 3 ; jmp controls_nop
handle_right_pressed:     .res 3 ; jmp controls_nop
handle_a_pressed:         .res 3 ; jmp controls_nop
handle_x_pressed:         .res 3 ; jmp controls_nop
handle_l_pressed:         .res 3 ; jmp controls_nop
handle_r_pressed:         .res 3 ; jmp controls_nop

handle_b_down:         .res 3 ; jmp controls_nop
handle_y_down:         .res 3 ; jmp controls_nop
handle_select_down:    .res 3 ; jmp controls_nop
handle_start_down:     .res 3 ; jmp controls_nop
handle_up_down:        .res 3 ; jmp controls_nop
handle_down_down:      .res 3 ; jmp controls_nop
handle_left_down:      .res 3 ; jmp controls_nop
handle_right_down:     .res 3 ; jmp controls_nop
handle_a_down:         .res 3 ; jmp controls_nop
handle_x_down:         .res 3 ; jmp controls_nop
handle_l_down:         .res 3 ; jmp controls_nop
handle_r_down:         .res 3 ; jmp controls_nop

handler_b_pressed      = handle_b_pressed + 1
handler_y_pressed      = handle_y_pressed + 1
handler_select_pressed = handle_select_pressed + 1
handler_start_pressed  = handle_start_pressed + 1
handler_up_pressed     = handle_up_pressed + 1
handler_down_pressed   = handle_down_pressed + 1
handler_left_pressed   = handle_left_pressed + 1
handler_right_pressed  = handle_right_pressed + 1
handler_a_pressed      = handle_a_pressed + 1
handler_x_pressed      = handle_x_pressed + 1
handler_l_pressed      = handle_l_pressed + 1
handler_r_pressed      = handle_r_pressed + 1

handler_b_down      = handle_b_down + 1
handler_y_down      = handle_y_down + 1
handler_select_down = handle_select_down + 1
handler_start_down  = handle_start_down + 1
handler_up_down     = handle_up_down + 1
handler_down_down   = handle_down_down + 1
handler_left_down   = handle_left_down + 1
handler_right_down  = handle_right_down + 1
handler_a_down      = handle_a_down + 1
handler_x_down      = handle_x_down + 1
handler_l_down      = handle_l_down + 1
handler_r_down      = handle_r_down + 1

.code
controls_nop:
    rts

.proc controls_initialize
controls_initialize_state:
    ldx #8
state_loop:
    dex
    stz controls_last_state, x
    bne state_loop
    
    jsr controls_initialize_handlers

    X16_JOYSTICK_SCAN
    X16_JOYSTICK_GET 0
    eor #$ff
    sta controls_state
    txa
    eor #$ff
    sta controls_state+1
    tya
    eor #$ff
    sta controls_state+2
    rts
.endproc

.proc controls_process
    X16_JOYSTICK_SCAN
    X16_JOYSTICK_GET 1
    eor #$ff
    sta controls_state
    txa
    eor #$ff
    sta controls_state+1
    tya
    eor #$ff
    sta controls_state+2

.repeat 2,i
    lda controls_last_state+i
    and controls_state+i
    sta controls_pressed+i
.endrep

check_buttons_pressed:
    ; controls_pressed + 1 is already in A, from above
    ora controls_pressed
    beq check_buttons_down

    lda controls_pressed
check_b_pressed:
    bpl check_y_pressed
    pha
    jsr handle_b_pressed
    pla
check_y_pressed:
    rol
    bpl check_sel_pressed
    pha
    jsr handle_y_pressed
    pla
check_sel_pressed:
    rol
    bpl check_start_pressed
    pha
    jsr handle_select_pressed
    pla
check_start_pressed:
    rol
    bpl check_up_pressed
    pha
    jsr handle_start_pressed
    pla
check_up_pressed:
    rol
    bpl check_down_pressed
    pha
    jsr handle_up_pressed
    pla
check_down_pressed:
    rol
    bpl check_left_pressed
    pha
    jsr handle_down_pressed
    pla
check_left_pressed:
    rol
    bpl check_right_pressed
    pha
    jsr handle_left_pressed
    pla
check_right_pressed:
    rol
    bpl check_a_pressed
    pha
    jsr handle_right_pressed
    pla
check_a_pressed:
    lda controls_pressed+1
    bpl check_x_pressed
    pha
    jsr handle_a_pressed
    pla
check_x_pressed:
    rol
    bpl check_l_pressed
    pha
    jsr handle_x_pressed
    pla
check_l_pressed:
    rol
    bpl check_r_pressed
    pha
    jsr handle_l_pressed
    pla
check_r_pressed:
    rol
    bpl check_buttons_down
    pha
    jsr handle_r_pressed
    pla

check_buttons_down:
    lda controls_state
    and controls_state+1
    eor #$ff
    beq done

    lda controls_state
check_b_down:
    bpl check_y_down
    pha
    jsr handle_b_down
    pla
check_y_down:
    rol
    bpl check_sel_down
    pha
    jsr handle_y_down
    pla
check_sel_down:
    rol
    bpl check_start_down
    pha
    jsr handle_select_down
    pla
check_start_down:
    rol
    bpl check_up_down
    pha
    jsr handle_start_down
    pla
check_up_down:
    rol
    bpl check_down_down
    pha
    jsr handle_up_down
    pla
check_down_down:
    rol
    bpl check_left_down
    pha
    jsr handle_down_down
    pla
check_left_down:
    rol
    bpl check_right_down
    pha
    jsr handle_left_down
    pla
check_right_down:
    rol
    bpl check_a_down
    pha
    jsr handle_right_down
    pla
check_a_down:
    lda controls_state+1
    bpl check_x_down
    pha
    jsr handle_a_down
    pla
check_x_down:
    rol
    bpl check_l_down
    pha
    jsr handle_x_down
    pla
check_l_down:
    rol
    bpl check_r_down
    pha
    jsr handle_l_down
    pla
check_r_down:
    rol
    bpl done
    pha
    jsr handle_r_down
    pla

done:

.repeat 3,i
    lda controls_state+i
    sta controls_last_state+i
.endrep

    rts
.endproc

.proc controls_initialize_handlers
    ldx #72
loop:
    lda #>controls_nop
    sta handle_b_pressed-1, x
    dex
    lda #<controls_nop
    sta handle_b_pressed-1, x
    dex
    lda #$4C ; jmp absolute
    sta handle_b_pressed-1, x
    dex
    bne loop
    rts
.endproc

.proc controls_clear_handlers
    ldx #72
loop:
    lda #>controls_nop
    sta handle_b_pressed-1, x
    dex
    lda #<controls_nop
    sta handle_b_pressed-1, x
    dex
    dex
    bne loop
    rts
.endproc