THIS_FILE := $(firstword $(MAKEFILE_LIST))

# Arguments:
#   - Inputs:
#     - LOCAL_NAME       - Name of the target this rule will build.
#     - LOCAL_FAMILY     - The device family selected for the bitstream target (E.g.: zynq7)
#     - LOCAL_DEVICE     - The Yosys device selected for the bitstream target (E.g.: xc7z010_test)
#     - LOCAL_PARTNAME   - The xilinx partname for the target
#     - LOCAL_SRC_DIR    - The directory containing the sources
#     - LOCAL_V_SRC      - The verilog sources for this design
#     - LOCAL_BSV_SRC    - The Bluespec System Verilog sources for this design. The first one will be the top bsv module
#     - LOCAL_XDC        - The XDC file describing pin constrains
#
#     - LOCAL_DIR        - The current makefile directory
#


_BITSTREAM_DIR := $(_TARGET_DIR)/bitstream/$(LOCAL_NAME)
_GEN_VERILOG_DIR := $(_BITSTREAM_DIR)/gen_verilog
_GEN_BLUESPEC_DIR := $(_BITSTREAM_DIR)/gen_bluespec
_GEN_SYMBIFLOW_DIR := $(_BITSTREAM_DIR)/gen_symbiflow

_BITSTREAM := $(_BITSTREAM_DIR)/$(LOCAL_NAME).bit

_BLUESPEC_DUMMY_MARKER := $(_GEN_BLUESPEC_DIR)/.bsv_build

$(_BITSTREAM_DIR):
	@mkdir -p $@

$(_GEN_VERILOG_DIR):
	@mkdir -p $@

$(_GEN_BLUESPEC_DIR):
	@mkdir -p $@

$(_GEN_SYMBIFLOW_DIR):
	@mkdir -p $@

$(_BLUESPEC_DUMMY_MARKER): SRC_DIR := $(LOCAL_SRC_DIR)
$(_BLUESPEC_DUMMY_MARKER): GEN_VERILOG_DIR := $(_GEN_VERILOG_DIR)
$(_BLUESPEC_DUMMY_MARKER): GEN_BLUESPEC_DIR := $(_GEN_BLUESPEC_DIR)
$(_BLUESPEC_DUMMY_MARKER): $(addprefix $(LOCAL_SRC_DIR)/, $(LOCAL_BSV_SRC)) $(_GEN_BLUESPEC_DIR) $(_GEN_VERILOG_DIR) $(THIS_FILE)
	@echo "[$(_GREEN_BOLD)Building BSV sources$(_RESET_COLOR)]"
	@bsc -bdir $(GEN_BLUESPEC_DIR) -vdir $(GEN_VERILOG_DIR) -u -verilog -p $(SRC_DIR):%/Libraries $<
	@touch $@

