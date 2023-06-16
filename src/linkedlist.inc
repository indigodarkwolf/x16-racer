.ifndef LINKEDLIST_INC
LINKEDLIST_INC=1

;=================================================
;=================================================
;
;   Cheatsheet / Quick Reference
;
;-------------------------------------------------
;
;	Macros to assist in implementing and using linked lists of up to 255 elements.
;
;	Any .h/.inc file: 				LIST_DECLARE "list_name"
;	List's .asm file or segment: 	LIST_INSTANTIATE "list_name", list_size
; 	List's .asm file: 				LIST_IMPLEMENT "list_name", list_size
;	Other .asm files: 				See "Public API"
;
;	"list_name"			is the name of a list. Each different list needs a unique name.
;						The name cannot contain spaces or special characters, because these
;						list macros insert the name into the names of symbols it creates.
;
;	list_size			is the maximum size of the list, from 2 to 255. If you need more
;						than 255 items, you will need more lists or you should consider
;						a different, 16-bit implementation. If you need fewer than 2
;						items, you do not need a list.
;
;	LIST_DECLARE 		is a bunch of .global statements that ensure the list's relevant 
;				 		symbols are exported or imported, as necessary.
;
;	LIST_INSTANTIATE	declares a set of named variables which contain list indices
;						totaling 2 + 3 * list_size bytes.
;
;	LIST_IMPLEMENT		inserts all of the code needed to manage a linked list.
;
;	| Public API												| Registers |
;	|-----------------------------------------------------------+-----------|
; 	|	LIST_INIT "list_name"									| A, X		|
;	|	LIST_ALLOC "list_name"									| A, X, Y	|
; 	|	LIST_FREE "list_name", IDX_ADDR							| A, X, Y	|
; 	|	LIST_GET_FIRST "list_name"								| A			|
; 	|	LIST_GET_NEXT "list_name", IDX_ADDR						| A, X		|
; 	|	LIST_GET_PREV "list_name", IDX_ADDR						| A, X		|
; 	|	LIST_GET_ALLOCATED "list_name", IDX_ADDR				| A, X		|
; 	|	LIST_FOR_BEGIN "list_name", FOR_LABEL, PUSH_METHOD		| A			|
; 	|	LIST_FOR_CONTINUE "list_name", FOR_LABEL				| 			|
; 	|	LIST_FOR_END "list_name", FOR_LABEL, PULL_METHOD		| A, X		|
;
;	Note: Be aware that the list API does not intentionally preserve any registers.
;		  Preserve any CPU registers you need before invoking list API functions.
;
;	Note(2): LIST_FOR_* macros use branch instructions as opposed to jump instructions.
;			 If your for-loop is large enough that it cannot be traversed with branch
;			 instructions, consider implementing its contents as subroutines and use
;			 jsr, as the memory and cycle overhead of jsr/rts will be less than the
;			 overhead of branching logic to choose whether/which jmp instruction to
;			 execute.
;
;	IDX_ADDR			is an optional parameter that is the memory location of the
;						index to be operated on, in case that index is not already
;						going to be in the accumulator. If omitted, the list API expects
;						the list index to be in the accumulator.
;
;	FOR_LABEL			is a string uniquely identifying the for-loop within the current scope.
;						The string cannot contain spaces or special characters, because these
;						list macros insert the string into the symbols it creates.
;
;	PUSH_METHOD			is a single, whole instruction used by LIST_FOR_BEGIN to push or store the loop variable,
;						which will be in the accumulator. As such, it is only appropriate to use instructions
;						that store the accumulator (i.e. pha or sta).
;
;	PULL_METHOD			is a single, whole instruction used by LIST_FOR_CONTINUE and LIST_FOR_END to retrieve
;						the loop variable into the accumulator. As such, it is only appropriate to use
;						instructions that read into the accumulator (i.e. pla or lda).
;
;	LIST_INIT			initializes a given list to an "empty" state. All list nodes
;						are contained in a "free list", and as elements are allocated, 
;						they are moved from the "free list" into a "used list".
;
;	LIST_ALLOC			moves the first item from the "free list" into the "used list"
;						and returns the index of that item in the accumulator.
;
;	LIST_FREE			moves the specified item (index in the accumulator or at the 
;						specified address) from the "used list" into the "free list".
;
;	LIST_GET_FIRST		gets the index of the first element in the "used list", or 
;						#$FF if the used list is empty, and returns it in the accumulator.
;
;	LIST_GET_NEXT		gets the next index in the list, using the index in the accumulator
;						or the specified address.
;
;	LIST_GET_PREV		gets previous index in the list, using the index in the accumulator
;						or the specified address.
;
;	LIST_GET_ALLOCATED	gets whether the index in the accumulator or specified address is
;						allocated. non-zero indicates the index is allocated, zero indicates
;						it is not.
;
;	LIST_FOR_BEGIN		implements the start of a for-loop iterating through a list.
;
;	LIST_FOR_CONTINUE	skips to the end of a for-loop.
;
;	LIST_FOR_END		implements the tail of a for-loop iterating through a list.
;
;

