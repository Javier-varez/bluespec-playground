THIS_FILE := $(firstword $(MAKEFILE_LIST))

# Arguments:
#   - Inputs:
#     - LOCAL_NAME       - Name of the target this rule will build.
#     - LOCAL_SRCS       - The directory containing the sources
#     - LOCAL_CXXFLAGS   - The C++ flags used to build the target
#     - LOCAL_CFLAGS     - The C flags used to build the target
#     - LOCAL_LDFLAGS    - The linker flags used to build the target
#     - LOCAL_ASFLAGS    - The assembler flags used to build the target

_FW_DIR := $(_TARGET_DIR)/fw/$(LOCAL_NAME)
_OBJ_DIR := $(_TARGET_DIR)/fw/$(LOCAL_NAME)/obj
_FW_TARGET_ELF := $(_FW_DIR)/$(LOCAL_NAME).elf
_FW_TARGET_BIN := $(_FW_DIR)/$(LOCAL_NAME).bin
_FW_TARGET_MEM := $(_FW_DIR)/$(LOCAL_NAME).mem

_LOCAL_SRCS := $(subst $(_TOP_DIR)/,, $(addprefix $(LOCAL_DIR)/, $(LOCAL_SRCS)))
_FW_OBJS := \
			$(patsubst %.cpp, $(_OBJ_DIR)/%.cpp.o, $(filter %.cpp, $(_LOCAL_SRCS))) \
			$(patsubst %.c, $(_OBJ_DIR)/%.c.o, $(filter %.c, $(_LOCAL_SRCS))) \
			$(patsubst %.S, $(_OBJ_DIR)/%.S.o, $(filter %.S, $(_LOCAL_SRCS)))

$(_OBJ_DIR)/%.cpp.o: LOCAL_CXXFLAGS := $(LOCAL_CXXFLAGS)
$(_OBJ_DIR)/%.cpp.o: _OBJ_DIR := $(_OBJ_DIR)
$(_OBJ_DIR)/%.cpp.o: %.cpp $(THIS_FILE)
	$(SILENT)echo -e "[$(_GREEN_BOLD)$(subst $(_OBJ_DIR)/,,$@)$(_RESET_COLOR)]"
	$(SILENT)mkdir -p $(dir $@)
	riscv32-unknown-elf-g++ -c -o $@ $(LOCAL_CXXFLAGS) $<

$(_OBJ_DIR)/%.c.o: LOCAL_CFLAGS := $(LOCAL_CFLAGS)
$(_OBJ_DIR)/%.c.o: _OBJ_DIR := $(_OBJ_DIR)
$(_OBJ_DIR)/%.c.o: %.c $(THIS_FILE)
	$(SILENT)echo -e "[$(_GREEN_BOLD)$(subst $(_OBJ_DIR)/,,$@)$(_RESET_COLOR)]"
	$(SILENT)mkdir -p $(dir $@)
	riscv32-unknown-elf-gcc -c -o $@ $(LOCAL_CFLAGS) $<

$(_OBJ_DIR)/%.S.o: LOCAL_ASFLAGS := $(LOCAL_ASFLAGS)
$(_OBJ_DIR)/%.S.o: _OBJ_DIR := $(_OBJ_DIR)
$(_OBJ_DIR)/%.S.o: %.S $(THIS_FILE)
	$(SILENT)echo -e "[$(_GREEN_BOLD)$(subst $(_OBJ_DIR)/,,$@)$(_RESET_COLOR)]"
	$(SILENT)mkdir -p $(dir $@)
	riscv32-unknown-elf-as -o $@ $(LOCAL_ASFLAGS) $<

$(_FW_TARGET_ELF): _FW_OBJS := $(_FW_OBJS)
$(_FW_TARGET_ELF): LOCAL_CXXFLAGS := $(LOCAL_CXXFLAGS)
$(_FW_TARGET_ELF): LOCAL_LDFLAGS := $(LOCAL_LDFLAGS)
$(_FW_TARGET_ELF): _FW_DIR := $(_FW_DIR)
$(_FW_TARGET_ELF): $(_FW_OBJS)
	$(SILENT)echo -e "[$(_GREEN_BOLD)$(subst $(_FW_DIR)/,,$@)$(_RESET_COLOR)]"
	$(SILENT)mkdir -p $(dir $@)
	riscv32-unknown-elf-g++ -o $@ $(LOCAL_CXXFLAGS) $(_FW_OBJS) $(LOCAL_LDFLAGS)

$(_FW_TARGET_BIN): _FW_DIR := $(_FW_DIR)
$(_FW_TARGET_BIN): $(_FW_TARGET_ELF)
	$(SILENT)echo -e "[$(_GREEN_BOLD)$(subst $(_FW_DIR)/,,$@)$(_RESET_COLOR)]"
	$(SILENT)mkdir -p $(dir $@)
	riscv32-unknown-elf-objcopy -O binary $< $@

$(_FW_TARGET_MEM): $(_FW_TARGET_BIN)
	hexdump $< -e "1/4 \"%08x\" \"\n\"" > $@

$(LOCAL_NAME): $(_FW_TARGET_MEM)
.PHONY: $(LOCAL_NAME)

_ALL_TARGETS += $(_FW_TARGET_MEM)
