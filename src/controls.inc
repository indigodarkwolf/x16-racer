
.ifndef CONTROLS_INC
CONTROLS_INC=1

.global handler_b_pressed
.global handler_y_pressed
.global handler_select_pressed
.global handler_start_pressed
.global handler_up_pressed
.global handler_down_pressed
.global handler_left_pressed
.global handler_right_pressed
.global handler_a_pressed
.global handler_x_pressed
.global handler_l_pressed
.global handler_r_pressed

.global handler_b_down
.global handler_y_down
.global handler_select_down
.global handler_start_down
.global handler_up_down
.global handler_down_down
.global handler_left_down
.global handler_right_down
.global handler_a_down
.global handler_x_down
.global handler_l_down
.global handler_r_down

.global controls_initialize
.global controls_process
.global controls_clear_handlers

.global controls_state
.global controls_pressed

;=================================================
; CONTROLS_SET_HANDLER
;   Set a controls handler
;-------------------------------------------------
; INPUTS:   handler     Handler to set
;           proc        Address of procedure to assign to handler
;-------------------------------------------------
; MODIFIES: A,X,Y
; 
.macro CONTROLS_SET_HANDLER handler, proc
.scope
controls_set_handler:
    lda #<proc
    sta handler
    lda #>proc
    sta handler+1
.endscope
.endmacro


.endif ; CONTROLS_INC