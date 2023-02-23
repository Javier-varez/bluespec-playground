LOCAL_DIR := $(call current-dir)

include $(CLEAR_VARS)
LOCAL_NAME := zybo_counter

LOCAL_FAMILY := zynq7
LOCAL_DEVICE := xc7z010_test
LOCAL_PARTNAME := xc7z010clg400-1

LOCAL_SRC_DIR := counter

LOCAL_BSV_SRC := \
    Top.bsv \
    Utils.bsv \
    Zybo.bsv

LOCAL_V_SRC := \
    top.v

LOCAL_XDC := zybo.xdc

include $(BUILD_BITSTREAM)

include $(CLEAR_VARS)
LOCAL_NAME := cpu_tests

LOCAL_SRC_DIR := cpu
LOCAL_BSV_SRC := \
    Cpu.bsv \
    CpuMemory.bsv \
    Types.bsv

LOCAL_BSV_TB := \
    TestBench.bsv

include $(BUILD_BLUESIM_TEST)
