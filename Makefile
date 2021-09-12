
THIS_FILE := $(firstword $(MAKEFILE_LIST))

# Directories
CURRENT_DIR := $(PWD)
SOURCE_DIR := src
TARGET_DIR := build
VERILOG_DIR := $(TARGET_DIR)/verilog_sources
BLUESPEC_OUT_DIR := $(TARGET_DIR)/bluespec
SYMBIFLOW_DIR := $(TARGET_DIR)/symbiflow

# FPGA config
BITSTREAM_DEVICE := zynq7
DEVICE := xc7z010_test
PARTNAME := xc7z010clg400-1

# bitfile name
BLUESPEC_TOP_MODULE := mkTop
TOP := top
BITFILE := $(TARGET_DIR)/$(TOP).bit

# bluespec sources
BLUESPEC_FILES := \
    Top.bsv \
    Utils.bsv \
    Zybo.bsv

VERILOG_SOURCES := $(SOURCE_DIR)/$(TOP).v

# XDC
XDC_FILE := zybo.xdc

GREEN_BOLD := \e[32;1m
RESET_COLOR := \e[39;0m

all: $(BITFILE) $(THIS_FILE)

$(VERILOG_DIR)/$(BLUESPEC_TOP_MODULE).v: $(addprefix $(SOURCE_DIR)/, $(BLUESPEC_FILES)) $(THIS_FILE)
	@echo "[$(GREEN_BOLD)Building BSV sources$(RESET_COLOR)]"
	@mkdir -p $(BLUESPEC_OUT_DIR)
	@mkdir -p $(dir $@)
	@bsc -bdir $(BLUESPEC_OUT_DIR) -vdir $(VERILOG_DIR) -u -verilog -p $(SOURCE_DIR):%/Libraries $<

$(SYMBIFLOW_DIR)/$(TOP).eblif: $(VERILOG_DIR)/$(BLUESPEC_TOP_MODULE).v $(THIS_FILE)
	@echo "[$(GREEN_BOLD)Running Synthesys$(RESET_COLOR)]"
	@mkdir -p $(SYMBIFLOW_DIR)
	@cd $(SYMBIFLOW_DIR) && symbiflow_synth -t top -v $(addprefix $(CURRENT_DIR)/, $(VERILOG_SOURCES) $(wildcard $(VERILOG_DIR)/*.v)) -d $(BITSTREAM_DEVICE) -p $(PARTNAME) -x $(CURRENT_DIR)/$(XDC_FILE) 2>&1 > /dev/null

$(SYMBIFLOW_DIR)/$(TOP).net: $(SYMBIFLOW_DIR)/$(TOP).eblif $(THIS_FILE)
	@echo "[$(GREEN_BOLD)Pack netlist$(RESET_COLOR)]"
	@cd ${SYMBIFLOW_DIR} && symbiflow_pack -e ${TOP}.eblif -d ${DEVICE} ${SDC_CMD} 2>&1 > /dev/null

$(SYMBIFLOW_DIR)/$(TOP).place: $(SYMBIFLOW_DIR)/$(TOP).net $(THIS_FILE)
	@echo "[$(GREEN_BOLD)Runnig place$(RESET_COLOR)]"
	@cd $(SYMBIFLOW_DIR) && symbiflow_place -e $(TOP).eblif -d $(DEVICE) $(PCF_CMD) -n $(TOP).net -P $(PARTNAME) $(SDC_CMD) 2>&1 > /dev/null

$(SYMBIFLOW_DIR)/$(TOP).route: $(SYMBIFLOW_DIR)/$(TOP).place $(THIS_FILE)
	@echo "[$(GREEN_BOLD)Runnig route$(RESET_COLOR)]"
	@cd $(SYMBIFLOW_DIR) && symbiflow_route -e $(TOP).eblif -d $(DEVICE) $(SDC_CMD) 2>&1 > /dev/null

$(SYMBIFLOW_DIR)/$(TOP).fasm: $(SYMBIFLOW_DIR)/$(TOP).route $(THIS_FILE)
	@echo "[$(GREEN_BOLD)Generating fasm$(RESET_COLOR)]"
	@cd $(SYMBIFLOW_DIR) && symbiflow_write_fasm -e $(TOP).eblif -d $(DEVICE) 2>&1 > /dev/null

$(SYMBIFLOW_DIR)/$(TOP).bit: $(SYMBIFLOW_DIR)/$(TOP).fasm $(THIS_FILE)
	@echo "[$(GREEN_BOLD)Generating bitstream$(RESET_COLOR)]"
	@cd $(SYMBIFLOW_DIR) && symbiflow_write_bitstream -d $(BITSTREAM_DEVICE) -f $(TOP).fasm -p $(PARTNAME) -b $(TOP).bit 2>&1 > /dev/null

$(BITFILE): $(SYMBIFLOW_DIR)/$(TOP).bit
	@cp $^ $@

flash: $(BITFILE)
	@echo "[$(GREEN_BOLD)Flashing board$(RESET_COLOR)]"
	@vivado -mode batch -source flash.tcl -nojournal -nolog

clean:
	@rm -r $(TARGET_DIR)

.PHONY: flash
