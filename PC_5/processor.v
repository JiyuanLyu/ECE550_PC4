/**
 * READ THIS DESCRIPTION!
 *
 * The processor takes in several inputs from a skeleton file.
 *
 * Inputs
 * clock: this is the clock for your processor at 50 MHz
 * reset: we should be able to assert a reset to start your pc from 0 (sync or
 * async is fine)
 *
 * Imem: input data from imem
 * Dmem: input data from dmem
 * Regfile: input data from regfile
 *
 * Outputs
 * Imem: output control signals to interface with imem
 * Dmem: output control signals and data to interface with dmem
 * Regfile: output control signals and data to interface with regfile
 *
 * Notes
 *
 * Ultimately, your processor will be tested by subsituting a master skeleton, imem, dmem, so the
 * testbench can see which controls signal you active when. Therefore, there needs to be a way to
 * "inject" imem, dmem, and regfile interfaces from some external controller module. The skeleton
 * file acts as a small wrapper around your processor for this purpose.
 *
 * You will need to figure out how to instantiate two memory elements, called
 * "syncram," in Quartus: one for imem and one for dmem. Each should take in a
 * 12-bit address and allow for storing a 32-bit value at each address. Each
 * should have a single clock.
 *
 * Each memory element should have a corresponding .mif file that initializes
 * the memory element to certain value on start up. These should be named
 * imem.mif and dmem.mif respectively.
 *
 * Importantly, these .mif files should be placed at the top level, i.e. there
 * should be an imem.mif and a dmem.mif at the same level as process.v. You
 * should figure out how to point your generated imem.v and dmem.v files at
 * these MIF files.
 *
 * imem
 * Inputs:  12-bit address, 1-bit clock enable, and a clock
 * Outputs: 32-bit instruction
 *
 * dmem
 * Inputs:  12-bit address, 1-bit clock, 32-bit data, 1-bit write enable
 * Outputs: 32-bit data at the given address
 *
 */
