; mountain_palette (raw):
; 	0x00 0x00 0x00 0xcd 0xd6 0xc5 0x94 0x89 0x6a 0xa4 0xa1 0x83 0x73 0x5d 0x31 0x31 0x24 0x08 0xb4 0xbe 0xac 0x5a 0x48 0x20 0x52 0x38 0x10 0x83 0x71 0x4a 0x83 0x79 0x5a 0xa4 0xaa 0x9c 0xcd 0xca 0xb4 0xd5 0xe6 0xd5 0x00 0xf2 0xff 
mountain_palette:
	.word $0000, $0cdc, $0986, $0aa8, $0753, $0320, $0bba, $0542, $0531, $0874, $0875, $0aa9, $0ccb, $0ded, $00ff

mountain:
mountain_00_00:
	.byte $ee, $ee, $ee, $ee
	.byte $ee, $ee, $ee, $ee
	.byte $ee, $ee, $ee, $ee
	.byte $ee, $ee, $ee, $ee
	.byte $ee, $ee, $ee, $ee
	.byte $ee, $ee, $ee, $ee
	.byte $ee, $ee, $ee, $ee
	.byte $ee, $ee, $ee, $ee
mountain_00_03:
	.byte $ee, $ee, $ee, $ee
	.byte $ee, $ee, $ee, $ee
	.byte $ee, $ee, $ee, $ee
	.byte $ee, $ee, $ee, $df
	.byte $ee, $ee, $cd, $ff
	.byte $ee, $ec, $dd, $ff
	.byte $eb, $c1, $df, $ff
	.byte $b6, $1d, $ff, $ff
mountain_00_04:
	.byte $ee, $ee, $ee, $ee
	.byte $ee, $ee, $ee, $ee
	.byte $ee, $ee, $ee, $ee
	.byte $fd, $ce, $ee, $ee
	.byte $ff, $d1, $ee, $ee
	.byte $ff, $dd, $d6, $ee
	.byte $ff, $dd, $1d, $1e
	.byte $fd, $dd, $dd, $cc
mountain_01_01:
	.byte $ee, $ee, $ee, $ee
	.byte $ee, $ee, $ee, $ee
	.byte $ee, $ee, $ee, $ee
	.byte $ee, $ee, $ee, $ee
	.byte $ee, $ee, $ee, $ee
	.byte $ee, $ee, $ee, $ee
	.byte $ee, $ee, $ee, $ee
	.byte $ee, $ee, $ee, $e3
mountain_01_02:
	.byte $ee, $ee, $ee, $bb
	.byte $ee, $ee, $eb, $bb
	.byte $ee, $ee, $bb, $b6
	.byte $ee, $eb, $bb, $6c
	.byte $ee, $3b, $b6, $6c
	.byte $e3, $bb, $cc, $cc
	.byte $3b, $bc, $cc, $c6
	.byte $bb, $cc, $1c, $66
mountain_01_03:
	.byte $61, $dd, $df, $fd
	.byte $c1, $dd, $dd, $dd
	.byte $11, $1d, $dd, $dd
	.byte $11, $11, $dd, $dd
	.byte $cc, $11, $dd, $dd
	.byte $6c, $11, $dd, $dd
	.byte $6c, $1d, $dd, $dd
	.byte $61, $1d, $dd, $dd
mountain_01_04:
	.byte $dd, $dd, $1d, $1c
	.byte $dd, $dd, $dc, $dc
	.byte $dd, $dd, $d1, $c1
	.byte $dd, $dd, $dd, $1c
	.byte $dd, $d1, $1d, $1c
	.byte $dd, $11, $dc, $cc
	.byte $d1, $1d, $11, $cc
	.byte $1c, $c1, $dc, $1c
mountain_01_05:
	.byte $ce, $ee, $ee, $ee
	.byte $cb, $ee, $ee, $ee
	.byte $cc, $2e, $ee, $ee
	.byte $cc, $c2, $ee, $ee
	.byte $cc, $cc, $2e, $ee
	.byte $cc, $36, $6a, $ee
	.byte $6c, $c3, $6c, $94
	.byte $66, $6c, $26, $94
mountain_01_06:
	.byte $ee, $ee, $ee, $ee
	.byte $ee, $ee, $ee, $ee
	.byte $ee, $ee, $ee, $ee
	.byte $ee, $ee, $ee, $ee
	.byte $ee, $ee, $ee, $ee
	.byte $ee, $ee, $ee, $ee
	.byte $ee, $ee, $ee, $ee
	.byte $4e, $ee, $ee, $ee
