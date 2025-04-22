SIM ?= icarus
TOPLEVEL_LANG ?= verilog
VERILOG_SOURCES += $(PWD)/main_fsm.sv

TOPLEVEL = main_fsm
MODULE = test_main_fsm

# Use a more direct approach for Mac with conda environment
PYTHON_BIN ?= /usr/local/Caskroom/miniconda/base/envs/comparch/bin/python
COCOTB_HDL_TIMEUNIT = 1ns
COCOTB_HDL_TIMEPRECISION = 1ps

# Include the standard Icarus makefile configuration
include $(shell cocotb-config --makefiles)/Makefile.sim
