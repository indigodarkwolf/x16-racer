#!/usr/bin/python3

# Copyright (c) 2019, Frank Buss
# All rights reserved.

# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:

# 1. Redistributions of source code must retain the above copyright notice, this
#    list of conditions and the following disclaimer.

# 2. Redistributions in binary form must reproduce the above copyright notice,
#    this list of conditions and the following disclaimer in the documentation
#    and/or other materials provided with the distribution.

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


# Converts a PNG image to a C style array to be used as a sprite with Commander X16

from PIL import Image
import numpy as np
import math
import sys
import argparse

# parse arguments
parser = argparse.ArgumentParser(formatter_class=argparse.RawTextHelpFormatter,
    description='Converts a PNG file to Commander X16 sprite data.')
parser.add_argument('input', help='the PNG input file name')
parser.add_argument('output', help='the output file name')
parser.add_argument('-n', help='name of the asset')
parser.add_argument('-x', help='width of tiles within image (default: 8)')
parser.add_argument('-y', help='height of tiles within image (default: 8)')
args = parser.parse_args()
if args.n is None:
    args.n = 'asset'
if args.x is None:
    args.x = 8
if args.y is None:
    args.y = 8

args.x = int(args.x)
args.y = int(args.y)

# load image
im = Image.open(args.input)
p = np.array(im)

# convert to sprite data
with open(args.output, "w") as file:
    # palette information
    num_colors = len(im.getcolors());
    colors = im.getcolors();
    palette = im.getpalette();

    file.write("; %s_palette (raw):\n; \t" % args.n)
    for i in range(num_colors * 3):
        file.write("0x%02x " % palette[i])
    file.write("\n")
    
    file.write("%s_palette:\n\t.word " % args.n)
    for c in colors:
        i = colors.index(c)
        r = palette[(3 * i) + 0]
        g = palette[(3 * i) + 1]
        b = palette[(3 * i) + 2]

        print ("0x%02x 0x%02x 0x%02x\n" % (r, g, b))
        file.write("$%04x" % (((r & 0xf0) << 4) + ((g & 0xf0)) + ((b & 0xf0) >> 4)))

        if im.getcolors().index(c) != len(im.getcolors())-1:
            file.write(", ")

    file.write("\n\n")

    # unique tiles
    tiles = []
    
    file.write("%s:\n" % args.n)
    for yy in range(int(im.height/args.y)):
        for xx in range(int(im.width/args.x)):
            tile = ""
            h_flipped_tile = ""
            v_flipped_tile = ""
            hv_flipped_tile = ""
            
            for y in range(args.y):
                tile += ("\t.byte ")
                for x in range(0, args.x, 2):
                    # get palette index
                    by = yy * args.y
                    bx = xx * args.x

                    x1 = x
                    x2 = x + 1
                    
                    index = p[by + y][bx + x1]
                    h_flipped_index = p[by + y][bx + 7 - x1]
                    v_flipped_index = p[by + 7 - y][bx + x1]
                    hv_flipped_index = p[by + 7 - y][bx + 7 - x1]

                    index2 = p[by + y][bx + x2]
                    h_flipped_index2 = p[by + y][bx + 7 - x2]
                    v_flipped_index2 = p[by + 7 - y][bx + x2]
                    hv_flipped_index2 = p[by + 7 - y][bx + 7 - x2]

                    tile += ("$%02x" % ((index << 4) + index2))
                    h_flipped_tile += ("$%02x" % ((h_flipped_index << 4) + h_flipped_index2))
                    v_flipped_tile += ("$%02x" % ((v_flipped_index << 4) + v_flipped_index2))
                    hv_flipped_tile += ("$%02x" % ((hv_flipped_index << 4) + hv_flipped_index2))
                    
                    if x < args.x - 2:
                        tile += (", ")
                        h_flipped_tile += (", ")
                        v_flipped_tile += (", ")
                        hv_flipped_tile += (", ")
                            
                tile += ("\n")
                h_flipped_tile += ("\n")
                v_flipped_tile += ("\n")
                hv_flipped_tile += ("\n")

            if tile in tiles:
                print ("skipping duplicate tile %s_%02d_%02d" % (args.n, yy, xx))
            elif h_flipped_tile in tiles:
                print ("skipping duplicate tile %s_%02d_%02d (h-flipped)" % (args.n, yy, xx))
            elif v_flipped_tile in tiles:
                print ("skipping duplicate tile %s_%02d_%02d (v-flipped)" % (args.n, yy, xx))
            elif hv_flipped_tile in tiles:
                print ("skipping duplicate tile %s_%02d_%02d (hv-flipped)" % (args.n, yy, xx))
            else:
                file.write("%s_%02d_%02d:\n" % (args.n, yy, xx))
                file.write(tile)
                tiles.append("%s" % tile)
    file.write("%s_end:\n" % args.n)
