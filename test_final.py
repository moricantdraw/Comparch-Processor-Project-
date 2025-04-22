import cocotb
from cocotb.triggers import RisingEdge, Timer
from cocotb.clock import Clock

@cocotb.test()
async def test_final(dut):
    # Start clock
    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())
    # Apply reset
    dut.rst.value = 1
    for _ in range(2):  # Reset for 2 cycles to ensure reset logic has time to propagate
        await RisingEdge(dut.clk)
    dut.rst.value = 0

    # One dummy cycle to allow memory to stabilize
    # await RisingEdge(dut.clk)

    # Now start fetching
    for _ in range(10):
        await RisingEdge(dut.clk)
        instr = int(dut.rv_multi.DP.Instr.value)
        pc = int(dut.rv_multi.DP.PC.value)
        cocotb.log.info(f"PC: {pc:08x}, Instr: {instr:08x}")

@cocotb.test()
async def test_first_instruction_fetch(dut):
    """Check that the first instruction is correctly fetched and loaded."""

    # Start clock
    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())

    # Apply reset
    dut.rst.value = 1
    for _ in range(2):  # Reset for 2 cycles to ensure reset logic has time to propagate
        await RisingEdge(dut.clk)
    dut.rst.value = 0

    # Dummy cycle to skip the first bogus fetch cycle
    await RisingEdge(dut.clk)

    # Now perform the actual check after the dummy cycle
    state = dut.rv_multi.ControlUnit.MainFSM.state.value
    next = dut.rv_multi.ControlUnit.MainFSM.nextstate.value
    instr_val = int(dut.rv_multi.DP.Instr.value)
    opcode = dut.rv_multi.opcode.value
    funct3 = dut.rv_multi.funct3.value

    # Print the fetched values for debug purposes
    dut._log.info("state: %s", state)
    dut._log.info("next: %s", next)   
    dut._log.info("instr: 0x%08x", instr_val)
    dut._log.info("opcode: %s", opcode)   
    dut._log.info("funct3: %s", funct3)

    # Let the system run a few cycles to fetch the instruction
    for _ in range(3):
        await RisingEdge(dut.clk)
        # await Timer(1, units="ns")
        state = dut.rv_multi.ControlUnit.MainFSM.state.value
        next = dut.rv_multi.ControlUnit.MainFSM.nextstate.value
        instr_val = int(dut.rv_multi.DP.Instr.value)
        opcode = dut.rv_multi.opcode.value
        funct3 = dut.rv_multi.funct3.value
        dut._log.info("state: %s", state)
        dut._log.info("next: %s", next)
        dut._log.info("instr: 0x%08x", instr_val)   
        dut._log.info("opcode: %s", opcode)  
        dut._log.info("funct3: %s", funct3)

    # Final check for the instruction fetched
    instr_val = int(dut.rv_multi.DP.Instr.value)
    expected_instr = 0xfedcc0b7  # Expected instruction from memory

    assert instr_val == expected_instr, f"Expected Instr to be {expected_instr:#010x}, got {instr_val:#010x}"
    dut._log.info(f"Instruction fetched correctly: {instr_val:#010x}")

