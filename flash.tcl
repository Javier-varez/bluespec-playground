
set bitfile [pwd]/build/top.bit

open_hw_manager
connect_hw_server -allow_non_jtag

open_hw_target
current_hw_device [get_hw_devices xc7z010_1]

set_property PROGRAM.FILE $bitfile [get_hw_devices xc7z010_1]
program_hw_devices [get_hw_devices xc7z010_1]
