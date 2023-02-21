_THIS_FILE := $(firstword $(MAKEFILE_LIST))

# Directories
_TOP_DIR := $(PWD)
_TARGET_DIR := build

# Rules
BUILD_BITSTREAM := $(_TOP_DIR)/rules/bitstream.mk
BUILD_BLUESIM_TEST := $(_TOP_DIR)/rules/bluesim_test.mk
CLEAR_VARS := $(_TOP_DIR)/rules/clear_vars.mk

_GREEN_BOLD := \e[32;1m
_RESET_COLOR := \e[39;0m

# targets
_ALL_TARGETS =

define current-dir
$(abspath $(strip $(patsubst %/, %, $(dir $(lastword $(MAKEFILE_LIST))))))
endef

all: all_targets

clean:
	@rm -rf $(_TARGET_DIR)

.PHONY: all flash clean

include build.mk

all_targets: $(_ALL_TARGETS)
.PHONY: all_targets
