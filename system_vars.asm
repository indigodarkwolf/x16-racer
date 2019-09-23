.ifndef SYSTEM_VARS_ASM
SYSTEM_VARS_ASM=1

Sys_rand_mem: .byte $00, $00, $00
Sys_frame: .byte $00
Sys_mem_end:

.endif ; SYSTEM_VARS_ASM