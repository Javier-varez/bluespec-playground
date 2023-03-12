LOCAL_DIR := $(call current-dir)

include $(CLEAR_VARS)
LOCAL_NAME := test_fw

LOCAL_SRCS := main.cpp \
			  start.S

LOCAL_ASFLAGS := -march=rv32i -mabi=ilp32
LOCAL_CXXFLAGS := -Os -std=c++20 -Wall -Werror -fno-exceptions -fno-rtti -nostdlib -nostartfiles -march=rv32i -mabi=ilp32 -Wno-array-bounds
LOCAL_LDFLAGS := -T $(LOCAL_DIR)/script.ld

include $(BUILD_BINARY)
