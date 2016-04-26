SetActiveLib -work
comp -include "$dsn\src\MicroProcessor.vhd" 
comp -include "$dsn\src\TestBench\microprocessor_TB.vhd" 
asim +access +r TESTBENCH_FOR_microprocessor 
wave 
wave -noreg clk
wave -noreg rst
wave -noreg start
wave -noreg stop
# The following lines can be used for timing simulation
# acom <backannotated_vhdl_file_name>
# comp -include "$dsn\src\TestBench\microprocessor_TB_tim_cfg.vhd" 
# asim +access +r TIMING_FOR_microprocessor 
