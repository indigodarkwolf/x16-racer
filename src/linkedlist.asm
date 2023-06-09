;=================================================
; LIST_INSTANTIATE
;   Instantiate a list's variables here.
;-------------------------------------------------
; INPUTS:   NAME	Quoted string naming the list. This name will be 
;					concatenated into symbol names to create unique symbols 
;					for this list instace.
;			SIZE	Maximum elements in the list.
;-------------------------------------------------
; MODIFIES: (none)
; 
.macro LIST_INSTANTIATE NAME, SIZE

.ident (.concat ("list_", NAME, "_avail_head")): 
	.byte $00

.ident (.concat ("list_", NAME, "_used_head")): 
	.byte $00

.ident (.concat ("list_", NAME, "_next")):
.repeat SIZE
	.byte $00
.endrep

.ident (.concat ("list_", NAME, "_prev")):
.repeat SIZE
	.byte $00
.endrep

.ident (.concat ("list_", NAME, "_allocated")):
.repeat SIZE
	.byte $00
.endrep

.endmacro

;=================================================
; LIST_IMPLEMENT
;   Implement the subroutines for working with a list here.
;-------------------------------------------------
; INPUTS:   NAME	Quoted string naming the list. This name will be 
;					concatenated into symbol names to create unique symbols 
;					for this list instace.
;			SIZE	Maximum elements in the list.
;-------------------------------------------------
; MODIFIES: (none)
; 
.macro LIST_IMPLEMENT NAME, SIZE
.proc .ident (.concat ("list_", NAME, "_remove_avail"))			; .ident (.concat ("list_", NAME, "_remove_avail"))(signed char elem)
	tay														; We're going to preserve signed char elem in the Y register because we frequently need it for indexing.
	cmp .ident (.concat ("list_", NAME, "_avail_head"))				; signed char elem is already in A register.
	bne .ident (.concat ("list_", NAME, "_avail_head_handled"))
	lda .ident (.concat ("list_", NAME, "_next")),y
	cmp .ident (.concat ("list_", NAME, "_avail_head"))
	bne .ident (.concat ("list_", NAME, "_advanced_avail_head"))
	lda #$FF
	sta .ident (.concat ("list_", NAME, "_avail_head"))
	bra .ident (.concat ("list_", NAME, "_avail_head_handled"))

.ident (.concat ("list_", NAME, "_advanced_avail_head")):
	sta .ident (.concat ("list_", NAME, "_avail_head")) 				; .ident (.concat ("list_", NAME, "_next"))[elem] is already in A register
															; We can fall-through to .ident (.concat ("list_", NAME, "_avail_head_handled")).
.ident (.concat ("list_", NAME, "_avail_head_handled")):
	lda .ident (.concat ("list_", NAME, "_prev")),y 					; A now contains .ident (.concat ("list_", NAME, "_prev"))[elem]
	ldx .ident (.concat ("list_", NAME, "_next")),y 					; X now contains .ident (.concat ("list_", NAME, "_next"))[elem]
	sta .ident (.concat ("list_", NAME, "_prev")),x
	tay 													; We no longer need signed char elem, so we'll put .ident (.concat ("list_", NAME, "_prev"))[elem] in Y.
	txa 													; We need A for storing to absolute address plus index, so we'll put .ident (.concat ("list_", NAME, "_next"))[elem] in A
	sta .ident (.concat ("list_", NAME, "_next")),y
	rts
.endproc

.proc .ident (.concat ("list_", NAME, "_remove_used"))			; .ident (.concat ("list_", NAME, "_remove_used"))(signed char elem)
	tay														; We're going to preserve signed char elem in the Y register because we frequently need it for indexing.
	cmp .ident (.concat ("list_", NAME, "_used_head"))				; signed char elem is already in A register.
	bne .ident (.concat ("list_", NAME, "_used_head_handled"))
	lda .ident (.concat ("list_", NAME, "_next")),y
	cmp .ident (.concat ("list_", NAME, "_used_head"))
	bne .ident (.concat ("list_", NAME, "_advance_used_head"))
	lda #$FF
	sta .ident (.concat ("list_", NAME, "_used_head"))
	bra .ident (.concat ("list_", NAME, "_used_head_handled"))

