    lui   x1, 20’hABCDE      # x1 = 0xABCDE000

    # U-type
    auipc x2, 20’hFF123      # x2 = PC+4 + 0xFF123000 
                             #    = 0xFF123004

    # I-type
    addi  x3, x0, 1000       # x3 = 1000
    ori   x4, x3, 8’hF0      # x4 = 0x3E8 | 0xF0 = 0x3F8 = 1016

    # I-type: shift 
    slli  x5, x3, 2          # x5 = 1000 << 2 = 4000

    # S-type store & I-type load
    sw    x5, 0(x3)          # Mem[1000] = 4000
    lw    x6, 0(x3)          # x6 = Mem[1000] = 4000

    # R-type arithmetic       
    add   x7, x5, x6         # x7 = 4000 + 4000 = 8000

    # B-type branch    
    beq   x7, x7, SKIP       # taken, skip the next ADDI
    addi  x8, x0, 123        # (skipped)
SKIP:
    addi  x8, x0, 456        # x8 = 456

    # J-type jump  
    jal   x9, END            # x9 = return-addr = PC+4
    addi  x8, x0, 789        # (skipped)

END:
    addi  x10, x0, 321       # x10 = 321
