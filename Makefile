PROJECT	:= x16-race
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

runhybrid:
	cp $(SDCARD) $(EMUDIR)/
	cp $(BIN)/* $(EMUDIR)/
	cd $(EMUDIR) && $(EMU) -debug -scale 2 -quality nearest -sdcard $(PROJECT).img -prg $(PROJECT).prg

clean:
	$(MAKE) clean -f Makefile_prg
	$(MAKE) clean -f Makefile_seqs
	rm -r $(OBJ)
	rm -r $(BIN)
	rm -r $(IMG)

sdcard: all
	$(MKDIR) $(IMG)
	./mkcard.sh -f $(SDCARD) -s 40 -d $(BIN)

zips: all
	cd $(BIN) && tar -cvf ../$(RELEASE)/$(PROJECT).tar *
	cd $(BIN) && 7z a -t7z ../$(RELEASE)/$(PROJECT).7z *
	cd $(BIN) && 7z a -tzip ../$(RELEASE)/$(PROJECT).zip *
	cd $(RELEASE) && 7z a -tgzip $(PROJECT).tar.gz $(PROJECT).tar
	cd $(RELEASE) && 7z a -tbzip2 $(PROJECT).tar.bz2 $(PROJECT).tar

sdzips: sdcard
	cd $(IMG) && tar -cvf ../$(RELEASE)/$(PROJECT)_sdcard.tar *
	cd $(IMG) && 7z a -t7z ../$(RELEASE)/$(PROJECT)_sdcard.7z *
	cd $(IMG) && 7z a -tzip ../$(RELEASE)/$(PROJECT)_sdcard.zip *
	cd $(RELEASE) && 7z a -tgzip $(PROJECT)_sdcard.tar.gz $(PROJECT)_sdcard.tar
	cd $(RELEASE) && 7z a -tbzip2 $(PROJECT)_sdcard.tar.bz2 $(PROJECT)_sdcard.tar

release: zips sdzips