mountain_02_00:
	.byte $ee, $ee, $ee, $ee
	.byte $ee, $ee, $ee, $ee
	.byte $ee, $ee, $ee, $ee
	.byte $ee, $ee, $ee, $ee
	.byte $ee, $ee, $ee, $ee
	.byte $ee, $ee, $ee, $ee
	.byte $ee, $ee, $ee, $ee
	.byte $ee, $ee, $ee, $e2
mountain_02_01:
	.byte $ee, $ee, $ee, $3b
	.byte $ee, $ee, $eb, $bb
	.byte $ee, $ee, $bb, $bb
	.byte $ee, $eb, $bb, $b6
	.byte $ee, $bb, $bb, $bb
	.byte $e3, $bb, $b3, $bb
	.byte $b3, $b3, $22, $bb
	.byte $23, $32, $2a, $b2
mountain_02_02:
	.byte $b6, $cc, $c6, $66
	.byte $66, $66, $66, $66
	.byte $66, $66, $66, $66
	.byte $b6, $66, $66, $66
	.byte $bb, $66, $66, $66
	.byte $bb, $bb, $66, $66
	.byte $bb, $bb, $66, $66
	.byte $bb, $bb, $b6, $66
mountain_02_03:
	.byte $c1, $1d, $dd, $dd
	.byte $6c, $1d, $dd, $11
	.byte $6c, $1d, $dd, $cc
	.byte $6c, $1d, $dd, $cc
	.byte $66, $11, $dd, $1c
	.byte $66, $c1, $dd, $1c
	.byte $66, $6c, $1d, $d1
	.byte $66, $66, $1d, $d1
mountain_02_04:
	.byte $11, $cc, $dc, $1c
	.byte $dc, $1c, $1c, $1c
	.byte $c1, $cc, $c1, $c1
	.byte $c1, $cc, $cc, $cc
	.byte $cc, $11, $cc, $cc
	.byte $cc, $11, $1c, $c6
	.byte $1c, $11, $d1, $c6
	.byte $cc, $c1, $1c, $c6
mountain_02_05:
	.byte $66, $66, $6a, $66
	.byte $cb, $66, $66, $4a
	.byte $16, $36, $96, $67
	.byte $c6, $66, $a9, $97
	.byte $6c, $c6, $69, $99
	.byte $c6, $62, $66, $49
	.byte $c3, $66, $26, $44
	.byte $c6, $c6, $62, $44
mountain_02_06:
	.byte $94, $ee, $ee, $ee
	.byte $a4, $4e, $ee, $ee
	.byte $a4, $47, $7e, $ee
	.byte $44, $44, $77, $ee
	.byte $74, $44, $77, $7e
	.byte $97, $44, $77, $77
	.byte $44, $74, $77, $47
	.byte $44, $77, $47, $47
mountain_02_07:
	.byte $ee, $ee, $ee, $ee
	.byte $ee, $ee, $ee, $ee
	.byte $ee, $ee, $ee, $ee
	.byte $ee, $ee, $ee, $ee
	.byte $ee, $ee, $ee, $ee
	.byte $ee, $ee, $ee, $ee
	.byte $7e, $ee, $ee, $ee
	.byte $74, $ee, $ee, $ee
mountain_03_00:
	.byte $ee, $ee, $ee, $a2
	.byte $ee, $ee, $e4, $79
	.byte $ee, $e7, $74, $47
	.byte $ee, $77, $77, $77
	.byte $77, $87, $77, $77
	.byte $77, $47, $77, $77
	.byte $88, $74, $77, $77
	.byte $84, $77, $77, $75
mountain_03_01:
	.byte $22, $a9, $99, $99
	.byte $99, $44, $44, $44
	.byte $77, $77, $77, $78
	.byte $55, $88, $85, $58
	.byte $55, $55, $55, $5b
	.byte $55, $55, $55, $88
	.byte $55, $55, $55, $78
	.byte $55, $55, $55, $78
mountain_03_02:
	.byte $ab, $3b, $b6, $b6
	.byte $42, $3b, $bb, $66
	.byte $49, $bb, $bb, $66
	.byte $7b, $9b, $bb, $66
	.byte $b8, $74, $ab, $bb
	.byte $78, $87, $ba, $bb
	.byte $88, $88, $79, $a9
	.byte $58, $55, $87, $44
