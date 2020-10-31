
.repeat 32, yi
    .repeat 128, xi
        .word ((yi << 5) + xi)
    .endrep
.endrep