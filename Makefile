SIM ?= icarus
TOPLEVEL_LANG ?= verilog
VERILOG_SOURCES += $(PWD)/top.sv

TOPLEVEL = top
MODULE = test_top
# MODULE = test_top
MODULE = test_final

# Use a more direct approach for Mac with conda environment
PYTHON_BIN ?= /Applications/oss-cad-suite/bin/tabbypy3
COCOTB_HDL_TIMEUNIT = 1ns
COCOTB_HDL_TIMEPRECISION = 1ps

# COMPILE_ARGS += -P $(TOPLEVEL).INIT_FILE=\"rv32i_test.txt\"

# Include the standard Icarus makefile configuration
include $(shell cocotb-config --makefiles)/Makefile.sim

# # Optional target to clean up
# clean:
# 	rm -rf __pycache__ *.vcd *.vvp sim_build
