THIS_FILE := $(firstword $(MAKEFILE_LIST))

# Arguments:
#   - Inputs:
#     - LOCAL_NAME       - Name of the target this rule will build.
#     - LOCAL_SRC_DIR    - The directory containing the sources
#     - LOCAL_BSV_SRC    - The Bluespec System Verilog sources for this design. The first one will be the top bsv module
#     - LOCAL_BSV_TB     - The Bluespec System Verilog test bench sources for this design.
#
#     - LOCAL_DIR        - The current makefile directory
#

_BLUESIM_TEST_DIR := $(_TARGET_DIR)/bluesim_test/$(LOCAL_NAME)
_GEN_BLUESPEC_DIR := $(_BLUESIM_TEST_DIR)/gen_bluespec
_GEN_SIMULATION_DIR := $(_BLUESIM_TEST_DIR)/gen_simulation

_BLUESIM_TEST := $(_BLUESIM_TEST_DIR)/$(LOCAL_NAME)

_BLUESPEC_DUMMY_MARKER := $(_GEN_BLUESPEC_DIR)/.bsv_build

$(_GEN_BLUESPEC_DIR):
	@mkdir -p $@

$(_GEN_SIMULATION_DIR):
	@mkdir -p $@

_TESTBENCH_MODULE := mkTestBench

$(_BLUESIM_TEST): SRC_DIR := $(LOCAL_SRC_DIR)
$(_BLUESIM_TEST): GEN_BLUESPEC_DIR := $(_GEN_BLUESPEC_DIR)
$(_BLUESIM_TEST): GEN_SIMULATION_DIR := $(_GEN_SIMULATION_DIR)
$(_BLUESIM_TEST): SRC_DIR := $(LOCAL_SRC_DIR)
$(_BLUESIM_TEST): TESTBENCH_MODULE := $(_TESTBENCH_MODULE)
$(_BLUESIM_TEST): $(LOCAL_SRC_DIR)/$(LOCAL_BSV_TB) $(addprefix $(LOCAL_SRC_DIR)/, $(LOCAL_BSV_SRC)) $(_GEN_BLUESPEC_DIR) $(_GEN_SIMULATION_DIR) $(THIS_FILE)
	@echo "[$(_GREEN_BOLD)Building BSV test$(_RESET_COLOR)]"
	@bsc -u -sim -simdir $(GEN_SIMULATION_DIR) -bdir $(GEN_BLUESPEC_DIR) -info-dir $(GEN_BLUESPEC_DIR) -keep-fires -aggressive-conditions -check-assert -g $(TESTBENCH_MODULE) -p $(SRC_DIR):%/Libraries $<
	@bsc -e $(TESTBENCH_MODULE) -sim -o $@ -simdir $(GEN_SIMULATION_DIR) -bdir $(GEN_BLUESPEC_DIR) -info-dir $(GEN_BLUESPEC_DIR) -keep-fires -aggressive-conditions -check-assert -g $(TESTBENCH_MODULE) -p $(SRC_DIR):%/Libraries


$(LOCAL_NAME): $(_BLUESIM_TEST)
.PHONY: $(LOCAL_NAME)

run_$(LOCAL_NAME): NAME := $(LOCAL_NAME)
run_$(LOCAL_NAME): $(_BLUESIM_TEST)
	@echo "[$(_GREEN_BOLD)Running BSV test -> $(NAME)$(_RESET_COLOR)]"
	@$<
.PHONY: run_$(LOCAL_NAME)

_ALL_TARGETS += $(_BLUESIM_TEST)
