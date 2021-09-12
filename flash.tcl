
open_hw_manager
connect_hw_server -allow_non_jtag
open_hw_target
current_hw_device [get_hw_devices xc7z010_1]
refresh_hw_device -update_hw_probes false [lindex [get_hw_devices xc7z010_1] 0]
set_property PROBES.FILE {} [get_hw_devices xc7z010_1]
set_property FULL_PROBES.FILE {} [get_hw_devices xc7z010_1]
set bitfile [pwd]/build/top.bit
set_property PROGRAM.FILE $bitfile [get_hw_devices xc7z010_1]
program_hw_devices [get_hw_devices xc7z010_1]