.ident (.concat ("list_", NAME, "_advance_used_head")):
	sta .ident (.concat ("list_", NAME, "_used_head")) 				; .ident (.concat ("list_", NAME, "_next"))[elem] is already in A register
															; We can fall-through to .ident (.concat ("list_", NAME, "_used_head_handled")).
.ident (.concat ("list_", NAME, "_used_head_handled")):
	lda .ident (.concat ("list_", NAME, "_prev")),y 					; A now contains .ident (.concat ("list_", NAME, "_prev"))[elem]
	ldx .ident (.concat ("list_", NAME, "_next")),y 					; X now contains .ident (.concat ("list_", NAME, "_next"))[elem]
	sta .ident (.concat ("list_", NAME, "_prev")),x
	tay 													; We no longer need signed char elem, so we'll put .ident (.concat ("list_", NAME, "_prev"))[elem] in Y.
	txa 													; We need A for storing to absolute address plus index, so we'll put .ident (.concat ("list_", NAME, "_next"))[elem] in A
	sta .ident (.concat ("list_", NAME, "_next")),y
	rts
.endproc

.proc .ident (.concat ("list_", NAME, "_add_avail"))			; void .ident (.concat ("list_", NAME, "_add_avail"))(signed char elem) 
	tay							 							; signed char elem to Y
;	if(.ident (.concat ("list_", NAME, "_avail_head")) != -1) {
	ldx .ident (.concat ("list_", NAME, "_avail_head"))
	cpx #$FF
	beq .ident (.concat ("list_", NAME, "_empty_avail"))

;		.ident (.concat ("list_", NAME, "_prev"))[elem] = .ident (.concat ("list_", NAME, "_prev"))[.ident (.concat ("list_", NAME, "_avail_head"))];
	lda .ident (.concat ("list_", NAME, "_prev")),x
	sta .ident (.concat ("list_", NAME, "_prev")),y

;		.ident (.concat ("list_", NAME, "_next"))[elem] = .ident (.concat ("list_", NAME, "_avail_head"));
	txa							 							; .ident (.concat ("list_", NAME, "_avail_head")) to A
	sta .ident (.concat ("list_", NAME, "_next")),y

;		.ident (.concat ("list_", NAME, "_next"))[.ident (.concat ("list_", NAME, "_prev"))[.ident (.concat ("list_", NAME, "_avail_head"))]] = elem;
	lda .ident (.concat ("list_", NAME, "_prev")),x
	tax							 ; .ident (.concat ("list_", NAME, "_prev"))[.ident (.concat ("list_", NAME, "_avail_head"))] to X
	tya							 							; elem to A
	sta .ident (.concat ("list_", NAME, "_next")),x

;		.ident (.concat ("list_", NAME, "_prev"))[.ident (.concat ("list_", NAME, "_avail_head"))] = elem;
	ldx .ident (.concat ("list_", NAME, "_avail_head"))
	sta .ident (.concat ("list_", NAME, "_prev")),x
	rts
;	} else {
.ident (.concat ("list_", NAME, "_empty_avail")):
;		.ident (.concat ("list_", NAME, "_avail_head")) = elem;
	sta .ident (.concat ("list_", NAME, "_avail_head"))
;		.ident (.concat ("list_", NAME, "_next"))[elem] = elem;
	sta .ident (.concat ("list_", NAME, "_next")),y
;		.ident (.concat ("list_", NAME, "_prev"))[elem] = elem;
	sta .ident (.concat ("list_", NAME, "_prev")),y	
;	}
	rts
.endproc

.proc .ident (.concat ("list_", NAME, "_add_used"))				; void .ident (.concat ("list_", NAME, "_add_used"))(signed char elem) 
	tay							 							; signed char elem to Y
