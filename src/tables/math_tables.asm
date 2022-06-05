;=================================================
;=================================================
;
;   Math lib tables
;
;-------------------------------------------------
; Load into $A000
;
.define SquaresOverFour_0_512 0, 0, 1, 2, 4, 6, 9, 12, 16, 20, 25, 30, 36, 42, 49, 56, 64, 72, 81, 90, 100, 110, 121, 132, 144, 156, 169, 182, 196, 210, 225, 240, 256, 272, 289, 306, 324, 342, 361, 380, 400, 420, 441, 462, 484, 506, 529, 552, 576, 600, 625, 650, 676, 702, 729, 756, 784, 812, 841, 870, 900, 930, 961, 992, 1024, 1056, 1089, 1122, 1156, 1190, 1225, 1260, 1296, 1332, 1369, 1406, 1444, 1482, 1521, 1560, 1600, 1640, 1681, 1722, 1764, 1806, 1849, 1892, 1936, 1980, 2025, 2070, 2116, 2162, 2209, 2256, 2304, 2352, 2401, 2450, 2500, 2550, 2601, 2652, 2704, 2756, 2809, 2862, 2916, 2970, 3025, 3080, 3136, 3192, 3249, 3306, 3364, 3422, 3481, 3540, 3600, 3660, 3721, 3782, 3844, 3906, 3969, 4032, 4096, 4160, 4225, 4290, 4356, 4422, 4489, 4556, 4624, 4692, 4761, 4830, 4900, 4970, 5041, 5112, 5184, 5256, 5329, 5402, 5476, 5550, 5625, 5700, 5776, 5852, 5929, 6006, 6084, 6162, 6241, 6320, 6400, 6480, 6561, 6642, 6724, 6806, 6889, 6972, 7056, 7140, 7225, 7310, 7396, 7482, 7569, 7656, 7744, 7832, 7921, 8010, 8100, 8190, 8281, 8372, 8464, 8556, 8649, 8742, 8836, 8930, 9025, 9120, 9216, 9312, 9409, 9506, 9604, 9702, 9801, 9900, 10000, 10100, 10201, 10302, 10404, 10506, 10609, 10712, 10816, 10920, 11025, 11130, 11236, 11342, 11449, 11556, 11664, 11772, 11881, 11990, 12100, 12210, 12321, 12432, 12544, 12656, 12769, 12882, 12996, 13110, 13225, 13340, 13456, 13572, 13689, 13806, 13924, 14042, 14161, 14280, 14400, 14520, 14641, 14762, 14884, 15006, 15129, 15252, 15376, 15500, 15625, 15750, 15876, 16002, 16129, 16256, 16384, 16512, 16641, 16770, 16900, 17030, 17161, 17292, 17424, 17556, 17689, 17822, 17956, 18090, 18225, 18360, 18496, 18632, 18769, 18906, 19044, 19182, 19321, 19460, 19600, 19740, 19881, 20022, 20164, 20306, 20449, 20592, 20736, 20880, 21025, 21170, 21316, 21462, 21609, 21756, 21904, 22052, 22201, 22350, 22500, 22650, 22801, 22952, 23104, 23256, 23409, 23562, 23716, 23870, 24025, 24180, 24336, 24492, 24649, 24806, 24964, 25122, 25281, 25440, 25600, 25760, 25921, 26082, 26244, 26406, 26569, 26732, 26896, 27060, 27225, 27390, 27556, 27722, 27889, 28056, 28224, 28392, 28561, 28730, 28900, 29070, 29241, 29412, 29584, 29756, 29929, 30102, 30276, 30450, 30625, 30800, 30976, 31152, 31329, 31506, 31684, 31862, 32041, 32220, 32400, 32580, 32761, 32942, 33124, 33306, 33489, 33672, 33856, 34040, 34225, 34410, 34596, 34782, 34969, 35156, 35344, 35532, 35721, 35910, 36100, 36290, 36481, 36672, 36864, 37056, 37249, 37442, 37636, 37830, 38025, 38220, 38416, 38612, 38809, 39006, 39204, 39402, 39601, 39800, 40000, 40200, 40401, 40602, 40804, 41006, 41209, 41412, 41616, 41820, 42025, 42230, 42436, 42642, 42849, 43056, 43264, 43472, 43681, 43890, 44100, 44310, 44521, 44732, 44944, 45156, 45369, 45582, 45796, 46010, 46225, 46440, 46656, 46872, 47089, 47306, 47524, 47742, 47961, 48180, 48400, 48620, 48841, 49062, 49284, 49506, 49729, 49952, 50176, 50400, 50625, 50850, 51076, 51302, 51529, 51756, 51984, 52212, 52441, 52670, 52900, 53130, 53361, 53592, 53824, 54056, 54289, 54522, 54756, 54990, 55225, 55460, 55696, 55932, 56169, 56406, 56644, 56882, 57121, 57360, 57600, 57840, 58081, 58322, 58564, 58806, 59049, 59292, 59536, 59780, 60025, 60270, 60516, 60762, 61009, 61256, 61504, 61752, 62001, 62250, 62500, 62750, 63001, 63252, 63504, 63756, 64009, 64262, 64516, 64770, 65025, 65280
.define Squares_0_255 0, 1, 4, 9, 16, 25, 36, 49, 64, 81, 100, 121, 144, 169, 196, 225, 256, 289, 324, 361, 400, 441, 484, 529, 576, 625, 676, 729, 784, 841, 900, 961, 1024, 1089, 1156, 1225, 1296, 1369, 1444, 1521, 1600, 1681, 1764, 1849, 1936, 2025, 2116, 2209, 2304, 2401, 2500, 2601, 2704, 2809, 2916, 3025, 3136, 3249, 3364, 3481, 3600, 3721, 3844, 3969, 4096, 4225, 4356, 4489, 4624, 4761, 4900, 5041, 5184, 5329, 5476, 5625, 5776, 5929, 6084, 6241, 6400, 6561, 6724, 6889, 7056, 7225, 7396, 7569, 7744, 7921, 8100, 8281, 8464, 8649, 8836, 9025, 9216, 9409, 9604, 9801, 10000, 10201, 10404, 10609, 10816, 11025, 11236, 11449, 11664, 11881, 12100, 12321, 12544, 12769, 12996, 13225, 13456, 13689, 13924, 14161, 14400, 14641, 14884, 15129, 15376, 15625, 15876, 16129, 16384, 16641, 16900, 17161, 17424, 17689, 17956, 18225, 18496, 18769, 19044, 19321, 19600, 19881, 20164, 20449, 20736, 21025, 21316, 21609, 21904, 22201, 22500, 22801, 23104, 23409, 23716, 24025, 24336, 24649, 24964, 25281, 25600, 25921, 26244, 26569, 26896, 27225, 27556, 27889, 28224, 28561, 28900, 29241, 29584, 29929, 30276, 30625, 30976, 31329, 31684, 32041, 32400, 32761, 33124, 33489, 33856, 34225, 34596, 34969, 35344, 35721, 36100, 36481, 36864, 37249, 37636, 38025, 38416, 38809, 39204, 39601, 40000, 40401, 40804, 41209, 41616, 42025, 42436, 42849, 43264, 43681, 44100, 44521, 44944, 45369, 45796, 46225, 46656, 47089, 47524, 47961, 48400, 48841, 49284, 49729, 50176, 50625, 51076, 51529, 51984, 52441, 52900, 53361, 53824, 54289, 54756, 55225, 55696, 56169, 56644, 57121, 57600, 58081, 58564, 59049, 59536, 60025, 60516, 61009, 61504, 62001, 62500, 63001, 63504, 64009, 64516, 65025
.define Squares_256_512 65536, 66049, 66564, 67081, 67600, 68121, 68644, 69169, 69696, 70225, 70756, 71289, 71824, 72361, 72900, 73441, 73984, 74529, 75076, 75625, 76176, 76729, 77284, 77841, 78400, 78961, 79524, 80089, 80656, 81225, 81796, 82369, 82944, 83521, 84100, 84681, 85264, 85849, 86436, 87025, 87616, 88209, 88804, 89401, 90000, 90601, 91204, 91809, 92416, 93025, 93636, 94249, 94864, 95481, 96100, 96721, 97344, 97969, 98596, 99225, 99856, 100489, 101124, 101761, 102400, 103041, 103684, 104329, 104976, 105625, 106276, 106929, 107584, 108241, 108900, 109561, 110224, 110889, 111556, 112225, 112896, 113569, 114244, 114921, 115600, 116281, 116964, 117649, 118336, 119025, 119716, 120409, 121104, 121801, 122500, 123201, 123904, 124609, 125316, 126025, 126736, 127449, 128164, 128881, 129600, 130321, 131044, 131769, 132496, 133225, 133956, 134689, 135424, 136161, 136900, 137641, 138384, 139129, 139876, 140625, 141376, 142129, 142884, 143641, 144400, 145161, 145924, 146689, 147456, 148225, 148996, 149769, 150544, 151321, 152100, 152881, 153664, 154449, 155236, 156025, 156816, 157609, 158404, 159201, 160000, 160801, 161604, 162409, 163216, 164025, 164836, 165649, 166464, 167281, 168100, 168921, 169744, 170569, 171396, 172225, 173056, 173889, 174724, 175561, 176400, 177241, 178084, 178929, 179776, 180625, 181476, 182329, 183184, 184041, 184900, 185761, 186624, 187489, 188356, 189225, 190096, 190969, 191844, 192721, 193600, 194481, 195364, 196249, 197136, 198025, 198916, 199809, 200704, 201601, 202500, 203401, 204304, 205209, 206116, 207025, 207936, 208849, 209764, 210681, 211600, 212521, 213444, 214369, 215296, 216225, 217156, 218089, 219024, 219961, 220900, 221841, 222784, 223729, 224676, 225625, 226576, 227529, 228484, 229441, 230400, 231361, 232324, 233289, 234256, 235225, 236196, 237169, 238144, 239121, 240100, 241081, 242064, 243049, 244036, 245025, 246016, 247009, 248004, 249001, 250000, 251001, 252004, 253009, 254016, 255025, 256036, 257049, 258064, 259081, 260100, 261121

