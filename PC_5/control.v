module control (opcode, aluOp, final_opcode, Rwe, Rdst, ALUinB, ALUop, DMwe, Rwd, BR, JP, my_bne, my_blt, my_jal, my_jr, my_setx);
	input [4:0] opcode, aluOp;
    output Rwe, Rdst, ALUinB, ALUop, DMwe, Rwd, BR, JP, my_bne, my_blt, my_jal, my_jr, my_setx;
    output [4:0] final_opcode;

    wire [4:0] opcode;

    // Here we need to know if the operation is add, addi, sw, lw
    wire my_add, my_addi, my_sw, my_lw;
    assign my_add = (~opcode[4])&(~opcode[3])&(~opcode[2])&(~opcode[1])&(~opcode[0]);//00000
    assign my_addi = (~opcode[4])&(~opcode[3])&(opcode[2])&(~opcode[1])&(opcode[0]);//00101
    assign my_sw = (~opcode[4])&(~opcode[3])&(opcode[2])&(opcode[1])&(opcode[0]);//00111
    assign my_lw = (~opcode[4])&(opcode[3])&(~opcode[2])&(~opcode[1])&(~opcode[0]);//01000

    // Here we need to know if the operation is bne, j, jal, jr, blt, bex, setx
    wire my_j;
    assign my_bne = (~opcode[4])&(~opcode[3])&(~opcode[2])&(opcode[1])&(~opcode[0]);//00010
    assign my_j = (~opcode[4])&(~opcode[3])&(~opcode[2])&(~opcode[1])&(opcode[0]);//00001
    assign my_jal = (~opcode[4])&(~opcode[3])&(~opcode[2])&(opcode[1])&(opcode[0]);//00011
    assign my_jr = (~opcode[4])&(~opcode[3])&(opcode[2])&(~opcode[1])&(~opcode[0]);//00100
    assign my_blt = (~opcode[4])&(~opcode[3])&(opcode[2])&(opcode[1])&(~opcode[0]);//00110
    assign my_bex = (opcode[4])&(~opcode[3])&(opcode[2])&(opcode[1])&(~opcode[0]);//10110
    assign my_setx =(opcode[4])&(~opcode[3])&(~opcode[2])&(opcode[1])&(~opcode[0]);//10101

    // Define 8 signal
    or myRwe (Rwe, my_add, my_addi, my_lw, my_jal, my_setx);
    assign Rdst = my_sw;
    or myALUinB (ALUinB, my_addi, my_lw, my_sw);
    assign ALUop = my_bne|my_blt|my_bex; 
    assign DMwe = my_sw;
    assign Rwd = my_lw;
    assign BR = my_bne|my_blt;
    assign JP = my_j|my_jal;

    // Find the final ALU opcode
    // If is R-type (opcode = 00000), then final code is aluOp
    // If is addi (opcode = 00101), then final code is 00000 (add)
    // If ALUop is 1'b1, the aluOp should be 00001(sub)
    assign final_opcode = ALUop ? 5'b00001 : my_addi ? 5'b00000 : my_add ? aluOp : opcode;
endmodule
