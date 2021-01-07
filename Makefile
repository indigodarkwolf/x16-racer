PROJECT	:= x16-racer
#EMUDIR  := ../../vs2019/x16-bin
EMUDIR  := ../../x16emu_win-r38
#EMU     := ./x16emu_Release.exe
EMU     := ./x16emu.exe
MKDIR   := mkdir -p
RMDIR   := rmdir -p
CC      := ca65
LD      := cl65
RELEASE := ./release
BIN     := ./build
OBJ     := ./obj
SRC     := ./src
IMG     := ./img
SRCS    := $(wildcard $(SRC)/*.asm)
OBJS    := $(patsubst $(SRC)/%.asm,$(OBJ)/%.o,$(SRCS))
SEQS    := $(patsubst $(SRC)/%.asm,$(BIN)/%.seq,$(SRCS))
EXE     := $(BIN)/$(PROJECT).prg
CFLAGS  := --cpu 65C02
LDFLAGS := --target cx16
MKFILE	:= $(abspath $(lastword $(MAKEFILE_LIST)))
MKPATH  := $(notdir $(patsubst %/,%,$(dir $(MKFILE))))
DOSIMG  := $(IMG)/$(PROJECT).dos
SDCARD  := $(IMG)/$(PROJECT).img

.PHONY: all run clean release

default: all

all:
	$(MAKE) all -f Makefile_prg
	$(MAKE) all -f Makefile_seqs

run:
	cp $(BIN)/* $(EMUDIR)/
	cd $(EMUDIR) && $(EMU) -debug -scale 2 -quality nearest -prg $(PROJECT).prg

runsd:
	cp $(SDCARD) $(EMUDIR)/
	cd $(EMUDIR) && $(EMU) -debug -scale 2 -quality nearest -sdcard $(PROJECT).img

clean:
	$(MAKE) clean -f Makefile_prg
	$(MAKE) clean -f Makefile_seqs
	rm -r $(OBJ)
	rm -r $(BIN)
	rm -r $(IMG)

release:
	cd $(BIN) && tar -cvf ../$(RELEASE)/$(PROJECT).tar *
	cd $(BIN) && 7z a -t7z ../$(RELEASE)/$(PROJECT).7z *
	cd $(BIN) && 7z a -tzip ../$(RELEASE)/$(PROJECT).zip *
	cd $(RELEASE) && 7z a -tgzip $(PROJECT).tar.gz $(PROJECT).tar
	cd $(RELEASE) && 7z a -tbzip2 $(PROJECT).tar.bz2 $(PROJECT).tar

dosimg:
	$(MKDIR) $(IMG)
	dd if=/dev/zero of=$(DOSIMG) bs=1K count=39K
	/sbin/mkfs.fat -F32 $(DOSIMG)
	mcopy -i $(DOSIMG) $(BIN)/* ::

sdcard: dosimg
	dd if=/dev/zero of=$(SDCARD) bs=1K count=40K
	/sbin/sfdisk $(SDCARD) < sdcard.sfdisk
	dd if=$(DOSIMG) of=$(SDCARD) bs=1K count=39K seek=1K