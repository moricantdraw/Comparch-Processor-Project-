import cocotb
from cocotb.triggers import RisingEdge, Timer
from cocotb.clock import Clock
import os

# Expected comments for each PC step
instruction_log = [
    "lui x1, 0xFEDCC",
    "addi x1, x1, 0xA98",
    "slli x2, x1, 0x4",
    "srai x3, x1, 0x4",
    "andi x4, x3, 0xFFF",
    "addi x5, zero, 0x2",
    "add x6, x5, x4",
    "sub x7, x6, x4",
    "sll x8, x4, x5",
    "xori x9, x8, 0x7",
    "auipc x10, 0x12345",
]

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
        for _ in range(5):  # Wait ~5 cycles per instruction (adjust as needed)
            await RisingEdge(dut.clk)

        line = f"After {instruction_log[i]}:\n"
        for reg_idx in range(11):  # Just dump x0 to x10 for your use case
            reg_val = int(dut.rv_multi.DP.rf.registers_debug[reg_idx].value)
            dut._log.info("Register value: 0x%08x", reg_val)
            line += f"x{reg_idx:>2} = 0x{reg_val:08X}\n"
        line += "\n"
        output_lines.append(line)

    # Write to file
    with open("register_dump.txt", "w") as f:
        f.writelines(output_lines)

    dut._log.info("Register dump saved to register_dump.txt")
