import cocotb
from cocotb.triggers import Timer

# The branch opcode
BRANCH_OP = 0b1100011

@cocotb.test()
async def test_bgeu_activation(dut):
    """Test that bgeu signal activates correctly when conditions are met"""
    
    # Initialize inputs - all signals initially 0
    dut.op.value = 0
    dut.funct3.value = 0
    dut.branch.value = 0
    
    # Allow signals to settle
    await Timer(1, units='ns')
    
    # Check that all branch signals are initially 0
    assert dut.beq.value == 0, f"beq should be 0 initially, got {dut.beq.value}"
    assert dut.bne.value == 0, f"bne should be 0 initially, got {dut.bne.value}"
    assert dut.blt.value == 0, f"blt should be 0 initially, got {dut.blt.value}"
    assert dut.bge.value == 0, f"bge should be 0 initially, got {dut.bge.value}"
    assert dut.bltu.value == 0, f"bltu should be 0 initially, got {dut.bltu.value}"
    assert dut.bgeu.value == 0, f"bgeu should be 0 initially, got {dut.bgeu.value}"
    
    dut._log.info("All branch signals initially 0: PASS")
    
    # Now set the specific conditions for bgeu
    dut.op.value = BRANCH_OP      # 7'b1100011 
    dut.funct3.value = 0b111      # 3'b111
    dut.branch.value = 1          # Branch signal enabled
    
    # Allow signals to settle
    await Timer(1, units='ns')
    
    # Check that only bgeu is activated
    assert dut.beq.value == 0, f"beq should remain 0, got {dut.beq.value}"
    assert dut.bne.value == 0, f"bne should remain 0, got {dut.bne.value}"
    assert dut.blt.value == 0, f"blt should remain 0, got {dut.blt.value}"
    assert dut.bge.value == 0, f"bge should remain 0, got {dut.bge.value}"
    assert dut.bltu.value == 0, f"bltu should remain 0, got {dut.bltu.value}"
    assert dut.bgeu.value == 1, f"bgeu should be 1, got {dut.bgeu.value}"
    
    dut._log.info("bgeu activated when op=1100011, funct3=111, branch=1: PASS")
    
    # Verify branch=0 disables the signal
    dut.branch.value = 0
    
    # Allow signals to settle
    await Timer(1, units='ns')
    
    # bgeu should now be 0 again
    assert dut.bgeu.value == 0, f"bgeu should be 0 when branch=0, got {dut.bgeu.value}"
    
    dut._log.info("bgeu deactivated when branch=0: PASS")

@cocotb.test()
async def test_other_branch_conditions(dut):
    """Test a few other branch conditions to verify specificity"""
    # Set up base condition - branch enabled with branch opcode
    dut.op.value = BRANCH_OP
    dut.branch.value = 1
    
    # Test BEQ (funct3 = 000)
    dut.funct3.value = 0b000
    await Timer(1, units='ns')
    assert dut.beq.value == 1, "beq should be 1"
    assert dut.bgeu.value == 0, "bgeu should be 0"
    dut._log.info("beq test: PASS")
    
    # Test BNE (funct3 = 001)
    dut.funct3.value = 0b001
    await Timer(1, units='ns')
    assert dut.bne.value == 1, "bne should be 1"
    assert dut.bgeu.value == 0, "bgeu should be 0"
    dut._log.info("bne test: PASS")
    
    # Test wrong opcode
    dut.op.value = 0b0000011  # LOAD opcode
    dut.funct3.value = 0b111   # BGEU funct3
    await Timer(1, units='ns')
    assert dut.bgeu.value == 0, "bgeu should be 0 with wrong opcode"
    dut._log.info("Wrong opcode test: PASS")