mountain_03_03:
	.byte $66, $66, $c1, $dd
	.byte $66, $66, $6c, $dd
	.byte $bb, $66, $66, $b6
	.byte $b3, $3b, $36, $6b
	.byte $b2, $bb, $2b, $bb
	.byte $ab, $b4, $bb, $b8
	.byte $9b, $77, $b8, $78
	.byte $47, $88, $88, $78
mountain_03_04:
	.byte $dc, $cc, $cc, $c6
	.byte $dd, $6c, $cc, $c6
	.byte $6b, $b6, $6c, $cc
	.byte $66, $6b, $6c, $c6
	.byte $bb, $bb, $b6, $c6
	.byte $bb, $bb, $b3, $66
	.byte $8b, $bb, $bb, $3b
	.byte $58, $77, $4a, $23
mountain_03_05:
	.byte $66, $66, $66, $64
	.byte $c6, $c6, $66, $29
	.byte $c6, $66, $66, $42
	.byte $cc, $66, $66, $64
	.byte $6c, $c6, $66, $66
	.byte $66, $66, $66, $66
	.byte $b6, $66, $b6, $36
	.byte $33, $66, $bb, $66
mountain_03_06:
	.byte $44, $47, $97, $74
	.byte $44, $47, $44, $47
	.byte $47, $78, $84, $48
	.byte $a7, $78, $57, $47
	.byte $a9, $47, $58, $77
	.byte $a9, $97, $55, $57
	.byte $6a, $99, $45, $55
	.byte $32, $29, $47, $55
mountain_03_07:
	.byte $77, $4e, $ee, $ee
	.byte $78, $47, $ee, $ee
	.byte $77, $84, $8e, $ee
	.byte $77, $77, $77, $ee
	.byte $77, $47, $74, $74
	.byte $77, $74, $77, $87
	.byte $77, $57, $47, $77
	.byte $54, $78, $74, $88
mountain_04_00:
	.byte $87, $77, $78, $75
	.byte $47, $74, $47, $78
	.byte $29, $94, $44, $77
	.byte $32, $29, $44, $75
	.byte $6b, $32, $29, $85
	.byte $c6, $66, $32, $78
	.byte $11, $cc, $66, $24
	.byte $11, $11, $cc, $62
mountain_04_01:
	.byte $55, $55, $55, $55
	.byte $55, $55, $55, $58
	.byte $55, $55, $55, $55
	.byte $55, $55, $55, $55
	.byte $55, $55, $55, $55
	.byte $55, $55, $55, $55
	.byte $88, $55, $55, $55
	.byte $47, $85, $55, $85
mountain_04_02:
	.byte $85, $55, $87, $44
	.byte $55, $58, $77, $77
	.byte $55, $57, $77, $87
	.byte $55, $57, $77, $88
	.byte $55, $57, $87, $78
	.byte $55, $55, $57, $87
	.byte $55, $55, $57, $88
	.byte $55, $55, $58, $78
mountain_04_03:
	.byte $78, $85, $88, $77
	.byte $78, $55, $58, $77
	.byte $78, $55, $58, $75
	.byte $88, $55, $58, $75
	.byte $55, $55, $55, $85
	.byte $55, $55, $55, $55
	.byte $55, $55, $55, $85
	.byte $55, $55, $58, $85
mountain_04_04:
	.byte $58, $88, $79, $a2
	.byte $55, $55, $74, $49
	.byte $55, $55, $84, $74
	.byte $55, $55, $87, $87
	.byte $55, $55, $57, $55
	.byte $55, $55, $57, $55
	.byte $55, $55, $58, $55
	.byte $55, $55, $55, $55
mountain_04_05:
	.byte $23, $3b, $b3, $b3
	.byte $aa, $23, $33, $33
	.byte $44, $49, $22, $22
	.byte $47, $58, $79, $9a
	.byte $77, $55, $84, $94
	.byte $77, $75, $87, $74
	.byte $57, $75, $87, $77
	.byte $57, $47, $57, $77
mountain_04_06:
	.byte $32, $24, $44, $77
	.byte $22, $a9, $77, $74
	.byte $aa, $94, $47, $57
	.byte $94, $94, $47, $55
	.byte $44, $44, $77, $88
	.byte $44, $77, $77, $47
	.byte $77, $77, $77, $94
	.byte $77, $77, $47, $77