;	if(.ident (.concat ("list_", NAME, "_used_head")) != -1) {
	ldx .ident (.concat ("list_", NAME, "_used_head"))
	cpx #$FF
	beq .ident (.concat ("list_", NAME, "_empty_used"))

;		.ident (.concat ("list_", NAME, "_prev"))[elem] = .ident (.concat ("list_", NAME, "_prev"))[.ident (.concat ("list_", NAME, "_used_head"))];
	lda .ident (.concat ("list_", NAME, "_prev")),x
	sta .ident (.concat ("list_", NAME, "_prev")),y

;		.ident (.concat ("list_", NAME, "_next"))[elem] = .ident (.concat ("list_", NAME, "_used_head"));
	txa							 							; .ident (.concat ("list_", NAME, "_used_head")) to A
	sta .ident (.concat ("list_", NAME, "_next")),y

;		.ident (.concat ("list_", NAME, "_next"))[.ident (.concat ("list_", NAME, "_prev"))[.ident (.concat ("list_", NAME, "_used_head"))]] = elem;
	lda .ident (.concat ("list_", NAME, "_prev")),x
	tax							 							; .ident (.concat ("list_", NAME, "_prev"))[.ident (.concat ("list_", NAME, "_used_head"))] to X
	tya							 							; elem to A
	sta .ident (.concat ("list_", NAME, "_next")),x

;		.ident (.concat ("list_", NAME, "_prev"))[.ident (.concat ("list_", NAME, "_used_head"))] = elem;
	ldx .ident (.concat ("list_", NAME, "_used_head"))
	sta .ident (.concat ("list_", NAME, "_prev")),x
	rts
;	} else {
.ident (.concat ("list_", NAME, "_empty_used")):
;		.ident (.concat ("list_", NAME, "_used_head")) = elem;
	sta .ident (.concat ("list_", NAME, "_used_head"))
;		.ident (.concat ("list_", NAME, "_next"))[elem] = elem;
	sta .ident (.concat ("list_", NAME, "_next")),y
;		.ident (.concat ("list_", NAME, "_prev"))[elem] = elem;
	sta .ident (.concat ("list_", NAME, "_prev")),y	
;	}
	rts
.endproc

.proc .ident (.concat ("list_", NAME, "_init_list")) ; void .ident (.concat ("list_", NAME, "_init_list"))()
;{
;	signed char i;
;	.ident (.concat ("list_", NAME, "_used_head")) = -1;
	lda #$FF
	sta .ident (.concat ("list_", NAME, "_used_head"))
;	.ident (.concat ("list_", NAME, "_avail_head")) = 0;
	stz .ident (.concat ("list_", NAME, "_avail_head"))
;	.ident (.concat ("list_", NAME, "_allocated"))[0] = 0;
	stz .ident (.concat ("list_", NAME, "_allocated"))
;	.ident (.concat ("list_", NAME, "_prev"))[0] = SIZE-1;
	lda #(SIZE-1)
	sta .ident (.concat ("list_", NAME, "_prev"))
;	.ident (.concat ("list_", NAME, "_next"))[0] = 1;
	lda #$1
	sta .ident (.concat ("list_", NAME, "_next"))
	tax
	clc
;	for(i=1; i<SIZE-1; ++i) {
.ident (.concat ("list_", NAME, "_init_for")):
;		.ident (.concat ("list_", NAME, "_next"))[i] = i+1;
		adc #$01
		sta .ident (.concat ("list_", NAME, "_next")),x
;		.ident (.concat ("list_", NAME, "_prev"))[i] = i-1;
		sbc #$01
		sta .ident (.concat ("list_", NAME, "_prev")),x
;		.ident (.concat ("list_", NAME, "_allocated"))[i] = 0;
		stz .ident (.concat ("list_", NAME, "_allocated")),x
		inx
		txa
		cmp #(SIZE-1)
		bcc .ident (.concat ("list_", NAME, "_init_for"))
;	}
;	.ident (.concat ("list_", NAME, "_prev"))[SIZE-1] = SIZE-2;
	sbc #$01
	sta .ident (.concat ("list_", NAME, "_prev")),x
;	.ident (.concat ("list_", NAME, "_next"))[SIZE-1] = 0;
	stz .ident (.concat ("list_", NAME, "_next")),x
;	.ident (.concat ("list_", NAME, "_allocated"))[SIZE-1] = 0;
	stz .ident (.concat ("list_", NAME, "_allocated")),x
;}
	rts