$(_GEN_SYMBIFLOW_DIR)/top.eblif: GEN_SYMBIFLOW_DIR := $(_GEN_SYMBIFLOW_DIR)
$(_GEN_SYMBIFLOW_DIR)/top.eblif: GEN_VERILOG_DIR := $(_GEN_VERILOG_DIR)
$(_GEN_SYMBIFLOW_DIR)/top.eblif: FAMILY := $(LOCAL_FAMILY)
$(_GEN_SYMBIFLOW_DIR)/top.eblif: DEVICE := $(LOCAL_DEVICE)
$(_GEN_SYMBIFLOW_DIR)/top.eblif: PARTNAME := $(LOCAL_PARTNAME)
$(_GEN_SYMBIFLOW_DIR)/top.eblif: NAME := $(LOCAL_NAME)
$(_GEN_SYMBIFLOW_DIR)/top.eblif: DIR := $(LOCAL_DIR)
$(_GEN_SYMBIFLOW_DIR)/top.eblif: SRC_DIR := $(LOCAL_SRC_DIR)
$(_GEN_SYMBIFLOW_DIR)/top.eblif: V_SRC := $(LOCAL_V_SRC)
$(_GEN_SYMBIFLOW_DIR)/top.eblif: XDC := $(LOCAL_XDC)
$(_GEN_SYMBIFLOW_DIR)/top.eblif: $(_BLUESPEC_DUMMY_MARKER) $(_GEN_SYMBIFLOW_DIR) $(THIS_FILE)
	@echo "[$(_GREEN_BOLD)Running Synthesys$(_RESET_COLOR)]"
	@cd $(GEN_SYMBIFLOW_DIR) && symbiflow_synth -t top -v $(addprefix $(DIR)/$(SRC_DIR)/, $(V_SRC)) $(addprefix $(DIR)/, $(wildcard $(GEN_VERILOG_DIR)/*.v)) -d $(FAMILY) -p $(PARTNAME) -x $(DIR)/$(XDC) 2>&1 > /dev/null

$(_GEN_SYMBIFLOW_DIR)/top.net: GEN_SYMBIFLOW_DIR := $(_GEN_SYMBIFLOW_DIR)
$(_GEN_SYMBIFLOW_DIR)/top.net: DEVICE := $(LOCAL_DEVICE)
$(_GEN_SYMBIFLOW_DIR)/top.net: $(_GEN_SYMBIFLOW_DIR)/top.eblif $(_GEN_SYMBIFLOW_DIR) $(THIS_FILE)
	@echo "[$(_GREEN_BOLD)Pack netlist$(_RESET_COLOR)]"
	@cd $(GEN_SYMBIFLOW_DIR) && symbiflow_pack -e top.eblif -d $(DEVICE) 2>&1 > /dev/null

$(_GEN_SYMBIFLOW_DIR)/top.place: GEN_SYMBIFLOW_DIR := $(_GEN_SYMBIFLOW_DIR)
$(_GEN_SYMBIFLOW_DIR)/top.place: DEVICE := $(LOCAL_DEVICE)
$(_GEN_SYMBIFLOW_DIR)/top.place: PARTNAME := $(LOCAL_PARTNAME)
$(_GEN_SYMBIFLOW_DIR)/top.place: $(_GEN_SYMBIFLOW_DIR)/top.net $(_GEN_SYMBIFLOW_DIR) $(THIS_FILE)
	@echo "[$(_GREEN_BOLD)Runnig place$(_RESET_COLOR)]"
	@cd $(GEN_SYMBIFLOW_DIR) && symbiflow_place -e top.eblif -d $(DEVICE) -n top.net -P $(PARTNAME) 2>&1 > /dev/null

$(_GEN_SYMBIFLOW_DIR)/top.route: GEN_SYMBIFLOW_DIR := $(_GEN_SYMBIFLOW_DIR)
$(_GEN_SYMBIFLOW_DIR)/top.route: DEVICE := $(LOCAL_DEVICE)
$(_GEN_SYMBIFLOW_DIR)/top.route: $(_GEN_SYMBIFLOW_DIR)/top.place $(_GEN_SYMBIFLOW_DIR) $(THIS_FILE)
	@echo "[$(_GREEN_BOLD)Runnig route$(_RESET_COLOR)]"
	@cd $(GEN_SYMBIFLOW_DIR) && symbiflow_route -e top.eblif -d $(DEVICE) 2>&1 > /dev/null

$(_GEN_SYMBIFLOW_DIR)/top.fasm: GEN_SYMBIFLOW_DIR := $(_GEN_SYMBIFLOW_DIR)
$(_GEN_SYMBIFLOW_DIR)/top.fasm: DEVICE := $(LOCAL_DEVICE)
$(_GEN_SYMBIFLOW_DIR)/top.fasm: $(_GEN_SYMBIFLOW_DIR)/top.route $(_GEN_SYMBIFLOW_DIR) $(THIS_FILE)
	@echo "[$(_GREEN_BOLD)Generating fasm$(_RESET_COLOR)]"
	@cd $(GEN_SYMBIFLOW_DIR) && symbiflow_write_fasm -e top.eblif -d $(DEVICE) 2>&1 > /dev/null

$(_GEN_SYMBIFLOW_DIR)/top.bit: GEN_SYMBIFLOW_DIR := $(_GEN_SYMBIFLOW_DIR)
$(_GEN_SYMBIFLOW_DIR)/top.bit: FAMILY := $(LOCAL_FAMILY)
$(_GEN_SYMBIFLOW_DIR)/top.bit: PARTNAME := $(LOCAL_PARTNAME)
$(_GEN_SYMBIFLOW_DIR)/top.bit: $(_GEN_SYMBIFLOW_DIR)/top.fasm $(_GEN_SYMBIFLOW_DIR) $(THIS_FILE)
	@echo "[$(_GREEN_BOLD)Generating bitstream$(_RESET_COLOR)]"
	@cd $(GEN_SYMBIFLOW_DIR) && symbiflow_write_bitstream -d $(FAMILY) -f top.fasm -p $(PARTNAME) -b top.bit 2>&1 > /dev/null

$(_BITSTREAM): $(_GEN_SYMBIFLOW_DIR)/top.bit
	@cp $^ $@

$(LOCAL_NAME): $(_BITSTREAM)
.PHONY: $(LOCAL_NAME)

flash_$(LOCAL_NAME): NAME := $(LOCAL_NAME)
flash_$(LOCAL_NAME): $(_BITSTREAM)
	@echo "[$(_GREEN_BOLD)Flashing board -> $(NAME).bit$(_RESET_COLOR)]"
	@vivado -mode batch -source flash.tcl -nojournal -nolog -tclargs $<

.PHONY: flash_$(LOCAL_NAME)

_ALL_TARGETS += $(_BITSTREAM)
