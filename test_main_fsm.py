import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge, Timer
from cocotb.regression import TestFactory
import random

# RISC-V Opcodes
R_TYPE    = 0b0110011
I_ARITH   = 0b0010011
LOAD      = 0b0000011
STORE     = 0b0100011
BRANCH    = 0b1100011
JAL       = 0b1101111
AUIPC     = 0b0010111
LUI       = 0b0110111
JALR      = 0b1100111
INVALID   = 0b1111111

# State mapping
STATES = {
    0: "s0 (Fetch)",
    1: "s1 (Decode)",
    2: "s2 (Addr Calc)",
    3: "s3 (Mem Access)",
    4: "s4 (Load Writeback)",
    5: "s5 (Store)",
    6: "s6 (R-type Execute)",
    7: "s7 (R/I Writeback)",
    8: "s8 (I-arith Execute)",
    9: "s9 (JAL)",
    10: "s10 (Branch)",
    11: "s11 (AUIPC)",
    12: "s12 (LUI)",
    13: "s13 (Error)"
}

async def check_control_signals(dut, expected):
    """Check if control signals match expected values"""
    actual = {
        "branch": dut.branch.value,
        "pcupdate": dut.pcupdate.value,
        "regwrite": dut.regwrite.value,
        "memwrite": dut.memwrite.value,
        "irwrite": dut.irwrite.value,
        "resultsrc": dut.resultsrc.value,
        "alusrcb": dut.alusrcb.value,
        "alusrca": dut.alusrca.value,
        "adrsrc": dut.adrsrc.value,
        "aluop": dut.aluop.value
    }
    
    for signal, value in expected.items():
        if actual[signal] != value:
            dut._log.error(f"Signal {signal} mismatch: expected {value}, got {actual[signal]}")
            return False
    return True

async def print_control_signals(dut):
    """Check if control signals match expected values"""
    actual = {
        "branch": dut.branch.value,
        "pcupdate": dut.pcupdate.value,
        "regwrite": dut.regwrite.value,
        "memwrite": dut.memwrite.value,
        "irwrite": dut.irwrite.value,
        "resultsrc": dut.resultsrc.value,
        "alusrcb": dut.alusrcb.value,
        "alusrca": dut.alusrca.value,
        "adrsrc": dut.adrsrc.value,
        "aluop": dut.aluop.value
    }

    dut._log.info("state: %s", dut.state.value)
    dut._log.info("next: %s", dut.nextstate.value)
    for signal, value in actual.items():
        dut._log.info(f"Signal {signal}: got {value}")
    return True

async def run_fsm_cycle(dut, op_code):
    """Run a single FSM cycle with the given opcode"""
    dut.op.value = op_code
    await RisingEdge(dut.clk)

async def reset_fsm(dut):
    """Reset FSM to known state (s0)"""
    # # Set to s13 first (assuming it loops back to itself)
    # dut.op.value = INVALID
    # for _ in range(5):  # several cycles to ensure we reach s13
    #     await RisingEdge(dut.clk)
    
    # # Then start a fresh cycle to reach s0
    # dut.op.value = R_TYPE  # Arbitrary valid opcode
    # await RisingEdge(dut.clk)
    # await RisingEdge(dut.clk)
    dut.state.value = 0b0000
    await Timer(1, "ns")