mountain_04_07:
	.byte $57, $47, $84, $77
	.byte $75, $77, $74, $74
	.byte $47, $84, $4a, $22
	.byte $79, $94, $23, $b3
	.byte $89, $a3, $b6, $66
	.byte $99, $3b, $66, $cc
	.byte $23, $6c, $c1, $11
	.byte $11, $11, $11, $11
mountain_05_00:
	.byte $1d, $d1, $1c, $6b
	.byte $11, $dd, $1c, $c6
	.byte $c1, $11, $d1, $c6
	.byte $cc, $11, $1c, $c6
	.byte $6c, $cc, $cc, $66
	.byte $66, $cc, $c6, $33
	.byte $63, $66, $63, $29
	.byte $23, $23, $3a, $24
mountain_05_01:
	.byte $64, $75, $55, $55
	.byte $62, $47, $55, $55
	.byte $63, $a4, $85, $55
	.byte $63, $29, $78, $85
	.byte $bb, $24, $47, $78
	.byte $32, $a4, $44, $75
	.byte $22, $a9, $44, $47
	.byte $74, $a9, $94, $47
mountain_05_02:
	.byte $55, $55, $55, $78
	.byte $55, $55, $55, $57
	.byte $55, $58, $55, $55
	.byte $55, $88, $85, $55
	.byte $55, $58, $88, $55
	.byte $55, $58, $87, $85
	.byte $55, $58, $87, $75
	.byte $75, $58, $87, $75
mountain_05_03:
	.byte $55, $85, $58, $75
	.byte $58, $85, $58, $85
	.byte $58, $85, $55, $55
	.byte $55, $55, $55, $55
	.byte $55, $55, $55, $55
	.byte $55, $55, $55, $55
	.byte $58, $55, $75, $55
	.byte $78, $55, $77, $55
mountain_05_04:
	.byte $55, $55, $55, $55
	.byte $85, $55, $55, $55
	.byte $85, $88, $85, $55
	.byte $75, $88, $85, $55
	.byte $78, $85, $55, $55
	.byte $78, $55, $55, $55
	.byte $78, $55, $55, $55
	.byte $77, $55, $55, $55
mountain_05_05:
	.byte $57, $47, $77, $77
	.byte $57, $44, $77, $77
	.byte $57, $74, $77, $77
	.byte $57, $77, $77, $77
	.byte $57, $77, $77, $57
	.byte $57, $77, $44, $75
	.byte $77, $77, $47, $77
	.byte $77, $77, $74, $75
mountain_05_06:
	.byte $77, $77, $77, $71
	.byte $77, $77, $77, $cc
	.byte $77, $77, $76, $c1
	.byte $77, $76, $66, $1b
	.byte $44, $66, $c6, $23
	.byte $78, $64, $9a, $aa
	.byte $58, $87, $44, $94
	.byte $58, $88, $77, $77
mountain_05_07:
	.byte $11, $11, $11, $11
	.byte $11, $11, $cc, $cc
	.byte $6c, $cc, $66, $66
	.byte $66, $66, $bb, $b6
	.byte $3b, $bb, $33, $3b
	.byte $a2, $22, $22, $3b
	.byte $99, $9a, $a9, $c3
	.byte $44, $79, $29, $33
mountain_06_00:
	.byte $92, $2a, $24, $2a
	.byte $29, $a4, $94, $99
	.byte $99, $47, $99, $79
	.byte $99, $47, $94, $74
	.byte $74, $94, $74, $74
	.byte $77, $99, $47, $74
	.byte $47, $49, $94, $77
	.byte $47, $74, $94, $77
mountain_06_01:
	.byte $78, $47, $44, $99
	.byte $97, $88, $74, $79
	.byte $a9, $78, $84, $78
	.byte $99, $48, $87, $48
	.byte $79, $47, $88, $44
	.byte $79, $44, $48, $77
	.byte $74, $97, $97, $77
	.byte $97, $94, $79, $77
mountain_06_02:
	.byte $47, $58, $87, $75
	.byte $94, $75, $87, $85
	.byte $94, $47, $77, $85
	.byte $74, $44, $77, $57
	.byte $87, $44, $77, $77
	.byte $48, $74, $77, $77
	.byte $77, $87, $77, $47
	.byte $77, $87, $77, $47