.endproc

.proc .ident (.concat ("list_", NAME, "_alloc_index")) ; signed char .ident (.concat ("list_", NAME, "_alloc_index"))()
;{
;	signed char index;
;	if(.ident (.concat ("list_", NAME, "_avail_head")) != -1) {
	lda .ident (.concat ("list_", NAME, "_avail_head"))
	cmp #$FF
	beq .ident (.concat ("list_", NAME, "_no_indices_available"))
;   	index = .ident (.concat ("list_", NAME, "_avail_head"));
	pha
;		.ident (.concat ("list_", NAME, "_remove_avail"))(index);
	jsr .ident (.concat ("list_", NAME, "_remove_avail"))
;		.ident (.concat ("list_", NAME, "_add_used"))(index);
	pla
	pha
	jsr .ident (.concat ("list_", NAME, "_add_used"))
;		.ident (.concat ("list_", NAME, "_allocated"))[index] = 1;
	ply
	lda #$01
	sta .ident (.concat ("list_", NAME, "_allocated")),y
;		return index;
	tya
	rts
;   } else {
;		return -1;
.ident (.concat ("list_", NAME, "_no_indices_available")):
	lda #$FF
	rts
;	}
;}
.endproc

.proc .ident (.concat ("list_", NAME, "_free_index")) ; void .ident (.concat ("list_", NAME, "_free_index"))(signed char index)
;{
	tax
;	if(.ident (.concat ("list_", NAME, "_allocated"))[index] != 0) {
	lda .ident (.concat ("list_", NAME, "_allocated")),x
	beq .ident (.concat ("list_", NAME, "_already_freed"))

;		.ident (.concat ("list_", NAME, "_remove_used"))(index);
	phx
	txa
	jsr .ident (.concat ("list_", NAME, "_remove_used"))

;		.ident (.concat ("list_", NAME, "_add_avail"))(index);
	pla
	pha
	jsr .ident (.concat ("list_", NAME, "_add_avail"))

;		.ident (.concat ("list_", NAME, "_allocated"))[index] = 0;
	plx
	stz .ident (.concat ("list_", NAME, "_allocated")),x
	; fall-through
;   } else {
.ident (.concat ("list_", NAME, "_already_freed")):
;		return;
	rts
;	}
;}
.endproc

.endmacro

;==============================
;
; Public API
;
;------------------------------

.macro LIST_INIT NAME
	jsr .ident (.concat ("list_", NAME, "_init_list"))
.endmacro

.macro LIST_ALLOC NAME
	jsr .ident (.concat ("list_", NAME, "_alloc_index"))
.endmacro

.macro LIST_FREE NAME, ADDR
	.ifnblank ADDR
		lda ADDR
	.endif
	jsr .ident (.concat ("list_", NAME, "_free_index"))
.endmacro

;==============================
;
; Example use
;
;------------------------------

LIST_INSTANTIATE "foo", 100
LIST_IMPLEMENT "foo", 100

.proc list_test
	LIST_INIT "foo"
	LIST_ALLOC "foo"	; Allocates index 0
	LIST_ALLOC "foo"	; Allocates index 1
	LIST_ALLOC "foo"	; Allocates index 2
	LIST_ALLOC "foo"	; Allocates index 3
	LIST_ALLOC "foo"	; Allocates index 4
	lda #2
	LIST_FREE "foo"		; Frees index 2
.endproc
.export list_test

;#define LIST_IS_ALLOCATED(NAME, INDEX) (.ident (.concat ("list_", NAME, "_allocated"))[INDEX] != 0)
;#define LIST_FOR_EACH(NAME, INDEX_NAME) for(INDEX_NAME=.ident (.concat ("list_", NAME, "_used_head")); INDEX_NAME != -1; INDEX_NAME = (.ident (.concat ("list_", NAME, "_next"))[INDEX_NAME] != .ident (.concat ("list_", NAME, "_used_head")) ? .ident (.concat ("list_", NAME, "_next"))[INDEX_NAME] : -1))

