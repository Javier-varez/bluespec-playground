
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
TOP := top
BITFILE := $(TARGET_DIR)/$(TOP).bit

# bluespec sources
BLUESPEC_TOP_FILE := ATE.bsv
BLUESPEC_TOP_MODULE := mkTop

VERILOG_SOURCES := $(SOURCE_DIR)/top.v

# XDC
XDC_FILE := zybo.xdc

# Find verilog sources
VERILOG_SOURCES += $(addprefix $(VERILOG_DIR)/, $(addsuffix .v, $(BLUESPEC_TOP_MODULE)))

all: $(BITFILE)

$(VERILOG_DIR)/$(BLUESPEC_TOP_MODULE).v: $(SOURCE_DIR)/$(BLUESPEC_TOP_FILE)
	@mkdir -p $(BLUESPEC_OUT_DIR)
	@mkdir -p $(dir $@)
	bsc -bdir $(BLUESPEC_OUT_DIR) -vdir $(dir $@) -verilog $^

$(SYMBIFLOW_DIR)/$(TOP).eblif: $(VERILOG_SOURCES)
	@mkdir -p $(SYMBIFLOW_DIR)
	cd $(SYMBIFLOW_DIR) && symbiflow_synth -t top -v $(addprefix $(CURRENT_DIR)/, $(VERILOG_SOURCES)) -d $(BITSTREAM_DEVICE) -p $(PARTNAME) -x $(CURRENT_DIR)/$(XDC_FILE) 2>&1 > /dev/null

$(SYMBIFLOW_DIR)/$(TOP).net: $(SYMBIFLOW_DIR)/$(TOP).eblif
	cd ${SYMBIFLOW_DIR} && symbiflow_pack -e ${TOP}.eblif -d ${DEVICE} ${SDC_CMD} 2>&1 > /dev/null

$(SYMBIFLOW_DIR)/$(TOP).place: $(SYMBIFLOW_DIR)/$(TOP).net
	cd $(SYMBIFLOW_DIR) && symbiflow_place -e $(TOP).eblif -d $(DEVICE) $(PCF_CMD) -n $(TOP).net -P $(PARTNAME) $(SDC_CMD) 2>&1 > /dev/null

$(SYMBIFLOW_DIR)/$(TOP).route: $(SYMBIFLOW_DIR)/$(TOP).place
	cd $(SYMBIFLOW_DIR) && symbiflow_route -e $(TOP).eblif -d $(DEVICE) $(SDC_CMD) 2>&1 > /dev/null

$(SYMBIFLOW_DIR)/$(TOP).fasm: $(SYMBIFLOW_DIR)/$(TOP).route
	cd $(SYMBIFLOW_DIR) && symbiflow_write_fasm -e $(TOP).eblif -d $(DEVICE)

$(SYMBIFLOW_DIR)/$(TOP).bit: $(SYMBIFLOW_DIR)/$(TOP).fasm
	cd $(SYMBIFLOW_DIR) && symbiflow_write_bitstream -d $(BITSTREAM_DEVICE) -f $(TOP).fasm -p $(PARTNAME) -b $(TOP).bit

$(BITFILE): $(SYMBIFLOW_DIR)/$(TOP).bit
	@cp $^ $@

flash: $(BITFILE)
	vivado -mode batch -source flash.tcl -nojournal -nolog

clean:
	rm -r $(TARGET_DIR)

.PHONY: flash
