.ifndef HEADERLESS
    .byte 0, 0
.endif

.define MAP_BANK_WIDTH 2
.define MAP_BANK_HEIGHT 8

.org 0
.repeat 16, bi
    .repeat 32, yi
        .repeat 32, xi
            .scope
                bank_x = (bi .mod MAP_BANK_WIDTH)
                bank_y = (bi / MAP_BANK_WIDTH)

                cell_x = xi + (bank_x * 32)
                cell_y = yi / 4 + (bank_y * 8)

                invert = (cell_x + cell_y) .mod 2
                color_base = (bi) .mod 15 + 1

                .if invert = 0
                    color_fg = (color_base << 8)
                    color_bg = 0
                .else
                    color_fg = 0
                    color_bg = (color_base << 12)
                .endif

                row = yi .mod 4

                .if row = 0
                    .word (color_fg + color_bg + $55)
                    .word (color_fg + color_bg + $43)
                    .word (color_fg + color_bg + $43)
                    .word (color_fg + color_bg + $49)

                .elseif row = 1
                    grid_x1 = cell_x .mod 10
                    grid_x10 = (cell_x / 10) .mod 10

                    .word (color_fg + color_bg + $42)

                    .if grid_x10 < 10
                        .word (color_fg + color_bg + $B0 + grid_x10)
                    .else
                        .word (color_fg + color_bg + $01 + grid_x10 - 10)
                    .endif

                    .if grid_x1 < 10
                        .word (color_fg + color_bg + $B0 + grid_x1)
                    .else
                        .word (color_fg + color_bg + $01 + grid_x1 - 10)
                    .endif

                    .word (color_fg + color_bg + $42)

                .elseif row = 2
                    grid_y1 = cell_y .mod 10
                    grid_y10 = (cell_y / 10) .mod 10

                    .word (color_fg + color_bg + $42)

                    .if grid_y10 < 10
                        .word (color_fg + color_bg + $B0 + grid_y10)
                    .else
                        .word (color_fg + color_bg + $01 + grid_y10 - 10)
                    .endif

                    .if grid_y1 < 10
                        .word (color_fg + color_bg + $B0 + grid_y1)
                    .else
                        .word (color_fg + color_bg + $01 + grid_y1 - 10)
                    .endif

                    .word (color_fg + color_bg + $42)

                .else
                    .word (color_fg + color_bg + $4A)
                    .word (color_fg + color_bg + $43)
                    .word (color_fg + color_bg + $43)
                    .word (color_fg + color_bg + $4B)

                .endif
            .endscope
        .endrep
    .endrep
.endrep