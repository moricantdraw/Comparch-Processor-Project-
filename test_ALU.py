import cocotb
from cocotb.triggers import Timer

def signed(val):
    return val - (1 << 32) if val & (1 << 31) else val

@cocotb.test()
async def test_addition(dut):
    """Test ALU addition operation"""
    dut.SrcA.value = 0x00000010
    dut.SrcB.value = 0x00000020
    dut.ALUControl.value = 0b0000

    await Timer(1, units="ns")  # wait for combinational logic to settle

    expected = 0x00000030

    result = int(dut.ALUResult.value)
    zero = int(dut.Zero.value)
    sign = int(dut.Sign.value)
    carry = int(dut.CarryOut.value)
    overflow = int(dut.Overflow.value)

    assert result == expected, f"Addition failed: {result:#x} != {expected:#x}"
    assert zero == 0, "Zero flag should be 0"
    assert sign == 0, "Sign flag should be 0"
    assert carry == 0, "CarryOut should be 0"
    assert overflow == 0, "Overflow should be 0"

@cocotb.test()
async def test_subtraction_overflow(dut):
    """Test ALU subtraction overflow"""
    dut.SrcA.value = 0x80000000
    dut.SrcB.value = 0x00000001
    dut.ALUControl.value = 0b0001

    await Timer(1, units="ns")

    expected = 0x7FFFFFFF
    assert dut.ALUResult.value == expected, f"Subtraction failed: {dut.ALUResult.value} != {expected}"
    assert dut.Overflow.value == 1
    assert dut.Sign.value == 0
    assert dut.Zero.value == 0

@cocotb.test()
async def test_and_operation(dut):
    """Test bitwise AND"""
    dut.SrcA.value = 0b10101010
    dut.SrcB.value = 0b11001100
    dut.ALUControl.value = 0b0010

    await Timer(1, units="ns")

    expected = 0b10001000
    assert dut.ALUResult.value == expected, f"AND failed: {dut.ALUResult.value} != {expected}"
    assert dut.Zero.value == 0

@cocotb.test()
async def test_slt_signed(dut):
    """Test signed less-than (slt)"""
    dut.SrcA.value = 0xFFFFFFFF  # -1
    dut.SrcB.value = 0x00000001
    dut.ALUControl.value = 0b0101

    await Timer(1, units="ns")

    assert dut.ALUResult.value == 1, "SLT signed failed"
    assert dut.Zero.value == 0
    assert dut.Sign.value == 0

@cocotb.test()
async def test_sltu_unsigned(dut):
    """Test unsigned less-than (sltu)"""
    dut.SrcA.value = 0x00000001
    dut.SrcB.value = 0xFFFFFFFF
    dut.ALUControl.value = 0b1000

    await Timer(1, units="ns")

    assert dut.ALUResult.value == 1, "SLTU unsigned failed"

@cocotb.test()
async def test_sra(dut):
    """Test arithmetic right shift"""
    dut.SrcA.value = 0xFFFFFFF0  # -16
    dut.SrcB.value = 0x00000002
    dut.ALUControl.value = 0b0100

    await Timer(1, units="ns")

    expected = signed(-16 >> 2) & 0xFFFFFFFF
    assert dut.ALUResult.value == expected, f"SRA failed: {dut.ALUResult.value} != {expected}"

@cocotb.test()
async def test_zero_flag(dut):
    """Test zero result and flag"""
    dut.SrcA.value = 0x12345678
    dut.SrcB.value = 0x12345678
    dut.ALUControl.value = 0b0001  # subtraction

    await Timer(1, units="ns")

    assert dut.ALUResult.value == 0
    assert dut.Zero.value == 1
    assert dut.Sign.value == 0






