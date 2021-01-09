.ifndef UTIL_INC
UTIL_INC=1

.define IMM(ARG) (.match (.left (1, {ARG}), #))
.define DECAY(ARG) (.right (.tcount ({ARG})-1, {ARG}))

.endif ; .ifndef UTIL_INC