module processor(
    // Control signals
    clock,                          // I: The master clock
    reset,                          // I: A reset signal

    // Imem
    address_imem,                   // O: The address of the data to get from imem
    q_imem,                         // I: The data from imem

    // Dmem
    address_dmem,                   // O: The address of the data to get or put from/to dmem
    data,                           // O: The data to write to dmem
    wren,                           // O: Write enable for dmem
    q_dmem,                         // I: The data from dmem

    // Regfile
    ctrl_writeEnable,               // O: Write enable for regfile
    ctrl_writeReg,                  // O: Register to write to in regfile
    ctrl_readRegA,                  // O: Register to read from port A of regfile
    ctrl_readRegB,                  // O: Register to read from port B of regfile
    data_writeReg,                  // O: Data to write to for regfile
    data_readRegA,                  // I: Data from port A of regfile
    data_readRegB                   // I: Data from port B of regfile
);
    // Control signals
    input clock, reset;

    // Imem
    output [11:0] address_imem;
    input [31:0] q_imem;

    // Dmem
    output [11:0] address_dmem;
    output [31:0] data;
    output wren;
    input [31:0] q_dmem;

    // Regfile
    output ctrl_writeEnable;
    output [4:0] ctrl_writeReg, ctrl_readRegA, ctrl_readRegB;
    output [31:0] data_writeReg;
    input [31:0] data_readRegA, data_readRegB;

    /* YOUR CODE STARTS HERE */


    // STEP: Decode
    wire Rwe, Rdst, ALUinB, ALUop, DMwe, Rwd, BR, JP;
    // R-type
    wire [4:0] opcode, rd, rs, rt, shamt, aluOp, final_opcode;
    // I-type
    wire [16:0] immediateN;
    // JI-type
    wire [31:0] T;

    assign opcode = q_imem[31:27];
    assign aluOp = q_imem[6:2];
    control my_ctrl (opcode, aluOp, final_opcode, Rwe, Rdst, ALUinB, ALUop, DMwe, Rwd, BR, JP);
    assign my_jr = (~opcode[4])&(~opcode[3])&(opcode[2])&(~opcode[1])&(~opcode[0]);//00100
    

    assign rd = q_imem[26:22];
    assign rs = q_imem[21:17];
    assign rt = q_imem[16:12];
    assign shamt = q_imem[11:7];
    assign immediateN = q_imem[16:0];
    assign ctrl_writeEnable = Rwe;
    assign T[26:0] = q_imem[26:0];
    assign T[31:27] = 5'b00000;

    // bex
    wire BEX, my_bex, my_bex_neq, my_final_bex;
    assign my_bex = (opcode[4])&(~opcode[3])&(opcode[2])&(opcode[1])&(~opcode[0]);//10110
    assign r30 = data_readRegA;
    assign my_bex_neq = r30[31]|r30[30]|r30[29]|r30[28]|r30[27]|r30[26]|r30[25]|r30[24]|r30[23]|r30[22]|r30[21]|r30[20]|r30[19]|r30[18]|r30[17]|r30[16]|r30[15]|r30[14]|r30[13]|r30[12]|r30[11]|r30[10]|r30[9]|r30[8]|r30[7]|r30[6]|r30[5]|r30[4]|r30[3]|r30[2]|r30[1]|r30[0];
    and my_bex_and (my_final_bex, my_bex, my_bex_neq);
    assign final_JP = my_final_bex ? 1'b1 : JP;

    // link s1 s2 and d for regfile
    assign ctrl_readRegA = my_jr ? rd : my_bex ? 5'b11110 : rs;
    assign ctrl_readRegB = Rdst ? rd : rt;
    // assign ctrl_writeReg = rd;

    // STEP: Execute
    // link to the ALU
    wire isNotEqual, isLessThan, overflow;
    wire [31:0] aluB, alu_result, immeB;
    sx my_sx (immeB, immediateN);
    assign aluB = ALUinB ? immeB : data_readRegB;
    alu my_alu (data_readRegA, aluB, final_opcode, shamt, alu_result, isNotEqual, isLessThan, overflow);
    
    // bne
    wire br_sel, bne_sel, blt_sel;
    and my_bne_and (bne_sel, BR, isNotEqual);
    // blt
    and my_blt_and (blt_sel, BR, isLessThan);
    assign br_sel = bne_sel|blt_sel;

    // overflow
	wire rstatus_of_signal;
    wire [31:0] rstatus_of;
    wire isAddi, isR, isAdd, isSub, myAdd, mySub;
    assign isAddi = (~opcode[4])&(~opcode[3])&(opcode[2])&(~opcode[1])&(opcode[0]);//00101
    assign isR = (~opcode[4])&(~opcode[3])&(~opcode[2])&(~opcode[1])&(~opcode[0]);//00000
    assign isAdd = (~aluOp[4])&(~aluOp[3])&(~aluOp[2])&(~aluOp[1])&(~aluOp[0]);//00000
    assign isSub = (~aluOp[4])&(~aluOp[3])&(~aluOp[2])&(~aluOp[1])&(aluOp[0]);//00001
    assign my_setx =(opcode[4])&(~opcode[3])&(~opcode[2])&(opcode[1])&(~opcode[0]);//10101
    assign my_jal = (~opcode[4])&(~opcode[3])&(~opcode[2])&(opcode[1])&(opcode[0]);//00011
    and myIsAdd (myAdd, isR, isAdd);
    and myIsSub (mySub, isR, isSub);
	assign rstatus_of_signal = (~overflow) ? 1'b0 : (isAddi|myAdd|mySub) ? 1'b1 : 1'b0;
    assign rstatus_of = my_setx ? T : isAddi ? 32'd2 : myAdd ? 32'd1 : mySub ? 32'd3 : 32'b0;
	assign ctrl_writeReg = my_jal ? 5'b11111 : my_setx ? 5'b11110 : rstatus_of_signal ? 5'b11110 : rd;

    // STEP: Memory
    assign address_dmem = alu_result[11:0];
    assign data = data_readRegB;
    assign wren = DMwe;

    // STEP: Fetch
    wire [31:0] pc_next, pc_current, pc_addN, pc_final;
    wire pc_isNotEqual1, pc_isLessThan1, pc_overflow1, pc_isNotEqualN, pc_isLessThanN, pc_overflowN;
    
    alu pc_add1 (pc_current, 32'd1, 5'b00000, 5'b00000, pc_next, pc_isNotEqual1, pc_isLessThan1, pc_overflow1);
    alu my_pc_addN (pc_next, immeB, 5'b00000, 5'b00000, pc_addN, pc_isNotEqualN, pc_isLessThanN, pc_overflowN);
	
    // j & jr & jal
    assign pc_final = my_jal ? T : my_jr ? data_readRegA : final_JP ? T : br_sel ? pc_addN : pc_next;
    assign address_imem = pc_current[11:0];

    pc_regsiter my_pc (clock, reset, 1'b1, pc_final, pc_current);

    // STEP: Write
    assign data_writeReg = my_jal ? pc_next : rstatus_of_signal ? rstatus_of : Rwd ? q_dmem : alu_result;

endmodule
