.ifndef MAP_INC
MAP_INC=1

MAP_BANK_START = 32

.global map_incr_view_x
.global map_incr_view_y
.global map_decr_view_x
.global map_decr_view_y
.global map_reset_view

.global test_map_draw_column

;=================================================
; MAP_LOAD
;   Load a map into the map banks
;
;-------------------------------------------------
; INPUTS:   name_len
;           name_addr
;
;-------------------------------------------------
; MODIFIES: A, X, Y
.macro MAP_LOAD name_len, name_addr
    SYS_SET_BANK MAP_BANK_START
    KERNAL_SETLFS 1, 8, 0
    KERNAL_SETNAM name_len, name_addr
    KERNAL_LOAD 0, $A000

    jsr map_reset_view
.endmacro

.endif ; MAP_INC