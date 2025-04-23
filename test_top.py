import cocotb
from cocotb.triggers import RisingEdge, Timer
from cocotb.clock import Clock
import os

# Expected comments for each PC step
# instruction_log = [
#     "lui   x1, 0x1",
#     "auipc x2, 0x0",
#     "addi  x3, x0, 5",
#     "andi  x4, x3, 3",
#     "slli  x5, x3, 1",
#     "sw    x5, 0(x0)",
#     "lw    x6, 0(x0)",
#     "add   x7, x3, x6",
#     "beq   x3, x3, +8",
#     "addi  x8, x0, 99",
#     "addi  x8, x0, 2",
#     "jal   x9, +8",
#     "addi  x8, x0, 3",
#     "addi  x10, x0, 7"
# ]

instruction_log = [
    "lui x1, 0xFEDCC         # pc = 0x00, x1 = 0xFEDCC000",
    "addi x1, x1, 0xA98      # pc = 0x04, x1 = 0xFEDCBA98",
    "sw x1, 0(x0)",
    "lw x2, 0(x0)",
]

async def debug_info(dut):
    readdata = dut.ReadData.value
    memwrite = dut.MemWrite.value
    writedata = dut.WriteData.value
    adr = dut.Adr.value
    instr = dut.rv_multi.DP.Instr.value
    pc = dut.rv_multi.DP.PC.value
    oldPC = dut.rv_multi.DP.nonarchreg_Instr.OldPC.value
    state = dut.rv_multi.ControlUnit.MainFSM.state.value
    next = dut.rv_multi.ControlUnit.MainFSM.nextstate.value
    opcode = dut.rv_multi.opcode.value

    dut._log.info("readdata: 0x%X", int(readdata))
    cocotb.log.info(f"PC: {int(pc):08x}, oldPC: {int(oldPC):08x}, Instr: {int(instr):08x}")
    # dut._log.info("memwrite: %s", memwrite)
    # dut._log.info("writedata: 0x%X", int(writedata))
    dut._log.info("adr: 0x%X", int(adr))
    cocotb.log.info("state: %d", int(state))
    cocotb.log.info("next: %d", int(next))
    cocotb.log.info("opcode: %s", opcode)

@cocotb.test()
async def dump_registers_test(dut):
    # Start clock (assuming 10ns period)
    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())

    # Reset
    dut.rst.value = 1
    for _ in range(2):
        await RisingEdge(dut.clk)
    dut.rst.value = 0

    # Dummy cycle to skip the first bogus fetch cycle
    await RisingEdge(dut.clk)

    # Wait and dump registers after each instruction (11 in total)
    output_lines = []
    for i in range(len(instruction_log)):
        if instruction_log[i].startswith(("sw", "lw")):
            for _ in range(5):  # Wait ~5 cycles per instruction (adjust as needed)
                await RisingEdge(dut.clk)
                await debug_info(dut)
        else:
            for _ in range(4):  # Wait ~5 cycles per instruction (adjust as needed)
                await RisingEdge(dut.clk)
                await debug_info(dut)

        line = f"After {instruction_log[i]}:\n"
        for reg_idx in range(11):  # Just dump x0 to x10 for your use case
            reg_val = int(dut.rv_multi.DP.rf.registers_debug[reg_idx].value)
            line += f"x{reg_idx:>2} = 0x{reg_val:08X}\n"
        line += "\n"
        output_lines.append(line)

    # Write to file
    with open("register_dump.txt", "w") as f:
        f.writelines(output_lines)

    dut._log.info("Register dump saved to register_dump.txt")
