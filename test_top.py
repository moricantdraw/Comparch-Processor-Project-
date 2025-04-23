import cocotb
from cocotb.triggers import RisingEdge, Timer
from cocotb.clock import Clock
import os

# Expected comments for each PC step
instruction_log = [
    "lui   x1, 0xABCDE",        # pc = 0x00, x1 = 0xABCDE000
    "auipc x2, 0xFF123",        # pc = 0x04, x2 = 0xFF123004
    "addi  x3, x0, 1000",       # pc = 0x08, x3 = 0x000003E8
    "ori   x4, x3, 0xF0",       # pc = 0x0C, x4 = 0x000003F8
    "slli  x5, x3, 2",          # pc = 0x10, x5 = 0x00000FA0
    "sw    x5, 0(x3)",          # pc = 0x14, Mem[0x3E8] = 0x00000FA0
    "lw    x6, 0(x3)",          # pc = 0x18, x6 = 0x00000FA0
    "add   x7, x5, x6",         # pc = 0x1C, x7 = 0x00001F40
    "beq   x7, x7, SKIP",       # pc = 0x20, branch taken
  # "addi  x8, x0, 123",        # pc = 0x24, skipped
    "SKIP: addi x8, x0, 456",   # pc = 0x28, x8 = 0x000001C8
    "jal   x9, END",            # pc = 0x2C, x9 = 0x00000030
  # "addi  x8, x0, 789",        # pc = 0x30, skipped
    "END:  addi x10, x0, 321",  # pc = 0x34, x10 = 0x00000141
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

    cocotb.log.info("---------------------------------------------------")
    cocotb.log.info(f"PC: {int(pc):08x}, oldPC: {int(oldPC):08x}, Instr: {int(instr):08x}")
    cocotb.log.info("state: %d", int(state))
    cocotb.log.info("next: %d", int(next))
    cocotb.log.info("opcode: %s", opcode)
    cocotb.log.info("---------")
    dut._log.info("readdata: 0x%X", int(readdata))
    cocotb.log.info("memwrite: %s", memwrite)
    cocotb.log.info("writedata: 0x%X", int(writedata))
    dut._log.info("adr: 0x%X", int(adr))

@cocotb.test()
async def check_register_values(dut):
    # Start clock (assuming 10ns period)
    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())

    # Reset
    dut.rst.value = 1
    for _ in range(2):
        await RisingEdge(dut.clk)
    dut.rst.value = 0

    # Wait and dump registers after each instruction
    output_lines = []
    for i in range(len(instruction_log)):
        if instruction_log[i].startswith("lw"):
            for k in range(5):  # Wait 5 cycles for lw
                await RisingEdge(dut.clk)
                await debug_info(dut)
        else:
            for j in range(4):  # Wait 4 cycles for others
                await RisingEdge(dut.clk)
                await debug_info(dut)


        line = f"After {instruction_log[i]}:\n"
        regs = dut.rv_multi.DP.rf.registers_debug
        for reg_idx in range(11):  # Just dump x0 to x10
            reg_val = int(regs[reg_idx].value)
            line += f"x{reg_idx:>2} = 0x{reg_val:08X}\n"
        line += "\n"
        output_lines.append(line)

    # Write to file
    with open("register_dump.txt", "w") as f:
        f.writelines(output_lines)

    dut._log.info("Register dump saved to register_dump.txt")


    def check(reg_idx, expected):
        actual = int(regs[reg_idx].value)
        assert actual == expected, \
            f"Register x{reg_idx} expected {hex(expected)}, got {hex(actual)}"
        
    check(1,  0xABCDE000)
    check(2,  0xFF123004)
    check(3,  0x000003E8)
    check(4,  0x000003F8)
    check(5,  0x00000FA0)
    check(6,  0x00000FA0)
    check(7,  0x00001F40)
    check(8,  0x000001C8)
    check(9,  0x00000030)
    check(10, 0x00000141)

    dut._log.info("ALL REGISTERS CORRECT")