@cocotb.test()
async def test_instruction_sequence(dut):
    """Check that two instructions (lui and addi) are correctly fetched and executed, with a bypass for the first fetch cycle."""

    # Start clock
    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())

    # Apply reset
    dut.rst.value = 1
    for _ in range(2):
        await RisingEdge(dut.clk)
    dut.rst.value = 0

    # Dummy cycle to skip the first bogus fetch cycle
    state = dut.rv_multi.ControlUnit.MainFSM.state.value
    next = dut.rv_multi.ControlUnit.MainFSM.nextstate.value
    dut._log.info("state: %s", state)
    dut._log.info("next: %s", next)
    IRWrite = dut.rv_multi.IRWrite.value
    dut._log.info("IRWrite: %s", IRWrite)
    PC = dut.rv_multi.DP.PC.value
    dut._log.info("PC: %s", PC)  
    dut._log.info("Instr raw bits (hex): %s", dut.ReadData.value)
    opcode = dut.rv_multi.opcode.value
    funct3 = dut.rv_multi.funct3.value
    dut._log.info("opcode: %s", opcode)   
    dut._log.info("funct3: %s", funct3)
    dut._log.info("just now dummy cycle to skip first fetch")
    dut._log.info(f"_______")
    await RisingEdge(dut.clk)

    # Now we are sure the first instruction fetch has passed, start fetching the instructions we care about
    # Fetch first instruction (lui x1, 0xFEDCC)
    expected_instr1 = 0xfedcc0b7
    expected_x1_after_lui = 0xFEDCC000

    state = dut.rv_multi.ControlUnit.MainFSM.state.value
    next = dut.rv_multi.ControlUnit.MainFSM.nextstate.value
    dut._log.info("state: %s", state)
    dut._log.info("next: %s", next)
    PC = dut.rv_multi.DP.PC.value
    dut._log.info("PC: %s", PC)  
    instr_val = int(dut.rv_multi.DP.Instr.value)
    IRWrite = dut.rv_multi.IRWrite.value
    dut._log.info("IRWrite: %s", IRWrite)
    opcode = dut.rv_multi.opcode.value
    funct3 = dut.rv_multi.funct3.value
    dut._log.info("Instr raw bits (hex): %s", dut.ReadData.value)
    dut._log.info("instr: 0x%08x", instr_val)
    dut._log.info("opcode: %s", opcode)   
    dut._log.info("funct3: %s", funct3)
    dut._log.info(f"_______")
    
    # let instruction execute
    for _ in range(3):
        await RisingEdge(dut.clk)
        # state = dut.rv_multi.ControlUnit.MainFSM.state.value
        # next = dut.rv_multi.ControlUnit.MainFSM.nextstate.value
        # dut._log.info("state: %s", state)
        # dut._log.info("next: %s", next)
        # IRWrite = dut.rv_multi.IRWrite.value
        # dut._log.info("IRWrite: %s", IRWrite)
        # instr_val = int(dut.rv_multi.DP.Instr.value)
        # dut._log.info("instr: 0x%08x", instr_val)
        # opcode = dut.rv_multi.opcode.value
        # dut._log.info("opcode: %s", opcode) 
        # funct3 = dut.rv_multi.funct3.value
        # dut._log.info("funct3: %s", funct3)
        # PC = dut.rv_multi.DP.PC.value
        # dut._log.info("PC: %s", PC)  

    state = dut.rv_multi.ControlUnit.MainFSM.state.value
    next = dut.rv_multi.ControlUnit.MainFSM.nextstate.value
    IRWrite = dut.rv_multi.IRWrite.value
    dut._log.info("IRWrite: %s", IRWrite)
    instr_val = int(dut.rv_multi.DP.Instr.value)
    dut._log.info("First instruction fetched: 0x%08x", instr_val)
    PC = dut.rv_multi.DP.PC.value
    dut._log.info("PC: %s", PC)  
    opcode = dut.rv_multi.opcode.value
    funct3 = dut.rv_multi.funct3.value
    dut._log.info("Instr raw bits (hex): %s", dut.ReadData.value)
    dut._log.info("instr: 0x%08x", instr_val)
    dut._log.info("opcode: %s", opcode)   
    dut._log.info("funct3: %s", funct3)

    # Check if the first instruction is correct
    assert instr_val == expected_instr1, f"Expected Instr to be {expected_instr1:#010x}, got {instr_val:#010x}"

    # After LUI instruction, check that x1 is set to the correct value
    x1_val = int(dut.rv_multi.DP.rf.registers_debug[1].value)  # Assuming x1 is in register 1
    dut._log.info(f"Value of x1 after LUI: 0x{x1_val:08x}")
    assert x1_val == expected_x1_after_lui, f"Expected x1 to be {expected_x1_after_lui:#010x}, got {x1_val:#010x}"

    # Fetch second instruction (addi x1, x1, 0xA98)
    expected_instr2 = 0xa9808093
    expected_x1_after_addi = 0xFEDCBA98

    dut._log.info(f"_______")
   # let ADDI instruction execute
    for _ in range(4):
        await RisingEdge(dut.clk)
        state = dut.rv_multi.ControlUnit.MainFSM.state.value
        next = dut.rv_multi.ControlUnit.MainFSM.nextstate.value
        dut._log.info("state: %s", state)
        dut._log.info("next: %s", next)
        IRWrite = dut.rv_multi.IRWrite.value
        dut._log.info("IRWrite: %s", IRWrite)
        PC = dut.rv_multi.DP.PC.value
        dut._log.info("PC: %s", PC)  
        x1_val = int(dut.rv_multi.DP.rf.registers_debug[1].value)  # Again assuming x1 is in register 1
        dut._log.info(f"Value of x1 during ADDI: 0x{x1_val:08x}")
        opcode = dut.rv_multi.opcode.value
        funct3 = dut.rv_multi.funct3.value
        dut._log.info("opcode: %s", opcode)   
        dut._log.info("funct3: %s", funct3)
        dut._log.info(f"_______")
    

    instr_val = int(dut.rv_multi.DP.Instr.value)
    dut._log.info("Second instruction fetched: 0x%08x", instr_val)

    # Check if the second instruction is correct
    assert instr_val == expected_instr2, f"Expected Instr to be {expected_instr2:#010x}, got {instr_val:#010x}"

    # After ADDI instruction, check that x1 is updated correctly
    x1_val = int(dut.rv_multi.DP.rf.registers_debug[1].value)  # Again assuming x1 is in register 1
    dut._log.info(f"Value of x1 after ADDI: 0x{x1_val:08x}")
    assert x1_val == expected_x1_after_addi, f"Expected x1 to be {expected_x1_after_addi:#010x}, got {x1_val:#010x}"

    dut._log.info("Both instructions executed correctly.")
