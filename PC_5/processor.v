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

    // STEP: Fetch
    wire [31:0] pc_next, pc_current;
    wire pc_isNotEqual, pc_isLessThan, pc_overflow;
    pc_regsiter my_pc (clock, reset, 1'b1, pc_next, pc_current);
    alu pc_add1 (pc_current, 32'd1, 5'b00000, 5'b00000, pc_next, pc_isNotEqual, pc_isLessThan, pc_overflow);
    assign address_imem = pc_current[11:0];

    // STEP: Decode
    wire Rwe, Rdst, ALUinB, DMwe, Rwd;
    // R-type
    wire [4:0] opcode, rd, rs, rt, shamt, aluOp, final_opcode;
    // I-type
    wire [16:0] immediateN;

    assign opcode = q_imem[31:27];
    assign aluOp = q_imem[6:2];
    control my_ctrl (opcode, aluOp, final_opcode, Rwe, Rdst, ALUinB, ALUop, DMwe, Rwd);

    assign rd = q_imem[26:22];
    assign rs = q_imem[21:17];
    assign rt = q_imem[16:12];
    assign shamt = q_imem[11:7];
    assign immediateN = q_imem[16:0];
    assign ctrl_writeEnable = Rwe;

    // link s1 s2 and d for regfile
    assign ctrl_readRegA = rs;
    assign ctrl_readRegB = Rdst ? rd : rt;
    // assign ctrl_writeReg = rd;

    // STEP: Execute
    // link to the ALU
    wire isNotEqual, isLessThan, overflow;
    wire [31:0] aluB, alu_result, immeB;
    sx my_sx (immeB, immediateN);
    assign aluB = ALUinB ? immeB : data_readRegB;
    alu my_alu (data_readRegA, aluB, final_opcode, shamt, alu_result, isNotEqual, isLessThan, overflow);

    // overflow
	wire rstatus_of_signal;
    wire [31:0] rstatus_of;
    wire isAddi, isR, isAdd, isSub, myAdd, mySub;
    assign isAddi = (~opcode[4])&(~opcode[3])&(opcode[2])&(~opcode[1])&(opcode[0]);//00101
    assign isR = (~opcode[4])&(~opcode[3])&(~opcode[2])&(~opcode[1])&(~opcode[0]);//00000
    assign isAdd = (~aluOp[4])&(~aluOp[3])&(~aluOp[2])&(~aluOp[1])&(~aluOp[0]);//00000
    assign isSub = (~aluOp[4])&(~aluOp[3])&(~aluOp[2])&(~aluOp[1])&(aluOp[0]);//00001
    and myIsAdd (myAdd, isR, isAdd);
    and myIsSub (mySub, isR, isSub);
	assign rstatus_of_signal = (~overflow) ? 1'b0 : (isAddi|myAdd|mySub) ? 1'b1 : 1'b0;
    assign rstatus_of = isAddi ? 32'd2 : myAdd ? 32'd1 : mySub ? 32'd3 : 32'b0;
	assign ctrl_writeReg = rstatus_of_signal ? 5'b11110 : rd;

    // STEP: Memory
    assign address_dmem = alu_result[11:0];
    assign data = data_readRegB;
    assign wren = DMwe;

    // STEP: Write
    assign data_writeReg = rstatus_of_signal ? rstatus_of : Rwd ? q_dmem : alu_result;
endmodule