mountain_06_03:
	.byte $77, $55, $77, $87
	.byte $77, $55, $58, $87
	.byte $47, $55, $55, $57
	.byte $77, $55, $55, $57
	.byte $77, $55, $55, $57
	.byte $77, $85, $85, $87
	.byte $77, $75, $88, $87
	.byte $74, $87, $78, $87
mountain_06_04:
	.byte $77, $55, $55, $55
	.byte $78, $55, $55, $55
	.byte $78, $55, $55, $75
	.byte $75, $55, $55, $75
	.byte $47, $55, $55, $75
	.byte $47, $55, $87, $78
	.byte $47, $55, $87, $77
	.byte $78, $85, $88, $75
mountain_06_05:
	.byte $77, $74, $77, $55
	.byte $55, $77, $75, $55
	.byte $55, $77, $85, $58
	.byte $55, $77, $55, $57
	.byte $55, $85, $58, $87
	.byte $55, $55, $55, $88
	.byte $55, $55, $55, $58
	.byte $55, $55, $55, $58
mountain_06_06:
	.byte $58, $88, $88, $87
	.byte $58, $88, $88, $87
	.byte $75, $88, $77, $87
	.byte $78, $85, $75, $77
	.byte $88, $85, $58, $78
	.byte $88, $55, $57, $77
	.byte $55, $55, $87, $77
	.byte $55, $58, $77, $78
mountain_06_07:
	.byte $47, $84, $94, $a3
	.byte $78, $77, $44, $4a
	.byte $78, $77, $49, $79
	.byte $57, $77, $99, $47
	.byte $87, $78, $94, $47
	.byte $77, $78, $44, $77
	.byte $77, $77, $79, $77
	.byte $87, $87, $84, $47
mountain_07_00:
	.byte $87, $77, $74, $47
	.byte $77, $78, $84, $97
	.byte $87, $77, $57, $47
	.byte $88, $78, $57, $78
	.byte $77, $45, $57, $75
	.byte $77, $75, $58, $75
	.byte $57, $75, $55, $85
	.byte $55, $85, $55, $88
mountain_07_01:
	.byte $74, $74, $44, $97
	.byte $74, $77, $47, $a4
	.byte $77, $44, $97, $7a
	.byte $77, $79, $44, $77
	.byte $77, $77, $47, $77
	.byte $57, $77, $77, $77
	.byte $58, $77, $77, $77
	.byte $55, $77, $87, $77
mountain_07_02:
	.byte $87, $77, $97, $74
	.byte $88, $78, $74, $47
	.byte $78, $88, $84, $48
	.byte $98, $88, $57, $47
	.byte $44, $77, $58, $77
	.byte $77, $77, $55, $57
	.byte $77, $74, $75, $55
	.byte $74, $74, $47, $55
mountain_07_03:
	.byte $77, $48, $48, $78
	.byte $78, $47, $77, $74
	.byte $77, $87, $74, $78
	.byte $77, $77, $47, $88
	.byte $77, $77, $84, $78
	.byte $77, $74, $88, $74
	.byte $77, $57, $47, $88
	.byte $54, $75, $44, $75
mountain_07_04:
	.byte $77, $87, $87, $55
	.byte $87, $47, $75, $55
	.byte $47, $78, $55, $55
	.byte $84, $85, $55, $55
	.byte $88, $55, $55, $55
	.byte $45, $55, $55, $55
	.byte $55, $55, $55, $55
	.byte $55, $55, $55, $55
mountain_07_05:
	.byte $55, $55, $55, $55
	.byte $55, $55, $55, $55
	.byte $55, $55, $55, $55
	.byte $55, $55, $55, $55
	.byte $55, $55, $55, $55
	.byte $55, $55, $55, $58
	.byte $55, $55, $55, $78
	.byte $55, $55, $55, $78
mountain_07_06:
	.byte $55, $87, $78, $78
	.byte $58, $77, $88, $77
	.byte $88, $55, $85, $77
	.byte $55, $85, $58, $77
	.byte $55, $55, $57, $77
	.byte $85, $55, $58, $77
	.byte $85, $55, $55, $77
	.byte $55, $55, $55, $87
mountain_07_07:
	.byte $78, $87, $84, $47
	.byte $88, $77, $77, $48
	.byte $87, $75, $87, $78
	.byte $87, $85, $87, $77
	.byte $58, $85, $77, $77
	.byte $85, $85, $57, $78
	.byte $75, $55, $58, $75
	.byte $75, $55, $58, $78
mountain_end:
