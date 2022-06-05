PROJECT	:= x16-race

EMUDIR  := ../../git/box16/build/vs2022/out/x64/Release
EMU     := ./box16.exe
EMUFLAGS := -scale 2 -quality nearest -sym $(PROJECT).sym -hypercall_path ./

# EMUDIR  := ../../vs2019/x16-bin
# EMU     := ./x16emu_Release.exe
# EMUFLAGS := -debug -scale 2 -quality nearest

#EMUDIR  := ../../x16emu_win-r38
#EMU     := ./x16emu.exe
#EMUFLAGS := -debug -scale 2 -quality nearest

MKDIR   := mkdir -p
RMDIR   := rmdir -p
CC      := ca65
LD      := cl65
RELEASE := ./release
BIN     := ./build
OBJ     := ./obj
SRC     := ./src
IMG     := ./img
SRCS    := $(wildcard $(SRC)/*.asm) $(wildcard $(SRC)/x16/*.asm)
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

headerless:
	$(MAKE) -j8 all -f Makefile_prg DFLAGS="-D HEADERLESS"
	$(MAKE) -j8 all -f Makefile_seqs DFLAGS="-D HEADERLESS"

all:
	$(MAKE) -j8 all -f Makefile_prg
	$(MAKE) -j8 all -f Makefile_seqs

run:
	cd $(BIN) && ../$(EMUDIR)/$(EMU) $(EMUFLAGS) -prg $(PROJECT).prg
#	cp $(BIN)/* $(EMUDIR)/
#	cd $(EMUDIR) && $(EMU) $(EMUFLAGS) -prg $(PROJECT).prg

runsd:
	cp $(SDCARD) $(EMUDIR)/
	cd $(EMUDIR) && $(EMU) $(EMUFLAGS) -sdcard $(PROJECT).img

runhybrid:
	cp $(SDCARD) $(EMUDIR)/
	cp $(BIN)/* $(EMUDIR)/
	cd $(EMUDIR) && $(EMU) $(EMUFLAGS) -sdcard $(PROJECT).img -prg $(PROJECT).prg

clean:
	$(MAKE) clean -f Makefile_prg
	$(MAKE) clean -f Makefile_seqs
	rm -r $(OBJ)
	rm -r $(BIN)

clean_release:
	rm -r $(RELEASE)

clean_all: clean clean_release

sdcard: all
	$(MKDIR) $(IMG)
	./mkcard.sh -f $(SDCARD) -s 40 -d $(BIN)

zips: all
	if [ ! -d $(RELEASE) ]; then $(MKDIR) $(RELEASE); fi
	cd $(BIN) && tar -cvf ../$(RELEASE)/$(PROJECT).tar *
	cd $(BIN) && 7z a -t7z ../$(RELEASE)/$(PROJECT).7z *
	cd $(BIN) && 7z a -tzip ../$(RELEASE)/$(PROJECT).zip *
	cd $(RELEASE) && 7z a -tgzip $(PROJECT).tar.gz $(PROJECT).tar
	cd $(RELEASE) && 7z a -tbzip2 $(PROJECT).tar.bz2 $(PROJECT).tar

sdzips: sdcard
	if [ ! -d $(RELEASE) ]; then $(MKDIR) $(RELEASE); fi
	cd $(IMG) && tar -cvf ../$(RELEASE)/$(PROJECT)_sdcard.tar *
	cd $(IMG) && 7z a -t7z ../$(RELEASE)/$(PROJECT)_sdcard.7z *
	cd $(IMG) && 7z a -tzip ../$(RELEASE)/$(PROJECT)_sdcard.zip *
	cd $(RELEASE) && 7z a -tgzip $(PROJECT)_sdcard.tar.gz $(PROJECT)_sdcard.tar
	cd $(RELEASE) && 7z a -tbzip2 $(PROJECT)_sdcard.tar.bz2 $(PROJECT)_sdcard.tar

release: zips sdzips