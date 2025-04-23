import cocotb
from cocotb.triggers import RisingEdge, Timer
from cocotb.clock import Clock


@cocotb.test()
async def test_full_datapath_cycle(dut):
    """Test full datapath cycle: fetch -> decode -> execute -> memory -> writeback"""

    # Start the clock
    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())

    # Initial reset
    dut.rst.value = 1
    dut.PCWrite.value = 0
    dut.IRWrite.value = 0
    dut.AdrSrc.value = 0
    dut.ResultSrc.value = 0
    dut.ALUControl.value = 0
    dut.ALUSrcA.value = 0
    dut.ALUSrcB.value = 0
    dut.ImmSrc.value = 0
    dut.RegWrite.value = 0
    dut.ReadData.value = 0

    for _ in range(2):
        await RisingEdge(dut.clk)

    dut.rst.value = 0

    # === FETCH ===
    # Provide instruction (addi x1, x0, 0)
    dut.ReadData.value = 0x00000093
    dut.PCWrite.value = 1
    dut.IRWrite.value = 1
    dut.ALUControl.value = 0b0000
    dut.ALUSrcA.value = 0b00  # PC
    dut.ALUSrcB.value = 0b01  # constant 4
    dut.ResultSrc.value = 0b00  # ALUResult to PC

    await RisingEdge(dut.clk)

    # === DECODE ===
    dut.PCWrite.value = 0
    dut.IRWrite.value = 0
    dut.ALUSrcA.value = 0b10  # RD1 (x0 = 0)
    dut.ALUSrcB.value = 0b10  # ImmExt
    dut.ImmSrc.value = 0b000  # I-type

    await RisingEdge(dut.clk)

    # === EXECUTE ===
    dut.ALUControl.value = 0b0000  # ADD

    await RisingEdge(dut.clk)

    # === MEMORY ===
    # ALUOut stores result
    await RisingEdge(dut.clk)

    # === WRITE-BACK ===
    dut.ResultSrc.value = 0b00  # Use ALUOut
    dut.RegWrite.value = 1

    await RisingEdge(dut.clk)

    # Done writing back
    dut.RegWrite.value = 0
    await Timer(1, units="ns")

    assert int(dut.Instr.value) == 0x00000093, "Instruction not loaded correctly"
    assert int(dut.WriteData.value) == 0, "WriteData should still reflect x0 = 0"


# import cocotb
# from cocotb.triggers import RisingEdge, Timer
# from cocotb.clock import Clock


# @cocotb.test()
# async def test_fetch_cycle_with_reset(dut):
#     """Test datapath instruction fetch with reset"""

#     # Start the clock
#     cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())

#     # Apply reset
#     dut.rst.value = 1
#     dut.PCWrite.value = 0
#     dut.IRWrite.value = 0
#     dut.AdrSrc.value = 0
#     dut.ResultSrc.value = 0
#     dut.ALUControl.value = 0b0000
#     dut.ALUSrcA.value = 0b00
#     dut.ALUSrcB.value = 0b01
#     dut.ImmSrc.value = 0
#     dut.RegWrite.value = 0
#     dut.ReadData.value = 0

#     # Wait for a couple of clock cycles under reset
#     for _ in range(2):
#         await RisingEdge(dut.clk)

#     # Release reset
#     dut.rst.value = 0

#     # Set instruction to be fetched (e.g., addi x1, x0, 0)
#     dut.ReadData.value = 0x00000093  # opcode: 0x13 (addi)

#     # Enable PC and instruction register write
#     dut.PCWrite.value = 1
#     dut.IRWrite.value = 1

#     await RisingEdge(dut.clk)
#     await RisingEdge(dut.clk)

#     # Disable writes
#     dut.PCWrite.value = 0
#     dut.IRWrite.value = 0

#     # Let pipeline settle
#     await Timer(1, units="ns")

#     instr = int(dut.Instr.value)
#     pc = int(dut.Adr.value)

#     assert instr == 0x00000093, f"Instruction not loaded correctly: {instr:#010x}"
#     assert pc == 0x0, f"PC should start at 0 after reset, got: {pc:#x}"