@cocotb.test()
async def test_r_type_instruction(dut):
    """Test R-type instruction path"""
    # Start clock
    clock = Clock(dut.clk, 10, units="ns")
    cocotb.start_soon(clock.start())
    
    # We should now be in s0
    dut._log.info("Testing R-type instruction path")
    await run_fsm_cycle(dut, R_TYPE)
    await run_fsm_cycle(dut, R_TYPE)
    
    # s0 (Fetch) -> s1 (Decode)
    await check_control_signals(dut, {
        "pcupdate": 1, "irwrite": 1, "resultsrc": 0b10, "alusrcb": 0b10,
        "branch": 0, "regwrite": 0, "memwrite": 0, 
        "alusrca": 0, "adrsrc": 0, "aluop": 0
    })
    await print_control_signals(dut)
    assert dut.irwrite.value == 1, "Poop2"
    assert dut.resultsrc.value == 2, f"Got {dut.resultsrc.value}"
    assert dut.alusrcb.value == 0b10, f"Got {dut.alusrcb.value}"
    assert dut.aluop.value == 0b00, f"Got {dut.alusrcb.value}"
    assert dut.pcupdate.value == 1, f"Got {dut.pcupdate.value}"
    dut._log.info("S0 PASSED")
    await run_fsm_cycle(dut, R_TYPE)
    
    # s1 (Decode) -> s6 (R-type Execute)
    await check_control_signals(dut, {
        "alusrcb": 1, "alusrca": 1,
        "branch": 0, "pcupdate": 0, "regwrite": 0, "memwrite": 0, 
        "irwrite": 0, "resultsrc": 0, "adrsrc": 0, "aluop": 0
    })
    await run_fsm_cycle(dut, R_TYPE)
    
    # s6 (R-type Execute) -> s7 (R/I Writeback)
    await check_control_signals(dut, {
        "alusrca": 2, "aluop": 2,
        "branch": 0, "pcupdate": 0, "regwrite": 0, "memwrite": 0,
        "irwrite": 0, "resultsrc": 0, "alusrcb": 0, "adrsrc": 0
    })
    await run_fsm_cycle(dut, R_TYPE)
    
    # s7 (R/I Writeback) -> s0 (Fetch)
    await check_control_signals(dut, {
        "regwrite": 1,
        "branch": 0, "pcupdate": 0, "memwrite": 0, "irwrite": 0,
        "resultsrc": 0, "alusrcb": 0, "alusrca": 0, "adrsrc": 0, "aluop": 0
    })
    await run_fsm_cycle(dut, R_TYPE)
    
    # Back to s0 (Fetch)
    await check_control_signals(dut, {
        "pcupdate": 1, "irwrite": 1, "resultsrc": 2, "alusrcb": 2,
        "branch": 0, "regwrite": 0, "memwrite": 0, 
        "alusrca": 0, "adrsrc": 0, "aluop": 0
    })

@cocotb.test()
async def test_load_instruction(dut):
    """Test load instruction path"""
    clock = Clock(dut.clk, 10, units="ns")
    cocotb.start_soon(clock.start())
    
    await reset_fsm(dut)
    
    # s0 -> s1
    await run_fsm_cycle(dut, LOAD)
    await run_fsm_cycle(dut, LOAD)
    
    # s1 -> s2 (Address calculation)
    await check_control_signals(dut, {
        "alusrcb": 1, "alusrca": 1,
        "branch": 0, "pcupdate": 0, "regwrite": 0, "memwrite": 0, 
        "irwrite": 0, "resultsrc": 0, "adrsrc": 0, "aluop": 0
    })
    await run_fsm_cycle(dut, LOAD)
    
    # s2 -> s3 (Memory access)
    await check_control_signals(dut, {
        "alusrcb": 1, "alusrca": 2,
        "branch": 0, "pcupdate": 0, "regwrite": 0, "memwrite": 0, 
        "irwrite": 0, "resultsrc": 0, "adrsrc": 0, "aluop": 0
    })
    await run_fsm_cycle(dut, LOAD)
    
    # s3 -> s4 (Load writeback)
    await check_control_signals(dut, {
        "alusrcb": 0, "adrsrc": 1,
        "branch": 0, "pcupdate": 0, "regwrite": 0, "memwrite": 0, 
        "irwrite": 0, "resultsrc": 0, "alusrca": 0, "aluop": 0
    })
    await run_fsm_cycle(dut, LOAD)
    
    # s4 -> s0
    await check_control_signals(dut, {
        "regwrite": 1, "resultsrc": 1,
        "branch": 0, "pcupdate": 0, "memwrite": 0, "irwrite": 0,
        "alusrcb": 0, "alusrca": 0, "adrsrc": 0, "aluop": 0
    })