;=================================================
; LIST_DECLARE
;   Declare a list's symbols as globals, for header files.
;-------------------------------------------------
; INPUTS:   NAME	Quoted string naming the list. This name will be 
;					concatenated into symbol names to create unique symbols 
;					for this list instace.
;-------------------------------------------------
; MODIFIES: (none)
; 
.macro LIST_DECLARE NAME
.global .ident (.concat ("list_", NAME, "_avail_head"))
.global .ident (.concat ("list_", NAME, "_used_head")) 
.global .ident (.concat ("list_", NAME, "_next"))
.global .ident (.concat ("list_", NAME, "_prev"))
.global .ident (.concat ("list_", NAME, "_allocated"))

.global .ident (.concat ("list_", NAME, "_init_list"))
.global .ident (.concat ("list_", NAME, "_alloc_index"))
.global .ident (.concat ("list_", NAME, "_free_index"))
.endmacro

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

; list_*_remove_avail modifies A, X, Y
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

; list_*_remove_used modifies A, X, Y
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

; list_*_add_avail modifies A, X, Y
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

; list_*_add_used modifies A, X, Y
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

; list_*_init_list modifies A, X
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

; list_*_alloc_index modifies A, X, Y
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

; list_*_free_index modifies A, X, Y
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

;=================================================
;=================================================
;
; Public API Macros
;
;-------------------------------------------------

.macro LIST_INIT NAME
	jsr .ident (.concat ("list_", NAME, "_init_list"))
.endmacro

.macro LIST_ALLOC NAME
	jsr .ident (.concat ("list_", NAME, "_alloc_index"))
.endmacro

.macro LIST_FREE NAME, IDX_ADDR
	.ifnblank IDX_ADDR
		lda IDX_ADDR
	.endif
	jsr .ident (.concat ("list_", NAME, "_free_index"))
.endmacro

.macro LIST_GET_FIRST NAME
	lda .ident (.concat ("list_", NAME, "_used_head"))
.endmacro

.macro LIST_GET_NEXT NAME, IDX_ADDR
	.ifnblank IDX_ADDR
		ldx IDX_ADDR
	.else
		tax
	.endif
	lda .ident (.concat ("list_", NAME, "_next")),x
.endmacro

.macro LIST_GET_PREV NAME, IDX_ADDR
	.ifnblank IDX_ADDR
		ldx IDX_ADDR
	.else
		tax
	.endif
	lda .ident (.concat ("list_", NAME, "_next")),x
.endmacro

.macro LIST_GET_ALLOCATED NAME, IDX_ADDR
	.ifnblank IDX_ADDR
		ldx IDX_ADDR
	.else
		tax
	.endif
	lda .ident (.concat ("list_", NAME, "_allocated")),x
.endmacro

;#define LIST_FOR_EACH(NAME, INDEX_NAME) for(INDEX_NAME=.ident (.concat ("list_", NAME, "_used_head")); INDEX_NAME != -1; INDEX_NAME = (.ident (.concat ("list_", NAME, "_next"))[INDEX_NAME] != .ident (.concat ("list_", NAME, "_used_head")) ? .ident (.concat ("list_", NAME, "_next"))[INDEX_NAME] : -1))
.macro LIST_FOR_BEGIN NAME, FOR_LABEL, PUSH_METHOD
.ident (.concat (NAME, "_", FOR_LABEL, "_begin")):
	LIST_GET_FIRST NAME
	cmp #$FF
	beq .ident (.concat (NAME, "_", FOR_LABEL, "_end"))
.ident (.concat (NAME, "_", FOR_LABEL)):
	PUSH_METHOD
.endmacro

.macro LIST_FOR_CONTINUE NAME, FOR_LABEL
	bra .ident (.concat (NAME, "_", FOR_LABEL, "_continue"))
.endmacro

.macro LIST_FOR_END NAME, FOR_LABEL, PULL_METHOD
.ident (.concat (NAME, "_", FOR_LABEL, "_continue")):
	PULL_METHOD
	LIST_GET_NEXT NAME
	cmp .ident (.concat ("list_", NAME, "_used_head"))
	bne .ident (.concat (NAME, "_", FOR_LABEL))
.ident (.concat (NAME, "_", FOR_LABEL, "_end")):
.endmacro

.endif ; LINKEDLIST_INC