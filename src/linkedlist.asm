.define SIZE 100

.byte 

.proc list_remove_avail_foo 		; list_remove_avail_foo(signed char elem)
	tay								; We're going to preserve signed char elem in the Y register because we frequently need it for indexing.
	cmp avail_head_foo				; signed char elem is already in A register.
	bne avail_head_handled
	lda next_foo,y
	cmp avail_head_foo
	bne advance_avail_head
	lda #$FF
	sta avail_head_foo
	bra avail_head_handled

advance_avail_head:
	sta avail_head_foo 				; next_foo[elem] is already in A register
									; We can fall-through to avail_head_handled.
avail_head_handled:
	lda prev_foo,y 					; A now contains prev_foo[elem]
	ldx next_foo,y 					; X now contains next_foo[elem]
	sta prev_foo,x
	tay 							; We no longer need signed char elem, so we'll put prev_foo[elem] in Y.
	txa 							; We need A for storing to absolute address plus index, so we'll put next_foo[elem] in A
	sta next_foo,y
	rts
.endproc

.proc list_remove_used_foo			; list_remove_used_foo(signed char elem)
	tay								; We're going to preserve signed char elem in the Y register because we frequently need it for indexing.
	cmp used_head_foo				; signed char elem is already in A register.
	bne used_head_handled
	lda next_foo,y
	cmp used_head_foo
	bne advance_used_head
	lda #$FF
	sta used_head_foo
	bra used_head_handled

advance_used_head:
	sta used_head_foo 				; next_foo[elem] is already in A register
									; We can fall-through to used_head_handled.
used_head_handled:
	lda prev_foo,y 					; A now contains prev_foo[elem]
	ldx next_foo,y 					; X now contains next_foo[elem]
	sta prev_foo,x
	tay 							; We no longer need signed char elem, so we'll put prev_foo[elem] in Y.
	txa 							; We need A for storing to absolute address plus index, so we'll put next_foo[elem] in A
	sta next_foo,y
	rts
.endproc

.proc list_add_avail_foo            ; void list_add_avail_foo(signed char elem) 
    tay                             ; signed char elem to Y
;	if(avail_head_foo != -1) {
    ldx avail_head_foo
    cpx #$FF
    beq empty_list

;		prev_foo[elem] = prev_foo[avail_head_foo];
    lda prev_foo,x
    sta prev_foo,y

;		next_foo[elem] = avail_head_foo;
    txa                             ; avail_head_foo to A
    sta next_foo,y

;		next_foo[prev_foo[avail_head_foo]] = elem;
    lda prev_foo,x
    tax                             ; prev_foo[avail_head_foo] to X
    tya                             ; elem to A
    sta next_foo,x

;		prev_foo[avail_head_foo] = elem;
    ldx avail_head_foo
    sta prev_foo,x
    rts
;	} else {
empty_list:
;		avail_head_foo = elem;
    sta avail_head_foo
;		next_foo[elem] = elem;
    sta next_foo,y
;		prev_foo[elem] = elem;
    sta prev_foo,y    
;	}
    rts
.endproc

.proc list_add_used_foo            ; void list_add_used_foo(signed char elem) 
    tay                             ; signed char elem to Y
;	if(used_head_foo != -1) {
    ldx used_head_foo
    cpx #$FF
    beq empty_list

;		prev_foo[elem] = prev_foo[used_head_foo];
    lda prev_foo,x
    sta prev_foo,y

;		next_foo[elem] = used_head_foo;
    txa                             ; used_head_foo to A
    sta next_foo,y

;		next_foo[prev_foo[used_head_foo]] = elem;
    lda prev_foo,x
    tax                             ; prev_foo[used_head_foo] to X
    tya                             ; elem to A
    sta next_foo,x

;		prev_foo[used_head_foo] = elem;
    ldx used_head_foo
    sta prev_foo,x
    rts
;	} else {
empty_list:
;		used_head_foo = elem;
    sta used_head_foo
;		next_foo[elem] = elem;
    sta next_foo,y
;		prev_foo[elem] = elem;
    sta prev_foo,y    
;	}
    rts
.endproc

.proc init_list_foo ; void init_list_foo()
;{
;	signed char i;
;	used_head_foo = -1;
    lda #$FF
    sta used_head_foo
;	avail_head_foo = 0;
    stz avail_head_foo
;	allocated_foo[0] = 0;
    stz allocated_foo
;	prev_foo[0] = SIZE-1;
    lda #(SIZE-1)
    sta prev_foo
;	next_foo[0] = 1;
    lda #$1
    sta next_foo
;	for(i=1; i<SIZE-1; ++i) {
    tay
    sec
for_loop:
;		prev_foo[i] = i-1;
        sbc #$01
        sta prev_foo,y
;		next_foo[i] = i+1;
        adc #$02
        sta next_foo,y
;		allocated_foo[i] = 0;
        stz allocated_foo,y
        iny
        tya
        cmp #(SIZE-1)
        bcc for_loop
;	}
;	prev_foo[SIZE-1] = SIZE-2;
    sbc #$01
    sta prev_foo,y
;	next_foo[SIZE-1] = 0;
    stz next_foo,y
;	allocated_foo[SIZE-1] = 0;
    stz allocated_foo,y
;}
    rts
.endproc

.proc alloc_index_foo ; signed char alloc_index_foo()
;{
;	signed char index;
;	if(avail_head_foo != -1) {
    lda avail_head_foo
    cmp #$FF
    beq no_indices_available
;   	index = avail_head_foo;
    pha
;	    list_remove_avail_foo(index);
    jsr list_remove_avail_foo
;	    list_add_used_foo(index);
    pla
    pha
    jsr list_add_used_foo
;	    allocated_foo[index] = 1;
    ply
    lda #$01
    sta allocated_foo,y
;	    return index;
    tya
    rts
;   } else {
;		return -1;
no_indices_available:
    lda #$FF
    rts
;	}
;}
.endproc

.proc free_index_foo ; void free_index_foo(signed char index)
;{
    tay
;	if(allocated_foo[index] != 0) {
    lda allocated_foo,y
    beq already_freed

;	    list_remove_used_foo(index);
    phy
    tya
    jsr list_remove_used_foo

;	    list_add_avail_foo(index);
    pla
    pha
    jsr list_add_avail_foo

;	    allocated_foo[index] = 0;
    ply
    stz allocated_foo,y
    ; fall-through
;   } else {
already_freed:
;		return;
    rts
;	}
;}
.endproc

;#define LIST_INIT(NAME) init_list_foo()
;#define LIST_ALLOC(NAME) alloc_index_foo()
;#define LIST_FREE(NAME, INDEX) free_index_foo(INDEX)

;#define LIST_IS_ALLOCATED(NAME, INDEX) (allocated_foo[INDEX] != 0)
;#define LIST_FOR_EACH(NAME, INDEX_NAME) for(INDEX_NAME=used_head_foo; INDEX_NAME != -1; INDEX_NAME = (next_foo[INDEX_NAME] != used_head_foo ? next_foo[INDEX_NAME] : -1))

