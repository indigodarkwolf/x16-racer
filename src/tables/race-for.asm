.org 0

Race_forest_map:
.repeat 8, yi
    .repeat (128/8)
        .repeat 8, xi
            .word ($1000 | (yi*8 + xi + 1))
        .endrep
    .endrep
.endrep

Race_forest_inner_map:
.repeat 3
    .repeat 8, yi
        .repeat (128/8)
            .repeat 8, xi
                .word ($1000 | (yi*8 + xi + 65))
            .endrep
        .endrep
    .endrep
.endrep