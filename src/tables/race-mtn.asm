.org 0
.byte $00, $00

.repeat (256+44)
    .byte $00
.endrep

license_1:
	.word $605B, $6067, $6067, $6063, $6066, $6090, $6092, $6092, $6062, $6063, $6058, $6061, $605A, $6054, $6060, $6058, $6054, $6065, $6067, $608C, $6062, $6065, $605A, $6092, $6056, $6062, $6061, $6067, $6058, $6061, $6067, $6092, $6065, $6054, $6056, $605C, $6061, $605A, $6082, $6056, $6054, $6065
license_1_end:

LICENSE_1_SIZE = license_1_end - license_1

.repeat (256 - 44 - LICENSE_1_SIZE + 46)
    .byte $00
.endrep

license_2:
	.word $605A, $605C, $6057, $6058, $6061, $605C, $605F, $6066, $6062, $6061
license_2_end:

LICENSE_2_SIZE = license_2_end - license_2

.repeat (256 - 46 - LICENSE_2_SIZE + 48)
    .byte $00
.endrep

license_3:
	.word $603B, $603B, $6082, $603A, $6051, $6053, $6072, $608C, $606E
license_3_end:

LICENSE_3_SIZE = license_3_end - license_3

.repeat (256 - 48 - LICENSE_3_SIZE)
    .byte $00
.endrep

.repeat (256+128)
    .byte $00
.endrep

license_4:
	.word $605B, $6067, $6067, $6063, $6066, $6090, $6092, $6092, $6062, $6063, $6058, $6061, $605A, $6054, $6060, $6058, $6054, $6065, $6067, $608C, $6062, $6065, $605A, $6092, $6056, $6062, $6061, $6067, $6058, $6061, $6067, $6092, $606A, $6062, $6065, $605F, $6057, $6082, $6060, $6054, $6063, $6082, $6067, $605C, $605F, $6058, $6066
license_4_end:

LICENSE_4_SIZE = license_4_end - license_4

.repeat (256 - 128 - LICENSE_4_SIZE + 130)
    .byte $00
.endrep

license_5:
	.word $6042, $605C, $6061, $6061
license_5_end:

LICENSE_5_SIZE = license_5_end - license_5

.repeat (256 - 130 - LICENSE_5_SIZE + 132)
    .byte $00
.endrep

license_6:
	.word $603B, $603B, $6082, $603A, $6051, $6082, $604B, $6039, $6053, $6071, $608C, $606E
license_6_end:

LICENSE_6_SIZE = license_6_end - license_6

.repeat (256 - 132 - LICENSE_6_SIZE)
    .byte $00
.endrep

.repeat (256 + 22)
    .byte $00
.endrep

license_1_hflip:
	.word $645B, $6467, $6467, $6463, $6466, $6490, $6492, $6492, $6462, $6463, $6458, $6461, $645A, $6454, $6460, $6458, $6454, $6465, $6467, $648C, $6462, $6465, $645A, $6492, $6456, $6462, $6461, $6467, $6458, $6461, $6467, $6492, $6465, $6454, $6456, $645C, $6461, $645A, $6482, $6456, $6454, $6465
license_1_hflip_end:
    
.repeat (256 - 22 - LICENSE_1_SIZE + 26)
    .byte $00
.endrep

license_2_hflip:
	.word $645A, $645C, $6457, $6458, $6461, $645C, $645F, $6466, $6462, $6461
license_2_hflip_end:

.repeat (256 - 26 - LICENSE_2_SIZE + 28)
    .byte $00
.endrep

license_3_hflip:
	.word $643B, $643B, $6482, $643A, $6451, $6453, $6472, $648C, $646E
license_3_hflip_end:

.repeat (256 - 28 - LICENSE_3_SIZE)
    .byte $00
.endrep

.repeat (256 + 64)
    .byte $00
.endrep

license_4_vflip:
	.word $685B, $6867, $6867, $6863, $6866, $6890, $6892, $6892, $6862, $6863, $6858, $6861, $685A, $6854, $6860, $6858, $6854, $6865, $6867, $688C, $6862, $6865, $685A, $6892, $6856, $6862, $6861, $6867, $6858, $6861, $6867, $6892, $686A, $6862, $6865, $685F, $6857, $6882, $6860, $6854, $6863, $6882, $6867, $685C, $685F, $6858, $6866
license_4_vflip_end:

.repeat (256 - 64 - LICENSE_4_SIZE + 66)
    .byte $00
.endrep

license_5_vflip:
	.word $6842, $685C, $6861, $6861
license_5_vflip_end:

.repeat (256 - 66 - LICENSE_5_SIZE + 68)
    .byte $00
.endrep

license_6_vflip:
	.word $683B, $683B, $6882, $683A, $6851, $6882, $684B, $6839, $6853, $6871, $688C, $686E
license_6_vflip_end:

.repeat (256 - 68 - LICENSE_6_SIZE)
    .byte $00
.endrep
    
.repeat (256 + 12)
    .byte $00
.endrep

license_1_hvflip:
	.word $6C5B, $6C67, $6C67, $6C63, $6C66, $6C90, $6C92, $6C92, $6C62, $6C63, $6C58, $6C61, $6C5A, $6C54, $6C60, $6C58, $6C54, $6C65, $6C67, $6C8C, $6C62, $6C65, $6C5A, $6C92, $6C56, $6C62, $6C61, $6C67, $6C58, $6C61, $6C67, $6C92, $6C65, $6C54, $6C56, $6C5C, $6C61, $6C5A, $6C82, $6C56, $6C54, $6C65
license_1_hvflip_end:

.repeat (256 - 12 - LICENSE_1_SIZE + 14)
    .byte $00
.endrep

license_2_hvflip:
	.word $6C5A, $6C5C, $6C57, $6C58, $6C61, $6C5C, $6C5F, $6C66, $6C62, $6C61
license_2_hvflip_end:

.repeat (256 - 14 - LICENSE_2_SIZE + 16)
    .byte $00
.endrep

license_3_hvflip:
	.word $6C3B, $6C3B, $6C82, $6C3A, $6C51, $6C53, $6C72, $6C8C, $6C6E
license_3_hvflip_end:

.repeat (256 - 16 - LICENSE_3_SIZE)
    .byte $00
.endrep

.repeat (256*3)
    .byte $00
.endrep

.repeat (128/8)
    .word $0000, $0000, $0000, $0001, $0002, $0000, $0000, $0000
.endrep
.repeat (128/8)
    .word $0000, $0003, $0004, $0005, $0006, $0007, $0008, $0000
.endrep
.repeat (128/8)
    .word $0009, $000a, $000b, $000c, $000d, $000e, $000f, $0010
.endrep
.repeat (128/8)
    .word $0011, $0012, $0013, $0014, $0015, $0016, $0017, $0018
.endrep
.repeat (128/8)
    .word $0019, $001a, $001b, $001c, $001d, $001e, $001f, $0020
.endrep
.repeat (128/8)
    .word $0021, $0022, $0023, $0024, $0025, $0026, $0027, $0028
.endrep
.repeat (128/8)
    .word $0029, $002a, $002b, $002c, $002d, $002e, $002f, $0030
.endrep
.repeat (128/8)
    .word $0031, $0032, $0033, $0034, $0035, $0036, $0037, $0038
.endrep

.repeat (256*30)
    .byte $00
.endrep
