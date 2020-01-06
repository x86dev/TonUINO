#
# TonUINO Makefile
#
# Author: Alexander Willner
# Date: 2020-01-03

# Config
## Arduino Nano (old bootloader)
MCU = arduino:avr:nano:cpu=atmega328old
BOARD = arduino:avr
SERIAL = /dev/cu.usbserial-1410
## Main
SKETCH = Tonuino
## Helper
OS = $(shell uname -s)
.PHONY: help test

info:
	$(info TonUINO Makefile)
	$(info ================)
	$(info )
	$(info Configured to use MCU "$(MCU)" attached to port "$(SERIAL)".)
	$(info )
	$(info Available commands:)
	$(info - help    : get support from the community)
	$(info - install : installation of required binaries (arduino-cli))
	$(info - init    : initialize environment (arduino-cli))
	$(info - compile : create binary)
	$(info - upload  : store binary on board flash)
	$(info - find    : get information about the pluged-in board)
	$(info - test    : run some basic tests on the code)
	$(info - clean   : delete temporary files)
	@true

help:
	@python -m webbrowser "http://discourse.voss.earth"

install:
ifeq ($(OS),Darwin)
ifeq (, $(shell which brew))
	$(error "No brew in PATH, consider installing http://brew.sh")
else
	@brew install platformio arduino-cli
endif
endif
ifeq ($(OS),Linux)
ifeq (, $(shell which arduino-cli))
	@pip install setuptools wheel
	@curl -fsSL https://raw.githubusercontent.com/arduino/arduino-cli/master/install.sh | sh
endif
ifeq (, $(shell which platformio))
	@pip install -U platformio
endif
endif

init:
	@arduino-cli config init
	@arduino-cli core update-index
	@arduino-cli core install $(BOARD)
	@arduino-cli lib install "DFPlayer Mini Mp3 by Makuna"
	@arduino-cli lib install "MFRC522"
	@arduino-cli lib install "JC_Button"
	@platformio lib install 1561 # DFPlayer Mini Mp3 by Makuna
	@platformio lib install 2284 # EEPROM
	@platformio lib install 77   # JC_Button
	@platformio lib install 63   # MFRC522

compile: $(SKETCH)/*.cpp
	@arduino-cli compile --fqbn $(MCU) --warnings none "$(SKETCH)"

find:
	@arduino-cli board list

upload: compile
	@arduino-cli upload -p $(SERIAL) --fqbn $(MCU) --verify Tonuino

test:
	@arduino-cli compile --fqbn $(MCU) --warnings all "$(SKETCH)"
ifneq (, $(shell which pio))
	@pio test -e native
endif

check: $(SKETCH)/*.cpp
	@cppcheck --enable=all --std=c++20 --language=c++ $(SKETCH)/*.cpp $(SKETCH)/*.h

clean:
	@rm -rf ".pio/build/"
	@rm -f "$(SKETCH)"/*.hex
	@rm -f "$(SKETCH)"/*.elf