.define Sin_0_45 0, 0, 1, 2, 3, 3, 4, 5, 6, 7, 7, 8, 9, 10, 10, 11, 12, 13, 14, 14, 15, 16, 17, 18, 18, 19, 20, 21, 21, 22, 23, 24, 25, 25, 26, 27, 28, 28, 29, 30, 31, 32, 32, 33, 34, 35, 36, 36, 37, 38, 39, 39, 40, 41, 42, 42, 43, 44, 45, 46, 46, 47, 48, 49, 49, 50, 51, 52, 53, 53, 54, 55, 56, 56, 57, 58, 59, 59, 60, 61, 62, 62, 63, 64, 65, 66, 66, 67, 68, 69, 69, 70, 71, 72, 72, 73, 74, 75, 75, 76, 77, 78, 78, 79, 80, 81, 81, 82, 83, 84, 84, 85, 86, 86, 87, 88, 89, 89, 90, 91, 92, 92, 93, 94, 95, 95, 96, 97, 97, 98, 99, 100, 100, 101, 102, 103, 103, 104, 105, 105, 106, 107, 108, 108, 109, 110, 110, 111, 112, 112, 113, 114, 115, 115, 116, 117, 117, 118, 119, 119, 120, 121, 122, 122, 123, 124, 124, 125, 126, 126, 127, 128, 128, 129, 130, 130, 131, 132, 132, 133, 134, 134, 135, 136, 136, 137, 138, 138, 139, 140, 140, 141, 142, 142, 143, 144, 144, 145, 146, 146, 147, 148, 148, 149, 149, 150, 151, 151, 152, 153, 153, 154, 155, 155, 156, 156, 157, 158, 158, 159, 159, 160, 161, 161, 162, 163, 163, 164, 164, 165, 166, 166, 167, 167, 168, 168, 169, 170, 170, 171, 171, 172, 173, 173, 174, 174, 175, 175, 176, 177, 177, 178, 178, 179, 179, 180
.define Cos_0_45 256, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 254, 253, 253, 253, 253, 253, 253, 253, 253, 253, 252, 252, 252, 252, 252, 252, 252, 252, 251, 251, 251, 251, 251, 251, 251, 250, 250, 250, 250, 250, 250, 249, 249, 249, 249, 249, 249, 248, 248, 248, 248, 248, 247, 247, 247, 247, 247, 246, 246, 246, 246, 246, 245, 245, 245, 245, 244, 244, 244, 244, 244, 243, 243, 243, 243, 242, 242, 242, 242, 241, 241, 241, 241, 240, 240, 240, 239, 239, 239, 239, 238, 238, 238, 237, 237, 237, 237, 236, 236, 236, 235, 235, 235, 234, 234, 234, 234, 233, 233, 233, 232, 232, 232, 231, 231, 231, 230, 230, 230, 229, 229, 229, 228, 228, 227, 227, 227, 226, 226, 226, 225, 225, 225, 224, 224, 223, 223, 223, 222, 222, 221, 221, 221, 220, 220, 219, 219, 219, 218, 218, 217, 217, 217, 216, 216, 215, 215, 215, 214, 214, 213, 213, 212, 212, 211, 211, 211, 210, 210, 209, 209, 208, 208, 207, 207, 207, 206, 206, 205, 205, 204, 204, 203, 203, 202, 202, 201, 201, 200, 200, 199, 199, 198, 198, 197, 197, 196, 196, 195, 195, 194, 194, 193, 193, 192, 192, 191, 191, 190, 190, 189, 189, 188, 188, 187, 187, 186, 185, 185, 184, 184, 183, 183, 182, 182, 181
.define Sin_0_360 0, 6, 12, 18, 25, 31, 37, 43, 49, 56, 62, 68, 74, 80, 86, 92, 97, 103, 109, 115, 120, 126, 131, 136, 142, 147, 152, 157, 162, 167, 171, 176, 181, 185, 189, 193, 197, 201, 205, 209, 212, 216, 219, 222, 225, 228, 231, 234, 236, 238, 241, 243, 244, 246, 248, 249, 251, 252, 253, 254, 254, 255, 255, 255, 256, 255, 255, 255, 254, 254, 253, 252, 251, 249, 248, 246, 244, 243, 241, 238, 236, 234, 231, 228, 225, 222, 219, 216, 212, 209, 205, 201, 197, 193, 189, 185, 181, 176, 171, 167, 162, 157, 152, 147, 142, 136, 131, 126, 120, 115, 109, 103, 97, 92, 86, 80, 74, 68, 62, 56, 49, 43, 37, 31, 25, 18, 12, 6, 0, -6, -12, -18, -25, -31, -37, -43, -49, -56, -62, -68, -74, -80, -86, -92, -97, -103, -109, -115, -120, -126, -131, -136, -142, -147, -152, -157, -162, -167, -171, -176, -181, -185, -189, -193, -197, -201, -205, -209, -212, -216, -219, -222, -225, -228, -231, -234, -236, -238, -241, -243, -244, -246, -248, -249, -251, -252, -253, -254, -254, -255, -255, -255, -256, -255, -255, -255, -254, -254, -253, -252, -251, -249, -248, -246, -244, -243, -241, -238, -236, -234, -231, -228, -225, -222, -219, -216, -212, -209, -205, -201, -197, -193, -189, -185, -181, -176, -171, -167, -162, -157, -152, -147, -142, -136, -131, -126, -120, -115, -109, -103, -97, -92, -86, -80, -74, -68, -62, -56, -49, -43, -37, -31, -25, -18, -12, -6

.ifndef HEADERLESS
    .byte 0, 0
.endif

SQUARES_OVER_FOUR_LO: 
    .lobytes SquaresOverFour_0_512

SQUARES_OVER_FOUR_HI: 
    .hibytes SquaresOverFour_0_512

SIN360_TABLE_LO:
    .lobytes Sin_0_360

SIN360_TABLE_HI:
    .hibytes Sin_0_360