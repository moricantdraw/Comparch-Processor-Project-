SIM ?= icarus
TOPLEVEL_LANG ?= verilog
VERILOG_SOURCES += $(PWD)/top.sv

TOPLEVEL = top
MODULE = test_top

# Use a more direct approach for Mac with conda environment
PYTHON_BIN ?= /usr/local/Caskroom/miniconda/base/envs/comparch/bin/python
COCOTB_HDL_TIMEUNIT = 1ns
COCOTB_HDL_TIMEPRECISION = 1ps

# COMPILE_ARGS += -P $(TOPLEVEL).INIT_FILE=\"rv32i_test.txt\"

# Include the standard Icarus makefile configuration
include $(shell cocotb-config --makefiles)/Makefile.sim
