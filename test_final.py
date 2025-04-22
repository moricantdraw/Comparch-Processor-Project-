import cocotb
from cocotb.triggers import RisingEdge, Timer
from cocotb.clock import Clock


@cocotb.test()
async def test_first_instruction_fetch(dut):
    """Check that the first instruction is correctly fetched and loaded."""

    # Start clock
    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())

    # Apply reset
    dut.rst.value = 1
    for _ in range(2):
        await RisingEdge(dut.clk)
    dut.rst.value = 0

    # check values
    state = dut.rv_multi.ControlUnit.MainFSM.state.value
    next = dut.rv_multi.ControlUnit.MainFSM.nextstate.value
    instr_val = dut.rv_multi.DP.Instr.value
    opcode = dut.rv_multi.opcode.value
    funct3 = dut.rv_multi.funct3.value
    dut._log.info("state: %s", state)
    dut._log.info("next: %s", next)   
    dut._log.info("instr: %s", instr_val)   
    dut._log.info("opcode: %s", opcode)   
    dut._log.info("funct3: %s", funct3)
    # Let the system run a few cycles to fetch the instruction
    for _ in range(5):
        await RisingEdge(dut.clk)
        await Timer(1, units="ns")
        state = dut.rv_multi.ControlUnit.MainFSM.state.value
        next = dut.rv_multi.ControlUnit.MainFSM.nextstate.value
        instr_val = dut.rv_multi.DP.Instr.value
        opcode = dut.rv_multi.opcode.value
        funct3 = dut.rv_multi.funct3.value
        dut._log.info("state: %s", state)
        dut._log.info("next: %s", next)
        dut._log.info("instr: %s", instr_val)   
        dut._log.info("opcode: %s", opcode)  
        dut._log.info("funct3: %s", funct3)

    dut._log.info("state: %s", state)
    dut._log.info("next: %s", next)   
    dut._log.info("instr: %s", instr_val)  
    dut._log.info("opcode: %s", opcode)
    dut._log.info("funct3: %s", funct3)
    # Access internal signal via hierarchy
    instr_val = int(dut.rv_multi.DP.Instr.value)
    expected_instr = 0xfedcc0b7

    assert instr_val == expected_instr, f"Expected Instr to be {expected_instr:#010x}, got {instr_val:#010x}"
    dut._log.info(f"Instruction fetched correctly: {instr_val:#010x}")


# import cocotb
# from cocotb.clock import Clock
# from cocotb.triggers import RisingEdge, FallingEdge, Timer

# async def reset_signal(dut):
#     """Try accessing the design."""
#     dut.rst.value = 0
#     await Timer(1, "ns")
#     dut.rst.value = 1
#     await RisingEdge(dut.clk)
#     await RisingEdge(dut.clk)
#     dut.rst.value = 0

# @cocotb.test()
# async def test_test(dut):
#     clock = Clock(dut.clk, 10, units="ns")
#     cocotb.start_soon(clock.start())

#     reset_signal(dut)
#     await Timer(1, "ns")
#     memory = dut.memory.read_data
#     dut._log.info("Memory: %s", memory)
#     value = dut.rv_multi.DP.nonarchreg_PC.PC.value
#     value2 = dut.rv_multi.ControlUnit.PCWrite.value
#     state = dut.rv_multi.ControlUnit.MainFSM.state.value
#     next = dut.rv_multi.ControlUnit.MainFSM.nextstate.value
#     dut._log.info("PC: %s", value)
#     dut._log.info("PCWrite: %s", value2)
#     dut._log.info("state: %s", state)
#     dut._log.info("next: %s", next)
#     await RisingEdge(dut.clk)
#     await Timer(1, "ns")
#     await RisingEdge(dut.clk)
#     dut._log.info("PC: %s", value)
#     dut._log.info("PCWrite: %s", value2)
#     dut._log.info("state: %s", state)
#     dut._log.info("next: %s", next)
