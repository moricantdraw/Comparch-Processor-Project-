import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge, Timer

async def reset_signal(dut):
    """Try accessing the design."""
    dut.rst.value = 0
    await Timer(1, "ns")
    dut.rst.value = 1
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    dut.rst.value = 0

@cocotb.test()
async def test_test(dut):
    clock = Clock(dut.clk, 10, units="ns")
    cocotb.start_soon(clock.start())

    reset_signal(dut)
    await Timer(1, "ns")
    value = dut.rv_multi.DP.nonarchreg_PC.PC.value
    value2 = dut.rv_multi.ControlUnit.PCWrite.value
    state = dut.rv_multi.ControlUnit.MainFSM.state.value
    next = dut.rv_multi.ControlUnit.MainFSM.nextstate.value
    dut._log.info("PC: %s", value)
    dut._log.info("PCWrite: %s", value2)
    dut._log.info("state: %s", state)
    dut._log.info("next: %s", next)
    await RisingEdge(dut.clk)
    await Timer(1, "ns")
    await RisingEdge(dut.clk)
    dut._log.info("PC: %s", value)
    dut._log.info("PCWrite: %s", value2)
    dut._log.info("state: %s", state)
    dut._log.info("next: %s", next)