@cocotb.test()
async def test_store_instruction(dut):
    """Test store instruction path"""
    clock = Clock(dut.clk, 10, units="ns")
    cocotb.start_soon(clock.start())
    
    await reset_fsm(dut)
    
    # s0 -> s1
    await run_fsm_cycle(dut, STORE)
    await run_fsm_cycle(dut, STORE)
    
    # s1 -> s2 (Address calculation)
    await run_fsm_cycle(dut, STORE)
    
    # s2 -> s5 (Store)
    await check_control_signals(dut, {
        "alusrcb": 1, "alusrca": 2,
        "branch": 0, "pcupdate": 0, "regwrite": 0, "memwrite": 0, 
        "irwrite": 0, "resultsrc": 0, "adrsrc": 0, "aluop": 0
    })
    await run_fsm_cycle(dut, STORE)
    
    # s5 -> s0
    await check_control_signals(dut, {
        "memwrite": 1, "adrsrc": 1,
        "branch": 0, "pcupdate": 0, "regwrite": 0, "irwrite": 0,
        "resultsrc": 0, "alusrcb": 0, "alusrca": 0, "aluop": 0
    })

@cocotb.test()
async def test_branch_instruction(dut):
    """Test branch instruction path"""
    clock = Clock(dut.clk, 10, units="ns")
    cocotb.start_soon(clock.start())
    
    await reset_fsm(dut)
    
    # s0 -> s1
    await run_fsm_cycle(dut, BRANCH)
    await run_fsm_cycle(dut, BRANCH)

    
    # s1 -> s10 (Branch)
    await run_fsm_cycle(dut, BRANCH)
    
    # s10 -> s0
    await check_control_signals(dut, {
        "branch": 1, "alusrca": 2, "aluop": 1,
        "pcupdate": 0, "regwrite": 0, "memwrite": 0, "irwrite": 0,
        "resultsrc": 0, "alusrcb": 0, "adrsrc": 0
    })

@cocotb.test()
async def test_jal_instruction(dut):
    """Test JAL instruction path"""
    clock = Clock(dut.clk, 10, units="ns")
    cocotb.start_soon(clock.start())
    
    await reset_fsm(dut)
    
    # s0 -> s1
    await run_fsm_cycle(dut, JAL)
    await run_fsm_cycle(dut, JAL)

    # s1 -> s9 (JAL)
    await run_fsm_cycle(dut, JAL)
    
    # s9 -> s7
    await check_control_signals(dut, {
        "pcupdate": 1, "alusrcb": 2, "alusrca": 1,
        "branch": 0, "regwrite": 0, "memwrite": 0, "irwrite": 0,
        "resultsrc": 0, "adrsrc": 0, "aluop": 0
    })
    await run_fsm_cycle(dut, JAL)
    
    # s7 -> s0
    await check_control_signals(dut, {
        "regwrite": 1,
        "branch": 0, "pcupdate": 0, "memwrite": 0, "irwrite": 0,
        "resultsrc": 0, "alusrcb": 0, "alusrca": 0, "adrsrc": 0, "aluop": 0
    })

# @cocotb.test()
# async def test_invalid_opcode(dut):
#     """Test invalid opcode handling"""
#     clock = Clock(dut.clk, 10, units="ns")
#     cocotb.start_soon(clock.start())
    
#     await reset_fsm(dut)
    
#     # s0 -> s1
#     await run_fsm_cycle(dut, INVALID)
    
#     # s1 -> s13 (Error)
#     await run_fsm_cycle(dut, INVALID)
    
#     # s13 -> s13 (Error state stays in error)
#     # Check that signals are X in error state
#     await RisingEdge(dut.clk)
#     # We can't directly check for X values in cocotb, but we can verify
#     # that we remain in the error state by running a few more cycles
#     await run_fsm_cycle(dut, R_TYPE)
#     await run_fsm_cycle(dut, R_TYPE)
#     # Still should be in error state
    
#     # Reset FSM
#     await reset_fsm(dut)
